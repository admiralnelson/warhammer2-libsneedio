-- test_file.lua
-- DO NOT PUT SYMBOLS LIKE ! @ # or number at this script filename
-- EXAMPLE to load music from youtube links.

-- alias to MinutesSecondsToSeconds, converts mm:ss to seconds
local mmss = sneedio.MinutesSecondsToSeconds;

-- add new music to Bretonnia and empire custom battle faction during battle
-- make sure these links already registered and downloaded during frontend

-- It's recommended that you apply playlist to all situations
-- there are 6 situations defined in sneedio modules:
-- * Deployment - when you deploy a unit
-- * FirstEngagement - when you engage against enemy unit after deployment
-- * Balanced - when you engage against enemy unit after first engagement and current battle is balanced
-- * Losing - when you are losing the battle
-- * Winning - when you are winning the battle
-- * LastStand - absolute losing.
-- The situation states looks like this: Deployment -> FirstEngagement -> Balanced -> Losing | Winning | LastStand
-- You should at least put 2 music in each situation for the best result.

sneedio.AddMusicBattle("wh_main_brt_bretonnia", "Deployment",
{
    FileName = "https://www.youtube.com/watch?v=Upx-mbiT8QQ",
    MaxDuration = mmss("2:12")
},
{
    FileName = "https://www.youtube.com/watch?v=0_Y3i2ct-ls",
    MaxDuration = mmss("1:00")
});

sneedio.AddMusicBattle("wh_main_brt_bretonnia", "FirstEngagement",
{
    FileName = "https://www.youtube.com/watch?v=0_Y3i2ct-ls",
    MaxDuration = mmss("3:28"),
    StartPos = mmss("1:45")
},
{
    FileName = "https://www.youtube.com/watch?v=EowWuNkj638",
    MaxDuration = mmss("3:17")
},
{
    FileName = "https://www.youtube.com/watch?v=JlxuUG1EtDs",
    MaxDuration = mmss("3:13")
});

sneedio.AddMusicBattle("wh_main_brt_bretonnia", "Balanced",
{
    FileName = "https://www.youtube.com/watch?v=yRAn8_VGM28",
    MaxDuration = mmss("7:32"),
},
{
    FileName = "https://www.youtube.com/watch?v=QTRYte36nx8",
    MaxDuration = mmss("2:00")
},
{
    FileName = "https://www.youtube.com/watch?v=n6u4EsjBlb8",
    MaxDuration = mmss("4:42")
},
{
    FileName = "https://www.youtube.com/watch?v=URmrY_5g8II",
    MaxDuration = mmss("2:28")
},
{
    FileName = "https://www.youtube.com/watch?v=ogxCLi4CG9U",
    MaxDuration = mmss("4:16")
},
{
    FileName = "https://www.youtube.com/watch?v=napwDHgukdg",
    MaxDuration = mmss("5:22")
},
{
    FileName = "https://www.youtube.com/watch?v=Z3-rYbhWmpw",
    MaxDuration = mmss("9:59")
});

sneedio.AddMusicBattle("wh_main_brt_bretonnia", "Winning",
{
    FileName = "https://www.youtube.com/watch?v=3MHZCYVqIPw",
    MaxDuration = mmss("2:47")
});


sneedio.AddMusicBattle("wh_main_brt_bretonnia", "Losing",
{
    FileName = "https://www.youtube.com/watch?v=kUwHsJNkQ3E",
    MaxDuration = mmss("2:24")
});


-- for empire custom battle

sneedio.AddMusicBattle("wh_main_emp_empire_mp_custom_battles_only", "Deployment",
{
    FileName = "https://www.youtube.com/watch?v=Upx-mbiT8QQ",
    MaxDuration = mmss("2:12")
},
{
    FileName = "https://www.youtube.com/watch?v=0_Y3i2ct-ls",
    MaxDuration = mmss("1:00")
});

sneedio.AddMusicBattle("wh_main_emp_empire_mp_custom_battles_only", "FirstEngagement",
{
    FileName = "https://www.youtube.com/watch?v=0_Y3i2ct-ls",
    MaxDuration = mmss("3:28"),
    StartPos = mmss("1:45")
},
{
    FileName = "https://www.youtube.com/watch?v=EowWuNkj638",
    MaxDuration = mmss("3:17")
},
{
    FileName = "https://www.youtube.com/watch?v=JlxuUG1EtDs",
    MaxDuration = mmss("3:13")
});

sneedio.AddMusicBattle("wh_main_emp_empire_mp_custom_battles_only", "Balanced",
{
    FileName = "https://www.youtube.com/watch?v=yRAn8_VGM28",
    MaxDuration = mmss("7:32"),
},
{
    FileName = "https://www.youtube.com/watch?v=QTRYte36nx8",
    MaxDuration = mmss("2:00")
},
{
    FileName = "https://www.youtube.com/watch?v=n6u4EsjBlb8",
    MaxDuration = mmss("4:42")
},
{
    FileName = "https://www.youtube.com/watch?v=URmrY_5g8II",
    MaxDuration = mmss("2:28")
},
{
    FileName = "https://www.youtube.com/watch?v=ogxCLi4CG9U",
    MaxDuration = mmss("4:16")
},
{
    FileName = "https://www.youtube.com/watch?v=napwDHgukdg",
    MaxDuration = mmss("5:22")
},
{
    FileName = "https://www.youtube.com/watch?v=Z3-rYbhWmpw",
    MaxDuration = mmss("9:59")
});

sneedio.AddMusicBattle("wh_main_emp_empire_mp_custom_battles_only", "Winning",
{
    FileName = "https://www.youtube.com/watch?v=3MHZCYVqIPw",
    MaxDuration = mmss("2:47")
});


sneedio.AddMusicBattle("wh_main_emp_empire_mp_custom_battles_only", "Losing",
{
    FileName = "https://www.youtube.com/watch?v=kUwHsJNkQ3E",
    MaxDuration = mmss("2:24")
});



-- ...and let sneedio do the rest.