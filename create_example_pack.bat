@echo off

SET RPFM_CLI_EXE=F:\rpfm-2.0.2-windows\rpfm_cli.exe
mkdir out
%RPFM_CLI_EXE% --game warhammer_2 --packfile "%CD%\out\libsneedio_sample.pack"  packfile --new-packfile
%RPFM_CLI_EXE% --game warhammer_2 --packfile "%CD%\out\libsneedio_sample.pack"  packfile --add-folders "script" "%CD%\script\battle"
%RPFM_CLI_EXE% --game warhammer_2 --packfile "%CD%\out\libsneedio_sample.pack"  packfile --add-folders "script" "%CD%\script\campaign"
%RPFM_CLI_EXE% --game warhammer_2 --packfile "%CD%\out\libsneedio_sample.pack"  packfile --add-folders "script" "%CD%\script\frontend"
	%RPFM_CLI_EXE% --game warhammer_2 --packfile "%CD%\out\libsneedio_sample.pack"  packfile --delete-files "script/battle/mod/z_sneedio_starter.lua"
	%RPFM_CLI_EXE% --game warhammer_2 --packfile "%CD%\out\libsneedio_sample.pack"  packfile --delete-files "script/campaign/mod/z_sneedio_starter.lua"
	%RPFM_CLI_EXE% --game warhammer_2 --packfile "%CD%\out\libsneedio_sample.pack"  packfile --delete-files "script/frontend/mod/z_sneedio_starter.lua"
if not exist "%CD%\out\libsneedio_sample.pack" (
	echo if it's errored out, pos probably broken. pack it up  yourself
)
