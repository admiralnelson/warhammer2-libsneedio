@echo off

SET VS_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE"
SET patches=%CD%
SET PATH=%PATH%;%VS_PATH%

echo location of devenv %VS_PATH%
echo is this correct??
echo press enter if you're ready
pause > NUL


echo apply audeo patch
cd external\audeo
git apply < "%patches%\patches\audeo.patch"
cd ..\..

echo apply lua patch
cd external\lua
git apply < "%patches%\patches\lua.patch"
cd ..\..

echo apply sdl patch
cd %CD%\external\sdl
git apply < "%patches%\patches\sdl.patch"
cd ..\..

echo apply sdl-mixer patch
cd %CD%\external\sdl-mixer
git apply < "%patches%\patches\sdl-mixer.patch"
cd ..\..

echo press enter if you're ready
pause > NUL

devenv.exe "%CD%\Libsneedio.sln" /Build Release

SET RPFM_CLI_EXE=F:\rpfm-2.0.2-windows\rpfm_cli.exe
mkdir out
%RPFM_CLI_EXE% -n "%CD%\out\sneedio.pack" 
if not exist "%CD%\out\sneedio.pack" (
	echo if it's errored out, pos probably broken. pack it up  yourself
)