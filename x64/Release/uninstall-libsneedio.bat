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

echo do you want to delete configs?

set /p input="y/n "
if "%input%"=="y" (
	del user-sneedio.json
)
del .sneedio-system.json