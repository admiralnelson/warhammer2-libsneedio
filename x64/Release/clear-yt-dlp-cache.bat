@echo off
rd /s /q yt-dlp-audio
del yt-dlp-db.json
del .sneedio-system.json
echo Done. You may will prompted to download audio assets upon launching the game again.
echo Enter=Continue
pause > nul
