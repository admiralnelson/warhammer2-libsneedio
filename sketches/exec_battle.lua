local math = math;
local PError = PrintError or nil;
local PWarn = PrintWarning or print;
local real_timer = real_timer;
local core = core;
local find_uicomponent = find_uicomponent;
local v_to_s = v_to_s;
local get_bm = get_bm;
local is_vector = is_vector;
local is_faction = is_faction;
local is_unit = is_unit;
local is_uicomponent = is_uicomponent;
local out = out;
local cm = cm;

-- breaks ForEach loop
local YIELD_BREAK = "_____BREAK_____";

local print = function (x)
	out("chuckio: "..tostring(x));
	print2(tostring(x).."\n");
end;

local PrintError = function (x)
	if(PError) then PError(tostring(x).."\a\a\n"); else print("ERROR "..x); end
	--print("ERROR "..x);
end

local PrintWarning = function (x)
	if(PWarn) then PWarn(tostring(x).."\n"); else print("WARN "..x); end
	--print("WARN "..x);
end



print("location of load");
print(tostring(load));
print(string);
print(string.gsub);
PrintError("test if red text is working");

-- if(StopDebugger) then StopDebugger(); end

local MOUSE_NORMAL = "1";
local MOUSE_NOT_ALLOWED = "3";
local MOUSE_ATTACK = "18";
local MOUSE_MOVE_UNIT = "86";
local MOUSE_MOVE_UNIT_1 = "86";

local MOCK_UP = true;
local PATH = "/script/bin/";
local OUTPUTPATH = "";

-- music tick in ms, executed in timer
local MUSIC_TICK = 900;
-- fadein and out transition tick in ms, executed in timer
local TRANSITION_TICK = 100;
-- system tick in ms, executed in timer
local SYSTEM_TICK = 100;
local BATTLE_EVENT_MONITOR_TICK = 3*1000;
local BATTLE_MORALE_MONITOR_TICK = 5*1000;
-- ambient tick in ms, potentially expensive operation as it iterates units in AMBIENT_TRIGGER_CAMERA_DISTANCE
local AMBIENT_TICK = 5*1000;
local AMBIENT_TRIGGER_CAMERA_DISTANCE = 40;

--#region init stuff soon to be removed into their own libs

local base64 = require("base64");
if(base64) then
	PrintWarning("base64 is working");
end
--local json = require("json") or require("libsneedio_json");
local json = require("libsneedio_json");
if(json)then
	PrintWarning("json has loaded");
end




local function string_(o)
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
            if type(k) ~= 'number' then k = string_(k) end
            s = s .. indent2 .. '[' .. k .. '] = ' .. recurse(v, indent2)
            first = false
        end
        return s .. '\n' .. indent .. '}'
    else
        return string_(o)
    end
end

local function var_dump(...)
    local args = {...}
    if #args > 1 then
        var_dump(args)
    else
        print(recurse(args[1]))
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

local libSneedio =  require(DLL_FILENAMES[1]);-- require2("libsneedio", "luaopen_libsneedio") --require(DLL_FILENAMES[1]);

if(libSneedio) then
	print("lib loaded ok");
else
	PrintError("unable to load libsneedio!");
end

--#endregion init stuff soon to be removed into their own libs

local BM = nil;
if core:is_battle() then
    BM = get_bm();
end

local CM = cm or nil;
local TM = nil;

var_dump(real_timer);

-- timer_manager doesn't work properly in frontend, i have to code myself. thanks to vandy for the hint

TM = {
	_ListOfCallbacks = {},
	_ListOfCallbacksOnce = {},
	_bInited = false,
	OnceCallback = function (callback, delay)
		if(type(callback) ~= "function" ) then
			PrintError("callback is not a function");
			error("callback err");
			-- for type hint
			callback = function ()	end
			return;
		end
		if(type(delay) ~= "number") then
			PrintError("delay is not a number");
			error("number err");
			delay = 0;
			return;
		end
		PrintError("not implemented yet");
		error("FIX ME: TODO NOT IMPLEMENTED");
	end,
	RepeatCallback = function (callback, delay, name)
		if(type(callback) ~= "function") then
			PrintError("callback is not a function");
			-- for type hint
			callback = function ()	end
			return;
		end

		if(type(delay) ~= "number") then
			PrintError("delay is not a number");
			delay = 0;
			return;
		end

		if(type(name) ~= "string") then
			PrintError("name is not a string");
			name = "";
			return;
		end

		TM._ListOfCallbacks[name] = callback;
		real_timer.register_repeating(name, delay);
	end,

	RemoveCallback = function (name)
		if type(name) ~= "string" then return end
		if not TM._ListOfCallbacks[name] then return end

		TM._ListOfCallbacks[name] = nil
		real_timer.unregister(name);

		--type hint
		name = "";
	end,

	Init = function ()
		if(TM._bInited) then return end;
		PrintWarning("starting timer custom timer");
		core:add_listener(
			"sneedio_timer_handler",
			"RealTimeTrigger",
			function(context)
				return TM._ListOfCallbacks[context.string] ~= nil;
			end,
			function(context)
				local callback = TM._ListOfCallbacks[context.string]
				local ok, er = pcall(function() callback() end);
				if not ok then PrintError(er) end;
			end,
		true);
		TM._bInited = true;
	end
};
TM.Init();


if(TM == nil or TM == false)then
	PrintError("time manager is fucking NULL or FALSE");
end

--#region helper functions

local ReadFile = function (file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

-- foreach array or kv map
-- pred = function (value, key)
local ForEach = function (array, pred)
	if(type(array)~="table" or type(pred)~="function")then
		PrintError("invalid params");
		print(debug.traceback());
	end
	for key, value in pairs(array) do
		local res = pred(value, key);
		if(res == YIELD_BREAK) then return; end
	end
end

-- timeout in ms
local DelayedCall = function(pred, timeout)
	if(BM) then
		BM:callback(pred, timeout/1000);
		return;
	end
	if(CM) then
		CM:callback(pred, timeout/1000);
		return;
	end
	TM.OnceCallback(pred, timeout);
end

local Split = function (str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
       return { str };
    end
    if maxNb == nil or maxNb < 1 then
       maxNb = 0;
    end
    local result = {};
    local pat = "(.-)" .. delim .. "()";
    local nb = 0;
    local lastPos;
    for part, pos in string.gfind(str, pat) do
       nb = nb + 1;
       result[nb] = part;
       lastPos = pos;
       if nb == maxNb then
          break;
       end
    end
    -- Handle the last field
    if nb ~= maxNb then
       result[nb + 1] = string.sub(str, lastPos);
    end
    return result;
end

local TrimPrefix = function (s, prefix)
	local t = (s:sub(0, #prefix) == prefix) and s:sub(#prefix+1) or s;
	return t;
end

local StartsWith = function (s, prefix)
	return string.sub(s,1,string.len(prefix))==prefix;
end

local Trim = function (s)
    return s:match'^%s*(.*%S)' or '';
end

local FindEl = function (Parent, ElPath)
	if not is_uicomponent(Parent) then
		ElPath = Parent;
		Parent = core:get_ui_root();
	end

	ElPath = Trim(ElPath);
	local str = string.gsub(ElPath, "%s*root%s*>%s+", "");
	local args = Split(str, ">");
	for k, v in pairs(args) do
		args[k] = Trim(v);
	end
	return find_uicomponent(Parent, unpack(args));
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
	if(type(Min) == "string")then
		Min = tonumber(Min);
	end
	if(type(Max) == "string")then
		Max = tonumber(Max);
	end
	if(type(X) == "string")then
		X = tonumber(X);
	end
	return Max >= X and X >= Min;
end

local CampaignCameraToTargetPos = function (cameraPos, bearing)
	if(type(cameraPos)~="table")then return; end
	return {
		x=cameraPos.x + math.cos(bearing),
		y=cameraPos.y + math.sin(bearing) + 5,
		z=0
	};
end

local CAVectorToSneedVector = function(CAVector)
	--yeah I have to convert them to string, my DLL can't accept number for some reason.
	if(is_vector(CAVector)) then
		return {
			x = tostring(CAVector:get_x()),
			y = tostring(CAVector:get_y()),
			z = tostring(CAVector:get_z())
		};
	elseif(type(CAVector) == "table")then
		return {
			x = tostring(CAVector.x),
			y = tostring(CAVector.y),
			z = tostring(CAVector.z)
		}
	end
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
				local res = FunctionToProcess(CurrentUnit, CurrentArmy);
				if(res == YIELD_BREAK) then return; end
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
					local res = FunctionToProcess(CurrentUnit, CurrentArmy);
					if(res == YIELD_BREAK) then return; end
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
				local res = FunctionToProcess(CurrentUnit, CurrentArmy);
				if(res == YIELD_BREAK) then return; end
			end;
		end;
	end;
end

local CharacterPositionInCampaign = function (characterScriptInterfaceObject)
	return {
		x = characterScriptInterfaceObject:display_position_x(),
		y = characterScriptInterfaceObject:display_position_y(),
		z = 0
	};
end


--#endregion helper functions

-- FIX ME, there must be better way....
sneedio.MuteGameEngineMusic = function (bMute)
	if(BM) then
		if(bMute) then
			BM:set_volume(0, 0);
		else
			BM:set_volume(0, 100);
		end
		return;
	end

	-- manipulate the memory first.
	if(bMute) then
		libSneedio.SetWarscapeMusicVolume(0);
	else
		libSneedio.SetWarscapeMusicVolume(100);
	end

	-- then apply the changes through SimulateLClick hacks
	if(CM) then
		-- through esc menu in the campaign
		local root = core:get_ui_root();
		root:TriggerShortcut("escape_menu");
		local ButtonOptions = FindEl(root, "root > esc_menu_campaign > menu_1 > button_options");
		if(ButtonOptions)then
			ButtonOptions:SimulateLClick();
			local ButtonAudio = FindEl(root, "root > options_main > menu_options > button_audio");
			if(ButtonAudio)then
				ButtonAudio:SimulateLClick();
				local ButtonCancel = FindEl(root, "root > options_audio > basic_options > ok_cancel_buttongroup > button_cancel");
				if(ButtonCancel)then
					ButtonCancel:SimulateLClick();
					print("mute ok");
					local ButtonBack = FindEl(root, "root > options_main > menu_options > button_back");
					ButtonBack:SimulateLClick();
					local Resume = FindEl(root, "root > esc_menu_campaign > menu_1 > button_resume");
					Resume:SimulateLClick();
				else
					PrintError("mute fail");
				end
			else
				PrintError("fail to access audio button");
			end
		else
			PrintError("fail to access options button");
		end
		return;
	else
		-- through frontend menu
		local root = core:get_ui_root();
		-- local ButtonOptions = FindEl(root, "root > main > banner_clip > fe_banner > menu > options_frame > holder > button_header_options");
		local ButtonOptions = find_uicomponent(root, "main", "banner_clip", "fe_banner", "menu", "options_frame", "holder", " button_audio");
		if(ButtonOptions) then
			ButtonOptions:SimulateLClick();
			local ButtonCancel = FindEl(root, "root > options_audio > basic_options > ok_cancel_buttongroup > button_cancel");
			if(ButtonCancel)then
				ButtonCancel:SimulateLClick();
				print("mute ok");
			else
				print("mute fail in frontend");
			end
		else
			PrintError("unable to find button audio in frontend");
		end
	end
end

sneedio.IsPaused = function()
	return sneedio._bPaused;
end

sneedio.Pause = function (bPause)
	sneedio._bPaused = bPause;
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

sneedio.AddMusicCampaign = function (factionId, ...)
	if(sneedio._MusicPlaylist[factionId] == nil) then
		return;
	end
	if(sneedio._MusicPlaylist[factionId]["CampaignMap"]) then
		sneedio._MusicPlaylist[factionId]["CampaignMap"] = {};
	end
	local fileNamesArr = {...};
	ForEach(fileNamesArr, function (filename)
		table.insert(sneedio._MusicPlaylist[factionId]["CampaignMap"], filename);
	end);
end

sneedio.AddMusicBattle = function (factionId, Situation, ...)
	if(not sneedio._bAllowModToAddMusic) then
		PrintWarning("AddMusicBattle: sneedio._bAllowModToAddMusic was set to false. Mod music is not allowed");
		return;
	end
	local fileNamesArr = {...};
	if(Situation == nil or Situation == "") then
		PrintError("AddMusicBattle: Situation was empty!");
		return;
	end

	ForEach(fileNamesArr, function (filename)
		if(not HasKey(filename, "FileName") or
		   not HasKey(filename, "MaxDuration") ) then
			PrintError("AddMusicBattle: this element doesn't have FileName or/and MaxDuration param");
			var_dump(filename);
			return YIELD_BREAK;
		end

		if(not sneedio._MusicPlaylist[factionId]) then
			sneedio._MusicPlaylist[factionId] = {};
		end
		if(not sneedio._MusicPlaylist[factionId]["Battle"]) then
			sneedio._MusicPlaylist[factionId]["Battle"] = {};
		end
		if(not sneedio._MusicPlaylist[factionId]["Battle"][Situation]) then
			sneedio._MusicPlaylist[factionId]["Battle"][Situation] = {};
		end

		local fileName = filename;
		fileName.CurrentDuration = 0;
		table.insert(sneedio._MusicPlaylist[factionId]["Battle"][Situation], fileName);
		print("added music for faction "..factionId..
			  " situation "..Situation.." filename "..
			  fileName.FileName.." max duration "..
			  tostring(fileName.MaxDuration));
	end);
end

-- loaded in battle only
--#region battle procedures only

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

--#endregion battle procedures only

sneedio.IsCurrentMusicHalfWaythrough = function ()
	local MaxDur = sneedio._CurrentPlayedMusic.MaxDuration;
	if(MaxDur <= 0) then return true; end
	return (sneedio._CurrentPlayedMusic.CurrentDuration / MaxDur) >= 0.5;
end

sneedio.IsCurrentMusicQuarterWaythrough = function ()
	local MaxDur = sneedio._CurrentPlayedMusic.MaxDuration;
	if(MaxDur <= 0) then return true; end
	return (sneedio._CurrentPlayedMusic.CurrentDuration / MaxDur) >= 0.25;
end


sneedio.IsCurrentMusicFinished = function ()
	local MaxDur = sneedio._CurrentPlayedMusic.MaxDuration;
	if(MaxDur <= 0) then return true; end
	return sneedio._CurrentPlayedMusic.CurrentDuration >= MaxDur;
end

sneedio.GetPlayerFactionPlaylistForCampaign = function ()
	if(CM == nil)then return; end
	local factionKey = sneedio.GetPlayerFaction();
	if(sneedio._MusicPlaylist[factionKey] == nil)then
		PrintWarning("faction "..factionKey.." has no playlist registered");
		return;
	end
	if(sneedio._MusicPlaylist[factionKey]["CampaignMap"] == nil)then
		PrintWarning("faction "..factionKey.." has no campaign map music playlist");
		return;
	end
	return sneedio._MusicPlaylist[factionKey]["CampaignMap"];
end

sneedio.GetPlayerFactionPlaylistForBattle = function (Situation)
	if(Situation == nil) then
		PrintError("situation was null!");
		return;
	end
	local availableSituations = {"Deployment", "Complete", "Balanced", "FirstEngagement", "Losing", "Winning", "LastStand"};
	if(not InArray(availableSituations, Situation))then
		PrintError("invalid Situation. Situation are {'Deployment', 'Complete', 'FirstEngagement', 'Losing', 'Winning', 'LastStand'} yours was "..Situation);
		return;
	end
	local factionKey = sneedio.GetPlayerFaction();
	if (sneedio._MusicPlaylist[factionKey] == nil) then
		PrintError(factionKey.." has no music playlist registered at all");
		return;
	end
	if(sneedio._MusicPlaylist[factionKey]["Battle"] == nil)then
		PrintError(factionKey.." has no music playlist battle to play with");
		return;
	end
	if(sneedio._MusicPlaylist[factionKey]["Battle"][Situation] == nil)then
		PrintWarning(factionKey.." has no music playlist battle for Situation "..Situation);
		return;
	end
	return sneedio._MusicPlaylist[factionKey]["Battle"][Situation];
end

sneedio.GetPlayerFaction = function ()
	if(BM) then
		return BM:get_player_army():faction_key();
	elseif(CM) then
		return CM:get_local_faction_name(true); -- warning
	else
		print("called outside battle or campaign");
	end
end

sneedio.GetBattleSituation = function ()
	if(BM == nil)then return; end
	return sneedio._CurrentSituation;
end

sneedio.GetNextMusicData = function ()
	local Playlist = {};
	if(BM) then
		Playlist = sneedio.GetPlayerFactionPlaylistForBattle(sneedio.GetBattleSituation());
	elseif(CM)then
		Playlist = sneedio.GetPlayerFactionPlaylistForCampaign();
	else
		return sneedio._FrontEndMusic;
	end
	--print("battle play list");
	local rand = math.random(#Playlist);
	local result = Playlist[rand];
	while (result.FileName == sneedio._CurrentPlayedMusic.FileName and #Playlist > 1) do
		rand = math.random(#Playlist);
		result = Playlist[rand];
	end
	return result;
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
		PrintError("failed to load Custom audio .."..identifier.." filename path: "..fileName.." maybe file doesn't exist or wrong path");
	end
end

sneedio.IsIdentifierValid = function(identifier)
	return sneedio._ListOfCustomAudio[identifier] ~= nil;
end

sneedio.PlayCustomAudio2D = function (identifier , volume)
	local pos = nil;
	if(BM)then
		pos = BM:camera():position();
	elseif(CM) then
		local x,y, distance, bearing, height = CM:get_camera_position();
		pos = {x =x, y=y, z=height};
	end
	if(pos)then
		sneedio.PlayCustomAudio(identifier, pos, 600, volume, pos);
	end
end

sneedio.PlayCustomAudioCampaign = function (identifier, atPosition, maxDistance, volume)
	if(not CM) then
		PrintError("error not in campaign mode");
		return;
	end

	local x, y, distance, bearing, h = CM:get_camera_position();
	local cameraPos = {x=x,y=y,z=h};
	local target = CampaignCameraToTargetPos(cameraPos, bearing);
	libSneedio.PlayVoiceBattle(identifier, tostring(1), CAVectorToSneedVector(atPosition), tostring(maxDistance), tostring(volume));
	sneedio.UpdateCameraPosition(cameraPos, target);
end

sneedio.PlayCustomAudioBattle = function(identifier, atPosition, maxDistance, volume, listener)
	if(not BM) then
		PrintError("not in battle mode");
		return;
	end
	local defaultPosition = BM:camera():position();
	listener = listener or defaultPosition;
	maxDistance = maxDistance or 400;
	volume = volume or 1;
	atPosition = atPosition or defaultPosition;
	if(not is_vector(atPosition))then
		PrintError("atPosition param is not a vector");
		return;
	end
	if(not is_vector(listener)) then
		PrintError("listener param is not a vector");
		return;
	end
	if(type(maxDistance) ~= "number")then
		PrintError("maxDistance param is not a number");
		return;
	end
	if(type(volume) ~= "number")then
		PrintError("volume param is not a number");
		return;
	end
	if(not sneedio.IsIdentifierValid(identifier)) then
		PrintError("identifier is not valid");
		return;
	end
	local res = libSneedio.PlayVoiceBattle(identifier, tostring(1), CAVectorToSneedVector(atPosition), tostring(maxDistance), tostring(volume));
	if(res == 0)then
		print("audio played "..identifier);
	end

	local lookat = BM:camera():target();
	libSneedio.UpdateListenerPosition(CAVectorToSneedVector(listener), CAVectorToSneedVector(lookat));
end

sneedio.RegisterVoice = function(unittype, fileNames)
	sneedio._ListOfRegisteredVoices[unittype] = fileNames;
end

sneedio.GetListOfVoicesFromUnit = function(unitType, voiceType)
	if(sneedio._ListOfRegisteredVoices[unitType] == nil) then return nil; end
	if(sneedio._ListOfRegisteredVoices[unitType][voiceType] == nil) then return nil; end
	return sneedio._ListOfRegisteredVoices[unitType][voiceType];
end

--#endregion audio/voices operations

--#region battle helper
sneedio.GetPlayerGeneralOnBattle = function ()
	if(BM and sneedio._PlayerGeneral == nil)then
		local general = nil;
		ForEachUnitsPlayer(function (Unit, Armies)
			if(Unit:is_commanding_unit()) then
				general = Unit;
				return YIELD_BREAK;
			end
		end);
		sneedio._PlayerGeneral = general;
		return general;
	elseif (BM) then
		return sneedio._PlayerGeneral;
	end
end

sneedio.RegisterCallbackSpeedEventOnBattle = function(UniqueName, EventName, Callback)
	PrintWarning("RegisterCallbackSpeedEventOnBattle: registered event "..
	             UniqueName.." for event "..EventName);
	if (sneedio._ListOfCallbacksForBattleEvent[UniqueName] == nil) then
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
	if (BM == nil) then return false; end
	local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
	if(parent)then
		local button = find_uicomponent(parent, "pause");
		-- var_dump(uic_pause:CurrentState());
		return button:CurrentState() == "selected";
	end
end

sneedio.IsBattleInSlowMo = function()
	if (BM == nil) then return false; end
	local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
	if(parent)then
		local button = find_uicomponent(parent, "slow_mo");
		-- var_dump(uic_pause:CurrentState());
		return button:CurrentState() == "selected";
	end
end

sneedio.IsBattleInNormalPlay = function()
	if (BM == nil) then return false; end
	local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
	if(parent)then
		local button = find_uicomponent(parent, "play");
		-- var_dump(uic_pause:CurrentState());
		return button:CurrentState() == "selected";
	end
end

sneedio.IsBattleInFastForward = function()
	if (BM == nil) then return false; end
	local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
	if(parent) then
		local buttonFWD = find_uicomponent(parent, "fwd");
		local buttonFFWD = find_uicomponent(parent, "ffwd");
		return buttonFWD:CurrentState() == "selected" or buttonFFWD:CurrentState() == "selected";
	end
end

sneedio.GetBattleSpeedMode = function()
	if(BM == nil) then return "None"; end
	if(sneedio.IsBattlePaused()) then return "Paused"; end
	if(sneedio.IsBattleInSlowMo()) then return "SlowMo"; end
	if(sneedio.IsBattleInNormalPlay()) then return "Normal"; end
	if(sneedio.IsBattleInFastForward()) then return "FastForward"; end
	return "None";
end

sneedio.GetBattleTicks = function()
	return sneedio._BattleCurrentTicks;
end

sneedio.SetMusicVolume = function (amount)
	libSneedio.SetMusicVolume(tostring(amount));
end


--#endregion battle helper
---------------------------------PRIVATE methods----------------------------------

sneedio._LoadUserConfig = function ()
	local userConfigJson = ReadFile("user-sneedio.json");
	if(not userConfigJson) then
		PrintWarning("user-sneedio.json doesn't exist. Not loading user config.");
		return;
	end

	local result, userConfig = pcall(json.decode, userConfigJson);
	if(not result) then
		PrintError("Fail to parse config file. Not loading user config.");
		return;
	end

	var_dump(userConfig);
	sneedio._FrontEndMusic = userConfig["FrontEndMusic"];
	sneedio._bAllowModToAddMusic = userConfig["OverrideAllModMusic"] or false;
	local BatteMusic = userConfig["BattleMusic"];
	local CampaignMusic = userConfig["FactionMusic"];

	ForEach(CampaignMusic, function (campaignMusicArr, faction)
		sneedio._MusicPlaylist[faction] = {};
		sneedio._MusicPlaylist[faction]["CampaignMap"] = {};
		ForEach(campaignMusicArr, function (m)
			m.CurrentDuration = 0;
			table.insert(sneedio._MusicPlaylist[faction]["CampaignMap"], m);
		end);
	end);

	ForEach(BatteMusic, function (battleMusicTypes, faction)
		print("_LoadUserConfig: processing "..faction);
		sneedio._MusicPlaylist[faction] = {};
		sneedio._MusicPlaylist[faction]["Battle"] = {};
		ForEach(battleMusicTypes, function (music, type)
			if(sneedio._MusicPlaylist[faction]["Battle"][type] == nil) then
				sneedio._MusicPlaylist[faction]["Battle"][type] = {};
			end
			ForEach(music, function (m)
				local mus = m;
				mus.CurrentDuration = 0;
				table.insert(sneedio._MusicPlaylist[faction]["Battle"][type], mus);
			end);
		end);
	end);

	if(userConfig["AlwaysMuteWarscapeMusic"]) then libSneedio.AlwaysMuteWarscapeMusic(); end
	print("audio loaded");
end

--#region frontend procedures

sneedio._InitFrontEnd = function ()
	sneedio._LoadUserConfig();

	if(TM == nil) then
		PrintError("current game is not frontend, operation failed");
		return;
	end

	sneedio._bNotInFrontEnd = false;

	if(sneedio._FrontEndMusic.FileName ~= nil or sneedio._FrontEndMusic.FileName ~= "") then
		PrintWarning("user frontend music exist, muting frontend music");
		sneedio.MuteGameEngineMusic(true);
		sneedio._FrontEndMusic.CurrentDuration = 0;
	end

	TM.RepeatCallback(function ()
		sneedio._MusicTimeTracker();
		sneedio._ProcessMusicState();
	end, MUSIC_TICK, "sneedio_music_tracker_frontend");

	TM.RepeatCallback(function ()
		sneedio._ProcessSmoothMusicTransition();
	end, TRANSITION_TICK, "sneedio_process_music_transition");
end

--#endregion frontend procedures

--#region campaign procedures

sneedio._CharTypeToSelect = function (charKey)
	return charKey.."_Select";
end

sneedio._CharTypeToAffirmative = function (charKey)
	return charKey.."_Affirmative";
end

sneedio._CharTypeToHostile = function (charKey)
	return charKey.."_Hostile";
end

sneedio._CharTypeToAbilities = function (charKey)
	return charKey.."_Abilities";
end

sneedio._CharDialogToDiplomacy = function (dialog, leaderId)
	return dialog.."_Dialog_"..leaderId;
end

sneedio._InitCampaign = function ()
	if(CM == nil) then return false; end

	sneedio._LoadUserConfig();
	sneedio._ValidateMusicData();

	core:add_listener(
		"sneedio_on_unit_select_campaign",
		"CharacterSelected",
		true,
		function (context)
			sneedio._SelectedCharacterOnCampaign = context:character();

			var_dump(context:character());
			sneedio._ProcessSomeCampaignEventIDK();
			sneedio._ProcessCharacterSelectedCampaign(context:character());
		end,
	true);

	core:add_listener(
		"sneedio_on_unit_deselcted_campaign",
		"CharacterDeselected",
		true,
		function(context)
			sneedio._SelectedCharacterOnCampaign = nil;
		end,
	true);

	core:add_listener(
		"sneedio_diplomacy_panel_onclick",
		"ComponentLClickUp",
		function (context)
			local name = context.string;
			return StartsWith(name, "faction_row_entry_");
		end,
		function (context)
			local factionId = TrimPrefix(context.string, "faction_row_entry_")
			print("faction selected "..factionId);
			sneedio._ProcessDiplomacyOnClickAtFactionItemCampaign(factionId);
		end,
	true);

	core:add_listener(
		"sneedio_check_if_diplomatic_panel_displayed",
		"PanelOpenedCampaign",
		function (context)
			return context.string == "diplomacy_dropdown";
		end,
		function (context)
			print("diplomacy is open");
		end,
	true);

	core:add_listener(
		"sneedio_check_if_game_menu_displayed",
		"PanelOpenedCampaign",
		function (context)
			return context.string == "esc_menu_campaign";
		end,
		function (context)
			print("pause the music");
			sneedio.Pause(true);
			sneedio.MuteSoundFX(true);
		end,
	true);

	core:add_listener(
		"sneedio_check_if_game_menu_closed",
		"PanelClosedCampaign",
		function (context)
			return context.string == "esc_menu_campaign";
		end,
		function (context)
			print("unpause the music");
			sneedio.Pause(false);
			sneedio.MuteSoundFX(false);
		end,
	true);

	core:add_listener(
		"sneedio_check_if_battle_prompt_displayed",
		"ScriptEventPreBattlePanelOpened",
		true,
		function ()
			print("battle prompt displayed");
			print("play attack campaign music here");
		end,
	true);

	core:add_listener(
		"sneedio_check_if_battle_prompt_is_closed",
		"ScriptEventPreBattlePanelOpened",
		true,
		function ()
			print("battle prompt cloosed");
			print("stop attack campaign music here");
		end,
	true);

	core:add_listener(
		"sneedio_check_for_char_movement",
		"ScriptEventPlayerCharacterFinishedMovingEvent",
		function (context)
			var_dump(context);
			return true
		end,
		function (context)
			print("character moved");
		end,
	true);

	core:add_listener(
		"sneedio_check_for_diplomacy",
		"DiplomacyNegotiationStarted",
		true,
		function ()
			print("diplomacy initated");
			DelayedCall(function ()
				print("callback after diplomacy initiated");
				local TextBoxDiplomacyRight = FindEl(core:get_ui_root(), "root > diplomacy_dropdown > faction_right_status_panel > speech_bubble > dy_text");
				if(TextBoxDiplomacyRight) then
					local Text, Code = TextBoxDiplomacyRight:GetStateText();
					sneedio._CurrentDiplomacyStringRightSide = Text;
				end

				local TextBoxDiplomacyLeft = FindEl(core:get_ui_root(), "root > diplomacy_dropdown > faction_left_status_panel > speech_bubble > dy_text");
				if(TextBoxDiplomacyLeft) then
					local Text, Code = TextBoxDiplomacyLeft:GetStateText();
					sneedio._CurrentDiplomacyStringLeftSide = Text;
				end
				sneedio._ProcessDiplomacyOnEngagementCampaign();
			end, 500);
		end,
	true);

	TM.RepeatCallback(function ()
		sneedio._MusicTimeTracker();
		sneedio._ProcessMusicState();
	end, MUSIC_TICK, "sneedio_music_tracker");

	TM.RepeatCallback(function ()
		sneedio._ProcessSmoothMusicTransition();
		sneedio._UpdateCamera();
	end, TRANSITION_TICK, "sneedio_smooth_music_transition");

	TM.RepeatCallback(function ()
		sneedio._MonitorRightClickEvent();
	end, SYSTEM_TICK, "sneedio_monitor_right_click");

	sneedio._RegisterAllCharactersVoiceCampaign();
end

sneedio._GetCameraPositionCampaign = function ()
	local x,y,distance, bearing, height = CM:get_camera_position();
	return {x=x,y=y,z=height};
end

sneedio._ProcessMusicState = function ()
	if(sneedio.IsCurrentMusicFinished()) then
		sneedio._PlayMusic(sneedio.GetNextMusicData());
	end
end

--just for test, will be removed
sneedio._ProcessSomeCampaignEventIDK = function ()
	local x,y,distance, bearing, height = CM:get_camera_position();
	print("current position");
	var_dump({x=x,y=y,z=height});
	var_dump(CampaignCameraToTargetPos({x=x,y=y,z=0}, bearing));
end

sneedio._ProcessWhen3BattleOptionIsHovered = function (whichButton)
	print("general on player faction side ");
	print("button was hovered "..whichButton);
end

sneedio._ProcessCharacterSelectedCampaign = function (characterObject)
	print("campaign :"..characterObject:character_type_key());
	print(characterObject:character_subtype_key());
	print("pos");
	var_dump(CharacterPositionInCampaign(characterObject));
	local playerFaction = CM:get_local_faction(true); -- warning;
	local selectedCharFaction = characterObject:faction();
	local charKey = characterObject:character_subtype_key();
	local handle = "";
	var_dump(playerFaction:name());
	var_dump(selectedCharFaction:name());
	var_dump(playerFaction:name() == selectedCharFaction:name());
	if(playerFaction:name() == selectedCharFaction:name()) then
		handle = sneedio._CharTypeToSelect(charKey);
		sneedio._PlayVoiceCharacterOnCampaign(handle);
	else
		local bIsAtWar = selectedCharFaction:at_war_with(playerFaction);
		if(bIsAtWar)then
			handle = sneedio._CharTypeToSelect(charKey);
			sneedio._PlayVoiceCharacterOnCampaign(handle);
		else
			handle = sneedio._CharTypeToHostile(charKey);
			sneedio._PlayVoiceCharacterOnCampaign(handle);
		end
	end
end

sneedio._ProcessDiplomacyOnClickAtFactionItemCampaign = function (factionId)
	local faction = CM:get_faction(factionId);
	local leader = faction:faction_leader();
	local charLeaderId = leader:character_subtype_key();
	print("faction "..factionId.." charLeaderId "..charLeaderId);
	local handle = sneedio._CharTypeToSelect(charLeaderId);
	sneedio._PlayVoiceCharacterOnCampaign(handle);
	sneedio._CurrentDiplomacySelectedFaction = faction;
end

sneedio._ProcessDiplomacyOnEngagementCampaign = function ()
	local stringLeftSide = sneedio._CurrentDiplomacyStringLeftSide;
	local stringRightSide = sneedio._CurrentDiplomacyStringRightSide;

	if(stringRightSide ~= "") then -- player requesting diplomacy
		print("local player request diplo");
		print("bubble on the right side "..stringRightSide);
		if(is_faction(sneedio._CurrentDiplomacySelectedFaction))then
			local targetFaction = sneedio._CurrentDiplomacySelectedFaction;
			local leader = targetFaction:faction_leader();
			local leaderId = leader:character_subtype_key();
			local stringToDiploKey = sneedio._CharDialogToDiplomacy(stringRightSide, leaderId);
			sneedio._PlayVoiceCharacterOnCampaign(stringToDiploKey, leaderId);
		end
	elseif(stringLeftSide ~= "") then -- player got diplomacy request from bot or other player
		print("local player got request diplo from ai/player");
		print("bubble on the left side "..stringLeftSide);
		local playerLeaderChar = CM:get_local_faction(true):faction_leader(); -- warning
		local playerLeaderId = playerLeaderChar:character_subtype_key();
		local stringToDiploKey = sneedio._CharDialogToDiplomacy(stringLeftSide, playerLeaderId);
		sneedio._PlayVoiceCharacterOnCampaign(stringToDiploKey, playerLeaderId);
	end

	-- clear left and right diplomatic bubble text left and right
	sneedio._CurrentDiplomacyStringRightSide = "";
	sneedio._CurrentDiplomacyStringLeftSide = "";
end

sneedio._RegisterAllCharactersVoiceCampaign = function ()
	ForEach(sneedio._ListOfRegisteredVoices, function (value, key)
		print("RegisterAllCharactersVoiceCampaign: registering "..key);
		sneedio._RegisterCharacterVoiceCampaign(key);
	end);
end

sneedio._RegisterCharacterVoiceCampaign = function (characterKey)
	local voices = sneedio._ListOfRegisteredVoices[characterKey];
	if(voices == nil) then
		print("no campaign voice registered for this characterKey "..characterKey);
		return;
	end
	if(voices["Select"])then
		ForEach(voices["Select"], function (subvoice)
			local charType = sneedio._CharTypeToSelect(characterKey);
			if(libSneedio.LoadVoiceBattle(subvoice, charType)) then
				print(characterKey..": registered Select voice "..subvoice);
				if(sneedio._MapCharTypeToAudioFile[charType] == nil) then
					sneedio._MapCharTypeToAudioFile[charType] = {};
				end
				table.insert(sneedio._MapCharTypeToAudioFile[charType], subvoice);
			else
				PrintError("failed to register "..
				      characterKey.." Select voice "..
					  subvoice.." maybe path was wrong or invalid file?");
			end
		end);
	end
	if(voices["Affirmative"])then
		ForEach(voices["Affirmative"], function (subvoice)
			local charType = sneedio._CharTypeToAffirmative(characterKey);
			if(libSneedio.LoadVoiceBattle(subvoice, charType)) then
				print(characterKey..": registered Affirmative voice "..subvoice);
				if(sneedio._MapCharTypeToAudioFile[charType] == nil) then
					sneedio._MapCharTypeToAudioFile[charType] = {};
				end
				table.insert(sneedio._MapCharTypeToAudioFile[charType], subvoice);
			else
				PrintError("failed to register "..
				      characterKey.." Affirmative voice "..
					  subvoice.." maybe path was wrong or invalid file?");
			end
		end);
	end
	if(voices["Hostile"])then
		ForEach(voices["Hostile"], function (subvoice)
			local charType = sneedio._CharTypeToHostile(characterKey);
			if(libSneedio.LoadVoiceBattle(subvoice, charType)) then
				print(characterKey..": registered Hostile voice "..subvoice);
				if(sneedio._MapCharTypeToAudioFile[charType] == nil) then
					sneedio._MapCharTypeToAudioFile[charType] = {};
				end
				table.insert(sneedio._MapCharTypeToAudioFile[charType], subvoice);
			else
				PrintError("failed to register "..
				            characterKey.." Hostile voice "..
							subvoice.." maybe path was wrong or invalid file?");
			end
		end);
	end
	if(voices["Abilities"])then
		ForEach(voices["Abilities"], function (subvoice)
			local charType = sneedio._CharTypeToAbilities(characterKey);
			if(libSneedio.LoadVoiceBattle(subvoice, charType)) then
				print(characterKey..": registered Abilities voice "..subvoice);
				if(sneedio._MapCharTypeToAudioFile[charType] == nil) then
					sneedio._MapCharTypeToAudioFile[charType] = {};
				end
				table.insert(sneedio._MapCharTypeToAudioFile[charType], subvoice);
			else
				PrintError("failed to register "..
				      characterKey.." Abilities voice "..
					  subvoice.." maybe path was wrong or invalid file?");
			end
		end);
	end
	if(voices["Diplomacy"])then
		ForEach(voices["Diplomacy"], function (subvoice, dialogKey)
			local charDialogCode = sneedio._CharDialogToDiplomacy(dialogKey, characterKey);
			if(libSneedio.LoadVoiceBattle(subvoice, charDialogCode)) then
				print(characterKey..": registered Dialog voice "..subvoice);
				if(sneedio._MapCharTypeToAudioFile[charDialogCode] == nil) then
					sneedio._MapCharTypeToAudioFile[charDialogCode] = {};
				end
				table.insert(sneedio._MapCharTypeToAudioFile[charDialogCode], subvoice);
			else
				PrintError("failed to register "..
				            characterKey.." Dialog voice "..
							subvoice.." maybe path was wrong or invalid file?");
			end
		end);
	end
end


sneedio._PlayVoiceCharacterOnCampaign = function(unitHandle, playAtPos)
	playAtPos = playAtPos or sneedio._GetCameraPositionCampaign();
	local MaxDistance = 390;
	local Volume = 0.8;
	if(sneedio._MapCharTypeToAudioFile[unitHandle])then
		local ListOfAudio = sneedio._MapCharTypeToAudioFile[unitHandle];
		local PickRandom = math.random(#ListOfAudio);
		print("playing voice: ".. ListOfAudio[PickRandom]);
		local result = libSneedio.PlayVoiceBattle(unitHandle, tostring(PickRandom), CAVectorToSneedVector(playAtPos), tostring(MaxDistance), tostring(Volume));
		var_dump(result);
		if(result == 0) then
			print("audio played");
		end
	else
		print("no audio found for "..unitHandle)
	end
end

sneedio._OnRightClickEventWithCharacter = function()
	print("right click was released");
	if(sneedio._SelectedCharacterOnCampaign == nil)then
		return;
	end
	local playerFaction = CM:get_local_faction(true); -- warning;
	local bIsSelectedCharOwnedByPlayer = sneedio._SelectedCharacterOnCampaign:faction():name() == playerFaction:name();
	if(not bIsSelectedCharOwnedByPlayer) then
		return; -- don't play audio on rightclick if char is not owned by player!
	end

	local characterKey = sneedio._SelectedCharacterOnCampaign:character_subtype_key();
	if(libSneedio.GetCursorType() == MOUSE_NOT_ALLOWED) then
		print("character key "..characterKey.."says no (hostile)");
		characterKey = sneedio._CharTypeToHostile(characterKey);
		sneedio._PlayVoiceCharacterOnCampaign(characterKey);
	elseif(libSneedio.GetCursorType() == MOUSE_ATTACK) then
		print("character key "..characterKey.." says attack (abilities)");
		characterKey = sneedio._CharTypeToAbilities(characterKey);
		sneedio._PlayVoiceCharacterOnCampaign(characterKey);
		print("maybe play medieval 2 attack audio here (2D)");
	else
		print("character key "..characterKey.." says move (affirmative)");
		characterKey = sneedio._CharTypeToAffirmative(characterKey);
		sneedio._PlayVoiceCharacterOnCampaign(characterKey);
		print("cursor type "..libSneedio.GetCursorType());
	end
end

sneedio._MonitorRightClickEvent = function()
	if(libSneedio.WasRightClickHeld())then
		sneedio._RightClickHeldMs = sneedio._RightClickHeldMs + 100;
	else
		if(sneedio._RightClickHeldMs >= 100)then
			sneedio._RightClickHeldMs = 0;
			if(CM) then
				sneedio._OnRightClickEventWithCharacter();
			end
		end
	end
end

sneedio._RightClickHeldMs = 0;

sneedio._CurrentDiplomacySelectedFaction = nil;

sneedio._CurrentDiplomacyStringRightSide = "";

sneedio._CurrentDiplomacyStringLeftSide = "";

sneedio._MapCharTypeToAudioFile = {};

--#endregion campaign procedures

--#region only exists in battle
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

	local General = sneedio.GetPlayerGeneralOnBattle();

	-- check player general state
	if(General:is_valid_target())then
		if(General:is_routing() or General:is_wavering() or General:is_shattered())then
			sneedio._CurrentSituation = "Losing";
			sneedio._ProcessMusicPhaseChangesBattle();
		end
	end

	sneedio._CountPlayerUnits = TotalPlayerUnits;
	--print("sneedio._CountPlayerUnits "..tostring(sneedio._CountPlayerUnits));
	sneedio._CountPlayerRoutedUnits = PlayerRouting;
	--print("sneedio._CountPlayerRoutedUnits"..tostring(sneedio._CountPlayerRoutedUnits))
end
--#endregion only exists in battle

--------------------------------Music methods------------------------------------

sneedio._FadeToMuteMusic = function (bMute)
	if(bMute)then
		sneedio._bFlagMute = true;
		sneedio._TransitionMusicFlag = 1;
	else
		sneedio._bFlagMute = false;
		sneedio._TransitionMusicFlag = 2;
	end
end

sneedio._ProcessSmoothMusicTransition = function ()

	if(sneedio.IsBattlePaused()) then return; end

	if(sneedio._TransitionMusicFlag == 0) then -- no need to process any transition if flag is not set
		return;
	end

	-- just mute the music
	if(sneedio._CurrentMusicVolume <= 0 and sneedio._bFlagMute) then
		sneedio._TransitionMusicFlag = 0;
		return;
	end

	-- transition to mute
	if(sneedio._CurrentMusicVolume <= 0) then
		print("current _CurrentMusicVolume is 0, set flag = 2");
		sneedio._TransitionMusicFlag = 2;

		local musicData = table.remove(sneedio._TransitionMusicQueue, 1);
		if(not musicData) then
			print("unknown music data");
			return;
		end
		if( libSneedio.PlayMusic(musicData.FileName)) then
			print("music played...");
			if(BM) then
				BM:set_volume(0, 0);
			end
		else
			print("failed to play music: "..musicData.FileName);
			if(BM) then
				print("fallback to warscape music");
				BM:set_volume(0, 100);
			end
		end
	end
	-- transition complete
	if(sneedio._TransitionMusicFlag == 2 and sneedio._CurrentMusicVolume  >= sneedio._MaximumMusicVolume) then
		print("flag 2, now it is not muted and play audio");
		sneedio._TransitionMusicFlag = 0;
		print("set flag to 0");
	end
	-- unmute it
	if(sneedio._TransitionMusicFlag == 2 and sneedio._CurrentMusicVolume <= sneedio._MaximumMusicVolume) then
		print("processing flag = 2 until not mute");
		sneedio._CurrentMusicVolume = sneedio._CurrentMusicVolume + 0.05;
		sneedio.SetMusicVolume(sneedio._CurrentMusicVolume);
	end
	-- mute it
	if(sneedio._TransitionMusicFlag == 1) then
		print("processing flag = 1 until equal to mute");
		sneedio._CurrentMusicVolume = sneedio._CurrentMusicVolume - 0.05;
		sneedio.SetMusicVolume(sneedio._CurrentMusicVolume);
	end
end

sneedio._PlayMusic = function (musicData)
	if(not musicData)then
		print("musicdata is null. aborting");
		return;
	end
	print("playing music ".. musicData.FileName);
	if(not libSneedio.IsMusicValid(musicData.FileName))then
		print("unable to load file "..musicData.FileName.. " this will not change the situation!");
		return;
	end
	-- don't replay the music if the filename is the same with the current played one
	-- but change the situation
	if(sneedio._CurrentPlayedMusic) then
		sneedio._CurrentPlayedMusic.Situation = sneedio._CurrentSituation;
	end

	if(musicData.FileName == sneedio._CurrentPlayedMusic.FileName and sneedio._bNotInFrontEnd) then
		print("same music is being played");
	end

	sneedio._CurrentPlayedMusic = musicData;
	--sneedio._CurrentPlayedMusic.Situation = sneedio._CurrentSituation;
	if(#sneedio._Last2PlayedMusic >= 2) then
		table.remove(sneedio._Last2PlayedMusic, 1);
	end
	table.insert(sneedio._Last2PlayedMusic, musicData);
	PrintWarning("now playing "..musicData.FileName.." duration is "..tostring(musicData.MaxDuration));
	-- start mute transition
	sneedio._TransitionMusicFlag = 1;
	print("flag is set "..tostring(sneedio._TransitionMusicFlag));
	table.insert(sneedio._TransitionMusicQueue, musicData);
end

-- BIG BUG!
-- if game was fast forward, the timer will get FASTER!

sneedio._MusicTimeTracker = function ()
	if(sneedio.IsPaused()) then
		return;
	end
	if(sneedio._CurrentPlayedMusic) then
		if(sneedio.IsCurrentMusicFinished()) then
			sneedio._CurrentPlayedMusic.CurrentDuration = 0;
		end
		sneedio._CurrentPlayedMusic.CurrentDuration = sneedio._CurrentPlayedMusic.CurrentDuration + 1;
		--PrintWarning(tostring(sneedio._CurrentPlayedMusic.CurrentDuration).." track "..sneedio._CurrentPlayedMusic.FileName);
	end
end

sneedio._UpdateMusicSituation = function ()
	if(sneedio._CurrentSituation == "Deployment") then return; end
	if(sneedio._CurrentSituation == "FirstEngagement") then return; end

	local PlayerRouts = sneedio.GetPlayerSideRoutRatioQuick();
	print("PlayerRouts" .. tostring(PlayerRouts));
	local EnemyRouts = sneedio.GetEnemySideRoutRatioQuick();
	print("EnemyRouts" .. tostring(EnemyRouts));

	if (IsBetween(0, 0.4, PlayerRouts) and IsBetween(0, 0.4, EnemyRouts))then
		print("changed to balanced");
		sneedio._CurrentSituation = "Balanced";
	elseif (IsBetween(0.5, 0.7, PlayerRouts) and IsBetween(0, 0.7, EnemyRouts)) then
		print("changed to losing");
		sneedio._CurrentSituation = "Losing";
	elseif (IsBetween(0.7, 1, PlayerRouts) and IsBetween(0, 0.6, EnemyRouts)) then
		print("changed to last stand");
		sneedio._CurrentSituation = "LastStand";
	elseif (IsBetween(0, 0.3, PlayerRouts) and IsBetween(0.8, 1, EnemyRouts)) then
		print("changed to winning");
		sneedio._CurrentSituation = "Winning";
	end
end

-- called only when transitioning:
-- Deployment -> FirstEngagement.
-- FirstEngagement Balanced Losing LastStand Winning -> Complete.
-- FirstEngagement Balanced -> Losing (when general wounded).
sneedio._ProcessMusicPhaseChangesBattle = function ()
	print("important phase changes!")
	sneedio._PlayMusic(sneedio.GetNextMusicData());
end

sneedio._ProcessMusicEventBattle = function ()
	if(sneedio.IsCurrentMusicFinished())then
		print("music finished, new music pls");
		-- reset the current music duration.
		sneedio._CurrentPlayedMusic.CurrentDuration = 0;
		print("current music");
		var_dump(sneedio._CurrentPlayedMusic);
		print("all music");
		var_dump(sneedio._MusicPlaylist);
		print("current situation: "..sneedio._CurrentSituation);
		local playlist = sneedio._MusicPlaylist[sneedio.GetPlayerFaction()].Battle[sneedio._CurrentSituation];
		var_dump(playlist);
		local idx = GetArrayIndexByPred(playlist, function (el)
			return el.FileName == sneedio._CurrentPlayedMusic.FileName;
		end);
		-- print("index "..tostring(idx));
		-- print("current situation: "..sneedio._CurrentSituation);
		-- var_dump(sneedio._MusicPlaylist[sneedio.GetPlayerFaction()].Battle[sneedio._CurrentPlayedMusic.Situation][idx]);
		sneedio._MusicPlaylist[sneedio.GetPlayerFaction()].Battle[sneedio._CurrentSituation][idx].CurrentDuration = 0;
		sneedio._PlayMusic(sneedio.GetNextMusicData());
	end
	if(sneedio.IsCurrentMusicQuarterWaythrough()) then
		sneedio._UpdateMusicSituation();
	end
end

sneedio._ValidateMusicData = function ()
	local hasMissingTypes = false;
	ForEach(sneedio._MusicPlaylist, function (musicData, factionKey)
		if(factionKey == "faction_none") then return; end
		print("_ValidateMusicData processing "..factionKey);
		if(CM) then
			local battleMusicData = musicData["CampaignMap"];
			if(battleMusicData == nil or #battleMusicData == 0) then
				PrintError(factionKey.." has empty music list");
				return;
			end
		end
		if(BM) then
			local missingTypes = {
				["Deployment"] = true,
				["FirstEngagement"] = true,
				["Balanced"] = true,
				["Losing"] = true,
				["Winning"] = true;
			};
			local battleMusicData = musicData["Battle"];
			if(battleMusicData == nil) then
				PrintError(factionKey.." has no battle music at all");
				return;
			end
			ForEach(battleMusicData, function (music, musicType)
				missingTypes[musicType] = #music == 0;
			end);
			ForEach(missingTypes, function (value, key)
				if(value) then
					PrintError(factionKey.." battle music has missing music type: "..key.." this can cause playback problem");
					hasMissingTypes = true;
				end
			end);
			if(hasMissingTypes) then
				PrintWarning("there is playlist problem for faction "..factionKey);
			else
				print(factionKey.." playlist is ok");
			end
		end
	end);
	var_dump(sneedio._MusicPlaylist);
	return hasMissingTypes;
end

---------------------------Sound effects methods----------------------------------

--#region Sound effects
--#region only exists in battle only
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
		if(type(ListOfAudio[PickRandom]) == "table") then
			if(not sneedio._IsAmbientAllowedToPlay(ListOfAudio[PickRandom])) then
				print("playing ambient voice: ".. ListOfAudio[PickRandom].FileName.." but because cooldown, aborted");
				return;
			end
			print("playing ambient voice: ".. ListOfAudio[PickRandom].FileName);
		else
			print("playing voice: ".. ListOfAudio[PickRandom]);
		end
		local result = libSneedio.PlayVoiceBattle(unitTypeInstanced, tostring(PickRandom), CAVectorToSneedVector(playAtPos), tostring(MaxDistance), tostring(Volume));
		var_dump(result);
		if(result == 0) then
			print("audio played");
		end
	else
		print("no audio regisered for "..unitTypeInstanced);
	end

	local lookat = BM:camera():target();

	libSneedio.UpdateListenerPosition(CAVectorToSneedVector(cameraPos), CAVectorToSneedVector(lookat));
	-- print(" at camera pos: ".. v_to_s(cameraPos).. " from: ".. v_to_s(playAtPos));
end

sneedio._ProcessSelectedUnitRightClickBattle = function()
	if(not libSneedio.WasRightClickHeld()) then return; end
	--print("line 278");
	ForEach(sneedio._MapUnitToSelected, function (selected, unitInstanceName)
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
	end);
end


-- can only work with single unit :(
sneedio._ProcessSelectedUnitOnAbilitiesBattle = function()
	local selectedUnit = {};

	ForEach(sneedio._MapUnitToSelected, function (selected, unitInstanceName)
		if(selected)then
			table.insert(selectedUnit, unitInstanceName);
		end
	end);

	if(#selectedUnit>1 and #selectedUnit ~= 0)then return; end

	local theUnit = sneedio._MapUnitInstanceNameToActualUnits[selectedUnit[1]];
	local unitInstanceNameAbilities = sneedio._UnitTypeToInstancedAbilities(theUnit);
	local camPos = BM:camera():position();
	print("playing unit audio on Abilities UI buttons "..selectedUnit[1].." Abilities "..unitInstanceNameAbilities);

	sneedio._PlayVoiceBattle(unitInstanceNameAbilities, camPos, theUnit:position());
end

sneedio._ProcessSelectedUnitOnStopOrBackspaceBattle = function()
	ForEach(sneedio._MapUnitToSelected, function (selected, unitInstanceName)
		local actualUnit = sneedio._MapUnitInstanceNameToActualUnits[unitInstanceName];
		if(selected and is_unit(actualUnit)) then
			local camPos = BM:camera():position();
			local unitPos = actualUnit:position();
			local unitInstanceNameAbort = sneedio._UnitTypeToInstancedAbort(actualUnit);

			print("playing unit audio on backspace/abort evt "..unitInstanceName.." abort "..unitInstanceNameAbort);
			sneedio._PlayVoiceBattle(unitInstanceNameAbort, camPos, unitPos);
		end
	end);
end

sneedio._IsAmbientAllowedToPlay = function(voice)
	if(voice.LastTimePlayed == nil) then
		voice.LastTimePlayed = sneedio._BattleCurrentTicks;
		return true;
	end
	if(sneedio._BattleCurrentTicks - voice.LastTimePlayed > voice.Cooldown * 100) then
		return false;
	end
	voice.LastTimePlayed = sneedio._BattleCurrentTicks;
	return true;
end


-- PRONE TO CRASHING FIX ME PLS
sneedio._ProcessAmbientUnitSoundBattle = function()
	if(not sneedio.IsBattleInNormalPlay())then return; end

	local cameraPos = BM:camera():position();
	PrintWarning("process ambient untt");
	ForEach(sneedio._MapUnitInstanceNameToActualUnits, function (TheActualUnit)
		if(TheActualUnit == nil) then return; end
		local Distance = cameraPos:distance(TheActualUnit:position());
		if(Distance < AMBIENT_TRIGGER_CAMERA_DISTANCE) then
			--print("line 318 -- process ambient sound");
			if(TheActualUnit:is_idle()) then
				print("line 326 -- process ambient sound");
				local instancedAmbientName = sneedio._UnitTypeToInstancedAmbient(TheActualUnit, "Idle");
				sneedio._PlayVoiceBattle(instancedAmbientName, cameraPos, TheActualUnit:position(), true);
			elseif(TheActualUnit:is_wavering() or
					TheActualUnit:is_routing() or
					TheActualUnit:is_shattered()) then
				local instancedAmbientName = sneedio._UnitTypeToInstancedAmbient(TheActualUnit, "Wavering");
				sneedio._PlayVoiceBattle(instancedAmbientName, cameraPos, TheActualUnit:position(), true);
			elseif(TheActualUnit:is_rampaging()) then
				local instancedAmbientName = sneedio._UnitTypeToInstancedAmbient(TheActualUnit, "Rampage");
				sneedio._PlayVoiceBattle(instancedAmbientName, cameraPos, TheActualUnit:position(), true);
			elseif(TheActualUnit:is_in_melee()) then
				local instancedAmbientName = sneedio._UnitTypeToInstancedAmbient(TheActualUnit, "Attack");
				sneedio._PlayVoiceBattle(instancedAmbientName, cameraPos, TheActualUnit:position(), true);
			elseif((TheActualUnit:is_in_melee() or
					TheActualUnit:is_rampaging()) and
					TheActualUnit:unary_hitpoints() > 0.5) then
				local instancedAmbientName = sneedio._UnitTypeToInstancedAmbient(TheActualUnit, "Winning");
				sneedio._PlayVoiceBattle(instancedAmbientName, cameraPos, TheActualUnit:position(), true);
			end
		end
	end);

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
		PrintError("warning, unknown type "..VoiceType.." aborting this function");
		print(debug.traceback());
		return;
	end

	--sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced] = Voices;
	if(sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced] == nil) then
		sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced] = {};
	end
	var_dump(Voices);
	var_dump(sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced] );
	ForEach(Voices, function (filename)
		if(type(filename)=="table")then
			print("================================");
			print("attempt to load ambience audio: "..filename.FileName);
			if(libSneedio.LoadVoiceBattle(filename.FileName, unitTypeInstanced)) then
				table.insert(sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced], filename);
				print(unitTypeInstanced..": audio loaded "..filename.FileName.." for voice type "..VoiceType);
			else
				PrintError("warning, failed to load .."..unitTypeInstanced.." filename path: "..filename.FileName.." for voice type "..VoiceType.." maybe file doesn't exist or wrong path");
			end
		else
			print("attempt to load: "..filename);
			if(libSneedio.LoadVoiceBattle(filename, unitTypeInstanced)) then
				table.insert(sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced], filename);
				print(unitTypeInstanced..": audio loaded "..filename.." for voice type "..VoiceType);
			else
				PrintError("warning, failed to load .."..unitTypeInstanced.." filename path: "..filename.." for voice type "..VoiceType.." maybe file doesn't exist or wrong path");
			end
		end
	end);
end

--#endregion only exists in battle only
--#endregion sound effects

--#region tick procedures
sneedio._UpdateCamera = function()
	if(BM) then
		local camera = BM:camera();
		sneedio.UpdateCameraPosition(camera:position(), camera:target());
	elseif(CM) then
		local x,y,d,b,h = CM:get_camera_position();
		local cam = {x=x,y=y,z=0};
		local target = CampaignCameraToTargetPos(cam, b);
		sneedio.UpdateCameraPosition(cam, target);
	end
end

sneedio._BattleOnTick = function()
	sneedio._UpdateCamera();
	sneedio._bHasSpeedChanged = sneedio._CurrentSpeed ~= sneedio.GetBattleSpeedMode();
	sneedio._CurrentSpeed = sneedio.GetBattleSpeedMode();
	if(sneedio._bHasSpeedChanged) then
		sneedio._ProcessSpeedEvents(sneedio._CurrentSpeed);
	end

	sneedio._ProcessSelectedUnitRightClickBattle();

	sneedio._BattleCurrentTicks = sneedio._BattleCurrentTicks + SYSTEM_TICK;
end

sneedio._ProcessSpeedEvents = function(eventToProcess)
	-- print("event "..eventToProcess);
	ForEach(sneedio._ListOfCallbacksForBattleEvent, function (eventList)
		ForEach(eventList, function (callback, eventKey)
			if(eventKey == eventToProcess)then
				callback();
				return YIELD_BREAK;
			end
		end);
	end);
	-- print("event process done");
end

--#endregion tick procedures

--#region init procedures
sneedio._RegisterSneedioTickBattleFuns = function()

	if(BM == nil)then
		PrintError("not in battle mode!");
		return;
	end
	print("battle mode");

	sneedio._LoadUserConfig();
	sneedio._ValidateMusicData();

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

	TM.RepeatCallback(function ()
		sneedio._ProcessAmbientUnitSoundBattle();
	end, AMBIENT_TICK,
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
		sneedio._ProcessMusicPhaseChangesBattle();
	else
		BM:register_phase_change_callback("Deployment", function ()
			print("battle in Deployment");
			sneedio._BattlePhaseStatus = "Deployment";
			sneedio._CurrentSituation = "Deployment";
			sneedio._ProcessMusicPhaseChangesBattle();
		end);
	end


	BM:register_phase_change_callback("Deployed", function ()
		print("battle Deployment");
		sneedio._BattlePhaseStatus = "Deployed";
		sneedio._CurrentSituation = "FirstEngagement";
		sneedio._ProcessMusicPhaseChangesBattle();
	end);

	BM:setup_victory_callback(function ()
		print("battle Deployment");
		sneedio._BattlePhaseStatus = "VictoryCountdown";
		sneedio._CurrentSituation = "Winning";
		sneedio._ProcessMusicPhaseChangesBattle();
	end);

	BM:register_phase_change_callback("Complete", function ()
		print("Battle complete in Deployment");
		sneedio._BattlePhaseStatus = "Complete";
		sneedio._CurrentSituation = "Complete";
		sneedio._ProcessMusicPhaseChangesBattle();

		sneedio._FadeToMuteMusic(); -- for testing only!
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
				sneedio._ProcessMusicPhaseChangesBattle();
			end, 0.1);
		end,
	true);

	TM.RepeatCallback(function ()
		sneedio._MusicTimeTracker();
	end, MUSIC_TICK,
	"sneedio_monitor_music_time_tracker");

	TM.RepeatCallback(function ()
		sneedio._ProcessMusicEventBattle();
	end, BATTLE_EVENT_MONITOR_TICK,
	"sneedio_monitor_music_event");

	TM.RepeatCallback(function ()
		sneedio._ProcessSmoothMusicTransition();
	end, TRANSITION_TICK,
	"sneedio_monitor_music_transition");

	-- get current music volume from config...
	sneedio._CurrentMusicVolume = 1.0;

	TM.RepeatCallback(function ()
		sneedio._MonitorRoutingUnits()
	end, BATTLE_MORALE_MONITOR_TICK, --expensive operations
	"sneedio_monitor_player+enemies_rallying_units_and_general");

	TM.RepeatCallback(function ()
		sneedio._bPaused = sneedio.IsBattlePaused();
		if(BM and not sneedio.IsBattlePaused()) then
			local camera = BM:camera();
			sneedio.UpdateCameraPosition(camera:position(), camera:target());
			sneedio._BattleOnTick();
		end
	end, SYSTEM_TICK,
	"sneedio_monitor_battle_camera_position_and_run_tick_funs");

end

sneedio._InitBattle = function(units)

	-- for select voice
	ForEach(units, function (unit)
		local UnitVoices = sneedio.GetListOfVoicesFromUnit(unit:type(), "Select");
		local InstancedName = sneedio._UnitTypeToInstancedSelect(unit);
		sneedio._MapUnitToSelected[InstancedName] = false;
		if(UnitVoices ~= nil) then
			sneedio._RegisterVoiceOnBattle(unit, UnitVoices, "Select");
		else
			print("Voice on Select, Warning unit:"..unit:type().." doesn not have associated voices");
		end

		local UnitVoices = sneedio.GetListOfVoicesFromUnit(unit:type(), "Affirmative");
		if(UnitVoices ~= nil) then
			sneedio._RegisterVoiceOnBattle(unit, UnitVoices, "Affirmative");
		else
			print("Voice on Affirmative, Warning unit:"..unit:type().." doesnt have associated voices");
		end

		local UnitVoices = sneedio.GetListOfVoicesFromUnit(unit:type(), "Abort");
		if(UnitVoices ~= nil) then
			sneedio._RegisterVoiceOnBattle(unit, UnitVoices, "Abort");
		else
			print("Voice on Abort, Warning unit:"..unit:type().." doesnt have associated voices");
		end

		local UnitVoices = sneedio.GetListOfVoicesFromUnit(unit:type(), "Abilities");
		if(UnitVoices ~= nil) then
			sneedio._RegisterVoiceOnBattle(unit, UnitVoices, "Abilities");
		else
			print("Voice on Abilities, Warning unit:"..unit:type().." doesnt have associated voices");
		end

		local UnitVoices = sneedio.GetListOfVoicesFromUnit(unit:type(), "Ambiences");
		if(UnitVoices ~= nil and type(UnitVoices) == "table")then
			var_dump(UnitVoices);
			ForEach(UnitVoices, function (ambienceVoices, ambientType)
				print("_InitBattle: processing "..ambientType);
				var_dump(ambienceVoices);
				sneedio._RegisterVoiceOnBattle(unit, ambienceVoices, ambientType);
			end);
		else
			print("Voice on Ambiences, Warning unit:"..unit:type().." doesnt have associated voices");
		end
	end);
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
-- in mili seconds;
sneedio._BattleCurrentTicks = 0;
sneedio._BattlePhaseStatus = "undefined";
sneedio._PlayerGeneral = nil;
-- balance of power
sneedio._CountPlayerUnits = 0;
sneedio._CountEnemyUnits = 0;

sneedio._CountPlayerRoutedUnits = 0;
sneedio._CountEnemyRoutedUnits = 0;

sneedio._CountPlayerRoutedGenerals = 0;
sneedio._CountEnemyRoutedGenerals = 0;

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

sneedio._ListOfRegisteredVoices = {
	["null"] = {
		["Select"] = {},
		["Affirmative"] = {},
		["Hostile"] = {},
		["Abilities"] = {},
		["Diplomacy"] = {
			["Diplomacy_str_x"] = "",
			["Diplomacy_str_y"] = "",
		},
		["Ambiences"] = {
			["CampaignMap"] = {
				["Any"] = { {Cooldown = 0, FileName = ""} },
				["Desert"] = {Cooldown = 0, FileName = ""},
				["OldWorld"] = {Cooldown = 0, FileName = ""},
				["HighElves"] = {Cooldown = 0, FileName = ""},
				["Lustria"] = {Cooldown = 0, FileName = ""},
				["Snow"] = {Cooldown = 0, FileName = ""},
				["Chaos"] = {Cooldown = 0, FileName = ""}
			},
			["Idle"] = {Cooldown = 0, FileName = ""},
			["Attack"] = {Cooldown = 0, FileName = ""},
			["Wavering"] = {Cooldown = 0, FileName = ""},
			["Winning"] = {Cooldown = 0, FileName = ""},
			["Rampage"] = {Cooldown = 0, FileName = ""},
			["EnslaveOption"] = {Cooldown = 0, FileName = ""},
			["KillOption"] = {Cooldown = 0, FileName = ""},
			["RansomOption"] = {Cooldown = 0, FileName = ""},
		},
	},
};

sneedio._ListOfCustomAudio = {};

--#endregion audio vars

--#region campaign vars

sneedio._SelectedCharacterOnCampaign = nil;

--#endregion campaign vars

--#region music vars

--get this value from user config
-- sneedio._ProcessSmoothMusicTransition needs this
sneedio._MaximumMusicVolume = 1;

-- this is controlled by sneedio._PlayMusic sneedio._ProcessSmoothMusicTransition
sneedio._CurrentMusicVolume = 1;
-- this is controlled by sneedio._PlayMusic sneedio._ProcessSmoothMusicTransition
sneedio._TransitionMusicFlag = 0;
-- this is controlled by sneedio._FadeToMuteMusic, will affect sneedio._ProcessSmoothMusicTransition
sneedio._bFlagMute = false;

-- this is controlled by sneedio._PlayMusic sneedio._ProcessSmoothMusicTransition
sneedio._TransitionMusicQueue = {};

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
};

sneedio._bAllowModToAddMusic = true;

sneedio._bPaused = false;

--#endregion music vars

sneedio._FrontEndMusic = {
    FileName = "",
    MaxDuration = 0
};

sneedio._bNotInFrontEnd = true;

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
			{
				Cooldown = 10,
				FileName = "man_insult_13.ogg",
			},
			{
				Cooldown = 10,
				FileName = "man_insult_7.ogg",
			},
			{
				Cooldown = 10,
				FileName = "man_insult_3.ogg",
			}
		},
		["Attack"] = {
			{
				Cooldown = 10,
				FileName = "man_yell_11.ogg",
			},
			{
				Cooldown = 10,
				FileName = "man_yell_15.ogg",
			},
			{
				Cooldown = 10,
				FileName = "man_insult_3.ogg",
			}
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
			{
				Cooldown = 10,
				FileName = "man_insult_13.ogg",
			},
			{
				Cooldown = 10,
				FileName = "man_insult_7.ogg",
			},
			{
				Cooldown = 10,
				FileName = "man_insult_3.ogg",
			}
		},
		["Attack"] = {
			{
				Cooldown = 10,
				FileName = "man_yell_11.ogg",
			},
			{
				Cooldown = 10,
				FileName = "man_yell_15.ogg",
			},
			{
				Cooldown = 10,
				FileName = "man_insult_3.ogg",
			}
		}
	}
});

sneedio.RegisterVoice("teb_borgio_the_besieger", {
	["Select"] = {
		"voice_over/borgio/interactive/select/audio (1).wav",
		"voice_over/borgio/interactive/select/audio (2).wav",
		"voice_over/borgio/interactive/select/audio (3).wav",
		"voice_over/borgio/interactive/select/audio (10).wav",
	},
	["Affirmative"] = {
		"voice_over/borgio/interactive/move/audio (4).wav",
		"voice_over/borgio/interactive/move/audio (5).wav",
		"voice_over/borgio/interactive/move/audio (7).wav",
		"voice_over/borgio/interactive/move/audio (11).wav",
		"voice_over/borgio/interactive/move/audio (12).wav",
	},
	["Hostile"] = {
		"voice_over/borgio/interactive/reject/audio (9).wav",
		"voice_over/borgio/interactive/reject/audio (13).wav",
	},
	["Abilities"] = {
		"voice_over/borgio/interactive/attack/audio (6).wav",
		"voice_over/borgio/interactive/attack/audio (8).wav",
		"voice_over/borgio/interactive/attack/audio.wav",
	},
	["Diplomacy"] = {
		["Why talk to you? The Grand Theogonist should declare you traitors and heretics! "] = "voice_over/borgio/diplomacy/Why talk to you The Grand Theogonist should declare you traitors and heretics.wav",
		["Surely an agreement will be reached, for are we all not sons of Sigmar? "] = "voice_over/borgio/diplomacy/Surely an agreement will be reached, for are we all not sons of Sigmar.wav",
		["Greetings my countrymen, do you come in peace on this fine Marktag? "] = "voice_over/borgio/diplomacy/Greetings my countrymen, do you come in peace on this fine Marktag.wav",
		["It is good to see fellow sons of the Empire this day! "] = "voice_over/borgio/diplomacy/It is good to see fellow sons of the Empire this day.wav",
		["You dare come at me making demands? Call yourself men of the Empire?! "] = "voice_over/borgio/diplomacy/You dare come at me making demands Call yourself men of the Empire.wav",
		["Welcome, my countrymen! "] = "voice_over/borgio/diplomacy/Welcome, my countrymen.wav",
		["You have a proposal? We are willing to hear it. "] = "voice_over/borgio/diplomacy/You have a proposal We are willing to hear it.wav",
		["I am ready to parley, I hope your words are wise. "] = "voice_over/borgio/diplomacy/I am ready to parley, I hope your words are wise.",
		["Greetings, stranger??? "] = "voice_over/borgio/diplomacy/Greetings, stranger.wav",
		["Deliver your message??? "] = "voice_over/borgio/diplomacy/Deliver your message.wav",
		["Greetings - we may not be the Empire, but our realm has riches and strength in equal measure. "] = "voice_over/borgio/diplomacy/Greetings - we may not be the Empire, but our realm has riches and strength in equal measure.wav",
	},
	["Ambiences"] = {}
});




--sneedio.Debug();

print(sneedio.GetPlayerFaction());

out("hello world");

--var_dump(sneedio);
--var_dump(libSneedio);

local SneedioBattleMain = function()
	local ListOfUnits = {};
    ForEachUnitsAll(function(CurrentUnit, CurrentArmy)
		table.insert(ListOfUnits, CurrentUnit);
		local instancedName = sneedio._UnitTypeToInstancedSelect(CurrentUnit);
		sneedio._MapUnitInstanceNameToActualUnits[instancedName] = CurrentUnit;
    end);

	print("ListOfUnits have sneeded!");

	sneedio._InitBattle(ListOfUnits)
	-- var_dump(ListOfUnits);
	-- var_dump(sneedio);

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
	sneedio._ValidateMusicData();
	sneedio._RegisterSneedioTickBattleFuns();
	--sneedio.Debug();
	print("battle has sneeded!");
end

local SneedioCampaignMain = function ()
	sneedio._InitCampaign();
	var_dump(sneedio);
	print("campaign has sneeded!");
end

local SneedioFrontEndMain = function ()
	PrintWarning("called in FRONT END\n");
	sneedio._InitFrontEnd();
end

if BM ~= nil then SneedioBattleMain(); end
if CM ~= nil then SneedioCampaignMain(); end
if CM == nil and BM == nil then SneedioFrontEndMain(); end

local TILEA_TEST = true;
if(TILEA_TEST and CM) then
	CM:create_force_with_general(
		"wh_main_teb_tilea",
		"til_greatswords",
		"wh_main_tilea_miragliano",
		0,
		0,
		"general",
		"teb_borgio_the_besieger",
		"997016",
		"997017",
		"",
		"",
		true,
		function ()
			print("debug: ok");
		end
	);
end

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

