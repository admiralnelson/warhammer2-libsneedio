local sneedio = sneedio or require("sneedio");
local core = core;
local get_bm = get_bm;


-- give em delay so our client/modder script can add voices
if BM ~= nil then sneedio.TM.OnceCallback(function () sneedio._SneedioBattleMain(); end, sneedio.SYSTEM_TICK * 5, "battle once"); end
