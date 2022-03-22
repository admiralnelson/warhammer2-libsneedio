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
        "https://www.youtube.com/watch?v=SJlRgrF-9H0",
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
        print("IsValidYoutubeUrl: ".. url .. tostring(sneedio.IsValidYoutubeUrl(url)));
    end);
    sneedio.MessageBox("fdfdsd", "yt-dlp test", function ()
        sneedio.DownloadYoutubeUrls(urls);
        sneedio._StartDownloadingYoutube();
    end);

end, sneedio.SYSTEM_TICK * 5, "main menu once");
print("=============OK===========\n");