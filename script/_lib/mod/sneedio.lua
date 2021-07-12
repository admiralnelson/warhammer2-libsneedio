local print = print;
local MOCK_UP = true;
local path = "/script/bin/";
local outputPath = "";
if(MOCK_UP) then
	path = "G:/dev/libsneedio/script/bin/";
	outputPath = "";
end
if(not MOCK_UP) then
	print = out;
end

local base64 = require("base64");
local libSneedio = nil;
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

local tryLoadLibSneedio = pcall(
function()
	libSneedio = require(DLL_FILENAME[1]);
end);


if (not tryLoadLibSneedio) then	
	local UnpackThemDlls = function()
		for _, filename in ipairs(DLL_FILENAMES) do
			local path = path..filename;
			
			-- not on game
			if(MOCK_UP) then path = path..".lua" end;
			
			
			print("unpacking file:", path);
			local data = assert(loadfile(path))();
			local file = assert(io.open(outputPath..filename..".dll", "wb"));
			file:write(data);
			file:close();
		end
		
		libSneedio = require(DLL_FILENAMES[1]);
	end
	UnpackThemDlls();
end
	
	