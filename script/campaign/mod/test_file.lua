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
},
------
{
    FileName = "https://www.youtube.com/watch?v=UNPUNQUrYkw",
    MaxDuration = mmss("4:51")
},
{
    FileName = "https://www.youtube.com/watch?v=gRT_vCS7NGU",
    MaxDuration = mmss("2:51")
},
{
    FileName = "https://www.youtube.com/watch?v=kvtvva8jJw4",
    MaxDuration = mmss("4:17")
},
{
    FileName = "https://www.youtube.com/watch?v=MUJgeDHl3Yw",
    MaxDuration = mmss("1:18")
},
{
    FileName = "https://www.youtube.com/watch?v=f_We8aXKFKE",
    MaxDuration = mmss("3:10")
},
{
    FileName = "https://www.youtube.com/watch?v=7p8VLT3craE",
    MaxDuration = mmss("2:00")
},
{
    FileName = "https://www.youtube.com/watch?v=Lbq9x__K18M",
    MaxDuration = mmss("2:59")
},
{
    FileName = "https://www.youtube.com/watch?v=Uqv0pjkX-oo",
    MaxDuration = mmss("3:51")
},
{
    FileName = "https://www.youtube.com/watch?v=tn_lFSQ9GdM",
    MaxDuration = mmss("3:27")
},
{
    FileName = "https://www.youtube.com/watch?v=9WlLKjy9K58",
    MaxDuration = mmss("2:28")
},
{
    FileName = "https://www.youtube.com/watch?v=PU3hy6PtOYY",
    MaxDuration = mmss("3:52")
},
{
    FileName = "https://www.youtube.com/watch?v=j7ix2XJTbn0",
    MaxDuration = mmss("2:28")
},
{
    FileName = "https://www.youtube.com/watch?v=U25Xg_xlhtM",
    MaxDuration = mmss("3:25")
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
},
{
    FileName = "https://www.youtube.com/watch?v=BaiFF1mGzT8",
    MaxDuration = mmss("6:09")
});
-- ...and let sneedio do the rest.
