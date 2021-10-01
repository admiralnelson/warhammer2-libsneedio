local sneedio = require("sneedio");
local core = core;
local get_bm = get_bm;

local CM = cm;
local BM = nil;
if core:is_battle() then
    BM = get_bm();
end

-- give em delay so our client/modder script can add voices
if BM ~= nil then sneedio.TM.OnceCallback(function () sneedio._SneedioBattleMain(); end, sneedio.SYSTEM_TICK * 5, "battle once"); end
if CM ~= nil then sneedio.TM.OnceCallback(function () sneedio._SneedioCampaignMain(); end, sneedio.SYSTEM_TICK * 5, "campaign once"); end
if CM == nil and BM == nil then sneedio._SneedioFrontEndMain(); end


return _G.sneedio;