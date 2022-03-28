@echo off

SET RPFM_CLI_EXE=F:\rpfm-2.0.2-windows\rpfm_cli.exe

mkdir out
%RPFM_CLI_EXE% --game warhammer_2 --packfile "%CD%\out\libsneedio.pack"  packfile --new-packfile
%RPFM_CLI_EXE% --game warhammer_2 --packfile "%CD%\out\libsneedio.pack"  packfile --add-folders "script" "%CD%\script\_lib" "%CD%\script\battle" "%CD%\script\campaign" "%CD%\script\frontend" "%CD%\script\mct" 
if not exist "%CD%\out\libsneedio.pack" (
	echo if it's errored out, pos probably broken. pack it up  yourself
)
set /p input="do you wish to include example files for testing? y/n:"

if "%input%"=="n" (
	%RPFM_CLI_EXE% --game warhammer_2 --packfile "%CD%\out\libsneedio.pack"  packfile --delete-files "script/battle/mod/test_file.lua" "script/frontend/mod/test_file.lua" "script/campaign/mod/test_file.lua"
	rem %RPFM_CLI_EXE% --game warhammer_2 --packfile "%CD%\out\libsneedio.pack"  packfile --delete-files 
	rem %RPFM_CLI_EXE% --game warhammer_2 --packfile "%CD%\out\libsneedio.pack"  packfile --delete-files 
)