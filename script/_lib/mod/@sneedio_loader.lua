local VERSION = "a0.3.0";
require("libsneedio_trycatch");
------
-- Main sneedio module
local var_dump = require("var_dump");
if(var_dump) then
    print("var_dump is working");
end

local math = math;
local print2 = print2;
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
local BM = bm or nil;
local CM = cm or nil;
local TM = nil;
local throw = error;

_G.SNEEDIO_DEBUG = false or os.getenv("SNEEDIO_DEBUG");

-- breaks ForEach loop
local YIELD_BREAK = "_____BREAK_____";

-- sneedio config file
local SNEEDIO_USER_CONFIG_JSON = "user-sneedio.json";
-- yt-dlp music stash
local SNEEDIO_YT_DLP_DIRECTORY = "yt-dlp-audio";
-- yt-dlp playlist file
local SNEEDIO_YT_DLP_QUEUE_MOD_JSON = "yt-dlp-db.json";
-- sneedio system config file
local SNEEDIO_SYSTEM_CONFIG_JSON = ".sneedio-system.json";

-- sneedio mod identifier
local SNEEDIO_MCT_CONTROL_PANEL_ID = "Sneedio";

local print = function (x)
    if(not SNEEDIO_DEBUG) then return; end
    out("chuckio: "..tostring(x));
    if(print2) then print2(tostring(x).."\n"); end
end;

local PError = PrintError or print;
local PWarn = PrintWarning or print;

local PrintError = function (x)
    if(PError) then PError(tostring(x).."\a\a\n"); else print("ERROR "..x); end
    --print("ERROR "..x);
end

local PrintWarning = function (x)
    if(PWarn) then PWarn(tostring(x).."\n"); else print("WARN "..x); end
    --print("WARN "..x);
end

if _G.SNEEDIO_DEBUG then
    print("Sneedio debug is on");
end

var_dump(real_timer);

PrintWarning("called from ===========================");
print(debug.traceback());
PrintWarning("=======================================");

if(real_timer.register_repeating == nil) then
    PrintError("REALTIMER WAS NULL, try again after campaign module is loaded");
    return;
end

if(_G.sneedio ~= nil) then
    PrintWarning("sneedio already loaded");
    return _G.sneedio;
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
local PATH = "audio/";
local OUTPUTPATH = "";

local DOWNLOAD_STATUS_OK = 0;
local DOWNLOAD_STATUS_FAIL = 1;
local DOWNLOAD_STATUS_PARTIAL = 2;
local DOWNLOAD_STATUS_COMPLETE = 3;

local DOWNLOAD_PROGRESS_PREPARING = 0;
local DOWNLOAD_PROGRESS_DOWNLOADING = 1;
local DOWNLOAD_PROGRESS_CONVERTING = 2;


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
-- music padding
local MUSIC_ENDS_IN_SECONDS = 0;

--#region init stuff soon to be removed into their own libs


local json = require("libsneedio_json");
if(json)then
    print("json has loaded");
end
local base64 = require("libsneedio_base64");
if(base64)then
    print("base64 has loaded");
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

_G.sneedio = {};

local libSneedio =  nil;

try {
    function()
        libSneedio = require(DLL_FILENAMES[1]);
    end,

    catch {
        function(error)
            PrintError('cannot use ol require function caught error: ' .. error);
            try {
                function()
                    libSneedio = require2("libsneedio", "luaopen_libsneedio")(); --require(DLL_FILENAMES[1]);
                end,

                catch {
                    function(error)
                        PrintError('cannot use require2 caught error: ' .. error)
                    end
                }
            }

        end
    }
}


if(libSneedio) then
    print("lib loaded ok");
    var_dump(libSneedio);
    -- fix math.huge null value
    math.huge = libSneedio.GetInfinity();
    -- libSneedio = libSneedio();
    --var_dump(libSneedio);
    --StartDebugger();
else
    PrintError("unable to load libsneedio!");
end

--#endregion init stuff soon to be removed into their own libs


var_dump(real_timer);

-- timer_manager doesn't work properly in frontend, i have to code myself. thanks to vandy for the hint
local RandomString = nil;

TM = {
    _ListOfCallbacks = {},
    _bInited = false,
    OnceCallback = function (callback, delay, name)
        if(name == "") then name = nil; end
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
        name = name or RandomString();
        name = name .. "_ONCE";
        TM._ListOfCallbacks[name] = callback;
        real_timer.register_singleshot(name, delay)
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

    RemoveCallbackOnce = function (name)
        if type(name) ~= "string" then return end
        name = name .. "_ONCE";

        TM._ListOfCallbacks[name] = nil
        real_timer.unregister(name);
        --type hint
        name = "";
    end,

    RemoveCallback = function (name)
        if type(name) ~= "string" then return end

        TM._ListOfCallbacks[name] = nil
        real_timer.unregister(name);

        --type hint
        name = "";
    end,

    Init = function ()
        if(core == nil) then
            PrintError("CORE OBJECT WAS NIL. FAILING");
            PrintError(debug.traceback());
            return false;
        end
        if(TM._bInited) then return true; end
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
        return true;
    end
};
TM.Init();

if(TM == nil or TM == false)then
    PrintError("time manager is fucking NULL or FALSE");
end

--#region helper functions

-- a function that convert seconds to mm:ss
local SecondsToMMSS = function (seconds)
    local minutes = math.floor(seconds / 60);
    local seconds = seconds - (minutes * 60);
    return string.format("%02d:%02d", minutes, seconds);
end

local ShallowCopy = function (orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local MMSSToSeconds = function (mmss)
    local mm, ss = mmss:match("(%d+):(%d+)");
    if(mm == nil) then
        throw("invalid mmss format");
    end
    mm = tonumber(mm);
    ss = tonumber(ss);
    if(ss > 59) then
        throw("invalid mmss format, ss is above 59");
    end
    return  mm * 60 + ss;
end

local ReadFile = function (file)
    local f = assert(io.open(file, "rb"));
    local content = f:read("*all");
    f:close();
    return content;
end

local WriteFile = function (file, content)
    local f = assert(io.open(file, "wb"));
    f:write(content);
    f:close();
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

RandomString = function (length)
    local charset = {}
    length = length or 8;
    -- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
    for i = 48,  57 do table.insert(charset, string.char(i)) end
    for i = 65,  90 do table.insert(charset, string.char(i)) end
    for i = 97, 122 do table.insert(charset, string.char(i)) end

      math.randomseed(os.time())

      if length > 0 then
        return RandomString(length - 1) .. charset[math.random(1, #charset)]
      else
        return ""
      end

end

-- timeout in ms
local DelayedCall = function(pred, timeout, name)
    name = name or RandomString(5);
    if(BM) then
        BM:callback(pred, timeout/1000);
        return;
    end
    if(CM) then
        CM:callback(pred, timeout/1000);
        return;
    end
    TM.OnceCallback(pred, timeout, name);
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

local IsFileExist = function (path)
    local f=io.open(path,"r");
    if(f~=nil)then
        io.close(f);
        return true;
    else
        return false;
    end
end

local IsAudioHaveBeenExtracted = function (audioHiveFolder, audio)
    local res = true;
    ForEach(audio, function (_, filename)
        local path = PATH..audioHiveFolder.."/"..filename;
        res = res and IsFileExist(path);
        if(res) then
            PrintWarning("file found "..path.."\n");
        else
            PrintError("file not found "..path.."\n")
        end
    end);
    return res;
end

local MessageBox = function (id, message, callbackOk, callbackCancel, disablePrompts)
    local msgBox = require("libsneedio_alertbox");
    return msgBox(id, message, callbackOk, callbackCancel, disablePrompts,
        {
            core = core,
            bm = BM,
            cm = CM,
            is_uicomponent = is_uicomponent,
            find_uicomponent = find_uicomponent,
            effect = effect,
        });
end

sneedio.CONTROLPANEL = {};
sneedio.CONTROLPANEL.SNEEDIO_MCT_CONTROL_PANEL_ID = SNEEDIO_MCT_CONTROL_PANEL_ID;
sneedio.CONTROLPANEL.CheckMuteControlId = "MusicMute";
sneedio.CONTROLPANEL.CheckSoundMuteControlId = "SoundMute";
sneedio.CONTROLPANEL.SliderMusicVolumeControlId =  "MusicVolume";
sneedio.CONTROLPANEL.SliderSoundVolumeControlId =  "SoundVolume";
sneedio.CONTROLPANEL.SECTION_NAME = "General";
sneedio.CONTROLPANEL.CheckNoticeNoMusicFoundForFactionControlId = "NoticeNoMusicFoundForFaction";
sneedio.CONTROLPANEL.AllowModToModifyMenuMusicId = "AllowModToModifyMenuMusic";
sneedio.CONTROLPANEL.AllowModToModifyFactionMusicId = "AllowModToModifyFactionMusic";
sneedio.CONTROLPANEL.AllowModToDownloadAudioId = "AllowModToDownloadAudio";

local SetupControlPanel = function ()
    core:add_listener(
        "sneedio_mct_open",
        "MctPanelOpened",
        true,
        function (ctx)
        end,
    true);

    core:add_listener(
        "sneedio_mct_save",
        "MctFinalized",
        true,
        function(context)
            local mct = context:mct()
            local mod = mct:get_mod_by_key(sneedio.CONTROLPANEL.SNEEDIO_MCT_CONTROL_PANEL_ID)
            local volume = mod:get_option_by_key(sneedio.CONTROLPANEL.SliderMusicVolumeControlId):get_finalized_setting();
            sneedio.SetMusicVolume(volume / 100);
            PrintWarning("volume is set to"..volume);
            local soundvolume = mod:get_option_by_key(sneedio.CONTROLPANEL.SliderSoundVolumeControlId):get_finalized_setting();
            sneedio.SetSoundEffectVolume(soundvolume / 100);
            PrintWarning("sound volume is set to"..soundvolume);
            local mute = mod:get_option_by_key(sneedio.CONTROLPANEL.CheckMuteControlId):get_finalized_setting();
            sneedio.MuteMusic(mute);
            PrintWarning("music mute is set to"..tostring(mute));
            local muteSound = mod:get_option_by_key(sneedio.CONTROLPANEL.CheckSoundMuteControlId):get_finalized_setting();
            sneedio.MuteSoundFX(muteSound);
            PrintWarning("sound mute is set to"..tostring(muteSound));
            local noticeNoMusicFoundForFaction = mod:get_option_by_key(sneedio.CONTROLPANEL.CheckNoticeNoMusicFoundForFactionControlId):get_finalized_setting();
            sneedio._CurrentUserConfig.NoticeNoMusicFoundForFaction = noticeNoMusicFoundForFaction;
            PrintWarning("notice no music found for faction is set to"..tostring(noticeNoMusicFoundForFaction));
            local allowModToModifyMenuMusic = mod:get_option_by_key(sneedio.CONTROLPANEL.AllowModToModifyMenuMusicId):get_finalized_setting();
            sneedio._CurrentUserConfig.AllowModToModifyMenuMusic = allowModToModifyMenuMusic;
            PrintWarning("allow mod to modify menu music is set to"..tostring(allowModToModifyMenuMusic));
            local allowModToModifyFactionMusic = mod:get_option_by_key(sneedio.CONTROLPANEL.AllowModToModifyFactionMusicId):get_finalized_setting();
            sneedio._CurrentUserConfig.AllowModToModifyFactionMusic = allowModToModifyFactionMusic;
            PrintWarning("allow mod to modify faction music is set to"..tostring(allowModToModifyFactionMusic));
            local allowModToDownloadAudio = mod:get_option_by_key(sneedio.CONTROLPANEL.AllowModToDownloadAudioId):get_finalized_setting();
            sneedio._CurrentUserConfig.AllowModToDownloadAudio = allowModToDownloadAudio;
            PrintWarning("allow mod to download audio is set to"..tostring(allowModToDownloadAudio));
            sneedio.WriteConfigFile();
            MessageBox("sneedio_save", "Saved to user-sneedio.json");
        end,
    true);
end

--#endregion helper functions

--- generate random string
-- @param length length of the string
sneedio.RandomString = RandomString;

--- checks if values are between interval
sneedio.IsBetween = IsBetween

--- check if file exists
-- @param {string} path
sneedio.IsFileExist = IsFileExist;

--- write to file
-- @param {string} path
-- @param {string} content
sneedio.WriteFile = WriteFile;

--- display messagebox
-- @param {string} id
-- @param {string} message
-- @param {function} callbackOk (optional)
-- @param {function} callbackCancel (optional)
sneedio.MessageBox = MessageBox;

--- loops utils
-- @param {table} array/sets/kv
-- @param {function} predicate
sneedio.ForEach = ForEach;

--- breaks sneedio ForEach loops
--  return this value to break ForEach inside loop predicate
sneedio.YIELD_BREAK = YIELD_BREAK;

--- concatenate arrays
-- @param {table} array1, array2, array3, ...
sneedio.ConcatArray = ConcatArray;

--- filter arrays
-- @param {table} array
-- @param {function} predicate
sneedio.FilterArray = FilterArray;

--- logging
sneedio.PrintError = PrintError;
sneedio.PrintWarning = PrintWarning;
sneedio.print = print;

--- save sneedio user config file
sneedio.WriteConfigFile = function ()
    local dataToBeSaved = ShallowCopy(sneedio._CurrentUserConfig);
    local jsonString = json.encode(dataToBeSaved);

    WriteFile(SNEEDIO_USER_CONFIG_JSON, jsonString);
end

--- converts mm:ss string to seconds
-- @param {string} mmss formatted in mm:ss, ss must be within range [0..59]
-- @return {number} seconds
sneedio.MinutesSecondsToSeconds = MMSSToSeconds;

--- extract audio from base64 table
-- the is a key value map like this
-- {
--    ["audio.mp3"] = "BLsdsdBASE64STRINGaskd",
--    ["audio2_attack.ogg"] = "BLsdsdBASE64STRINGaskd",
-- }
-- where the key is the filename and the value is valid base64 string
-- @param hiveFolder: string, your audio will be stored under audio/%hiveFolder%
-- @param audios: a key map table, look above for the format
-- @param force: boolean, true will extract the audio anyway (could be performance hit if executed frequently)
sneedio.ExtractAudio = function (hiveFolder, audios, force)
    force = force or false;
    if(hiveFolder == nil or
       #hiveFolder == 0) then
        PrintError("hive folder cannot be empty or null");
        return false;
    end

    if(not force and IsAudioHaveBeenExtracted(hiveFolder, audios)) then
        PrintWarning("audio have been extracted before");
        return false;
    end

    print("extracting to hive folder "..hiveFolder.."...");
    if(not IsFileExist("audio"))then
        if(sneedio.MakeDir(PATH) or sneedio.MakeDir(PATH..hiveFolder.."/")) then
            print("dir create success\n");
        else
            print("failed to make dir");
        end
    end

    ForEach(audios, function (b64str, filename)
        local rawAudio = base64.decode(b64str);
        local path = PATH..hiveFolder.."/"..filename;
        local out = io.open(path, "wb");
        out:write(rawAudio);
        out:close();
        PrintWarning("wrote "..path.."\n");
    end);
    return true;
end


--- replace frontend music
-- {
-- 	FileName = "medieval.mp3",
-- 	MaxDuration = 30,
--  StartPos = 10,
-- }
-- StartPos attribute is optional.
-- @param musicData: table above
sneedio.ReplaceMenuMusic = function(musicData)
    if(musicData.FileName and musicData.MaxDuration) then
        sneedio._FrontEndMusic = musicData;
    end
end

--- create directory recursively
-- @param path: String, path
-- @return boolean True if succeeded
sneedio.MakeDir = function (path)
    return libSneedio.MakeDir(path);
end

-- maps numeric values from a to b to a new range c to d
-- @param {number} value, input value
-- @param {number} a, input range start
-- @param {number} b, input range end
-- @param {number} c, output range start
-- @param {number} d, output range end
sneedio.MapValueToNewRange = function(value, a, b, c, d)
    local newValue = (value - a) / (b - a) * (d - c) + c;
    return newValue;
end


--- Mute Warscape music engine
-- @param bMute: Boolean, true mutes
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

--- check if voice is disabled or not
-- @return boolean True if voice is disabled
sneedio.IsVoiceStopped = function ()
    return sneedio._StopVoice;
end

--- check if voice is disabled or not
-- @param stop: Boolean, true mutes voices (and disable the related script functions)
sneedio.StopVoice = function (stop)
    sneedio._StopVoice = stop;
end

--- check if music is paused
-- @return boolean True if music is paused
sneedio.IsPaused = function()
    return sneedio._bPaused;
end

--- pause the music
-- @param bPause True if music is paused
sneedio.Pause = function (bPause)
    sneedio._bPaused = bPause;
    libSneedio.Pause(bPause);
end

--- mutes sound effects
-- @param bMute True if sound effects are muted
sneedio.MuteSoundFX = function (bMute)
    sneedio._CurrentUserConfig.SoundEffectMute = bMute;
    libSneedio.MuteSoundFX(bMute);
end

--- mutes music
-- @param bMute True if music is paused
sneedio.MuteMusic = function (bMute)
    sneedio._CurrentUserConfig.MusicMute = bMute;
    libSneedio.MuteMusic(bMute);
end

--- updates libsneedio camera position
--- we use this function to sync game camera position to libsneedio engine
-- @param cameraPos vector userdata (is_vector)
-- @param cameraTarget vector userdata (is_vector)
sneedio.UpdateCameraPosition = function(cameraPos, cameraTarget)
    cameraPos = CAVectorToSneedVector(cameraPos);
    cameraTarget = CAVectorToSneedVector(cameraTarget);
    --print(VectorToString(cameraPos));
    --print(VectorToString(cameraTarget));
    libSneedio.UpdateListenerPosition(cameraPos, cameraTarget);
end

--- prints out to SNED terminal or .txt file for normal execution (sneedio debug must be turned on)
sneedio.Debug = function()
    var_dump(sneedio);
end

--- load music playlist to be processed by sneedio and uploaded to libsneedio
-- warning: does not check for playlist validity!
-- note: the format should look like this
-- {
-- 	["CampaignMap"] = {
-- 		{
-- 			FileName = "medieval.mp3",
-- 			MaxDuration = 30,
-- 		},
-- 	},
-- 	["Battle"] = {
-- 		["Deployment"] = {
-- 			{
-- 				FileName = "None.mp3",
-- 				MaxDuration = 50
-- 			},
-- 		},
-- 		["FirstEngagement"] = {
-- 			{
-- 				FileName = "Music A.mp3",
-- 				MaxDuration = 60,
--              StartPos = 10
-- 			}
-- 		},
-- 		["Balanced"] = {},
-- 		["Losing"] = {},
-- 		["Winning"] = {},
-- 		["LastStand"] = {},
-- 	},
-- }
-- StartPos attribute is optional. If not specified, the music will start from the beginning.
-- @param factionid: string, faction key in faction tables
-- @param MusicPlaylist: lua table, see note above
sneedio.LoadMusic = function (factionId, MusicPlaylist)
    if(not sneedio._CurrentUserConfig.AllowModToModifyFactionMusic)then
        PrintError("sneedio:LoadMusic: not allowed to modify faction music");
        return;
    end
    sneedio._MusicPlaylist[factionId] = MusicPlaylist;
end

--- add campaign music for faction
--  if faction does not exist, it will create one.
--  music table in variadic argument must looks like this:
-- {
-- 	FileName = "medieval.mp3",
-- 	MaxDuration = 30,
--  StartPos = 10,
-- },
-- since version 0.3 FileName supports youtube url. Keep in mind the music linked from the url must be downloaded
-- by yt-dlp on frontend menu (use sneedio.DownloadYoutubeUrls(url))
-- StartPos attribute is optional. If not specified, the music will start from the beginning.
-- @param factionid: string, faction key in faction tables
-- @param ...: music to be added (variadic arguments)
sneedio.AddMusicCampaign = function (factionId, ...)
    if(not sneedio._CurrentUserConfig.AllowModToModifyFactionMusic)then
        PrintError("sneedio:AddMusicCampaign: not allowed to modify faction music");
        return;
    end
    if(sneedio._MusicPlaylist[factionId] == nil) then
        sneedio._MusicPlaylist[factionId] = {};
    end
    if(sneedio._MusicPlaylist[factionId]["CampaignMap"] == nil) then
        sneedio._MusicPlaylist[factionId]["CampaignMap"] = {};
    end
    -- PrintWarning("called from");
    -- print(debug.traceback());
    -- print("music table");
    -- var_dump(sneedio._MusicPlaylist);
    -- print("fileNamesArr");
    -- var_dump(fileNamesArr);

    local fileNamesArr = {...};
    ForEach(fileNamesArr, function (filename)
        filename.CurrentDuration = 0;
        filename.bAddedFromMod = true;
        table.insert(sneedio._MusicPlaylist[factionId]["CampaignMap"], filename);
    end);
    var_dump(sneedio._MusicPlaylist);
end

--- add battle music for faction
--- if faction does not exist, it will create one.
--- music table in variadic argument must looks like this:
--[[
    {
        FileName = "medieval.mp3",
        MaxDuration = 30,
        StartPos = 10,
    },
]]
-- StartPos attribute is optional. If not specified, the music will start from the beginning.
-- @param factionid: string, faction key in faction tables
-- @param Situation: string, situation must be either: Deployment, FirstEngagement, Balanced, Losing, Winning, LastStand
-- @param ...: music to be added (variadic arguments)
sneedio.AddMusicBattle = function (factionId, Situation, ...)
    if(not sneedio._CurrentUserConfig.AllowModToModifyFactionMusic)then
        PrintError("sneedio:AddMusicBattle: not allowed to modify faction music");
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
        local startsAt = fileName.StartPos or 0;
        table.insert(sneedio._MusicPlaylist[factionId]["Battle"][Situation], fileName);
        print("added music for faction "..factionId..
              " situation "..Situation.." filename "..
              fileName.FileName.." max duration "..
              tostring(fileName.MaxDuration)..
              "starts at "..tostring(startsAt));
    end);
end

--#region battle procedures only
-- loaded in battle only

--- calculates the player rout ratio using cached value
-- @return real value ranging [0..1]
sneedio.GetPlayerSideRoutRatioQuick = function ()
    if(sneedio._CountPlayerUnits == 0) then return 1; end
    return sneedio._CountPlayerRoutedUnits / sneedio._CountPlayerUnits;
end

--- calculates the enemy rout ratio using cached value
-- @return real value ranging [0..1]
sneedio.GetEnemySideRoutRatioQuick = function ()
    if(sneedio._CountEnemyUnits == 0) then return 1; end
    return sneedio._CountEnemyRoutedUnits / sneedio._CountEnemyUnits;
end

--- calculates the player rout ratio
-- @return real value ranging [0..1]
sneedio.GetPlayerSideRoutRatio = function ()
    sneedio._MonitorRoutingUnits();
    return sneedio.GetPlayerSideRoutRatioQuick();
end

--- calculates the enemy rout ratio
-- @return real value ranging [0..1]
sneedio.GetEnemySideRoutRatio = function ()
    sneedio._MonitorRoutingUnits();
    return sneedio.GetEnemySideRoutRatioQuick();
end

--#endregion battle procedures only

--- is the current music played 1/2 way through?
-- @return boolean true if yes
sneedio.IsCurrentMusicHalfWaythrough = function ()
    local MaxDur = sneedio._CurrentPlayedMusic.MaxDuration;
    if(MaxDur <= 0) then return true; end
    return (sneedio._CurrentPlayedMusic.CurrentDuration / MaxDur) >= 0.5;
end

--- is the current music played 1/4 way through?
-- @return boolean true if yes
sneedio.IsCurrentMusicQuarterWaythrough = function ()
    local MaxDur = sneedio._CurrentPlayedMusic.MaxDuration;
    if(MaxDur <= 0) then return true; end
    return (sneedio._CurrentPlayedMusic.CurrentDuration / MaxDur) >= 0.25;
end

--- is the current music finished?
-- @return boolean true if yes
sneedio.IsCurrentMusicFinished = function ()
    local MaxDur = sneedio._CurrentPlayedMusic.MaxDuration;
    if(MaxDur <= 0) then return true; end
    return sneedio._CurrentPlayedMusic.CurrentDuration >= MaxDur - MUSIC_ENDS_IN_SECONDS;
end

--- gets playlist associated with player faction in campaign
-- @return a playlist tables (array)
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

--- gets playlist associated with player faction in battle
-- @return a playlist tables (array)
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

--- get player faction key
-- @return faction key string
sneedio.GetPlayerFaction = function ()
    if(BM) then
        return BM:get_player_army():faction_key();
    elseif(CM) then
        return CM:get_local_faction_name(true); -- warning
    else
        PrintError("called outside battle or campaign");
    end
end

--- get music situation in battle
-- @return a string either Deployment, FirstEngagement, Balanced, Losing, Winning, or LastStand
sneedio.GetBattleSituation = function ()
    if(BM == nil)then return; end
    return sneedio._CurrentSituation;
end

--- randomly get next music in the playlist based on the current situation (applies in the campaign too)
-- @return a table containing music data
sneedio.GetNextMusicData = function ()
    local Playlist = {};
    if(BM) then
        Playlist = sneedio.GetPlayerFactionPlaylistForBattle(sneedio.GetBattleSituation());
    elseif(CM)then
        Playlist = sneedio.GetPlayerFactionPlaylistForCampaign();
    else
        return sneedio._FrontEndMusic;
    end
    if(Playlist == nil)then
        return nil;
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

--- upload arbitary audio file to libsneedio
--- could be useful for playing UI sound effects or maybe even for custom advisor voice over?
-- @param identifier: string, name to associate the audio
-- @param fileName: string, path to the audio file
sneedio.LoadCustomAudio = function(identifier, fileName)
    if(sneedio.IsIdentifierValid(identifier))then
        print("audio already loaded for "..identifier);
        return;
    end
    print("attempt to load: "..fileName);
    if(sneedio.IsValidYoutubeUrl(fileName)) then
        fileName = sneedio._GetFileFromYoutubeUrl(fileName);
        print("youtube url detected, fileName is now: "..fileName);
    end
    if(libSneedio.LoadVoiceBattle(fileName, identifier)) then
        print(identifier..": audio loaded "..fileName);
        sneedio._ListOfCustomAudio[identifier] = fileName;
    else
        PrintError("failed to load Custom audio .."..identifier.." filename path: "..fileName.." maybe file doesn't exist or wrong path");
    end
end

--- check if custom audio identifier is already been used or not
-- @param identifier: string, identifier associated to a custom audio
-- @return true if it's valid
sneedio.IsIdentifierValid = function(identifier)
    return sneedio._ListOfCustomAudio[identifier] ~= nil;
end

--- play custom audio in 2D space
-- @param identifier: string, name to associate the audio (see LoadCustomAudio to upload arbitary audio file)
-- @param volume: the loudness real number ranging [0..1]
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

--- play custom audio in campaign
-- @param identifier: string, name to associate the audio (see LoadCustomAudio to upload arbitary audio file)
-- @param atPosition: userdata vector (is_vector), position where the audio will be played
-- @param maxDistance: number, distance from the listener
-- @param volume: the loudness real number ranging [0..1]
sneedio.PlayCustomAudioCampaign = function (identifier, atPosition, maxDistance, volume)
    if(sneedio.IsVoiceStopped()) then return; end

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

--- play custom audio in campaign
-- @param identifier: string, name to associate the audio (see LoadCustomAudio to upload arbitary audio file)
-- @param atPosition: userdata vector (is_vector), position where the audio will be played
-- @param maxDistance: number, distance from the listener
-- @param volume: the loudness real number ranging [0..1]
-- @param listener (optional): userdata vector (is_vector), the listener position (optional, listener is the camera)
sneedio.PlayCustomAudioBattle = function(identifier, atPosition, maxDistance, volume, listener)
    if(sneedio.IsVoiceStopped()) then return; end

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

--- register voices to associated unit
-- with format like this
-- {
-- 	["Select"] = {},
-- 	["Affirmative"] = {},
-- 	["Hostile"] = {},
-- 	["Abilities"] = {},
-- 	["Diplomacy"] = {
-- 		["Diplomacy_str_x"] = "",
-- 		["Diplomacy_str_y"] = "",
-- 	},
-- 	["Ambiences"] = {
-- 		["CampaignMap"] = {
-- 			["Any"] = { {Cooldown = 0, FileName = ""} },
-- 			["Desert"] = {Cooldown = 0, FileName = ""},
-- 			["OldWorld"] = {Cooldown = 0, FileName = ""},
-- 			["HighElves"] = {Cooldown = 0, FileName = ""},
-- 			["Lustria"] = {Cooldown = 0, FileName = ""},
-- 			["Snow"] = {Cooldown = 0, FileName = ""},
-- 			["Chaos"] = {Cooldown = 0, FileName = ""}
-- 		},
-- 		["Idle"] = {Cooldown = 0, FileName = ""},
-- 		["Attack"] = {Cooldown = 0, FileName = ""},
-- 		["Wavering"] = {Cooldown = 0, FileName = ""},
-- 		["Winning"] = {Cooldown = 0, FileName = ""},
-- 		["Rampage"] = {Cooldown = 0, FileName = ""},
-- 		["EnslaveOption"] = {Cooldown = 0, FileName = ""},
-- 		["KillOption"] = {Cooldown = 0, FileName = ""},
-- 		["RansomOption"] = {Cooldown = 0, FileName = ""},
-- 	},
-- },
-- note: Cooldown is in second!
-- @param unittype: string, a main unit key associated with the unit
-- @param fileName: a table, see the format above
sneedio.RegisterVoice = function(unittype, fileNames)
    PrintWarning("Registering voice "..unittype);
    var_dump(fileNames);
    sneedio._ListOfRegisteredVoices[unittype] = fileNames;
end

--- get registered voices from a unit
-- @return a voice table (see RegisterVoice note to see how the table looks like)
sneedio.GetListOfVoicesFromUnit = function(unitType, voiceType)
    if(sneedio._ListOfRegisteredVoices[unitType] == nil) then return nil; end
    if(sneedio._ListOfRegisteredVoices[unitType][voiceType] == nil) then return nil; end
    return sneedio._ListOfRegisteredVoices[unitType][voiceType];
end

--#endregion audio/voices operations

--#region battle helper

--- get player main general unit
-- @return general unit userdata (is_unit), it's possible to return null
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

--- register a callback for each speed event (including pause)
-- @param UniqueName: string to identify the callback
-- @param EventName: string either Paused, SlowMo, Normal, or FastForward
-- @param Callback: void function
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

--- check if unit is selected (battle only)
-- @param unit: userdata unit (is_unit)
-- @return boolean true if selected
sneedio.IsUnitSelected = function(unit)
    if(not is_unit(unit)) then
        print("not a unit");
        return false;
    end;
    local unitTypeInstanced = sneedio._UnitTypeToInstancedSelect(unit);
    return sneedio._MapUnitToSelected[unitTypeInstanced];
end

--- is battle paused
-- @return boolean true if paused
sneedio.IsBattlePaused = function()
    if (BM == nil) then return false; end
    local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
    if(parent)then
        local button = find_uicomponent(parent, "pause");
        -- var_dump(uic_pause:CurrentState());
        return button:CurrentState() == "selected";
    end
end

--- is battle in slow mode
-- @return boolean true if in slow mode
sneedio.IsBattleInSlowMo = function()
    if (BM == nil) then return false; end
    local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
    if(parent)then
        local button = find_uicomponent(parent, "slow_mo");
        -- var_dump(uic_pause:CurrentState());
        return button:CurrentState() == "selected";
    end
end

--- is battle in normal mode (1x speed)
-- @return boolean true if in in normal mode (1x speed)
sneedio.IsBattleInNormalPlay = function()
    if (BM == nil) then return false; end
    local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
    if(parent)then
        local button = find_uicomponent(parent, "play");
        -- var_dump(uic_pause:CurrentState());
        return button:CurrentState() == "selected";
    end
end

--- is battle in fast forward mode (2x speed and up)
-- @return boolean true if in fast forward mode (2x speed and up)
sneedio.IsBattleInFastForward = function()
    if (BM == nil) then return false; end
    local parent = find_uicomponent(core:get_ui_root(), "radar_holder", "speed_buttons");
    if(parent) then
        local buttonFWD = find_uicomponent(parent, "fwd");
        local buttonFFWD = find_uicomponent(parent, "ffwd");
        return buttonFWD:CurrentState() == "selected" or buttonFFWD:CurrentState() == "selected";
    end
end

--- get current speed mode
-- @return string either None (if called outside battle mode), Paused, SlowMo, Normal, or FastForward
sneedio.GetBattleSpeedMode = function()
    if(BM == nil) then return "None"; end
    if(sneedio.IsBattlePaused()) then return "Paused"; end
    if(sneedio.IsBattleInSlowMo()) then return "SlowMo"; end
    if(sneedio.IsBattleInNormalPlay()) then return "Normal"; end
    if(sneedio.IsBattleInFastForward()) then return "FastForward"; end
    return "None";
end

--- get current battle ticks
-- @return battle ticks in ms
sneedio.GetBattleTicks = function()
    return sneedio._BattleCurrentTicks;
end

--- set libsneedio music channel volume
-- @param amount real number range [0..1]
sneedio.SetMusicVolume = function (amount)
    sneedio._CurrentMusicVolume = amount;
    sneedio._CurrentUserConfig.MusicVolume = amount * 100;
    sneedio._MaximumMusicVolume = amount;
    libSneedio.SetMusicVolume(amount);
    print("set music volume to "..amount*100);
end

-- set libsneedio sound effect channel volume
-- @param amount real number range [0..1]
sneedio.SetSoundEffectVolume = function (amount)
    sneedio._CurrentUserConfig.SoundEffectVolume = amount * 100;
    libSneedio.SetSoundEffectVolume(amount);
    print("set sound effect volume to "..amount*100);
end

--- get libsneedio music channel volume
-- @return amount real number range [0..1]
sneedio.GetMusicVolume = function ()
    return libSneedio.GetMusicVolume();
end

sneedio.GetCurrentConfig = function ()
    return sneedio._CurrentUserConfig;
end

sneedio.DownloadYoutubeUrls = function (urls)
    ForEach(urls, function (url)
        print("queued youtube url "..url);
        if(not sneedio.IsValidYoutubeUrl(url)) then
            throw("invalid youtube url "..url, 2);
            return;
        end
        if(not HasKey(sneedio._MapUrlToActualFiles, url)) then
            PrintWarning("not downloaded yet "..url);
            sneedio._WriteYtDlpFlagDirty(true);
            sneedio._MapUrlToActualFiles[url] = "";
        end
    end);
    WriteFile(SNEEDIO_YT_DLP_QUEUE_MOD_JSON, json.encode(sneedio._MapUrlToActualFiles));
end

-- a function that checks if an url is valid youtube video link
-- @param url string
-- @return boolean true if valid
sneedio.IsValidYoutubeUrl = function (url)
    if (url == nil) then return false; end
    return libSneedio.IsValidYoutubeLink(url);
end

--#endregion battle helper
---------------------------------PRIVATE methods----------------------------------

sneedio._GetFileFromYoutubeUrl = function (url)
    if(not sneedio.IsValidYoutubeUrl(url)) then
        throw("invalid youtube url "..url, 2);
    end
    local file = nil;
    print("audio file is a youtube url, remapping to local file");
    PrintWarning(debug.traceback());
    if(HasKey(sneedio._MapUrlToActualFiles, url)) then
        file = sneedio._MapUrlToActualFiles[url];
    else
        sneedio._WriteYtDlpFlagDirty(true);
        PrintError("no local file found for "..url);
        throw("no local file found for "..url, 2);
    end
    return file;
end

sneedio._StartDownloadingYoutube = function ()
    print("preparing");
    local urls = {};
    ForEach(sneedio._MapUrlToActualFiles, function (actualFile, url)
        if(actualFile == "") then
            table.insert(urls, url);
        end
    end);
    var_dump(urls);
    if(#urls == 0) then
        PrintWarning("no youtube urls to download");
        return;
    end
    if(not sneedio._CurrentUserConfig.AllowModToDownloadAudio) then
        PrintWarning("user config does not allow downloading audio");
        return;
    end
    var_dump(sneedio._MapUrlToActualFiles);
    libSneedio.DownloadYoutubeUrls(urls);
    local progressBox = nil;
    progressBox = MessageBox("ytdlp", "Sneedio\n\nPlease stand by...", nil, nil, true);
    TM.RepeatCallback(function ()
        try{
            function ()
                local dy_text = find_uicomponent(progressBox, "DY_text");
                local title, url, details = sneedio._YtDlpDownloadProgressTracker();
                var_dump(title);
                var_dump(url);
                var_dump(details);
                if(title) then
                    if(title ~= "") then
                        local textToDisplay = "Sneedio\n\nProcessing file "..tostring(details.FileNo).." out of "..tostring(details.FileNoOutOf).."\n";
                        if(details.Status == DOWNLOAD_PROGRESS_PREPARING) then textToDisplay = textToDisplay.."Preparing "; end
                        if(details.Status == DOWNLOAD_PROGRESS_DOWNLOADING) then textToDisplay = textToDisplay.."Downloading "; end
                        if(details.Status == DOWNLOAD_PROGRESS_CONVERTING) then textToDisplay = textToDisplay.."Converting "; end
                        textToDisplay = textToDisplay ..  " " .. title .. "\n";
                        if(details.Status == DOWNLOAD_PROGRESS_DOWNLOADING) then textToDisplay = textToDisplay.." ("..tostring(details.Percentage).."%)\n"; end
                        if(details.Status == DOWNLOAD_PROGRESS_DOWNLOADING) then textToDisplay = textToDisplay.." Speed "..tostring(details.CurrentSpeedInKBpS).." KB/s ".." Size "..tostring(details.SizeInKB).." KB\n"; end
                        sneedio._MapUrlToActualFiles["https://www.youtube.com/watch?v="..url] = SNEEDIO_YT_DLP_DIRECTORY.."/"..title..".mp3";
                        textToDisplay = textToDisplay.."https://youtu.be/"..url;
                        dy_text:SetStateText(textToDisplay, "whatever");
                    end
                else
                    DelayedCall(function ()
                        progressBox:Destroy();
                        local status = sneedio._YtDlpDownloadCompleteStatusTracker();
                        var_dump(status);
                        if(status.DownloadStatus == DOWNLOAD_STATUS_FAIL) then
                            MessageBox("ytdlp error", "Sneedio\n\nDownload failed.\n\n"..status.ErrorMessage);
                        elseif (status.bAreDownloadsOk) then
                            sneedio._WriteYtDlpFlagDirty(false);
                            WriteFile(SNEEDIO_YT_DLP_QUEUE_MOD_JSON, json.encode(sneedio._MapUrlToActualFiles));
                        end
                        TM.RemoveCallback("download polling");
                    end, SYSTEM_TICK * 10, "ytdlp_destroy");
                end
            end,
            catch{
                function (err)
                    print("Error: "..err);
                    print(debug.traceback());
                end
            }
        };
    end, SYSTEM_TICK * 10 * 2, "download polling");
end

--- private volume method controlled by music system
-- @param amount real number range [0..1]
sneedio._SetMusicVolume = function (amount)
    libSneedio.SetMusicVolume(tostring(amount));
end

--- load user configs from file
sneedio._LoadUserConfig = function ()
    local userConfig = nil;
    try {
        function ()
            local userConfigJson = ReadFile(SNEEDIO_USER_CONFIG_JSON);
            userConfig = json.decode(userConfigJson);
            sneedio._CurrentUserConfig = userConfig;
        end,
        catch{
            function (err)
                PrintWarning("user-sneedio.json is not valid json or not found. Not loading user config.");
                PrintError(err);
            end
        }
    }
    if userConfig == nil then
        -- create default config
        userConfig = {
            MusicVolume = 15,
            SoundEffectVolume = 70,
            SoundEffectMute = false,
            MusicMute = false,
            NoticeNoMusicFoundForFaction = true,
            AlwaysMuteWarscapeMusic = false,
            FrontEndMusic = {},
            BattleMusic = {},
            FactionMusic = {},
            AllowModToModifyMenuMusic = true,
            AllowModToDownloadAudio = true,
            AllowModToModifyFactionMusic = true,
        }
        WriteFile(SNEEDIO_USER_CONFIG_JSON, json.encode(userConfig));
        sneedio._bIsFirstTimeStart = true;
        PrintWarning("created default user-sneedio.json");
    end

    if(userConfig.MusicVolume ~= nil and type(userConfig.MusicVolume) == "number") then
        sneedio.SetMusicVolume(userConfig.MusicVolume / 100);
    end
    if(userConfig.SoundEffectVolume ~= nil and type(userConfig.SoundEffectVolume) == "number") then
        sneedio.SetSoundEffectVolume(userConfig.SoundEffectVolume / 100);
    end
    if(userConfig.MusicEndsPadding ~= nil and type(userConfig.MusicEndsPadding) == "number") then
        sneedio._MusicEndsPadding = userConfig.MusicEndsPadding;
    end
    if(userConfig.MusicMute ~= nil and type(userConfig.MusicMute) == "boolean") then
        sneedio.MuteMusic(userConfig.MusicMute);
    end
    if(userConfig.SoundEffectMute ~= nil and type(userConfig.SoundEffectMute) == "boolean") then
        sneedio.MuteSoundFX(userConfig.SoundEffectMute);
    end
    if(userConfig.NoticeNoMusicFoundForFaction ~= nil and type(userConfig.NoticeNoMusicFoundForFaction) == "boolean") then
        sneedio._NoticeNoMusicFoundForFaction = userConfig.NoticeNoMusicFoundForFaction;
    else
        sneedio._CurrentUserConfig.NoticeNoMusicFoundForFaction = true;
    end
    if(userConfig.AllowModToModifyMenuMusic ~= nil and type(userConfig.AllowModToModifyMenuMusic) == "boolean") then
        sneedio._CurrentUserConfig.AllowModToModifyMenuMusic = userConfig.AllowModToModifyMenuMusic;
    else
        sneedio._CurrentUserConfig.AllowModToModifyMenuMusic = true;
    end
    if(userConfig.AllowModToModifyFactionMusic ~= nil and type(userConfig.AllowModToModifyFactionMusic) == "boolean") then
        sneedio._CurrentUserConfig.AllowModToModifyFactionMusic = userConfig.AllowModToModifyFactionMusic;
    else
        sneedio._CurrentUserConfig.AllowModToModifyFactionMusic = true;
    end
    if(userConfig.AllowModToDownloadAudio ~= nil and type(userConfig.AllowModToDownloadAudio) == "boolean") then
        sneedio._CurrentUserConfig.AllowModToDownloadAudio = userConfig.AllowModToDownloadAudio;
    else
        sneedio._CurrentUserConfig.AllowModToDownloadAudio = true;
    end

    --var_dump(userConfig);
    sneedio._FrontEndMusic = userConfig["FrontEndMusic"] or {};
    local BatteMusic = userConfig["BattleMusic"];
    local CampaignMusic = userConfig["FactionMusic"];

    ForEach(CampaignMusic, function (campaignMusicArr, faction)
        print("_LoadUserConfig: processing campaign music "..faction);
        if(sneedio._MusicPlaylist[faction] == nil) then
            sneedio._MusicPlaylist[faction] = {};
        end
        if(sneedio._MusicPlaylist[faction]["CampaignMap"] == nil) then
            sneedio._MusicPlaylist[faction]["CampaignMap"] = {};
        end
        ForEach(campaignMusicArr, function (m)
            m.CurrentDuration = 0;
            table.insert(sneedio._MusicPlaylist[faction]["CampaignMap"], m);
        end);
        print("_LoadUserConfig: campaign music "..faction.." loaded "..#sneedio._MusicPlaylist[faction]["CampaignMap"].." music");
    end);

    ForEach(BatteMusic, function (battleMusicTypes, faction)
        print("_LoadUserConfig: processing "..faction);
        if(sneedio._MusicPlaylist[faction] == nil) then
            sneedio._MusicPlaylist[faction] = {};
        end
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

    var_dump(sneedio._MusicPlaylist);
    print("audio loaded");
end

sneedio._LoadYtDlpUrlToMusicConfig = function ()
    print("_LoadYtDlpUrlToMusicConfig executed");
    local ytDlpUrlToMusic = nil;
    try {
        function ()
            local ytDlpUrlToMusicJson = ReadFile(SNEEDIO_YT_DLP_QUEUE_MOD_JSON);
            ytDlpUrlToMusic = json.decode(ytDlpUrlToMusicJson);
        end,
        catch{
            function (err)
                PrintWarning("yt-dlp-db.json is not valid json or not found. Not loading yt-dlp-db.json.");
                PrintError(err);
            end
        }
    }
    PrintError("sneedio._MapUrlToActualFiles");
    if(ytDlpUrlToMusic == nil) then return; end
    sneedio._MapUrlToActualFiles = ytDlpUrlToMusic;
    var_dump(sneedio._MapUrlToActualFiles);
end

-- called during frontend
sneedio._FirstTimeSetup = function ()
    if(not sneedio.IsFileExist(SNEEDIO_SYSTEM_CONFIG_JSON))then
        local sneedioVersion = {
            version = sneedio.VERSION,
        };
        sneedio.WriteFile(SNEEDIO_SYSTEM_CONFIG_JSON, json.encode(sneedioVersion));
        return true;
    end
    return false;
end

sneedio._UpdateSneedioSystemJson = function(data)
    data.version = sneedio.VERSION;
    WriteFile(SNEEDIO_SYSTEM_CONFIG_JSON, json.encode(data));
end

sneedio._IsYtDlpFlagDirty = function()
    local data = sneedio._GetSneedioSystemJson();
    return data.IsYtDlpDbDirty or false;
end

sneedio._WriteYtDlpFlagDirty = function(flag)
    local data = {
        IsYtDlpDbDirty = flag,
    };
    sneedio._UpdateSneedioSystemJson(data);
end

sneedio._GetSneedioSystemJson = function()
    local data = {};
    try {
        function ()
            data = json.decode(ReadFile(SNEEDIO_SYSTEM_CONFIG_JSON));
        end,
        catch{
            function (err)
                PrintWarning("sneedio-system.json is not valid json. Not loading user config.");
                PrintError(err);
            end
        }
    }
    return data;
end

sneedio._YtDlpDownloadProgressTracker = function ()
    if(libSneedio.GetYtDlpDownloadStatus()) then
        local title, url, details = libSneedio.GetYtDlpDownloadStatus();
        return title, url, details;
    end
end

sneedio._YtDlpDownloadCompleteStatusTracker = function ()
    return libSneedio.GetYtDlpDownloadCompleteStatus();
end

--#region frontend procedures

sneedio._InitFrontEnd = function ()
    TM.Init();

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

    SetupControlPanel();
    if(sneedio._bIsFirstTimeStart)then
        MessageBox("sneedio-defaultconf", "Sneedio\n\nA new user-sneedio.json has been created.\nEdit the file, put your music in the game folder, and restart the game.\nVisit https://tinyurl.com/sneedio to see config examples.",
            function ()
                MessageBox("Sneedio1", "It is recommended to mute in game music when using sneedio.\n\nYou can change this setting in the options menu.", function ()
                    if(sneedio._IsYtDlpFlagDirty()) then
                        sneedio._StartDownloadingYoutube();
                    end
                end);
            end
        );
    else
        if(sneedio._IsYtDlpFlagDirty()) then
            sneedio._StartDownloadingYoutube();
        end
    end
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
    TM.Init();

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

    SetupControlPanel();
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
            if(sneedio.IsValidYoutubeUrl(subvoice)) then
                subvoice = sneedio._GetFileFromYoutubeUrl(subvoice);
                print("youtube url detected, fileName is now: "..subvoice);
            end
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
            if(sneedio.IsValidYoutubeUrl(subvoice)) then
                subvoice = sneedio._GetFileFromYoutubeUrl(subvoice);
                print("youtube url detected, fileName is now: "..subvoice);
            end
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
            if(sneedio.IsValidYoutubeUrl(subvoice)) then
                subvoice = sneedio._GetFileFromYoutubeUrl(subvoice);
                print("youtube url detected, fileName is now: "..subvoice);
            end
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
            if(sneedio.IsValidYoutubeUrl(subvoice)) then
                subvoice = sneedio._GetFileFromYoutubeUrl(subvoice);
                print("youtube url detected, fileName is now: "..subvoice);
            end
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
            if(sneedio.IsValidYoutubeUrl(subvoice)) then
                subvoice = sneedio._GetFileFromYoutubeUrl(subvoice);
                print("youtube url detected, fileName is now: "..subvoice);
            end
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
    if(sneedio.IsVoiceStopped()) then return; end
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
        if(General:is_shattered())then
            sneedio._CurrentSituation = "Losing";
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
        local fileName = musicData.FileName;
        if(sneedio.IsValidYoutubeUrl(fileName)) then
            fileName = sneedio._GetFileFromYoutubeUrl(fileName);
            print("youtube url detected, fileName is now: "..fileName);
        end
        if(libSneedio.PlayMusic(fileName)) then
            if(musicData.StartPos and musicData.StartPos < musicData.MaxDuration )then
                if(libSneedio.SetMusicPosition(musicData.StartPos)) then
                    print("set music position to "..tostring(musicData.StartPos));
                end
            end
            var_dump(musicData);
            print("music played...");
            if(BM) then
                BM:set_volume(0, 0);
            end
        else
            print("failed to play music: "..fileName);
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
    local delta = sneedio.MapValueToNewRange(sneedio._CurrentUserConfig.MusicVolume, 0, 100, 0.01, 0.05);
    if(sneedio._TransitionMusicFlag == 2 and sneedio._CurrentMusicVolume <= sneedio._MaximumMusicVolume) then
        print("processing flag = 2 until not mute");
        sneedio._CurrentMusicVolume = sneedio._CurrentMusicVolume + delta;--0.05;
        sneedio._SetMusicVolume(sneedio._CurrentMusicVolume);
    end
    -- mute it
    if(sneedio._TransitionMusicFlag == 1) then
        print("processing flag = 1 until equal to mute");
        sneedio._CurrentMusicVolume = sneedio._CurrentMusicVolume - delta; --0.05;
        sneedio._SetMusicVolume(sneedio._CurrentMusicVolume);
    end
end

sneedio._PlayMusic = function (musicData)
    if(not musicData)then
        print("musicdata is null. aborting");
        return;
    end
    if(not musicData.FileName)then
        print("musicdata.FileName is null. aborting");
        return;
    end
    print("playing music ".. musicData.FileName);
    if(not sneedio.IsValidYoutubeUrl(musicData.FileName)) then
        if(not libSneedio.IsMusicValid(musicData.FileName))then
            print("unable to load file "..musicData.FileName.. " this will not change the situation!");
            return;
        end
    else
        if(sneedio._GetFileFromYoutubeUrl(musicData.FileName) == "") then
            print("URL "..musicData.FileName.. " has no cached music file. this will not change the situation!");
            return;
        else
            if(not libSneedio.IsMusicValid(sneedio._GetFileFromYoutubeUrl(musicData.FileName)))then
                local fil = sneedio._GetFileFromYoutubeUrl(musicData.FileName);
                print("unable to load file "..fil.. " pointed by this URL "..musicData.FileName.." this will not change the situation!");
                return;
            end
        end
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
        sneedio._CurrentPlayedMusic.CurrentDuration = libSneedio.GetMusicPosition();
        PrintWarning(SecondsToMMSS(sneedio._CurrentPlayedMusic.CurrentDuration).." - "..SecondsToMMSS(sneedio._CurrentPlayedMusic.MaxDuration).." track "  ..sneedio._CurrentPlayedMusic.FileName);
    end
end

sneedio._UpdateMusicSituation = function ()
    if(sneedio._CurrentSituation == "Deployment") then return; end
    if(sneedio._CurrentSituation == "FirstEngagement") then return; end

    local PlayerRouts = sneedio.GetPlayerSideRoutRatioQuick();
    print("PlayerRouts" .. tostring(PlayerRouts));
    local EnemyRouts = sneedio.GetEnemySideRoutRatioQuick();
    print("EnemyRouts" .. tostring(EnemyRouts));

    if (IsBetween(0, 0.25, PlayerRouts) and IsBetween(0, 0.7, EnemyRouts))then
        print("changed to balanced");
        sneedio._CurrentSituation = "Balanced";
    elseif (IsBetween(0.28, 0.69, PlayerRouts) and IsBetween(0, 0.7, EnemyRouts)) then
        print("changed to losing");
        sneedio._CurrentSituation = "Losing";
    elseif (IsBetween(0.7, 1, PlayerRouts) and IsBetween(0, 0.7, EnemyRouts)) then
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
    print("important phase changes!");
    print(debug.traceback())
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
    if(sneedio.IsVoiceStopped()) then return; end
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
            local fileName = filename.FileName;
            if(sneedio.IsValidYoutubeUrl(fileName)) then
                fileName = sneedio._GetFileFromYoutubeUrl(fileName);
                print("youtube url detected, fileName is now: "..fileName);
            end
            if(libSneedio.LoadVoiceBattle(fileName, unitTypeInstanced)) then
                table.insert(sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced], filename);
                print(unitTypeInstanced..": audio loaded "..fileName.." for voice type "..VoiceType);
            else
                PrintError("warning, failed to load .."..unitTypeInstanced.." filename path: "..filename.FileName.." for voice type "..VoiceType.." maybe file doesn't exist or wrong path");
            end
        else
            print("attempt to load: "..filename);
            if(sneedio.IsValidYoutubeUrl(filename)) then
                filename = sneedio._GetFileFromYoutubeUrl(filename);
                print("youtube url detected, fileName is now: "..filename);
            end
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
        sneedio.Pause(true);
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

    TM.RepeatCallback(function ()
        sneedio._MonitorRoutingUnits()
    end, BATTLE_MORALE_MONITOR_TICK, --expensive operations
    "sneedio_monitor_player+enemies_rallying_units_and_general");

    TM.RepeatCallback(function ()
        sneedio._bPaused = sneedio.IsBattlePaused();
        sneedio._bHasSpeedChanged = sneedio._CurrentSpeed ~= sneedio.GetBattleSpeedMode();
        sneedio._CurrentSpeed = sneedio.GetBattleSpeedMode();
        if(sneedio._bHasSpeedChanged) then
            sneedio._ProcessSpeedEvents(sneedio._CurrentSpeed);
        end
        if(BM and not sneedio.IsBattlePaused()) then
            local camera = BM:camera();
            sneedio.UpdateCameraPosition(camera:position(), camera:target());
            sneedio._BattleOnTick();
        end
    end, SYSTEM_TICK,
    "sneedio_monitor_battle_camera_position_and_run_tick_funs");

end

sneedio._InitBattle = function(units)
    TM.Init();
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
-- padding when the music is ending
sneedio._MusicEndsPadding = MUSIC_ENDS_IN_SECONDS;

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

sneedio._MapUrlToActualFiles = {
    -- ["null"] = "",
};

sneedio._bPaused = false;

sneedio._StopVoice = false;

--#endregion music vars

-- holds current sneedio config json
sneedio._CurrentUserConfig = {};

sneedio._bIsFirstTimeStart = false;

sneedio._FrontEndMusic = {
    FileName = "",
    MaxDuration = 0
};

sneedio._bNotInFrontEnd = true;
sneedio.VERSION = VERSION;
sneedio.TM = TM;
sneedio.MUSIC_TICK = MUSIC_TICK;
sneedio.TRANSITION_TICK = TRANSITION_TICK;
sneedio.SYSTEM_TICK = SYSTEM_TICK;
sneedio.BATTLE_EVENT_MONITOR_TICK = BATTLE_EVENT_MONITOR_TICK ;
sneedio.BATTLE_MORALE_MONITOR_TICK = BATTLE_MORALE_MONITOR_TICK;
sneedio.AMBIENT_TICK = AMBIENT_TICK;
sneedio.AMBIENT_TRIGGER_CAMERA_DISTANCE = AMBIENT_TRIGGER_CAMERA_DISTANCE;
sneedio.SNEEDIO_DEBUG = SNEEDIO_DEBUG;

-- if libsneedio is not loaded, then call MessageBox with a message "failed to load libsneedio"
if not libSneedio then
    MessageBox("sneedio_msgbox", "failed to load libsneedio, please check your mod installation");
    return;
else
    print("all ok");
end


--return sneedio;

--sneedio.Debug();

--print(sneedio.GetPlayerFaction());

out("hello world");

--var_dump(sneedio);
--var_dump(libSneedio);

sneedio._SneedioBattleMain = function()
    if(core == nil) then
        PrintError("SNEEDIO FATAL. Core object was NULL, aborting. Called from ");
        PrintError(debug.traceback());
        return;
    end
    -- fill bm variable!
    BM = get_bm();

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

sneedio._SneedioCampaignMain = function ()
    if(core == nil) then
        PrintError("SNEEDIO FATAL. Core object was NULL, aborting. Called from ");
        PrintError(debug.traceback());
        return;
    end
    sneedio._InitCampaign();
    print("campaign has sneeded!");
end

sneedio._SneedioFrontEndMain = function ()
    if(core == nil) then
        PrintError("SNEEDIO FATAL. Core object was NULL, aborting. Called from ");
        PrintError(debug.traceback());
        return;
    end
    PrintWarning("called in FRONT END\n");
    sneedio._InitFrontEnd();
end

sneedio.InitSneedio = function ()
    if(TM._bInited) then return TM._bInited; end
    if(math == nil or
       core == nil or
       find_uicomponent == nil or
       is_vector == nil or
       is_uicomponent == nil) then
        PrintWarning("some variable not set properly! may fail");
    end
    return TM.Init();
end

_G.sneedio = sneedio;

print("off we go....");

if(sneedio.InitSneedio()) then
    print("sneedio init ok");
    -- load at the beginning
    sneedio._FirstTimeSetup();
    sneedio._LoadUserConfig();
    sneedio._LoadYtDlpUrlToMusicConfig();

    PrintError("libsneedio.GetInfinity is "..tostring(libSneedio.GetInfinity()));
    PrintError("math.huge is "..tostring(math.huge));
    PrintError("math.pi is "..tostring(math.pi));
end

return _G.sneedio;