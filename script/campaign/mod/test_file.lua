-- test_file.lua
-- DO NOT PUT SYMBOLS LIKE ! @ # or number at this script filename
-- EXAMPLE to load music from youtube links.

-- alias to MinutesSecondsToSeconds, converts mm:ss to seconds
local mmss = sneedio.MinutesSecondsToSeconds;

-- add new music to Bretonnia faction during campaign
-- make sure these links already registered and downloaded during frontend
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
    FileName = "https://www.youtube.com/watch?v=EgyGAeIL6oI", --ok
    MaxDuration = mmss("2:50")
},
{
    FileName = "https://www.youtube.com/watch?v=j5A3lWkUTd8",
    MaxDuration = mmss("3:25")
},
{
    FileName = "https://www.youtube.com/watch?v=0fUtRmz03D8",
    MaxDuration = mmss("2:06")
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
    MaxDuration = mmss("2:06")
},
{
    FileName = "https://www.youtube.com/watch?v=aYM36JhkG4w",
    MaxDuration = mmss("2:27")
},
{
    FileName = "https://www.youtube.com/watch?v=aFLU69oiQOc",
    MaxDuration = mmss("2:57")
});
-- ...and let sneedio do the rest.
