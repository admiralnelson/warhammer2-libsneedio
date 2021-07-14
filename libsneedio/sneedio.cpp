// dllmain.cpp : Defines the entry point for the DLL application.
#include "pch.h"
#include "sneedio.h"
#include "music_library.h"
#include "audio_library.h"
extern "C" {
    #include "lua.h"
    #include "lauxlib.h"
}
#include <iostream>
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
	if (bIsSneedioReady) return true;
	audeo::InitInfo info;
	// Reserve some extra channels instead of the default (16). This amount can
	// later be raised by calling audeo::allocate_effect_channels(count).
	info.effect_channels = 32;
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
int L_somefunction(lua_State* L)
{
	// TODO: add implementation
	lua_getglobal(L, "print");
	lua_pushstring(L, "Now running somefunction...");
	lua_call(L, 1, 0);

#ifndef NDEBUG
	stackDump(L, "stack from somefunction()");
#endif

	return 0;	// number of return values on the Lua stack
};

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

	std::cout << "pos " << " x " << keyValueTablePosition["x"] << " y " << keyValueTablePosition["y"] << " z " << keyValueTablePosition["z"] << "\n";
	std::cout << "tar " << " x " << keyValueTableTarget["x"] << " y " << keyValueTableTarget["y"] << " z " << keyValueTableTarget["z"] << "\n";
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

		lua_pushboolean(L, 2);
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
		repeats = std::stoi(lua_tostring(L, -2));
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
		}
		lua_pushboolean(L, false);

		return 1;
	}

	lua_pushboolean(L, true);

	return 1;
}

/*
** ===============================================================
** Library initialization and shutdown
** ===============================================================
*/

// Structure with all functions made available to Lua
static const struct luaL_Reg LuaExportFunctions[] = {

	// TODO: add functions from 'exposed Lua API' section above
	{"somefunction",L_somefunction},
	{"PlayMusic",L_PlayMusic},
	{"LoadVoiceBattle",L_LoadVoiceBattle},
	{"PlayVoiceBattle",L_PlayVoiceBattle},
	{"UpdateListenerPosition",L_UpdateListenerPosition},
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

