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
    "https://www.youtube.com/watch?v=aFLU69oiQOc",

    "https://www.youtube.com/watch?v=JlxuUG1EtDs",
    "https://www.youtube.com/watch?v=napwDHgukdg",
    "https://www.youtube.com/watch?v=Z3-rYbhWmpw",
    "https://www.youtube.com/watch?v=Upx-mbiT8QQ",
    "https://www.youtube.com/watch?v=0_Y3i2ct-ls",
    "https://www.youtube.com/watch?v=yRAn8_VGM28",
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

-- ...and let sneedio do the rest.