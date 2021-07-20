
local print = function (x)
	out("chuckio: "..x);
end;

local MOCK_UP = true;
local PATH = "/script/bin/";
local OUTPUTPATH = "";

--#region init stuff soon to be removed into their own libs

local base64 = require("base64");

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

--#endregion init stuff soon to be removed into their own libs

local BM;
if core:is_battle() then
    BM = get_bm();
end

local InArray = function (array, item)
	for _, v in ipairs(array) do
		if(v == item) then return true; end
	end
	return false;
end


local FilterArray = function (array, pred)
	local results = {};
	for _, v in ipairs(array) do
		if(pred(v))then
			table.insert(results, v);
		end
	end
	return results;
end

local ConcatArray = function (...)
	local result = {};
	local arrays = {...};
	for _, array in ipairs(arrays) do
		for a in ipairs(array) do
			table.insert(result, a);
		end
	end
	return result;
end

local GetArrayIndexByPred = function (array, pred)
	for i=1, #array do
		if(pred(array[i]))then
			return i;
		end
	end
	return 0;
end

local HasKey = function (hashMap, key)
	if(type(hashMap) ~= "table") then return false; end
	return hashMap[key] ~= nil
end

local IsBetween = function (Min, Max, X)
	return Max >= X and X >= Min;
end


local CAVectorToSneedVector = function(CAVector)
	--yeah I have to convert them to string, my DLL can't accept number for some reason.
	return { 
		x = tostring(CAVector:get_x()),
		y = tostring(CAVector:get_y()),
		z = tostring(CAVector:get_z())
	};
end

local ForEachUnitsPlayer =  function (FunctionToProcess)
	if(BM == nil) then return end;

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

local ForEachUnitsAll = function(FunctionToProcess)
	if(BM == nil) then return end;

	local Alliances = BM:alliances();
	for a = 1, Alliances:count() do
		local Alliance = Alliances:item(a);
		local Armies = Alliance:armies();
		
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
	end
end

local ForEachUnitsEnemy = function (FunctionToProcess)
	if(BM == nil) then return end;

	local PlayerSideArmies = BM:get_non_player_alliance();
	local Armies = PlayerSideArmies:armies();

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

	
end

sneedio.Pause = function (bPause)
	libSneedio.Pause(tostring(bPause));
end

sneedio.MuteSoundFX = function (bPause)
	libSneedio.MuteSoundFX(tostring(bPause));
end

sneedio.MuteMusic = function (bPause)
	libSneedio.MuteMusic(tostring(bPause));
end

sneedio.UpdateCameraPosition = function(cameraPos, cameraTarget)
	cameraPos = CAVectorToSneedVector(cameraPos);
	cameraTarget = CAVectorToSneedVector(cameraTarget);
	--print(VectorToString(cameraPos));
	--print(VectorToString(cameraTarget));
	libSneedio.UpdateListenerPosition(cameraPos, cameraTarget);
end

sneedio.Debug = function()
	var_dump(sneedio);
end

sneedio.LoadMusic = function (factionId, MusicPlaylist)
	sneedio._MusicPlaylist[factionId] = MusicPlaylist;
end

sneedio.AddMusicCampaign = function (factionId, fileName)
	
	if(sneedio._MusicPlaylist[factionId] and sneedio._MusicPlaylist[factionId]["CampaignMap"])then
		if(sneedio._MusicPlaylist[factionId]["CampaignMap"])then
			table.insert(sneedio._MusicPlaylist[factionId]["CampaignMap"], fileName);
		end
	end
end

sneedio.AddMusicBattle = function (factionId, Situation, ...)
	local fileNamesArr = {...};
	
	for _, fileName in ipairs(fileNamesArr) do
		if(not HasKey(fileName, "FileName") and not HasKey(fileName, "MaxDuration") ) then
			print("error this element doesn't have FileName and MaxDuration param");
			var_dump(fileName);
			return;
		end
		if(not sneedio._MusicPlaylist[factionId]) then
			sneedio._MusicPlaylist[factionId] = {};
		end
		if(not sneedio._MusicPlaylist[factionId]["Battle"]) then
			sneedio._MusicPlaylist[factionId]["Battle"] = {};
		end
		if(sneedio._MusicPlaylist[factionId] and sneedio._MusicPlaylist[factionId]["Battle"])then
			if(not sneedio._MusicPlaylist[factionId]["Battle"][Situation]) then
				sneedio._MusicPlaylist[factionId]["Battle"][Situation] = {};
			end
			if(sneedio._MusicPlaylist[factionId]["Battle"][Situation])then
				local fileName = fileName;
				fileName.CurrentDuration = 0;
				table.insert(sneedio._MusicPlaylist[factionId]["Battle"][Situation], fileName);
				print("added music for faction "..factionId.." situation "..Situation.." filename "..fileName.FileName.." max duration "..tostring(fileName.MaxDuration));
			end
		end
	end
end

sneedio.GetPlayerSideRoutRatioQuick = function ()
	if(sneedio._CountPlayerUnits == 0) then return 1; end
	return sneedio._CountPlayerRoutedUnits / sneedio._CountPlayerUnits;
end

sneedio.GetEnemySideRoutRatioQuick = function ()
	if(sneedio._CountEnemyUnits == 0) then return 1; end
	return sneedio._CountEnemyRoutedUnits / sneedio._CountEnemyUnits;
end

sneedio.GetPlayerSideRoutRatio = function ()
	sneedio._MonitorRoutingUnits();
	return sneedio.GetPlayerSideRoutRatioQuick();
end

sneedio.GetEnemySideRoutRatio = function ()
	sneedio._MonitorRoutingUnits();
	return sneedio.GetEnemySideRoutRatioQuick();
end

sneedio.IsCurrentMusicHalfWaythrough = function ()
	local MaxDur = sneedio._CurrentPlayedMusic.MaxDuration;
	if(MaxDur <= 0) then return true; end
	return (sneedio._CurrentPlayedMusic.CurrentDuration / MaxDur) >= 0.5;
end

sneedio.IsCurrentMusicFinished = function ()
	local MaxDur = sneedio._CurrentPlayedMusic.MaxDuration;
	if(MaxDur <= 0) then return true; end
	return sneedio._CurrentPlayedMusic.CurrentDuration >= MaxDur;
end

sneedio.GetPlayerFactionPlaylistForBattle = function (Situation)
	if(Situation) then	
		local availableSituations = {"Deployment", "Complete", "Balanced", "FirstEngagement", "Losing", "Winning", "LastStand"};
		if(not InArray(availableSituations, Situation))then
			print("warn ".."invalid Situation. Situation are {'Deployment', 'Complete', 'FirstEngagement', 'Losing', 'Winning', 'LastStand'} yours was "..Situation);
		end
	end
	local factionKey = sneedio.GetPlayerFaction();
	if (sneedio._MusicPlaylist[factionKey]) then
		if(sneedio._MusicPlaylist[factionKey]["Battle"])then
			if(Situation)then				
				if(sneedio._MusicPlaylist[factionKey]["Battle"][Situation])then
					return sneedio._MusicPlaylist[factionKey]["Battle"][Situation];
				else
					print("warn "..factionKey.." has no music playlist battle for Situation "..Situation);
				end
			else
				return sneedio._MusicPlaylist[factionKey]["Battle"];
			end
		else
			print("warn "..factionKey.." has no music playlist battle to play with");
		end
	else
		print("warn "..factionKey.." has no music playlist registered at all");
	end
end

sneedio.GetPlayerFaction = function ()
	if(BM) then
		return BM:get_player_army():faction_key();
	else
		-- must be in CampaignMap
		print("warn ".."not implemented! getplayerfaction");
		return "not implemented";
	end
end

sneedio.GetBattleSituation = function ()
	if(BM)then
		return sneedio._CurrentSituation;
	end
end

sneedio.GetNextMusicData = function ()
	if(BM) then
		local battlePlaylist = sneedio.GetPlayerFactionPlaylistForBattle(sneedio.GetBattleSituation());
		--print("battle play list");
		local rand = math.random(#battlePlaylist);
		local result = battlePlaylist[rand];
		--print("prev battle music");
		--var_dump(sneedio._Last2PlayedMusic);
		local bPlayed2PrevMusic = GetArrayIndexByPred(sneedio._Last2PlayedMusic, function (e)
			return result.FileName == e.FileName;
		end);
		if(bPlayed2PrevMusic ~= 0) then
			print("pick music again, hope this time won't be the same");
			rand = math.random(#battlePlaylist);
			result = battlePlaylist[rand];
		end
		return result;
	end
end

--#region audio/voice operations

sneedio.LoadCustomAudio = function(identifier, fileName)
	if(sneedio.IsIdentifierValid(identifier))then
		print("audio already loaded for "..identifier);
		return;
	end
	print("attempt to load: "..fileName);
	if(libSneedio.LoadVoiceBattle(fileName, identifier)) then
		print(identifier..": audio loaded "..fileName);
		sneedio._ListOfCustomAudio[identifier] = fileName;
	else
		print("warning, failed to load Custom audio .."..identifier.." filename path: "..fileName.." maybe file doesn't exist or wrong path");
	end
end

sneedio.IsIdentifierValid = function(identifier)
	return sneedio._ListOfCustomAudio[identifier] ~= nil;
end

sneedio.PlayCustomAudio2D = function (identifier , volume)
	local pos = nil;
	if(BM)then
		pos = BM:camera():position();
		sneedio.PlayCustomAudio(identifier, pos, 600, volume, pos);
	end
end

sneedio.PlayCustomAudio = function(identifier, atPosition, maxDistance, volume, listener)
	local defaultPosition = v(0,0,0);
	if(BM)then
		defaultPosition = BM:camera():position();
	end
	listener = listener or defaultPosition;
	maxDistance = maxDistance or 400;
	volume = volume or 1;
	atPosition = atPosition or defaultPosition;
	if(not is_vector(atPosition))then
		print("atPosition param is not a vector");
		return;
	end
	if(not is_vector(listener)) then
		print("listener param is not a vector");
		return;
	end
	if(type(maxDistance) ~= "number")then
		print("maxDistance param is not a number");
		return;
	end
	if(type(volume) ~= "number")then
		print("volume param is not a number");
		return;
	end
	if(not sneedio.IsIdentifierValid(identifier)) then
		print("identifier is not valid");
		return;
	end
	local res = libSneedio.PlayVoiceBattle(identifier, tostring(1), CAVectorToSneedVector(atPosition), tostring(maxDistance), tostring(volume));
	if(res == 0)then
		print("audio played "..identifier);
	end
	libSneedio.UpdateListenerPosition(CAVectorToSneedVector(listener));
end

sneedio.RegisterVoice = function(unittype, fileNames)
	sneedio._ListOfRegisteredVoices[unittype] = fileNames;
end

sneedio.GetListOfVoicesFromUnit = function(unitType, voiceType)
	if(sneedio._ListOfRegisteredVoices[unitType]) then
		return sneedio._ListOfRegisteredVoices[unitType][voiceType];
	end
	return nil;
end

--#endregion audio/voices operations

--#region battle helper
sneedio.RegisterCallbackSpeedEventOnBattle = function(UniqueName, EventName, Callback)
	print("registered event "..UniqueName.." for event "..EventName);
	if (not sneedio._ListOfCallbacksForBattleEvent[UniqueName]) then
		sneedio._ListOfCallbacksForBattleEvent[UniqueName] = {};
	end
	sneedio._ListOfCallbacksForBattleEvent[UniqueName][EventName] = Callback;
	print("registered");
	-- var_dump(sneedio._ListOfCallbacksForBattleEvent);
end

sneedio.IsUnitSelected = function(unit)
	if(not is_unit(unit)) then 
		print("not a unit");
		return false;
	end;
	local unitTypeInstanced = sneedio._UnitTypeToInstancedSelect(unit);
	return sneedio._MapUnitToSelected[unitTypeInstanced];
end

sneedio.IsBattlePaused = function()
	if (BM) then
		local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
		if(parent)then
			local button = find_uicomponent(parent, "pause");
			-- var_dump(uic_pause:CurrentState());
			return button:CurrentState() == "selected";
		end
	end
end

sneedio.IsBattleInSlowMo = function()
	if (BM) then
		local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
		if(parent)then
			local button = find_uicomponent(parent, "slow_mo");
			-- var_dump(uic_pause:CurrentState());
			return button:CurrentState() == "selected";
		end
	end
end

sneedio.IsBattleInNormalPlay = function()
	if (BM) then
		local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
		if(parent)then
			local button = find_uicomponent(parent, "play");
			-- var_dump(uic_pause:CurrentState());
			return button:CurrentState() == "selected";
		end
	end
end

sneedio.IsBattleInFastForward = function()
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
		if(sneedio.IsBattlePaused()) then return "Paused"; end	
		if(sneedio.IsBattleInSlowMo()) then return "SlowMo"; end
		if(sneedio.IsBattleInNormalPlay()) then return "Normal"; end
		if(sneedio.IsBattleInFastForward()) then return "FastForward"; end
		return "None";
	end
	return "None";
end

sneedio.GetBattleTicks = function()
	return sneedio._BattleCurrentTicks;
end
--#endregion battle helper
---------------------------------PRIVATE methods----------------------------------

sneedio._IsFirstEngagement = function ()
	return sneedio._BattlePhaseStatus == "Deployed";
end

sneedio._MonitorRoutingUnits = function ()
	local EnemyRouting = 0;
	local TotalEnemyUnits = 0;
	ForEachUnitsEnemy(function (Unit, Armies)
		if(Unit:is_routing()) then 
			EnemyRouting = EnemyRouting + 1;
		end
		TotalEnemyUnits = TotalEnemyUnits + 1;
	end);
	sneedio._CountEnemyUnits = TotalEnemyUnits;
	sneedio._CountEnemyRoutedUnits = EnemyRouting;

	local PlayerRouting = 0;
	local TotalPlayerUnits = 0;
	ForEachUnitsPlayer(function (Unit, Armies)
		if(Unit:is_routing()) then 
			PlayerRouting = PlayerRouting + 1;
		end
		TotalPlayerUnits = TotalPlayerUnits + 1;
	end);
	sneedio._CountPlayerUnits = TotalPlayerUnits;
	sneedio._CountPlayerRoutedUnits = PlayerRouting;
end

--------------------------------Music methods------------------------------------

sneedio._PlayMusic = function (musicData)
	print("playing music ".. musicData.FileName);
	sneedio._CurrentPlayedMusic = musicData;
	sneedio._CurrentPlayedMusic.Situation = sneedio._CurrentSituation;
	if(#sneedio._Last2PlayedMusic >= 2) then
		table.remove(sneedio._Last2PlayedMusic, 1);
	end
	table.insert(sneedio._Last2PlayedMusic, musicData);
	print("now playing "..musicData.FileName.." duration is "..tostring(musicData.MaxDuration));
	if(libSneedio.PlayMusic(musicData.FileName)) then
		print("music played...");
		if(BM) then
			BM:set_volume(0, 0);
		end
	else
		print("failed to play music: "..musicData.FileName);
		print("fallback to warscape music");
		BM:set_volume(0, 1);
	end
end

sneedio._MusicTimeTracker = function ()
	sneedio._CurrentPlayedMusic.CurrentDuration = sneedio._CurrentPlayedMusic.CurrentDuration + 1;
	-- print(sneedio._CurrentPlayedMusic.CurrentDuration);
end

sneedio._UpdateMusicSituation = function ()
	if(sneedio._CurrentSituation == "Deployment") then return; end
	if(sneedio._CurrentSituation == "FirstEngagement") then return; end

	local PlayerRouts = sneedio.GetPlayerSideRoutRatioQuick();
	local EnemyRouts = sneedio.GetPlayerSideRoutRatioQuick();

	if (IsBetween(0, 0.4, PlayerRouts) and IsBetween(0, 0.4, EnemyRouts))then
		sneedio._CurrentSituation = "Balanced";
	elseif (IsBetween(0.5, 0.7, PlayerRouts) and IsBetween(0, 0.7, EnemyRouts)) then
		sneedio._CurrentSituation = "Losing";
	elseif (IsBetween(0.7, 1, PlayerRouts) and IsBetween(0, 0.6, EnemyRouts)) then
		sneedio._CurrentSituation = "LastStand";
	elseif (IsBetween(0, 0.3, PlayerRouts) and IsBetween(0.8, 1, EnemyRouts)) then
		sneedio._CurrentSituation = "Winning";
	end
end

-- called only when transitioning:
-- Deployment -> FirstEngagement.
-- FirstEngagement Balanced Losing LastStand Winning -> Complete.
-- FirstEngagement Balanced -> Losing (when general wounded).
sneedio._ProcessMusicPhaseChanges = function ()
	print("important phase changes!")
	sneedio._PlayMusic(sneedio.GetNextMusicData());
end

sneedio._ProcessMusicEvent = function ()
	if(sneedio.IsCurrentMusicFinished())then
		print("music finished, new music pls");
		-- reset the current music duration.
		sneedio._CurrentPlayedMusic.CurrentDuration = 0;
		-- print("current music");
		-- var_dump(sneedio._CurrentPlayedMusic);
		-- print("all music");
		-- var_dump(sneedio._MusicPlaylist);
		local playlist = sneedio._MusicPlaylist[sneedio.GetPlayerFaction()].Battle[sneedio._CurrentPlayedMusic.Situation];
		-- var_dump(playlist);
		local idx = GetArrayIndexByPred(playlist, function (el)
			return el.FileName == sneedio._CurrentPlayedMusic.FileName;
		end);
		-- print("index "..tostring(idx));
		-- print("current situation: "..sneedio._CurrentSituation);
		-- var_dump(sneedio._MusicPlaylist[sneedio.GetPlayerFaction()].Battle[sneedio._CurrentPlayedMusic.Situation][idx]);
		sneedio._MusicPlaylist[sneedio.GetPlayerFaction()].Battle[sneedio._CurrentPlayedMusic.Situation][idx].CurrentDuration = 0;
		
		sneedio._PlayMusic(sneedio.GetNextMusicData());
	end
	if(sneedio.IsCurrentMusicHalfWaythrough()) then
		sneedio._UpdateMusicSituation();
	end
end

---------------------------Sound effects methods----------------------------------

--#region Sound effects

sneedio._UnitTypeToInstancedSelect = function (unit)
	return unit:type().."_instance_select_"..tostring(unit:name().."_fac_idx_"..tostring(unit:alliance_index()));
end

sneedio._UnitTypeToInstancedAffirmative = function (unit)
	return unit:type().."_instance_affirmative_"..tostring(unit:name().."_fac_idx_"..tostring(unit:alliance_index()));
end

sneedio._UnitTypeToInstancedAbilities = function (unit)
	return unit:type().."_instance_abilities_"..tostring(unit:name().."_fac_idx_"..tostring(unit:alliance_index()));
end

sneedio._UnitTypeToInstancedAbort = function (unit)
	return unit:type().."_instance_abort_"..tostring(unit:name().."_fac_idx_"..tostring(unit:alliance_index()));
end

sneedio._UnitTypeToInstancedHostile = function (unit)
	return unit:type().."_instance_hostile_"..tostring(unit:name().."_fac_idx_"..tostring(unit:alliance_index()));
end

sneedio._UnitTypeToInstancedAmbient = function (unit, AmbientType)
	return unit:type().."_instance_ambient_type_"..AmbientType.."_"..tostring(unit:name());
end

---------------Battle Events--------------------


sneedio._PlayVoiceBattle = function(unitTypeInstanced, cameraPos, playAtPos, bIsAmbient)
	bIsAmbient = bIsAmbient or false;
	print("about to play audio");
	print("unit is "..unitTypeInstanced);
	local ListOfAudio = sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced];
	if(ListOfAudio)then
		--var_dump(ListOfAudio);
		local PickRandom = math.random( 1, #ListOfAudio);
		local MaxDistance = 390;
		local Volume = 0.7;
		if(bIsAmbient) then
			MaxDistance = 200;
			Volume = 0.5;
		end
		print("playing voice: ".. ListOfAudio[PickRandom]);
		local result = libSneedio.PlayVoiceBattle(unitTypeInstanced, tostring(PickRandom), CAVectorToSneedVector(playAtPos), tostring(MaxDistance), tostring(Volume));
		var_dump(result);
		if(result == 0) then
			print("audio played");
		end
	else
		print("no audio regisered for "..unitTypeInstanced);
	end
	libSneedio.UpdateListenerPosition(CAVectorToSneedVector(cameraPos));
	-- print(" at camera pos: ".. v_to_s(cameraPos).. " from: ".. v_to_s(playAtPos));
end

sneedio._ProcessSelectedUnitRightClickBattle = function()
	if(libSneedio.WasRightClickHeld()) then
		--print("line 278");
		for unitInstanceName, selected in pairs(sneedio._MapUnitToSelected) do
			--print("line 280");
			local actualUnit = sneedio._MapUnitInstanceNameToActualUnits[unitInstanceName];
			if(selected and is_unit(actualUnit)) then	
				--print("line 283");
				local bIsUnitReacting  = actualUnit:is_moving() or 
										 actualUnit:is_in_melee() or 
										 actualUnit:is_moving_fast();
				local camPos = BM:camera():position();
				local unitPos = actualUnit:position();
				local unitInstanceNameAffirmative = sneedio._UnitTypeToInstancedAffirmative(actualUnit);
				if(bIsUnitReacting) then
					print("playing unit audio on rightclick evt "..unitInstanceName.." affirmative "..unitInstanceNameAffirmative);
					sneedio._PlayVoiceBattle(unitInstanceNameAffirmative, camPos, unitPos);
				end
			end
		end
	end
end


-- can only work with single unit :(
sneedio._ProcessSelectedUnitOnAbilitiesBattle = function()
	local selectedUnit = {};
	for unitInstanceName, selected in pairs(sneedio._MapUnitToSelected) do
		if(selected)then 
			table.insert(selectedUnit, unitInstanceName); 
		end
		if(#selectedUnit>1 and #selectedUnit ~= 0)then
			return;
		end
	end
	
	local theUnit = sneedio._MapUnitInstanceNameToActualUnits[selectedUnit[1]];
	local unitInstanceNameAbilities = sneedio._UnitTypeToInstancedAbilities(theUnit);
	local camPos = BM:camera():position();
	print("playing unit audio on Abilities UI buttons "..selectedUnit[1].." Abilities "..unitInstanceNameAbilities);

	sneedio._PlayVoiceBattle(unitInstanceNameAbilities, camPos, theUnit:position());
end

sneedio._ProcessSelectedUnitOnStopOrBackspaceBattle = function()
	for unitInstanceName, selected in pairs(sneedio._MapUnitToSelected) do
		--print("line 298");
		local actualUnit = sneedio._MapUnitInstanceNameToActualUnits[unitInstanceName];
		if(selected and is_unit(actualUnit)) then	
			local camPos = BM:camera():position();
			local unitPos = actualUnit:position();
			local unitInstanceNameAbort = sneedio._UnitTypeToInstancedAbort(actualUnit);

			print("playing unit audio on backspace/abort evt "..unitInstanceName.." abort "..unitInstanceNameAbort);
			sneedio._PlayVoiceBattle(unitInstanceNameAbort, camPos, unitPos);
		end
	end
end


-- PRONE TO CRASHING FIX ME PLS
sneedio._ProcessAmbientUnitSoundBattle = function()	
	if(sneedio.IsBattleInNormalPlay())then
		local cameraPos = BM:camera():position();
	
		for unitInstanceName, TheActualUnit in pairs(sneedio._MapUnitInstanceNameToActualUnits) do
			local Distance = cameraPos:distance(TheActualUnit:position());
			local RollToQueueAmbience = math.random(1,10) == 1;
			local randomDelay = 9*10; --todo, improve this algo!
			if(Distance < 40 and RollToQueueAmbience) then
				--print("line 318 -- process ambient sound");
				if(TheActualUnit:is_idle()) then
					print("line 326 -- process ambient sound");
					local instancedAmbientName = sneedio._UnitTypeToInstancedAmbient(TheActualUnit, "Idle");
					sneedio._QueueAmbienceVoiceToPlay(instancedAmbientName, randomDelay, TheActualUnit);
				elseif(TheActualUnit:is_wavering() or 
					   TheActualUnit:is_routing() or
				       TheActualUnit:is_shattered()) then
					local instancedAmbientName = sneedio._UnitTypeToInstancedAmbient(TheActualUnit, "Wavering");
					sneedio._QueueAmbienceVoiceToPlay(instancedAmbientName, randomDelay, TheActualUnit);
				elseif(TheActualUnit:is_rampaging()) then
					local instancedAmbientName = sneedio._UnitTypeToInstancedAmbient(TheActualUnit, "Rampage");
					sneedio._QueueAmbienceVoiceToPlay(instancedAmbientName, randomDelay, TheActualUnit);
				elseif(TheActualUnit:is_in_melee()) then
					local instancedAmbientName = sneedio._UnitTypeToInstancedAmbient(TheActualUnit, "Attack");
					sneedio._QueueAmbienceVoiceToPlay(instancedAmbientName, randomDelay, TheActualUnit);
				elseif((TheActualUnit:is_in_melee() or 
						TheActualUnit:is_rampaging()) and
						TheActualUnit:unary_hitpoints() > 0.5) then
					local instancedAmbientName = sneedio._UnitTypeToInstancedAmbient(TheActualUnit, "Winning");
					sneedio._QueueAmbienceVoiceToPlay(instancedAmbientName, randomDelay, TheActualUnit);
				end
			end
		end
	end
end

sneedio._ProcessAmbienceQueues = function()
	local Timestamp = sneedio.GetBattleTicks();
	for unitInstanceName, queues in pairs(sneedio._AmbienceQueues) do
		-- print("processed "..unitInstanceName);
		if(queues and #queues > 0) then
			local top = queues[1];
			local camPos = BM:camera():position();
			print("pop ambiencequeue "..top.InstancedName.." current tick "..tostring(sneedio.GetBattleTicks()));
			sneedio._PlayVoiceBattle(top.InstancedName, camPos, top.Unit:position(), true);
			table.remove(queues, 1);
		end
	end
end

sneedio._QueueAmbienceVoiceToPlay = function(unitInstanceName, delayInSecs, theUnit)
	local Timestamp = sneedio.GetBattleTicks();
	local Queue = {
		InstancedName = unitInstanceName,
		PlayAfterTicks = Timestamp + delayInSecs*1000,
		Unit = theUnit
	};
	-- table.insert(sneedio._AmbienceQueues, Queue);
	if(sneedio._AmbienceQueues[unitInstanceName] == nil) then
		sneedio._AmbienceQueues[unitInstanceName] = {};
		print("queued new ambience voice "..unitInstanceName.." delayInSecs "..tostring(delayInSecs).." will play at ticks "..tostring(Queue.PlayAfterTicks).." current ticks "..tostring(Timestamp));
		table.insert(sneedio._AmbienceQueues[unitInstanceName], Queue);
	elseif(#sneedio._AmbienceQueues[unitInstanceName] < 1) then
		print("queued new ambience voice "..unitInstanceName.." delayInSecs "..tostring(delayInSecs).." will play at ticks "..tostring(Queue.PlayAfterTicks).." current ticks "..tostring(Timestamp));
		-- local prev = sneedio._AmbienceQueues[unitInstanceName][#sneedio._AmbienceQueues];
		-- if(Queue.PlayAfterTicks - prev.PlayAfterTicks < 2*1000)then
			-- Queue.PlayAfterTicks = Queue.PlayAfterTicks + math.random(2,5)*1000;
		-- end
		table.insert(sneedio._AmbienceQueues[unitInstanceName], Queue);
	else
		print("queue is overloaded. ");
	end
	
end

sneedio._RegisterVoiceOnBattle = function (unit, Voices, VoiceType)
	local unitTypeInstanced = "";
	
	if(VoiceType == "Select")then
		unitTypeInstanced = sneedio._UnitTypeToInstancedSelect(unit);
	elseif(VoiceType == "Affirmative") then
		unitTypeInstanced = sneedio._UnitTypeToInstancedAffirmative(unit);
	elseif(VoiceType == "Abort") then
		unitTypeInstanced = sneedio._UnitTypeToInstancedAbort(unit);
	elseif(VoiceType == "Abilities") then
		unitTypeInstanced = sneedio._UnitTypeToInstancedAbilities(unit);
	elseif(VoiceType == "Idle" or 
		   VoiceType == "Attack" or 
		   VoiceType == "Wavering" or 
		   VoiceType == "Winning" or 
		   VoiceType == "Rampage") then
		unitTypeInstanced = sneedio._UnitTypeToInstancedAmbient(unit, VoiceType);
	else
		print("warning, unknown type "..VoiceType.." aborting this function");
		return;
	end
	
	if(Voices) then
		sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced] = Voices;
		for __, filename in ipairs(Voices) do
			print("attempt to load: "..filename);
			if(libSneedio.LoadVoiceBattle(filename, unitTypeInstanced)) then
				print(unitTypeInstanced..": audio loaded "..filename.." for voice type "..VoiceType);
			else
				print("warning, failed to load .."..unitTypeInstanced.." filename path: "..filename.." for voice type "..VoiceType.." maybe file doesn't exist or wrong path");
			end
		end
	end
end

--#endregion sound effects

--#region tick procedures
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
	sneedio._ProcessAmbienceQueues();
	
	sneedio._BattleCurrentTicks = sneedio._BattleCurrentTicks + 100;
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

--#endregion tick procedures

--#region init procedures
sneedio._RegisterSneedioTickBattleFuns = function()
	
	if(BM)then
		sneedio._BattleOnTick();
		core:add_listener(
			"sneedio_battletick_0",
			"ShortcutTriggered",
			function(context)
				-- var_dump(context.string);
				return true;
			end,
			function()
				BM:callback(function()
					--sneedio._BattleOnTick();
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
					--sneedio._BattleOnTick();
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

		core:add_listener(
			"sneedio_battletick_3_afirmative",
			"ComponentLClickUp",
			function(context)
				local buttons = {
					"button_ability1", 
					"button_ability2",
					"button_ability3",
					"button_ability4",
					"button_ability5",
					"button_ability6",
					"button_ability7",
					"button_ability8"
				};
				return InArray(buttons, context.string);
			end,
			function()
				BM:callback(function()
					sneedio._ProcessSelectedUnitOnAbilitiesBattle();
				end, 0.1);
			end,
		true);
		
		core:add_listener(
			"sneedio_battleonabortcmd_1",
			"ShortcutTriggered",
			function(context)
				return context.string == "current_selection_order_cancel"
			end,
			function()
				BM:callback(function()
					sneedio._ProcessSelectedUnitOnStopOrBackspaceBattle();
				end, 0.1);
			end,
		true);
		
		core:add_listener(
			"sneedio_battleonabortcmd_2",
			"ComponentLClickUp",
			function(context)				
				return context.string == "button_halt";
			end,
			function()
				BM:callback(function()
					sneedio._ProcessSelectedUnitOnStopOrBackspaceBattle();
				end, 0.1);
			end,
		true);

		BM:repeat_callback(function ()
			sneedio._ProcessAmbientUnitSoundBattle();
		end, 5*1000,
		"sneedio_process_ambient_event");
		
		core:add_listener(
			"sneedio_button_right_click_test_3",
			"ComponentRClickUp",
			function(context)				
				return context.string == "root";
			end,
			function()
				BM:callback(function()
					print("root click click pressed");
				end, 0.1);
			end,
		true);

		sneedio.RegisterCallbackSpeedEventOnBattle("__SneedioInternal", "Paused", function()
			print("pause the music");
			print("pause all sound effects");
			sneedio.MuteSoundFX(true);
			sneedio.Pause(true);
		end);
		
		sneedio.RegisterCallbackSpeedEventOnBattle("__SneedioInternal", "SlowMo", function()
			print("mute all sound effects");
			sneedio.MuteSoundFX(true);
			sneedio.Pause(false);
		end);
		
		sneedio.RegisterCallbackSpeedEventOnBattle("__SneedioInternal", "Normal", function()
			print("unpause the music");
			print("unpause all sound effects");
			print("unmute all sound effects");
			sneedio.MuteSoundFX(false);
			sneedio.Pause(false);
		end);
		
		sneedio.RegisterCallbackSpeedEventOnBattle("__SneedioInternal", "FastForward", function()
			print("mute all sound effects");
			sneedio.MuteSoundFX(true);
			sneedio.Pause(false);
		end);

		-- used for music callbacks
		if(MOCK_UP) then
			sneedio._BattlePhaseStatus = "Deployment";
			sneedio._CurrentSituation = "Deployment";
			sneedio._ProcessMusicPhaseChanges();
		else
			BM:register_phase_change_callback("Deployment", function ()
				print("battle in Deployment");
				sneedio._BattlePhaseStatus = "Deployment";
				sneedio._CurrentSituation = "Deployment";
				sneedio._ProcessMusicPhaseChanges();
			end);
		end
		

		BM:register_phase_change_callback("Deployed", function ()
			print("battle Deployment");
			sneedio._BattlePhaseStatus = "Deployed";
			sneedio._CurrentSituation = "FirstEngagement";
			sneedio._ProcessMusicPhaseChanges();
		end);

		BM:register_phase_change_callback("Complete", function ()
			print("Battle complete in Deployment");
			sneedio._BattlePhaseStatus = "Complete";
			sneedio._CurrentSituation = "Complete";
			sneedio._ProcessMusicPhaseChanges();
		end);

		BM:start_engagement_monitor();

		core:add_listener(
			"sneedio_dynamic_music_during_heated_battle",
			"ScriptEventBattleArmiesEngaging",
			true,
			function ()
				BM:callback(function()
					print("no longer in FirstEngagement");
					sneedio._CurrentSituation = "Balanced";
					sneedio._ProcessMusicPhaseChanges();
				end, 0.1);
			end,
		true);

		BM:repeat_callback(function ()
			sneedio._MusicTimeTracker();
		end, 1*1000,
		"sneedio_monitor_music_time_tracker");
		
		BM:repeat_callback(function ()
			sneedio._ProcessMusicEvent();
		end, 3*1000,
		"sneedio_monitor_music_event");
		
		-- monitor for general routs here...

		BM:repeat_callback(function ()
			sneedio._MonitorRoutingUnits()
		end, 5*1000, --expensive operations
		"sneedio_monitor_player+enemies_rallying_units");

	end
	
end

sneedio._InitBattle = function(units)

	-- for select voice
	for _, unit in ipairs(units) do 
		local UnitVoices = sneedio.GetListOfVoicesFromUnit(unit:type(), "Select");
		local InstancedName = sneedio._UnitTypeToInstancedSelect(unit);
		sneedio._MapUnitToSelected[InstancedName] = false;
		if(UnitVoices ~= nil) then
			sneedio._RegisterVoiceOnBattle(unit, UnitVoices, "Select");
		else
			print("Voice on Select, Warning unit:"..unit:type().." doesn not have associated voices");
		end
	end
	
	-- for affirmative voice
	for _, unit in ipairs(units) do 
		local UnitVoices = sneedio.GetListOfVoicesFromUnit(unit:type(), "Affirmative");
		if(UnitVoices ~= nil) then
			sneedio._RegisterVoiceOnBattle(unit, UnitVoices, "Affirmative");
		else
			print("Voice on Affirmative, Warning unit:"..unit:type().." doesnt have associated voices");
		end
	end
	
	-- for abort voice
	for _, unit in ipairs(units) do 
		local UnitVoices = sneedio.GetListOfVoicesFromUnit(unit:type(), "Abort");
		if(UnitVoices ~= nil) then
			sneedio._RegisterVoiceOnBattle(unit, UnitVoices, "Abort");
		else
			print("Voice on Abort, Warning unit:"..unit:type().." doesnt have associated voices");
		end
	end
	
	-- for abilities voice
	for _, unit in ipairs(units) do 
		local UnitVoices = sneedio.GetListOfVoicesFromUnit(unit:type(), "Abilities");
		if(UnitVoices ~= nil) then
			sneedio._RegisterVoiceOnBattle(unit, UnitVoices, "Abilities");
		else
			print("Voice on Abilities, Warning unit:"..unit:type().." doesnt have associated voices");
		end
	end

	-- for ambiences voices
	for _, unit in ipairs(units) do 
		local UnitVoices = sneedio.GetListOfVoicesFromUnit(unit:type(), "Ambiences");
		if(UnitVoices ~= nil)then
			for ambientType, ambienceVoices in pairs(UnitVoices) do
				if(ambienceVoices) then
					sneedio._RegisterVoiceOnBattle(unit, ambienceVoices, ambientType);
				end
			end
		else
			print("Voice on Ambiences, Warning unit:"..unit:type().." doesnt have associated voices");
		end
	end
	
end

--#endregion init procedures

sneedio._CleanUpAfterBattle = function()
	libSneedio.ClearBattle();
	sneedio._ListOfRegisteredVoicesOnBattle = {
		["null"] = {},
	};
end

---------------------------------------Private variables----------------------------------------------------------

---------------Battle Events--------------------
--#region battle event vars
sneedio._bHasSpeedChanged = false;
sneedio._CurrentSpeed = "Normal";
sneedio._ListOfCallbacksForBattleEvent = {};
sneedio._BattleCurrentTicks = 0;
sneedio._BattlePhaseStatus = "undefined";

-- balance of power
sneedio._CountPlayerUnits = 0;
sneedio._CountEnemyUnits = 0;

sneedio._CountPlayerRoutedUnits = 0;
sneedio._CountEnemyRoutedUnits = 0;

sneedio._CountPlayerRoutedGenerals = 0;
sneedio._CountEnemyRoutedGenerals = 0;

sneedio._bPlayerGeneralDiesOrWounded = false;
sneedio._bEnemyGeneralDiesOrWounded = false;
--#endregion battle event vars

--#region audio vars
sneedio._ListOfRegisteredVoicesOnBattle = {
	["null"] = {},
};

sneedio._MapUnitToSelected = {
	["null"] = false,
};

sneedio._MapUnitInstanceNameToActualUnits = {
	["null"] = nil,
};

sneedio._AmbienceQueues = {};

sneedio._ListOfRegisteredVoices = {
	["null"] = {
		["Select"] = {},
		["Affirmative"] = {},
		["Hostile"] = {},
		["Abilities"] = {},
		["Ambiences"] = {
			["CampaignMap"] = {},
			["Idle"] = {},
			["Attack"] = {},
			["Wavering"] = {},
			["Winning"] = {},
			["Rampage"] = {},
		},		
	},
};

sneedio._ListOfCustomAudio = {};

--#endregion audio vars

--#region music vars
sneedio._CurrentPlayedMusic = {
	FileName = "None",
	MaxDuration = 0,
	CurrentDuration = 0
};
sneedio._Last2PlayedMusic = {};
sneedio._CurrentSituation = "";
sneedio._MusicPlaylist = {
	["faction_none"] = {
		["CampaignMap"] = {
			{
				FileName = "None",
				MaxDuration = 0,
			},
		},
		["Battle"] = {
			["Deployment"] = {
				{
					FileName = "None",
					MaxDuration = 0
				},
			},
			["FirstEngagement"] = {},
			["Balanced"] = {},
			["Losing"] = {},
			["Winning"] = {},
			["LastStand"] = {},
		},
	},
}

--#endregion music vars

print("all ok");

_G.sneedio = sneedio;

--return sneedio;

-- let's register our audio first

sneedio.RegisterVoice("wh2_dlc14_brt_cha_repanse_de_lyonesse_0", {
	["Select"] = {
		"woman_yell_1.ogg", 		
	},
	["Affirmative"] = {
		"woman_yell_2.ogg"
	}
});

sneedio.RegisterVoice("wh2_dlc14_brt_cha_repanse_de_lyonesse_1", {
	["Select"] = {
		"woman_yell_1.ogg", 		
	},
	["Affirmative"] = {
		"woman_yell_2.ogg"
	}
});


sneedio.RegisterVoice("wh2_dlc14_brt_cha_henri_le_massif_0", {
	["Select"] = {
		"man_grunt_1.ogg", 
		"man_grunt_2.ogg",
		"man_grunt_5.ogg",
		"man_grunt_13.ogg",
		"man_grunt_3.ogg",
	},
	["Affirmative"] = {
		"man_grunt_1.ogg", 
		"man_grunt_5.ogg",
		"man_grunt_3.ogg",
	},
	["Ambiences"] = {
		["Idle"] = {
			"man_insult_13.ogg",
			"man_insult_7.ogg",
			"man_insult_3.ogg",
		},
		["Attack"] = {
			"man_yell_11.ogg",
			"man_yell_15.ogg"
		}
	}
});

sneedio.RegisterVoice("wh2_dlc14_brt_cha_henri_le_massif_3", {
	["Select"] = {
		"man_grunt_1.ogg", 
		"man_grunt_2.ogg",
		"man_grunt_5.ogg",
		"man_grunt_13.ogg",
		"man_grunt_3.ogg",
	},
	["Affirmative"] = {
		"man_grunt_1.ogg", 
		"man_grunt_5.ogg",
		"man_grunt_3.ogg",
	},
	["Ambiences"] = {
		["Idle"] = {
			"man_insult_13.ogg",
			"man_insult_7.ogg",
			"man_insult_3.ogg",
		},
		["Attack"] = {
			"man_yell_11.ogg",
			"man_yell_15.ogg"
		}
	}
});

sneedio.AddMusicBattle("wh2_dlc14_brt_chevaliers_de_lyonesse", "Deployment", 
	{
		FileName = "music/deploy/15 Medieval II Total War 3 m 29 s.mp3",
		MaxDuration = 210
	},
	{
		FileName = "music/deploy/23 Medieval II Total War 3 m 01 s.mp3",
		MaxDuration = 182
	},
	{
		FileName = "music/deploy/24 Medieval II Total War (Battle Deployment) 2 m 57s.mp3",
		MaxDuration = 177
	},
	{
		FileName = "music/deploy/30 Medieval II Total War (Battle Deployement) 2m 41s.mp3",
		MaxDuration = 162
	}
);

sneedio.AddMusicBattle("wh2_dlc14_brt_chevaliers_de_lyonesse", "FirstEngagement", 
	{
		FileName = "music/first_engage/35 Medieval II Total War (First Engagement) 3m 41s.mp3",
		MaxDuration = 222
	},
	{
		FileName = "music/first_engage/36 Medieval II Total War (First Engagement) 3m 29s.mp3",
		MaxDuration = 210
	},
	{
		FileName = "music/first_engage/46 Medieval II Total War (First Engagement) 3m 29s.mp3",
		MaxDuration = 210
	},
	{
		FileName = "music/first_engage/54 Medieval II Total War (First Engagement) 4m 27s.mp3",
		MaxDuration = 267
	}
);

sneedio.AddMusicBattle("wh2_dlc14_brt_chevaliers_de_lyonesse", "Balanced",
	{
		FileName = "music/balanced/34 Medieval II Total War (Balanced) 4m 08s.mp3",
		MaxDuration = 248
	},
	{
		FileName = "music/balanced/44 Medieval II Total War (Balanced) 3m 26s.mp3",
		MaxDuration = 206
	},
	{
		FileName = "music/balanced/47 Medieval II Total War (Balanced) 3m 57s.mp3",
		MaxDuration = 237
	}
);

sneedio.AddMusicBattle("wh2_dlc14_brt_chevaliers_de_lyonesse", "Losing",
	{
		FileName = "music/losing/44 Medieval II Total War (losing) 3m 26s.mp3",
		MaxDuration = 207
	}
);

sneedio.AddMusicBattle("wh2_dlc14_brt_chevaliers_de_lyonesse", "Losing",
	{
		FileName = "music/losing/36 Medieval II Total War (winning) 3m 10s.mp3",
		MaxDuration = 190
	}
);

sneedio.Debug();

print(sneedio.GetPlayerFaction());

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
	local ListOfUnits = {};
    ForEachUnitsAll(function(CurrentUnit, CurrentArmy)
		table.insert(ListOfUnits, CurrentUnit);
		local instancedName = sneedio._UnitTypeToInstancedSelect(CurrentUnit);
		sneedio._MapUnitInstanceNameToActualUnits[instancedName] = CurrentUnit;
    end);

	print("ListOfUnits have sneeded!");
	
	var_dump(ListOfUnits);
	sneedio._InitBattle(ListOfUnits)
	var_dump(sneedio);
	
    -- register the callback when unit is selected
    ForEachUnitsPlayer(function(CurrentUnit, CurrentArmy)
        BM:register_unit_selection_callback(CurrentUnit, function(unit)
				local InstancedName = sneedio._UnitTypeToInstancedSelect(unit);
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
	
	print("battle has sneeded!");
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