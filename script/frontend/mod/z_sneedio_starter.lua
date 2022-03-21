local sneedio = sneedio;
local print = print2 or out;
local core = core;

sneedio.TM.OnceCallback(
function ()
    sneedio._SneedioFrontEndMain();
    sneedio.MessageBox("test", "yt-dlp test", function ()
        print("test");
        sneedio.DownloadYoutubeUrls({"https://youtu.be/hGrtN02XTI0", "https://www.youtube.com/watch?v=_hb0L2t3P3Y"});
    end);
end, sneedio.SYSTEM_TICK * 5, "main menu once");
print("=============OK===========\n");