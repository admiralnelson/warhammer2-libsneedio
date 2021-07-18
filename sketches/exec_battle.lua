
local MOCK_UP = false;
local PATH = "/script/bin/";
local OUTPUTPATH = "";

local base64 = require("lua/base64");

local function string(o)
    return '"' .. tostring(o) .. '"'
end

local function recurse(o, indent)
    if indent == nil then indent = '' end
    local indent2 = indent .. '  '
    if type(o) == 'table' then
        local s = indent .. '{' .. '\n'
        local first = true
        for k,v in pairs(o) do
            if first == false then s = s .. ', \n' end
            if type(k) ~= 'number' then k = string(k) end
            s = s .. indent2 .. '[' .. k .. '] = ' .. recurse(v, indent2)
            first = false
        end
        return s .. '\n' .. indent .. '}'
    else
        return string(o)
    end
end

local function var_dump(...)
    local args = {...}
    if #args > 1 then
        var_dump(args)
    else
        out(recurse(args[1]))
    end
end


local DLL_FILENAMES = { 
	"libsneedio", 
	"SDL2_mixer", 
	"SDL2", 
	"libvorbisfile-3", 
	"libvorbis-0",
	"libopusfile-0",
	"libopus-0",
	"libogg-0",
	"libmpg123-0",
	"libmodplug-1",
	"libFLAC-8"
};


local print = out;

print("line 30 ok");

local sneedio = {};

local libSneedio = require(DLL_FILENAMES[1]);

if(libSneedio) then

	print("lib loaded ok");

else
	local err = nil;
	local UnpackThemDlls = function()
		for _, filename in ipairs(DLL_FILENAMES) do
			local path = PATH..filename;
			if(MOCK_UP) then path = path..".lua" end;
			print("unpacking file:", path);
			local data = assert(loadfile(path))();
			data = base64.decode(data);
			local file = assert(io.open(OUTPUTPATH..filename..".dll", "wb"));
			file:write(data);
			file:close();
		end
		if(MOCK_UP) then
			libSneedio, err = pcall(require, DLL_FILENAMES[1]);
			if(not libSneedio) then
				print("failed to load libSneedio, cleaning up..");
				print(err);
				for _, filename in ipairs(DLL_FILENAMES) do
					local name = filename..".dll";
					os.remove(name);
					print("clean up ", name);
				end
			end
		else
			libSneedio, err = pcall(require, DLL_FILENAMES[1]);
			if(not libSneedio) then print(err) end;
		end
	end
	UnpackThemDlls();
end

local BM;
if core:is_battle() then
    BM = get_bm();
end

local VectorToString = function(SneedVector)
	return "x: "..SneedVector.x.." y: "..SneedVector.y.." z "..SneedVector.z;
end

local CAVectorToSneedVector = function(CAVector)
	--yeah I have to convert them to string, my DLL can't accept number for some reason.
	return { 
		x = tostring(CAVector:get_x()),
		y = tostring(CAVector:get_y()),
		z = tostring(CAVector:get_z())
	};
end

sneedio.RegisterCallbackSpeedEventOnBattle = function(UniqueName, EventName, Callback)
	print("registered event "..UniqueName.." for event "..EventName);
	if (not sneedio._ListOfCallbacksForBattleEvent[UniqueName]) then
		sneedio._ListOfCallbacksForBattleEvent[UniqueName] = {};
	end
	sneedio._ListOfCallbacksForBattleEvent[UniqueName][EventName] = Callback;
	print("registered");
	var_dump(sneedio._ListOfCallbacksForBattleEvent);
end

sneedio.Debug = function()
	print("list of registered voices");
	var_dump(sneedio._ListOfRegisteredVoices);
	if (BM) then
		print("list of registered voices on battle");
		var_dump(sneedio._ListOfRegisteredVoicesOnBattle);
	end
end

sneedio.RegisterVoice = function(unittype, fileNames)
	sneedio._ListOfRegisteredVoices[unittype] = fileNames;
end

sneedio.RegisterAmbientVoice = function(unitType, fileNames, mode)
	if(not ArrayContains({"idle", "attack", "wavering", "winning", "rampage"}, mode)) then 
		print("invalid mode "..mode.." allowed: {'idle', 'attack', 'wavering', 'winning', 'rampage'}");
		return;
	end
	if(not sneedio._ListOfRegisteredVoicesForAmbientOnBattle[unitType]) then 
		sneedio._ListOfRegisteredVoicesForAmbientOnBattle[unitType] = {};
	end
	sneedio._ListOfRegisteredVoicesForAmbientOnBattle[unitType][mode] = fileNames;
end

sneedio.RegisterVoiceOnReject = function(unitType, fileNames)
	sneedio._ListOfRegisteredVoicesOnReject[unitType] = fileNames;
end

sneedio.GetListOfVoicesFromUnit = function(unitType)
	return sneedio._ListOfRegisteredVoices[unitType];
end

sneedio.UpdateCameraPosition = function(cameraPos, cameraTarget)
	cameraPos = CAVectorToSneedVector(cameraPos);
	cameraTarget = CAVectorToSneedVector(cameraTarget);
	--print(VectorToString(cameraPos));
	--print(VectorToString(cameraTarget));
	libSneedio.UpdateListenerPosition(cameraPos, cameraTarget);
end

sneedio.RegisterSound2D = function(name, fileName)
	-- libSneedio.Load2DAudio(name, fileName);
end

sneedio.PlaySound2D = function(name)
	-- libSneedio.Play2DAudio(name);
end

sneedio.IsUnitSelected = function(unit)
	if(not is_unit(unit)) then 
		print("not a unit");
		return false;
	end;
	local unitTypeInstanced = sneedio._UnitTypeToInstanced(unit);
	return sneedio._MapUnitToSelected[unitTypeInstanced];
end

sneedio.IfBattlePaused = function()
	if (BM) then
		local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
		if(parent)then
			local button = find_uicomponent(parent, "pause");
			-- var_dump(uic_pause:CurrentState());
			return button:CurrentState() == "selected";
		end
	end
end

sneedio.IfBattleInSlowMo = function()
	if (BM) then
		local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
		if(parent)then
			local button = find_uicomponent(parent, "slow_mo");
			-- var_dump(uic_pause:CurrentState());
			return button:CurrentState() == "selected";
		end
	end
end

sneedio.IfBattleInNormalPlay = function()
	if (BM) then
		local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
		if(parent)then
			local button = find_uicomponent(parent, "play");
			-- var_dump(uic_pause:CurrentState());
			return button:CurrentState() == "selected";
		end
	end
end

sneedio.IfBattleInFastForward = function()
	if (BM) then
		local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
		if(parent) then
			local buttonFWD = find_uicomponent(parent, "fwd");
			local buttonFFWD = find_uicomponent(parent, "ffwd");
			return buttonFWD:CurrentState() == "selected" or buttonFFWD:CurrentState() == "selected";
		end
	end
end

sneedio.GetBattleSpeedMode = function()
	if(BM) then
		if(sneedio.IfBattlePaused()) then return "Paused"; end	
		if(sneedio.IfBattleInSlowMo()) then return "SlowMo"; end
		if(sneedio.IfBattleInNormalPlay()) then return "Normal"; end
		if(sneedio.IfBattleInFastForward()) then return "FastForward"; end
		return "None";
	end
	return "None";
end

---------------------------------PRIVATE methods----------------------------------

sneedio._UnitTypeToInstanced = function (unit)
	return unit:type().."_instance_"..tostring(unit:name());
end

sneedio._UnitTypeToInstancedAmbient = function (unit)
	return unit:type().."_instanceAmbient_"..tostring(unit:name());
end

---------------Battle Events--------------------

sneedio._PlayVoiceBattle = function(unitTypeInstanced, cameraPos, playAtPos)
	print("about to play audio");
	print("unit is "..unitTypeInstanced);
	local ListOfAudio = sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced];
	--var_dump(ListOfAudio);
	local PickRandom = math.random( 1, #ListOfAudio);
	print("playing voice: ".. ListOfAudio[PickRandom]);
	local result = libSneedio.PlayVoiceBattle(unitTypeInstanced, tostring(PickRandom), CAVectorToSneedVector(playAtPos));
	var_dump(result);
	if(result == 0) then
		print("audio played");
	end
	libSneedio.UpdateListenerPosition(CAVectorToSneedVector(cameraPos));
	-- print(" at camera pos: ".. v_to_s(cameraPos).. " from: ".. v_to_s(playAtPos));
end

sneedio._ProcessSelectedUnitRightClickBattle = function()
	if(libSneedio.WasRightClickHeld()) then
		for unitInstanceName, selected in pairs(sneedio._MapUnitToSelected) do
			local actualUnit = sneedio._MapUnitInstanceNameToActualUnits[unitInstanceName];
			if(selected and is_unit(actualUnit)) then	
				local bIsUnitReacting  = actualUnit:is_moving() or 
										 actualUnit:is_in_melee() or 
										 actualUnit:is_moving_fast();
				local camPos = BM:camera():position();
				local unitPos = actualUnit:position();
				if(bIsUnitReacting) then
					print("playing unit audio on rightclick evt "..unitInstanceName);
					sneedio._PlayVoiceBattle(unitInstanceName, camPos, unitPos);
				end
			end
		end
	end
end

sneedio._ProcessAmbientUnitSoundBattle = function()	
	-- local bIsMoving = actualUnit:is_moving();
	-- local bIsIdle = actualUnit:is_idle();
	-- local bIsWavering = actualUnit:is_wavering() or 
						-- actualUnit:is_routing() or 
						-- actualUnit:is_shattered();
	-- local bIsWinning = (actualUnit:is_in_melee() or actualUnit:is_rampaging()) and 
						-- actualUnit:unary_hitpoints() > 0.5;
	-- local bIsRampaging = actualUnit:is_rampaging();

end

sneedio._InitBattle = function(units)
	for _, unit in ipairs(units) do 
		local UnitVoices = sneedio.GetListOfVoicesFromUnit(unit:type());
		local InstancedName = sneedio._UnitTypeToInstanced(unit);
		sneedio._MapUnitToSelected[InstancedName] = false;
		if(UnitVoices ~= nil) then
			sneedio._RegisterVoiceOnBattle(unit, UnitVoices);
		else
			print("Warning unit:"..unit:type().." doesn not have associated voices");
		end
		
	end
end

sneedio._RegisterVoiceOnBattle = function (unit, Voices)
	local unitTypeInstanced = sneedio._UnitTypeToInstanced(unit);
	if(Voices) then
		sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced] = Voices;
		for __, filename in ipairs(Voices) do
			print("attempt to load: "..filename);
			if(libSneedio.LoadVoiceBattle(filename, unitTypeInstanced)) then
				print(unitTypeInstanced..": audio loaded "..filename);
			end
		end
	end
end

sneedio._CleanUpAfterBattle = function()
	libSneedio.ClearBattle();
	sneedio._ListOfRegisteredVoicesOnBattle = {
		["null"] = {},
	};
end

sneedio._UpdateCameraOnBattle = function()
	if(BM) then
		local camera = BM:camera();
		sneedio.UpdateCameraPosition(camera:position(), camera:target());
	end
end

sneedio._BattleOnTick = function()
	sneedio._UpdateCameraOnBattle();
	sneedio._bHasSpeedChanged = sneedio._CurrentSpeed ~= sneedio.GetBattleSpeedMode();
	sneedio._CurrentSpeed = sneedio.GetBattleSpeedMode();
	if(sneedio._bHasSpeedChanged) then
		sneedio._ProcessSpeedEvents(sneedio._CurrentSpeed);
	end
	
	sneedio._ProcessSelectedUnitRightClickBattle();
end

sneedio._ProcessSpeedEvents = function(eventToProcess)
	-- print("event "..eventToProcess);
	for uniqueName, eventsList in pairs(sneedio._ListOfCallbacksForBattleEvent) do
		for eventKey, callback in pairs(eventsList) do
			if(eventKey == eventToProcess)then
				callback();
				return;
			end
		end
	end
	-- print("event process done");
end


sneedio._RegisterSneedioTickBattleFuns = function()
	
	if(BM)then
		sneedio._BattleOnTick();
		core:add_listener(
			"sneedio_battletick_0",
			"ShortcutTriggered",
			function(context)
				var_dump(context.string);
				return true;
			end,
			function()
				BM:callback(function()
					sneedio._BattleOnTick();
				end, 0.1);
			end,
		  true);
		  
		core:add_listener(
			"sneedio_battletick_1",
			"ComponentLClickUp",
			function(context)
				var_dump(context.string);
				return true;
			end,
			function()
				BM:callback(function()
					sneedio._BattleOnTick();
				end, 0.1);
			end,
		true);

		core:add_listener(
			"sneedio_battletick_2",
			"ComponentMouseOn",
			function(context)
				return true;
			end,
			function()
				BM:callback(function()
					sneedio._BattleOnTick();
				end, 0.1);
			end,
		true);	
		
		
		
		sneedio.RegisterCallbackSpeedEventOnBattle("__SneedioInternal", "Paused", function()
			print("pause the music");
			print("pause all sound effects");
		end);
		
		sneedio.RegisterCallbackSpeedEventOnBattle("__SneedioInternal", "Normal", function()
			print("unpause the music");
			print("unpause all sound effects");
			print("unmute all sound effects");
		end);
		
		sneedio.RegisterCallbackSpeedEventOnBattle("__SneedioInternal", "FastForward", function()
			print("mute all sound effects");
		end);

	end
	
end

---------------------------------------Private variables----------------------------------------------------------

---------------Battle Events--------------------
sneedio._bHasSpeedChanged = false;
sneedio._CurrentSpeed = "Normal";

sneedio._ListOfCallbacksForBattleEvent = {};

sneedio._ListOfRegisteredVoicesOnBattle = {
	["null"] = {},
};

sneedio._ListOfRegisteredVoicesForAmbientOnBattle = {
	["null"] = {
		["idle"] = {},
		["attack"] = {},
		["wavering"] = {},
		["winning"] = {},
		["rampage"] = {}
	}
};

sneedio._MapUnitToSelected = {
	["null"] = false,
};

sneedio._MapUnitInstanceNameToActualUnits = {
	["null"] = nil,
};

sneedio._ListOfRegisteredVoices = {
	["null"] = {},
};



print("all ok");

_G.sneedio = sneedio;

--return sneedio;

-- let's register our audio first

sneedio.RegisterVoice("wh2_dlc14_brt_cha_repanse_de_lyonesse_0", {
	"woman_yell_1.ogg", 
	"woman_yell_2.ogg"
});

sneedio.RegisterVoice("wh2_dlc14_brt_cha_henri_le_massif_0", {
	"man_grunt_1.ogg", 
	"man_grunt_2.ogg",
	"man_grunt_5.ogg",
	"man_grunt_13.ogg",
	"man_grunt_3.ogg",
});

sneedio.Debug();

out("hello world");

function UpdateCamera()
	if(BM) then
		local camera = BM:camera();
		sneedio.UpdateCameraPosition(camera:position(), camera:target());
		sneedio._BattleOnTick();
	end
end

BM:register_repeating_timer("UpdateCamera", 100);
sneedio._RegisterSneedioTickBattleFuns();

var_dump(sneedio);
var_dump(libSneedio);

local SneedioBattleMain = function()


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

	local ListOfUnits = {};
    ForEachUnitsPlayer(function(CurrentUnit, CurrentArmy)
		table.insert(ListOfUnits, CurrentUnit);
		local instancedName = sneedio._UnitTypeToInstanced(CurrentUnit);
		sneedio._MapUnitInstanceNameToActualUnits[instancedName] = CurrentUnit;
    end);

	out("ListOfUnits have sneeded!");
	
	var_dump(ListOfUnits);
	sneedio._InitBattle(ListOfUnits)
	var_dump(sneedio);
	
    -- register the callback when unit is selected
    ForEachUnitsPlayer(function(CurrentUnit, CurrentArmy)
        BM:register_unit_selection_callback(CurrentUnit, function(unit)
				local InstancedName = sneedio._UnitTypeToInstanced(unit);
				if(not sneedio.IsUnitSelected(unit))then				
					local camera = BM:camera();
					print("Selected unit: ");
					print(unit:name());
					print(unit:type());
					
					print("camera "..v_to_s(camera:position()));
					print("unit "..v_to_s(unit:position()));
					sneedio._PlayVoiceBattle(InstancedName, camera:position(), unit:position());	
					sneedio._MapUnitToSelected[InstancedName] = true;
				else
					print("unit was unselected");
					print(InstancedName);
					sneedio._MapUnitToSelected[InstancedName] = false;
				end
            end);
    end);
	
	out("battle has sneeded!");
end

if BM ~= nil then SneedioBattleMain(); end

sneedio.RegisterCallbackSpeedEventOnBattle("test", "Normal", function()
	print("game is being played");
end);

sneedio.RegisterCallbackSpeedEventOnBattle("test", "SlowMo", function()
	print("game is on slowmo");
end);

sneedio.RegisterCallbackSpeedEventOnBattle("test", "Paused", function()
	print("game is paused");
end);

sneedio.RegisterCallbackSpeedEventOnBattle("test", "FastForward", function()
	print("game is on fastforward");
end);