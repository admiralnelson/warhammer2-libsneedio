local sneedio = sneedio;
local core = core;
local get_bm = get_bm;

local BM = get_bm;
local ForEach = sneedio.ForEach;

-- give em delay so our client/modder script can add voices
if BM ~= nil then sneedio.TM.OnceCallback(
    function ()
        sneedio._SneedioBattleMain();

        if(not sneedio.GetCurrentConfig().NoticeNoMusicFoundOrIncompleteMusicForFactionBattle) then return; end
        local availableSituations = {"Deployment", "Balanced", "FirstEngagement", "Losing", "Winning"};
        local unavailableSituations = {};
        ForEach(availableSituations, function (situation)
            local playlist = sneedio.GetPlayerFactionPlaylistForBattle(situation);
            if(playlist == nil or playlist == {})then
                table.insert(unavailableSituations, situation);
            end
        end);
        if(#unavailableSituations > 0)then
            local message = "Sneedio\n\n No battle playlist found for this faction: "..sneedio.GetPlayerFaction()..
                            ".\n\nPlease check your user-sneedio.json or contact mod author for custom faction.\n"..
                            "You may turn on the default in game music in the option menu.\n\n"..
                            "This message can be disabled in user-sneedio.json or via MCT control panel.";
            if(#unavailableSituations == #availableSituations)then
                message = message.."\n\nNo battle playlist found for any situation.";
            else
                message = message.."\n\nNo battle playlist found for the following situations: "..table.concat(unavailableSituations, ", ");
            end
            sneedio.MessageBox("sneediowarn", message);
        end

    end, sneedio.SYSTEM_TICK * 5, "battle once");
end
