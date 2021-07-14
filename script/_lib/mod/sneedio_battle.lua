require("sneedio");
local var_dump = require("var_dump");
local inspect = require("inspect");
local BM;
if core:is_battle() then
    BM = get_bm();
else 

end

local SneedioBattleMain = function()
    out("battle has sneeded!");

    local ForEachUnitsPlayer =  function (FunctionToProcess)
        local PlayerAlliance = BM:get_player_alliance();
        local Armies = PlayerAlliance:armies();
    
        for i = 1, Armies:count() do
            local CurrentArmy = Armies:item(i);
            local units = CurrentArmy:units();
            for j = 1, units:count() do
                local CurrentUnit = units:item(j);
                if CurrentUnit then
                    FunctionToProcess(CurrentUnit, CurrentArmy);
                end;
            end;
        end;
    end;

    ForEachUnitsPlayer(function(CurrentUnit, CurrentArmy)
        sneedio._RegisterVoiceOnBattle(CurrentUnit:type(), CurrentUnit:name());
    end);

    -- register the callback when unit is selected
    ForEachUnitsPlayer(function(CurrentUnit, CurrentArmy)
        BM:register_unit_selection_callback(CurrentUnit, function(context)
                out("Selected unit: ");
				out(context:name());
				out(context:type());
                sneedio._PlayVoiceBattle(sneedio._UnitTypeToInstanced(context:type(), context:name()));
            end);
    end);

end

if BM ~= nil then SneedioBattleMain(); end
