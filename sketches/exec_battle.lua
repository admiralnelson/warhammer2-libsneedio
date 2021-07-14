
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

----

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

local ArrayContains = function(Array, Object)
	for _, item in ipairs(Array) do
		if(item == Object) return true;
	end
	return false;
end

sneedio.PauseAll = function(bPause)
	bPause = bPause or true;
	if(bPause)
		-- libsneedio.PauseSoundFX();
		-- libsneedio.PauseMusic();
	else
		-- libsneedio.UnpauseSoundFX();
		-- libsneedio.UnpauseMusic();
	end
end



sneedio.Debug = function()
	print("list of registered voices");
	var_dump(sneedio._ListOfRegisteredVoicesOnActivate);
	if BM then
		print("list of registered voices on battle");
		var_dump(sneedio._ListOfRegisteredVoicesOnBattle);
	end
end

sneedio.RegisterVoiceOnActivate = function(unitType, fileNames)
	sneedio._ListOfRegisteredVoicesOnActivate[unitType] = fileNames;
end

sneedio.RegisterVoiceOnAttack = function(unitType, fileNames)
	sneedio._ListOfRegisteredVoicesOnAttack[unitType] = fileNames;
end

sneedio.RegisterAmbientVoice = function(unitType, fileNames, mode)
	if(not ArrayContains({"idle", "attack", "wavering", "winning", "always"}, mode)) then 
		print("invalid mode "..mode.." allowed: {'idle', 'attack', 'wavering', 'winning', 'always'}");
		return;
	end
	sneedio._ListOfRegisteredVoicesForAmbientOnBattle[unitType][mode] = fileNames;
end

sneedio.RegisterVoiceOnReject = function(unitType, fileNames)
	sneedio._ListOfRegisteredVoicesOnReject[unitType] = fileNames;
end

sneedio.GetListOfVoicesFromUnit = function(unitType)
	return sneedio._ListOfRegisteredVoicesOnActivate[unitType];
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

---------------------------------PRIVATE methods----------------------------------

sneedio._UnitTypeToInstanced = function (unit)
	return unit:type().."_instance_"..tostring(unit:name());
end

sneedio._UnitTypeToAttack = function (unit)
	return unit:type().."_instanceAttack_"..tostring(unit:name());
end

sneedio._UnitTypeToInstancedAmbient = function (unit)
	return unit:type().."_instanceAmbient_"..tostring(unit:name());
end

sneedio._PlayVoiceBattle = function(unitTypeInstanced, cameraPos, playAtPos)
	print("about to play audio");
	print("unit is "..unitTypeInstanced);
	local ListOfAudio = sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced];
	var_dump(ListOfAudio);
	local PickRandom = math.random( 1, #ListOfAudio);
	print("playing voice: ".. ListOfAudio[PickRandom]);
	local result = libSneedio.PlayVoiceBattle(unitTypeInstanced, tostring(PickRandom), CAVectorToSneedVector(playAtPos));
	var_dump(result);
	if(result == 0) then
		print("audio played");
	end
	libSneedio.UpdateListenerPosition(CAVectorToSneedVector(cameraPos));
	print(" at camera pos: ".. v_to_s(cameraPos).. " from: ".. v_to_s(playAtPos));
end

sneedio._InitBattle = function(units)
	for _, unit in ipairs(units) do 
		local UnitVoices = sneedio._ListOfRegisteredVoicesOnActivate[unit:type()];
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

---------------------------------------Private variables----------------------------------------------------------

sneedio._ListOfRegisteredVoicesForAmbientOnBattle = {
	["null"] = {
		["idle"] = {},
		["attack"] = {},
		["wavering"] = {},
		["winning"] = {},
		["always"] = {}
	}
}

sneedio._ListOfRegisteredVoicesOnAttack = {
	["null"] = {},
};

sneedio._ListOfRegisteredVoicesOnReject = {
	["null"] = {},
};


sneedio._ListOfRegisteredVoicesOnActivate = {
	["null"] = {},
};

----------------------------------------- not persistent -------------------------------

sneedio._ListOfRegisteredVoicesOnBattle = {
	["null"] = {},
};

sneedio._MapUnitToSelected = {
	["null"] = false,
};

----------------------------------------- not persistent -------------------------------

print("all ok");

_G.sneedio = sneedio;

--return sneedio;


local BM;
if core:is_battle() then
    BM = get_bm();
end


-- let's register our audio first

sneedio.RegisterVoiceOnActivate("wh2_dlc14_brt_cha_repanse_de_lyonesse_0", {
	"woman_yell_1.ogg", 
	"woman_yell_2.ogg"
});

sneedio.RegisterVoiceOnActivate("wh2_dlc14_brt_cha_henri_le_massif_0", {
	"man_grunt_1.ogg", 
	"man_grunt_2.ogg",
	"man_grunt_5.ogg",
	"man_grunt_13.ogg",
	"man_grunt_3.ogg",
});

sneedio.Debug();

function UpdateCamera()
	if(BM) then
		local camera = BM:camera();
		sneedio.UpdateCameraPosition(camera:position(), camera:target());
	end
end

BM:register_repeating_timer("UpdateCamera", 100);

out("hello world");

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

	--- setup voices here ---

	local ListOfUnits = {};
    ForEachUnitsPlayer(function(CurrentUnit, CurrentArmy)
		table.insert(ListOfUnits, CurrentUnit);
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
	
	--- setup ui event here ---
	core:add_listener(
		"admiralnelson_escape_mute_music_and_sound_effects",
		"ShortcutTriggered", function(context)
			return context.string == "escape_menu"
		end, function()
			bm:callback(function()
				print("escape_menu called");
				-- sneedio.PauseAll();
			end, 
			0.5);
		end, 
		true);
		
		
	out("battle has sneeded!");
end

if BM ~= nil then SneedioBattleMain(); end