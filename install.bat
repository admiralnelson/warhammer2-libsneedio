@echo off

if not exist "%CD%\x64\Release\libsneedio.dll" (
	echo build the project first, retard.
	goto :EOF
)

SET WARHAMMER2_PATH="F:\Steam\steamapps\common\Total War WARHAMMER II"

echo is this correct warhammer 2 path? "%WARHAMMER2_PATH%"
echo press enter if you're ready
pause > NUL

copy  "%CD%\x64\Release\libsneedio.dll" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\SDL2_mixer.dll" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\SDL2.dll" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\libvorbisfile-3.dll" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\libvorbis-0.dll" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\libopusfile-0.dll" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\libopus-0.dll" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\libogg-0.dll" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\libopus-0.dll" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\libmpg123-0.dll" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\libmodplug-1.dll" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\libFLAC-8.dll" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\libsneedio.pdb" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\SDL2_mixer.pdb" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\SDL2.pdb" "%WARHAMMER2_PATH%"
copy  "%CD%\x64\Release\uninstall-libsneedio.bat" "%WARHAMMER2_PATH%"
copy  "%CD%\out\libsneedio.pack"  "%WARHAMMER2_PATH%\data\libsneedio.pack"
rem copy user-sneedio.json "%WARHAMMER2_PATH%\user-sneedio.json"
echo done