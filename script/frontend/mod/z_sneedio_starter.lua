local sneedio = sneedio;
local print = print2 or out;
local core = core;

sneedio.TM.OnceCallback(
function ()
    sneedio._SneedioFrontEndMain();
    sneedio.MessageBox("test", "yt-dlp test", function ()
        print("test");
        sneedio.DownloadYoutubeUrls({"https://youtu.be/EDKwCvD56kw", "https://youtu.be/6gluNoLVKiQ"});
    end);
end, sneedio.SYSTEM_TICK * 5, "main menu once");
print("=============OK===========\n");