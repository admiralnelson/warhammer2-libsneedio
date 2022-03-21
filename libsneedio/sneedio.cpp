// dllmain.cpp : Defines the entry point for the DLL application.
#include "pch.h"
#include "sneedio.h"
#include "music_library.h"
#include "audio_library.h"
#include <sstream>
#include <iomanip>

extern "C" {
    #include "lua.h"
    #include "lauxlib.h"
}
#include <iostream>
#include <ShlObj_core.h>
#include "ytdlp_interface.h"
#pragma comment( lib, "lua" ) 


/*
** ===============================================================
**   Declarations
** ===============================================================
*/

// TODO: add declarations

/*
** ===============================================================
**   Generic internal code
** ===============================================================
*/

// TODO: add generic code

static bool bIsSneedioReady = false;

bool InitSneedio()
{
	audeo::InitInfo info;
	// Reserve some extra channels instead of the default (16). This amount can
	// later be raised by calling audeo::allocate_effect_channels(count).
	info.effect_channels = 32*2;
	if (!audeo::init(info)) 
	{
		std::cout << "Failed to initialize audeo.\n";
		return false;
	}
	else
	{
		bIsSneedioReady = true;
		return true;
	}
}

typedef int(__fastcall* GET_CURSOR_MODE)(void);

static GET_CURSOR_MODE cursor_mode = nullptr;
bool SetupCursorDetector()
{
	HMODULE Warhammer2EXE = GetModuleHandleA("Warhammer2.exe");
	if (!Warhammer2EXE)
	{
		std::cout << "failed to find base module";;
		return false;
	}
	void* get_mode_empire = (void*)GetProcAddress(Warhammer2EXE, "?get_mode@HARDWARE_CURSOR@EMPIREUTILITY@@YA?AW4CURSOR_MODE@12@XZ");
	if (!get_mode_empire)
	{
		std::cout << "failed to find the procedure";
		return false;
	}
	cursor_mode = (GET_CURSOR_MODE)get_mode_empire;
}

template< typename T >
std::string IntToHex(T i)
{
	std::stringstream stream;
	stream << "0x"
		<< std::setfill('0') << std::setw(sizeof(T) * 2)
		<< std::hex << i;
	return stream.str();
}

extern "C" {

#ifndef NDEBUG
//can be found here  http://www.lua.org/pil/24.2.3.html
static void stackDump(lua_State* L, const char* text) {
	int i;
	int top = lua_gettop(L);
	if (text == NULL)
		printf("--------Start Dump------------\n");
	else
		printf("--------Start %s------------\n", text);
	for (i = 1; i <= top; i++) {  /* repeat for each level */
		int t = lua_type(L, i);
		switch (t) {

		case LUA_TSTRING:  /* strings */
			printf("`%s'", lua_tostring(L, i));
			break;

		case LUA_TBOOLEAN:  /* booleans */
			printf(lua_toboolean(L, i) ? "true" : "false");
			break;

		case LUA_TNUMBER:  /* numbers */
			printf("%g", lua_tonumber(L, i));
			break;

		default:  /* other values */
			printf("%s", lua_typename(L, t));
			break;

		}
		printf("  ");  /* put a separator */
	}
	printf("\n");  /* end the listing */
	printf("--------End Dump------------\n");
}

static void tableDump(lua_State* L, int idx, const char* text)
{
	lua_pushvalue(L, idx);		// copy target table
	lua_pushnil(L);
	if (text == NULL)
		printf("--------Table Dump------------\n");
	else
		printf("--------Table dump: %s------------\n", text);
	while (lua_next(L, -2) != 0) {
		printf("%s - %s\n",
			lua_typename(L, lua_type(L, -2)),
			lua_typename(L, lua_type(L, -1)));
		lua_pop(L, 1);
	}
	lua_pop(L, 1);	// remove table copy
	printf("--------End Table dump------------\n");
}
#endif

/*
** ===============================================================
**   Exposed Lua API
** ===============================================================
*/

// TODO: example somefunction, add more here
int L_GetLuaTopMemPos(lua_State* L)
{
	// TODO: add implementation
	lua_gettop(L);
	void *x = (void*) &lua_gettop;

	std::string test = "Now running somefunction..." + std::to_string((int)x);
	lua_getglobal(L, "print");
	lua_pushstring(L,test.c_str());
	lua_call(L, 1, 0);

	std::string retLua_gettopPos = IntToHex<void*>(x);

	lua_pushstring(L, retLua_gettopPos.c_str());;
	return 1;

#ifndef NDEBUG
	stackDump(L, "stack from somefunction()");
#endif

	return 0;	// number of return values on the Lua stack
};

int L_GetCursorType(lua_State* L)
{
	if (cursor_mode == nullptr)
	{
		SetupCursorDetector();
	}
	if (cursor_mode)
	{
		int Mode = cursor_mode();
		lua_pushstring(L, std::to_string(Mode).c_str());
		return 1;
	}
	return 0;
}

int L_WasRightClickHeld(lua_State* L)
{
	if (GetKeyState(VK_RBUTTON) & 0x8000)
	{
		lua_pushboolean(L, true);
		return 1;
	}
	else
	{
		lua_pushboolean(L, false);
		return 1;
	}
}

int L_UpdateListenerPosition(lua_State* L) //6 params.
{
	lua_pushvalue(L, 1);
	lua_pushnil(L); //push 1st param

	std::map<std::string, float> keyValueTablePosition;

	while (lua_next(L, -2))
	{
		lua_pushvalue(L, -2);
		const char* key = lua_tostring(L, -1);
		float value = std::stof(lua_tostring(L, -2));
		keyValueTablePosition[key] = value;
		lua_pop(L, 2);
	}
	lua_pop(L, 1);
	lua_pushnil(L); //push 2sn param

	std::map<std::string, float> keyValueTableTarget;

	while (lua_next(L, -2))
	{
		lua_pushvalue(L, -2);
		const char* key = lua_tostring(L, -1);
		float value = std::stof(lua_tostring(L, -2));
		keyValueTableTarget[key] = value;
		lua_pop(L, 2);
	}
	lua_pop(L, 1);

	//std::cout << "pos " << " x " << keyValueTablePosition["x"] << " y " << keyValueTablePosition["y"] << " z " << keyValueTablePosition["z"] << "\n";
	//std::cout << "tar " << " x " << keyValueTableTarget["x"] << " y " << keyValueTableTarget["y"] << " z " << keyValueTableTarget["z"] << "\n";
	float xPos = keyValueTablePosition["x"];
	float yPos = keyValueTablePosition["y"];
	float zPos = keyValueTablePosition["z"];

	float xTar = keyValueTableTarget["x"];
	float yTar = keyValueTableTarget["y"];
	float zTar = keyValueTableTarget["z"];
	SneedioFX::Get().UpdateListenerPosition({ xPos,yPos,zPos }, { xTar, yTar, zTar });

	return 0;
}

int L_LoadVoiceBattle(lua_State* L)
{
	const char* FileNameParam = luaL_checkstring(L, 1);
	std::string FileName = FileNameParam;
	std::string UnitClassName = luaL_checkstring(L, 2);
	if (FileNameParam)
	{
		bool bIsSuccess = SneedioFX::Get().LoadVoiceBattle(FileName, UnitClassName);
		if (!bIsSuccess)
		{
			std::string ErrorMsg = "failed to play audio  with filename: " + FileName;
			lua_getglobal(L, "print");
			lua_pushstring(L, ErrorMsg.data());
			lua_call(L, 1, 0);

			lua_pushboolean(L, false);
			return 1;
		}
	}
	else
	{
		std::string ErrorMsg = "filename not supplied";
		lua_getglobal(L, "print");
		lua_pushstring(L, ErrorMsg.data());
		lua_call(L, 1, 0);

		lua_pushboolean(L, false);
		return 1;
	}

	std::string Msg = "loading audio... UnitClassName: " + UnitClassName + " filename: " + FileName;
	lua_getglobal(L, "print");
	lua_pushstring(L, Msg.data());
	lua_call(L, 1, 0);

	lua_pushboolean(L, true);
	return 1;
}

int L_PlayVoiceBattle(lua_State* L)
{
	const char* UnitParam = luaL_checkstring(L, 1);
	std::string UnitClassName = UnitParam;
	int AudioIndex = std::stoi(luaL_checkstring(L, 2)) - 1;
	if (AudioIndex < 0) AudioIndex = 0;
	bool bCheckIf3rdArgumentIsTable = lua_type(L, 3) == LUA_TTABLE;
	if (!bCheckIf3rdArgumentIsTable)
	{
		std::string ErrorMsg = "3rd argument must be table with x, y, z field";
		lua_getglobal(L, "print");
		lua_pushstring(L, ErrorMsg.data());
		lua_call(L, 1, 0);

		lua_pushinteger(L, 1);
		return 1;
	}
	lua_pushvalue(L, 3);
	lua_pushnil(L); //3rd argument

	std::map<std::string, float> keyValueTablePos;
	while (lua_next(L, -2))
	{
		lua_pushvalue(L, -2);
		const char* key = lua_tostring(L, -1);
		float value = std::stof(lua_tostring(L, -2));
		keyValueTablePos[key] = value;
		lua_pop(L, 2);
	}

	lua_pop(L, 1);
	
	float Distance = 255, Volume = 1;
	if (lua_type(L, 4) == LUA_TSTRING)
	{
		std::string s = luaL_checkstring(L, 4);
		Distance = std::atof(s.data());		
	}
	if (lua_type(L, 5) == LUA_TSTRING)
	{
		std::string s = luaL_checkstring(L, 5);
		Volume = std::atof(s.data());
	}
	if (UnitParam)
	{
		audeo::vec3f pos;
		pos.x = keyValueTablePos["x"];
		pos.y = keyValueTablePos["y"];
		pos.z = keyValueTablePos["z"];
	
		bool bIsSuccess = SneedioFX::Get().PlayVoiceBattle(UnitClassName, AudioIndex, pos, Distance, Volume);
		if (!bIsSuccess)
		{
			std::string ErrorMsg = "failed to play audio  with UnitClassName: " +
				UnitClassName + " AudioIndex (0th, cus C++)  " + std::to_string(AudioIndex);
			lua_getglobal(L, "print");
			lua_pushstring(L, ErrorMsg.data());
			lua_call(L, 1, 0);

			lua_pushinteger(L, 2);
			return 1;
		}


		std::string Msg = "playing audio... UnitClassName: " + UnitClassName;
		lua_getglobal(L, "print");
		lua_pushstring(L, Msg.data());
		lua_call(L, 1, 0);

		lua_pushinteger(L, 0);
		return 1;
	}
	else
	{
		std::string Msg = "unit name not supplied!";
		lua_getglobal(L, "print");
		lua_pushstring(L, Msg.data());
		lua_call(L, 1, 4);

		lua_pushinteger(L, 2);
		return 1;
	}
}

int L_IsMusicFileValid(lua_State* L)
{
	std::string File = luaL_checkstring(L, 1);
	bool Result = SneedioMusic::Get().IsFileValid(File);

	if (Result)
	{
		lua_pushboolean(L, true);
		return 1;
	}
	else
	{
		lua_pushboolean(L, false);
		return 1;
	}
}

int L_PlayMusic(lua_State* L)
{
	const char* FileNameParam = luaL_checkstring(L, 1);
	std::string FileName = FileNameParam;
	int repeats = -1;
	if (lua_gettop(L) > 1)
	{
		std::string repeat = lua_tostring(L, -2);
		repeats = std::stoi(repeat.c_str());
	}
	if (FileNameParam)
	{
		bool bIsSuccess = SneedioMusic::Get().PlayMusic(FileName, repeats);
		if (!bIsSuccess)
		{
			std::string ErrorMsg = "failed to play music with filename: " + FileName;
			lua_getglobal(L, "print");
			lua_pushstring(L, ErrorMsg.data());
			lua_call(L, 1, 0);

			lua_pushboolean(L, false);

			return 1;
		}
		lua_pushboolean(L, true);

		return 1;
	}

	lua_pushboolean(L, true);

	return 1;
}

int L_Pause(lua_State* L)
{
	bool pause = lua_toboolean(L, 1);
	SneedioFX::Get().Pause(pause);
	SneedioMusic::Get().Pause(pause);
	
	return 0;
}

int L_MuteSoundFX(lua_State* L)
{
	bool mute = lua_toboolean(L, 1);
	SneedioFX::Get().Mute(mute);


	return 0;
}

int L_MuteMusic(lua_State* L)
{
	bool mute = lua_toboolean(L, 1);
	SneedioMusic::Get().Mute(mute);

	return 0;
}

int L_SetMusicVolume(lua_State* L)
{
	float v = luaL_checknumber(L, 1);
	SneedioMusic::Get().SetVolume(v);

	return 0;
}

int L_GetMusicVolume(lua_State* L)
{
	lua_pushnumber(L, SneedioMusic::Get().GetVolume());
	return 1;
}

int L_KillMe(lua_State* L)
{
	audeo::quit();
	return 0;
}

uintptr_t FindDMAAddy(uintptr_t ptr, std::vector<unsigned int> offsets)
{
	uintptr_t addr = ptr;
	for (unsigned int i = 0; i < offsets.size(); ++i)
	{
		addr = *(uintptr_t*)addr;
		addr += offsets[i];
	}
	return addr;
}

static int UserOldVolume = 0;
static bool bAlwaysMute = false;

int GetWarscapeMusicVolume()
{
	return 0;

	uintptr_t BaseAddress = (uintptr_t)GetModuleHandleA("Warhammer2.exe");
	uintptr_t PtrToMusicVolumeVal = FindDMAAddy(BaseAddress + 0x036F4938, std::vector<UINT>{0x47c});

	return *(int*)PtrToMusicVolumeVal;
}

void SetWarscapeMusicVolume(int val)
{
	return; 
	uintptr_t BaseAddress = (uintptr_t)GetModuleHandleA("Warhammer2.exe");
	uintptr_t PtrToMusicVolumeVal = FindDMAAddy(BaseAddress + 0x036F4938, std::vector<UINT>{0x47c});
	*(int*)PtrToMusicVolumeVal = val;

	uintptr_t PtrToSoundConfigObj = FindDMAAddy(BaseAddress + 0x036F4938, std::vector<UINT>{0});
	HMODULE Warhammer2EXE = GetModuleHandleA("Warhammer2.exe");
	void* get_mode_empire = (void*)GetProcAddress(Warhammer2EXE, "");
}

int L_GetWarscapeMusicVolume(lua_State* L)
{
	int volume = luaL_checknumber(L, 1);

	lua_pushnumber(L, GetWarscapeMusicVolume());
	return 1;
}

int L_SetWarscapeMusicVolume(lua_State* L)
{
	int volume = luaL_checknumber(L, 1);

	SetWarscapeMusicVolume(volume);
	std::cout << "volume is set to " << volume << std::endl;

	return 0;
}

int L_AlwaysMuteWarscapeMusic(lua_State* L)
{
	bAlwaysMute = true;
	SetWarscapeMusicVolume(0);
	return 0;
}

BOOL DirectoryExists(LPSTR szPath)
{
	DWORD dwAttrib = GetFileAttributesA(szPath);

	return (dwAttrib != INVALID_FILE_ATTRIBUTES &&
		(dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
}

void CreateDirectoryRecursively(std::string path)
{
	size_t pos = 0;
	do
	{
		pos = path.find_first_of("\\/", pos + 1);
		CreateDirectoryA(path.substr(0, pos).c_str(), NULL);
	} while (pos != std::string::npos);
}

int L_MakeDir(lua_State* L)
{
	std::string path = luaL_checkstring(L, 1);
	if (DirectoryExists(path.data()))
	{
		lua_pushboolean(L, false);
		return 1;
	}
	CreateDirectoryRecursively(path);
	lua_pushboolean(L, true);
	return 1;
}

int L_SetMusicPosition(lua_State* L)
{
	float secs = luaL_checknumber(L, 1);
	bool ret = SneedioMusic::Get().SeekToPosition(secs);
	lua_pushboolean(L, ret);
	return 1;
}

int L_GetMusicPosition(lua_State* L)
{
	int ret = SneedioMusic::Get().GetPosition();
	lua_pushnumber(L, ret);
	return 1;
}

int L_GetInfinity(lua_State* L)
{
	lua_pushnumber(L, INFINITY);
	return 1;
}

int L_SetSoundEffectVolume(lua_State* L)
{
	float f = luaL_checknumber(L, 1);
	SneedioFX::Get().SetSoundEffectVolume(f);
	return 0;
}

int L_GetSoundEffectVolume(lua_State* L)
{
	lua_pushnumber(L, SneedioFX::Get().GetSoundEffectVolume());
	return 1;
}

int L_DownloadYoutubeUrls(lua_State* L)
{
	luaL_checktype(L, 1, LUA_TTABLE);
	// let alone excessive arguments (idiomatic), or do:
	lua_settop(L, 1);
	int a_size = lua_objlen(L, 1); // absolute indexing for arguments
	std::vector<Url> urls;

	for (int i = 1; i <= a_size; i++) 
	{
		lua_pushinteger(L, i);
		lua_gettable(L, 1); // always give a chance to metamethods
		// OTOH, metamethods are already broken here with lua_rawlen()
		// if you are on 5.2, use lua_len()

		if (lua_isnil(L, -1)) { // relative indexing for "locals"
			a_size = i - 1; // fix actual size (e.g. 4th nil means a_size==3)
			break;
		}

		if (!lua_isstring(L, -1)) // optional check
			return luaL_error(L, "item %d invalid (string required, got %s)",
				i, luaL_typename(L, -1));

		Url url = lua_tostring(L, -1);

		urls.push_back(url);
		lua_pop(L, 1);
	}

	std::cout << "url to be passed : " << SneedioYtDlp::Get().UrlQueuesToString(urls) << std::endl;

	return 0;
}

/*
** ===============================================================
** Library initialization and shutdown
** ===============================================================
*/

// Structure with all functions made available to Lua
static const struct luaL_Reg LuaExportFunctions[] = {

	// TODO: add functions from 'exposed Lua API' section above
	{"GetLuaTopMemPos",L_GetLuaTopMemPos},
	{"GetCursorType", L_GetCursorType},
	{"PlayMusic",L_PlayMusic},
	{"LoadVoiceBattle",L_LoadVoiceBattle},
	{"PlayVoiceBattle",L_PlayVoiceBattle},
	{"UpdateListenerPosition",L_UpdateListenerPosition},
	{"WasRightClickHeld",L_WasRightClickHeld},
	{"Pause", L_Pause},
	{"MuteSoundFX", L_MuteSoundFX},
	{"MuteMusic", L_MuteMusic},
	{"SetMusicVolume", L_SetMusicVolume},
	{"GetMusicVolume", L_GetMusicVolume},
	{"IsMusicValid", L_IsMusicFileValid},
	{"GetWarscapeMusicVolume", L_GetWarscapeMusicVolume},
	{"SetWarscapeMusicVolume", L_SetWarscapeMusicVolume},
	{"AlwaysMuteWarscapeMusic", L_AlwaysMuteWarscapeMusic},
	{"MakeDir", L_MakeDir},
	{"SetMusicPosition", L_SetMusicPosition},
	{"GetMusicPosition", L_GetMusicPosition},
	{"GetInfinity", L_GetInfinity},
	{"SetSoundEffectVolume", L_SetSoundEffectVolume},
	{"GetSoundEffectVolume", L_GetSoundEffectVolume},
	{"DownloadYoutubeUrls", L_DownloadYoutubeUrls},
	{NULL,NULL}  // last entry; list terminator
};

// Open method called when Lua opens the library
// On success; return 1
// On error; push errorstring on stack and return 0
static int L_openLib(lua_State* L) {

	// TODO: add startup/initialization code
	lua_getglobal(L, "print");
	lua_pushstring(L, "Now initializing module 'required' as:");
	lua_pushvalue(L, 1); // pos 1 on the stack contains the module name
	lua_call(L, 2, 0);
	
	lua_getglobal(L, "print");
	InitSneedio();
	if (bIsSneedioReady)
	{
		lua_pushstring(L, "Libsneedio is ready");
	}
	else
	{
		lua_pushstring(L, "Libsneedio failed to init. No external sound/music for (you).");
	}
	lua_pushvalue(L, 1); // pos 1 on the stack contains the module name
	lua_call(L, 2, 0);

	UserOldVolume = GetWarscapeMusicVolume();

	return 1;	// report success
}


// Close method called when Lua shutsdown the library
// Note: check Lua os.exit() function for exceptions,
// it will not always be called! Changed from Lua 5.1 to 5.2.
static int L_closeLib(lua_State* L) {


	// TODO: add shutdown/cleanup code
	lua_getglobal(L, "print");
	lua_pushstring(L, "Now closing the Lua template library");
	lua_call(L, 1, 0);

	if (!bAlwaysMute) //otherwise leave it muted
	{
		SetWarscapeMusicVolume(UserOldVolume);
	}

	SneedioFX::Get().Mute(false);
	SneedioFX::Get().Pause(false);
	SneedioFX::Get().ClearBattle();
	SneedioMusic::Get().Mute(false);
	SneedioMusic::Get().Pause(false);
	audeo::quit();


	return 0;
}


/*
** ===============================================================
** Core startup functionality, no need to change anything below
** ===============================================================
*/


// Setup a userdata to provide a close method
static void L_setupClose(lua_State* L) {
	// create library tracking userdata
	if (lua_newuserdata(L, sizeof(void*)) == NULL) {
		luaL_error(L, "Cannot allocate userdata, out of memory?");
	};
	// Create a new metatable for the tracking userdata
	luaL_newmetatable(L, LTLIB_UDATAMT);
	// Add GC metamethod
	lua_pushstring(L, "__gc");
	lua_pushcfunction(L, L_closeLib);
	lua_settable(L, -3);
	// Attach metatable to userdata
	lua_setmetatable(L, -2);
	// store userdata in registry
	lua_setfield(L, LUA_REGISTRYINDEX, LTLIB_UDATANAME);
}

// When initialization fails, removes the userdata and metatable
// again, throws the error stored by L_openLib(), will not return
// Top of stack must hold error string
static void L_openFailed(lua_State* L) {
	// get userdata and remove its metatable
	lua_getfield(L, LUA_REGISTRYINDEX, LTLIB_UDATANAME);
	lua_pushnil(L);
	lua_setmetatable(L, -2);
	// remove userdata
	lua_pushnil(L);
	lua_setfield(L, LUA_REGISTRYINDEX, LTLIB_UDATANAME);
	// throw the error (won't return)
	luaL_error(L, lua_tostring(L, -1));
}

LTLIB_EXPORTAPI	int LTLIB_OPENFUNC(lua_State* L) {

	// Setup a userdata with metatable to create a close method
	 L_setupClose(L);

	if (L_openLib(L) == 0)  // call initialization code
		L_openFailed(L);    // Init failed, so cleanup, will not return

	// Export Lua API
	lua_newtable(L);
#if LUA_VERSION_NUM < 502
	luaL_register(L, LTLIB_GLOBALNAME, LuaExportFunctions);
#else
	luaL_setfuncs(L, LuaExportFunctions, 0);
#endif        
	return 1;
};

}

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

