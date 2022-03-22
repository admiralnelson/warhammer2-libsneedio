require("libsneedio_trycatch");
local var_dump = require("var_dump");
local sneedio = sneedio;
local print = print2 or out;
local core = core;
local ForEach = sneedio.ForEach;

sneedio.TM.OnceCallback(
function ()
    sneedio._SneedioFrontEndMain();
    local urls = {
        "https://www.youtube.com/watch?v=gKghZxlbTLo",
        "https://www.youtube.com/watch?v=QTRYte36nx8",
        "https://www.youtube.com/watch?v=kUwHsJNkQ3E",
        "https://youtu.be/SJlRgrF-9H0", -- error test
        "https://www.youtube.com/watch?v=n6u4EsjBlb8",
        "https://www.youtube.com/watch?v=URmrY_5g8II",
        "https://www.youtube.com/watch?v=Icq86BRW4WE",
        "https://www.youtube.com/watch?v=ogxCLi4CG9U",
        "https://www.youtube.com/watch?v=82rfU4Wo4hQ",
        "https://www.youtube.com/watch?v=EgyGAeIL6oI",
        "https://www.youtube.com/watch?v=3MHZCYVqIPw",
        "https://www.youtube.com/watch?v=j5A3lWkUTd8",
        "https://www.youtube.com/watch?v=0fUtRmz03D8",
        "https://www.youtube.com/watch?v=nRjNcbDuxrs",
        "https://www.youtube.com/watch?v=EowWuNkj638",
        "https://www.youtube.com/watch?v=aYM36JhkG4w",
        "https://www.youtube.com/watch?v=aFLU69oiQOc"
    };
    ForEach(urls, function (url)
        print("url: " .. url .. " is valid? " .. tostring(sneedio.IsValidYoutubeUrl(url)));
    end);
    local msgbox = sneedio.MessageBox("test", "yt-dlp test", function ()
        print("preparing");
        sneedio.TM.OnceCallback(function ()
            sneedio.DownloadYoutubeUrls(urls);
            local progressBox = nil;
            progressBox = sneedio.MessageBox("ytdlp", "Sneedio\n\nPlease stand by...", nil, nil, true);
            sneedio.TM.RepeatCallback(function ()
                try{
                    function ()
                        local dy_text = find_uicomponent(progressBox, "DY_text");
                        local title, url, details = sneedio._YtDlpDownloadProgressTracker();
                        var_dump(title);
                        var_dump(url);
                        var_dump(details);
                        if(title) then
                            if(title ~= "") then
                                local textToDisplay = "Sneedio\n\nProcessing file "..tostring(details.FileNo).." out of "..tostring(details.FileNoOutOf).."\n";
                                if(details.Status == 0) then textToDisplay = textToDisplay.."Preparing "; end
                                if(details.Status == 1) then textToDisplay = textToDisplay.."Downloading "; end
                                if(details.Status == 2) then textToDisplay = textToDisplay.."Converting "; end
                                textToDisplay = textToDisplay ..  " " .. title .. "\n";
                                if(details.Status == 1) then textToDisplay = textToDisplay.." ("..tostring(details.Percentage).."%)\n"; end
                                if(details.Status == 1) then textToDisplay = textToDisplay.." Speed "..tostring(details.CurrentSpeedInKBpS).." KB/s ".." Size "..tostring(details.SizeInKB).." KB\n"; end
                                textToDisplay = textToDisplay.."https://youtu.be/"..url;
                                dy_text:SetStateText(textToDisplay, "whatever");
                            end
                        else
                            sneedio.TM.OnceCallback(function ()
                                progressBox:Destroy();
                                local status = sneedio._YtDlpDownloadCompleteStatusTracker();
                                var_dump(status);
                                if(status.DownloadStatus == 1) then
                                    sneedio.MessageBox("ytdlp error", "Sneedio\n\nDownload failed.\n\n"..status.ErrorMessage);
                                end
                                sneedio.TM.RemoveCallback("download poll test");
                            end, sneedio.SYSTEM_TICK * 10, "ytdlp_destroy");
                        end
                    end,
                    catch{
                        function (err)
                            print("Error: "..err);
                            print(debug.traceback());
                        end
                    }
                };
            end, sneedio.SYSTEM_TICK * 10 * 3, "download poll test");
        end, sneedio.SYSTEM_TICK, "ytdlp once");
    end);
    var_dump(msgbox);
end, sneedio.SYSTEM_TICK * 5, "main menu once");
print("=============OK===========\n");