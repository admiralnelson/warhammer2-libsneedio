local MOCK_UP = false;
local PATH = "/script/bin/";
local OUTPUTPATH = "";

local base64 = require("lua/base64");

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

local libSneedio = pcall(require, DLL_FILENAMES[1]);

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

local VectorToString = function(SneedVector)
	return "x: "..SneedVector.x.." y: "..SneedVector.y.." z "..SneedVector.z;
end

local CAVectorToSneedVector = function(CAVector)
	return { 
		x = CAVector.get_x(),
		y = CAVector.get_y(),
		z = CAVector.get_z()
	};
end

sneedio.Debug = function()
	print("list of registered voices");
	var_dump(sneedio._ListOfRegisteredVoices);
	if BM then
		print("list of registered voices on battle");
		var_dump(sneedio._ListOfRegisteredVoicesOnBattle);
	end
end

sneedio.RegisterVoice = function(unittype, fileNames)
	sneedio._ListOfRegisteredVoices[unittype] = fileNames;
end

sneedio.GetListOfVoicesFromUnit = function(unitType)
	return sneedio._ListOfRegisteredVoices[unitType];
end

sneedio.UpdateCameraPosition = function(cameraPos, cameraTarget)
	cameraPos = CAVectorToSneedVector(cameraPos);
	cameraTarget = CAVectorToSneedVector(cameraTarget);
	libSneedio.UpdateListenerPosition(cameraPos, cameraTarget);
end

sneedio.RegisterSound2D = function(name, fileName)
	-- libSneedio.Load2DAudio(name, fileName);
end

sneedio.PlaySound2D = function(name)
	-- libSneedio.Play2DAudio(name);
end

---------------------------------PRIVATE methods----------------------------------

sneedio._UnitTypeToInstanced = function (unitType, unitName)
	return unitType .. "_instance_" .. tostring(unitName);
end

sneedio._PlayVoiceBattle = function(unitTypeInstanced, cameraPos, playAtPos)
	local ListOfAudio = sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced];
	local PickRandom = math.random( 1, #ListOfAudio);
	cameraPos = CAVectorToSneedVector(cameraPos);
	playAtPos = CAVectorToSneedVector(playAtPos);
	print("playing voice: ", ListOfAudio[PickRandom], " at camera pos: ", VectorToString(cameraPos), " from: ", VectorToString(playAtPos));
	libSneedio.PlayVoiceBattle(unitTypeInstanced, PickRandom, playAtPos);
	libSneedio.UpdateListenerPosition(cameraPos);
end

sneedio._InitBattle = function(units)
	for _, unit in ipairs(units) do 
		local UnitVoices = sneedio.GetListOfVoicesFromUnit(unit:type());
		if(UnitVoices) then
			sneedio._RegisterVoiceOnBattle(unit:type(), unit:name(), UnitVoices);
		end
	end
end

sneedio._RegisterVoiceOnBattle = function (unitType, instance, Voices)
	local unitTypeInstanced = sneedio._UnitTypeToInstanced(unitType, instance);
	sneedio._ListOfRegisteredVoicesOnBattle[unitTypeInstanced] = Voices;
	for __, filename in ipairs(Voices) do
		libSneedio.LoadVoiceBattle(unitType, filename);
	end
end


sneedio._CleanUpAfterBattle = function()
	libSneedio.ClearBattle();
	sneedio._ListOfRegisteredVoicesOnBattle = {
		["null"] = {},
	};
end

sneedio._ListOfRegisteredVoicesOnBattle = {
	["null"] = {},
};

sneedio._ListOfRegisteredVoices = {
	["null"] = {},
};

print("all ok");

_G.sneedio = sneedio;

--return sneedio;
