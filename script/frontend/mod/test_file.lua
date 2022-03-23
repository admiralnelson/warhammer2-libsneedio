-- test_file.lua
-- DO NOT PUT SYMBOLS LIKE ! @ # or number at this script filename
-- EXAMPLE to load music from youtube links.

-- alias to MinutesSecondsToSeconds, converts mm:ss to seconds
local mmss = sneedio.MinutesSecondsToSeconds;

-- knights of honor ost
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
-- queue the urls
sneedio.DownloadYoutubeUrls(urls);

-- mixes for battle music
local urls2 = {
    "https://www.youtube.com/watch?v=hLnXaZsBjv8", -- Medieval 2 : Total War Soundtrack - Crusaders
    "https://www.youtube.com/watch?v=QJuz7_ngu_w", -- Medieval 2 : Total War Soundtrack - Nothing Left

    "https://www.youtube.com/watch?v=347qmxgydkE", -- Empire Earth Main Theme
}

-- queue again
sneedio.DownloadYoutubeUrls(urls2);

-- replace menu music, will override player's music
sneedio.ReplaceMenuMusic(
{
    FileName = "https://www.youtube.com/watch?v=347qmxgydkE",
    MaxDuration = mmss("3:36")
});

-- add new music to Bretonnia faction during campaign
sneedio.AddMusicCampaign("wh_main_brt_bretonnia",
{
    FileName = "https://www.youtube.com/watch?v=gKghZxlbTLo",
    MaxDuration = mmss("1:52")
},
{
    FileName = "https://www.youtube.com/watch?v=Icq86BRW4WE",
    MaxDuration = mmss("3:12")
},
{
    FileName = "https://www.youtube.com/watch?v=82rfU4Wo4hQ",
    MaxDuration = mmss("3:00")
},
{
    FileName = "https://www.youtube.com/watch?v=EgyGAeIL6oI",
    MaxDuration = mmss("2:50")
},
{
    FileName = "https://www.youtube.com/watch?v=j5A3lWkUTd8",
    MaxDuration = mmss("3:25")
},
{
    FileName = "https://www.youtube.com/watch?v=0fUtRmz03D8",
    MaxDuration = mmss("2:09")
},
{
    FileName = "https://www.youtube.com/watch?v=aYM36JhkG4w",
    MaxDuration = mmss("2:27")
},
{
    FileName = "https://www.youtube.com/watch?v=aFLU69oiQOc",
    MaxDuration = mmss("2:57")
});

-- add new music to Morgiana faction during campaign
sneedio.AddMusicCampaign("wh_main_brt_carcassonne",
{
    FileName = "https://www.youtube.com/watch?v=gKghZxlbTLo",
    MaxDuration = mmss("1:52")
},
{
    FileName = "https://www.youtube.com/watch?v=Icq86BRW4WE",
    MaxDuration = mmss("3:12")
},
{
    FileName = "https://www.youtube.com/watch?v=82rfU4Wo4hQ",
    MaxDuration = mmss("3:00")
},
{
    FileName = "https://www.youtube.com/watch?v=EgyGAeIL6oI",
    MaxDuration = mmss("2:50")
},
{
    FileName = "https://www.youtube.com/watch?v=j5A3lWkUTd8",
    MaxDuration = mmss("3:25")
},
{
    FileName = "https://www.youtube.com/watch?v=0fUtRmz03D8",
    MaxDuration = mmss("2:09")
},
{
    FileName = "https://www.youtube.com/watch?v=aYM36JhkG4w",
    MaxDuration = mmss("2:27")
},
{
    FileName = "https://www.youtube.com/watch?v=aFLU69oiQOc",
    MaxDuration = mmss("2:57")
});

-- ...and let the sneedio do the rest.