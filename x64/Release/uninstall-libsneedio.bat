@echo off
del libFLAC-8.dll
del libmodplug-1.dll
del libmpg123-0.dll
del libogg-0.dll
del libopus-0.dll
del libopusfile-0.dll
del libvorbis-0.dll
del libvorbisfile-3.dll
del SDL2.dll
del SDL2_mixer.dll
del libsneedio.dll
del *.pdb
rd /s /q yt-dlp-audio
rd /s /q yt-dlpbin
del yt-dlp-db.json
del .sneedio-system.json
del user-sneedio.json
echo Done. You may restart the game with libsneedio mod to reinstall native libraries (dll).
echo Enter=Continue
pause > nul
