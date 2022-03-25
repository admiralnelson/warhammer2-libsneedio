# Sneedio common methods
`sneedio` contains functionalities to load, play, and control your custom audio and music. It's registered as global object.  

To see full implementation of `sneedio`, please check [@sneedio_loader.lua](..\script\_lib\mod\@sneedio_loader.lua)  
You can also check examples in:
- Frontend music setup script: [test_file.lua](..\script\frontend\mod\test_file.lua) 
- Campaign music script: [test_file.lua](..\script\campaign\mod\test_file.lua) 
- Battle music script: [test_file.lua](..\script\battle\mod\test_file.lua)

These examples help you to setup your own custom music playlist.

## Audio format
It's recommended to use mp3 for all your audio files. Because there are some audio format that doesn't support position seeking. Youtube links is automatically cached as mp3 file. Check [troubleshooting.md](troubleshooting.md) if you encounter any playback issues. Feel free to create new issues if you find any bugs.

## Frontend methods

`sneedio.ReplaceMenuMusic`: Replace the current menu music with a new one. This will override the user's custom music.  

```lua
--- replaces frontend music
-- {
-- 	  FileName = "medieval.mp3",
-- 	  MaxDuration = 30,
--    StartPos = 10,
-- }
-- StartPos attribute is optional.
-- @param musicData: table above
sneedio.ReplaceMenuMusic = function(musicData)
```

`sneedio.DownloadYoutubeUrls`: Enqueues your Youtube links here. Sneedio then will download it into your local cache located in `yt-dlp-audio` folder.
```lua
--- enqueue urls to be downloaded
-- @param urls: array of urls to be downloaded
sneedio.DownloadYoutubeUrls = function (urls)
```


`sneedio.ExtractAudio` : Extracts audio from key value array containing file name and base64 string. Keep in mind that this is a very slow operation. (`force` set to `false`). `hiveFolder` is located relative to the game executable.
```lua
--- extract audio from base64 table
-- the is a key value map like this
-- {
--    ["audio.mp3"] = "BLsdsdBASE64STRINGaskd",
--    ["audio2_attack.ogg"] = "BLsdsdBASE64STRINGaskd",
-- }
-- where the key is the filename and the value is valid base64 string
-- @param hiveFolder: string, your audio will be stored under audio/%hiveFolder%
-- @param audios: a key map table, look above for the format
-- @param force: boolean, true will extract the audio anyway (could be performance hit if executed frequently)
sneedio.ExtractAudio = function (hiveFolder, audios, force)
```

## Campaign methods

`sneedio.RegisterVoice`: Register unit voices during campaign. Sneedio will play the voice when the unit is selected or interacted with. As for now, `CampaignMap` ambience audio (example: when Repanse complains about the heat in the desert) is not supported. `EnslaveOption, KillOption, RansomOption` are also not supported. 

- `Select` when unit is selected/clicked
- `Affirmative` when unit moves to a new location/obeys command
- `Abilites` when an agent uses its ability
- `Hostile` when unit cannot obey command or you're selecting hostile unit
- `Diplomacy` when unit (which is faction leader) is in a diplomacy dialog. `Diplomacy_str_x` key must match the string in your dialog localisation db, and the value is file name.

**`unittype` is your agent key** defined in database.

These options are only supported in campaign mode.  
`FileName` supports Youtube URL, as long you have downloaded it into your local cache during [Frontend: `sneedio.DownloadYoutubeUrls`](#Frontend-methods)

```lua
--- register voices to associated unit
-- with format like this
-- {
-- 	["Select"] = {...}, -- array of fileName
-- 	["Affirmative"] = {...}, -- array of fileName
-- 	["Hostile"] = {...}, -- array of fileName
-- 	["Abilities"] = {...}, -- array of fileName
-- 	["Diplomacy"] = { -- key value map
-- 		["Diplomacy_str_x"] = "", -- filename, Diplomacy_str_x must match the string in your localisation db.
-- 		["Diplomacy_str_y"] = "",
-- 	},
-- },
-- note: Cooldown is in second!
-- @param unittype: string, a main unit key associated with the unit
-- @param fileName: a table, see the format above
sneedio.RegisterVoice = function(unittype, fileNames)
```

`sneedio.LoadCustomAudio`: Upload aribtary audio file to libsneedio with your defined identifier. Could be useful for playing scripted audio or narration or UI sound effect.  
`fileName` supports Youtube URL, as long you have downloaded it into your local cache during [Frontend: `sneedio.DownloadYoutubeUrls`](#Frontend-methods)
```lua
--- upload arbitary audio file to libsneedio
--- could be useful for playing UI sound effects or maybe even for custom advisor voice over?
-- @param identifier: string, name to associate the audio
-- @param fileName: string, path to the audio file
sneedio.LoadCustomAudio = function(identifier, fileName)
```

`sneedio.PlayCustomAudio2D`: Play a custom audio file without spatialisation, could be useful for UI sound. `indentifier` is the name you defined in [Campaign: `sneedio.LoadCustomAudio`](#Campaign-methods)
```lua
--- play custom audio in 2D space
-- @param identifier: string, name to associate the audio (see LoadCustomAudio to upload arbitary audio file)
-- @param volume: the loudness real number ranging [0..1]
sneedio.PlayCustomAudio2D = function (identifier , volume)
```

`sneedio.PlayCustomAudio3D`: Play a custom audio file with spatialisation, could be useful for other sound effect scattered in the map. 
- `indentifier` is the name you defined in [Campaign: `sneedio.LoadCustomAudio`](#Campaign-methods)
- `atPosition` is the position of the audio source (must be supplied with CA vector, which means passes `is_vector` test)
- `maxDistance` is the maximum distance the audio source can be heard

Keep in mind that implementation of spatialisation is not perfect, and the audio may be played in the wrong position (could be noticable when using headphones).

```lua
--- play custom audio in campaign
-- @param identifier: string, name to associate the audio (see LoadCustomAudio to upload arbitary audio file)
-- @param atPosition: userdata vector (is_vector), position where the audio will be played
-- @param maxDistance: number, distance from the listener
-- @param volume: the loudness real number ranging [0..1]
sneedio.PlayCustomAudioCampaign = function (identifier, atPosition, maxDistance, volume)
```

`sneedio.AddMusicCampaign`: Add music to the campaign. The music will be played in the background. Existring other mods and user custom music will also be played.  
- `FileName` supports Youtube URL, as long you have downloaded it into your local cache during [Frontend: `sneedio.DownloadYoutubeUrls`](#Frontend-methods)  
- `StartPos` is the second when the music will start. If not supplied, it will be played from the beginning. You can use `sneedio.MinutesSecondsToSeconds` to convert mm:ss string format to seconds  
  
This function uses variadic arguments, so you can pass in multiple music files.
```lua
--- add campaign music for faction
--  if faction does not exist, it will create one.
--  music table in variadic argument must looks like this:
-- {
-- 	  FileName = "medieval.mp3",
-- 	  MaxDuration = sneedio.MinutesSecondsToSeconds("1:00"),
--    StartPos = 10,
-- },
-- since version 0.3 FileName supports youtube url. Keep in mind the music linked from the url must be downloaded
-- by yt-dlp on frontend menu (use sneedio.DownloadYoutubeUrls(url))
-- StartPos attribute is optional. If not specified, the music will start from the beginning.
-- @param factionid: string, faction key in faction tables
-- @param ...: music to be added (variadic arguments)
sneedio.AddMusicCampaign = function (factionId, ...)
```

## Battle methods

`sneedio.RegisterVoice`: Register voices to associated unit with format like this. 
- `Select` when unit is selected/clicked
- `Affirmative` when unit moves to a new location/obeys command
- `Abilites` when an unit uses its ability (only works for SEU/SEM aka single entity unit/monster)
- `Idle` when unit is idle
- `Attack` when unit is attacking
- `Winning` when unit is winning their battle (when in melee or in rampage and health > 50%) (could be buggy)
- `Rampage` when unit is in rampage
- `Wavering` when unit is wavering (when shattered or routing or wavering)

**`unittype` is your main unit key** defined in database.

`Cooldown` control how spammy the voices will be.
```lua
--- register voices to associated unit
-- with format like this
-- {
-- 	["Select"] = {...}, -- array of fileName
-- 	["Affirmative"] = {...}, -- array of fileName
-- 	["Abilities"] = {...}, -- array of fileName
-- 	["Ambiences"] = {
-- 		["Idle"] = {{Cooldown = 0, FileName = ""}, ...},
-- 		["Attack"] = {{Cooldown = 0, FileName = ""}, ...},
-- 		["Wavering"] = {{Cooldown = 0, FileName = ""}, ...},
-- 		["Winning"] = {{Cooldown = 0, FileName = ""}, ...},
-- 		["Rampage"] = {{Cooldown = 0, FileName = ""}, ...},
-- 	},
-- },
-- note: Cooldown is in second!
-- @param unittype: string, a main unit key associated with the unit
-- @param fileName: a table, see the format above
sneedio.RegisterVoice = function(unittype, fileNames)
```

`sneedio.LoadCustomAudio`: Upload aribtary audio file to libsneedio with your defined identifier. Could be useful for playing scripted audio or narration or UI sound effect.  
`fileName` supports Youtube URL, as long you have downloaded it into your local cache during [Frontend: `sneedio.DownloadYoutubeUrls`](#Frontend-methods)
```lua
--- upload arbitary audio file to libsneedio
--- could be useful for playing UI sound effects or maybe even for custom advisor voice over?
-- @param identifier: string, name to associate the audio
-- @param fileName: string, path to the audio file
sneedio.LoadCustomAudio = function(identifier, fileName)
```

`sneedio.PlayCustomAudio2D`: Play a custom audio file without spatialisation, could be useful for UI sound or narration. `indentifier` is the name you defined in [Battle: `sneedio.LoadCustomAudio`](#Battle-methods)
```lua
--- play custom audio in 2D space
-- @param identifier: string, name to associate the audio (see LoadCustomAudio to upload arbitary audio file)
-- @param volume: the loudness real number ranging [0..1]
sneedio.PlayCustomAudio2D = function (identifier , volume)
```

`sneedio.PlayCustomAudioBattle`: Play a custom audio file with spatialisation, could be useful for custom sound effects in the map. `indentifier` is the name you defined in [Battle: `sneedio.LoadCustomAudio`](#Battle-methods)
- `indentifier` is the name you defined in [Battle: `sneedio.LoadCustomAudio`](#Battle-methods)
- `atPosition` is the position of the audio source (must be supplied with CA vector, which means passes `is_vector` test)
- `maxDistance` is the maximum distance the audio source can be heard
- `listener` is the position of the listener (must be supplied with CA vector, which means passes `is_vector` test), if not supplied, it will be the camera position.

Keep in mind that implementation of spatialisation is not perfect, and the audio may be played in the wrong position (could be noticable when using headphones).

```lua
--- play custom audio in campaign
-- @param identifier: string, name to associate the audio (see LoadCustomAudio to upload arbitary audio file)
-- @param atPosition: userdata vector (is_vector), position where the audio will be played
-- @param maxDistance: number, distance from the listener
-- @param volume: the loudness real number ranging [0..1]
-- @param listener (optional): userdata vector (is_vector), the listener position (optional, listener is the camera)
sneedio.PlayCustomAudioBattle = function(identifier, atPosition, maxDistance, volume, listener)
```

`sneedio.AddMusicBattle`: Add music to the current battle. The music will be played in the background. Existring other mods and user custom music will also be played.  
- `FileName` supports Youtube URL, as long you have downloaded it into your local cache during [Frontend: `sneedio.DownloadYoutubeUrls`](#Frontend-methods)  
- `StartPos` is the second when the music will start. If not supplied, it will be played from the beginning. You can use `sneedio.MinutesSecondsToSeconds` to convert mm:ss string format to seconds  
- `Situation` is the battle situation. It can be one of the following:  `Deployment, FirstEngagement, Balanced, Losing, Winning`
  
This function uses variadic arguments, so you can pass in multiple music files.
```lua
--- add battle music for faction
--- if faction does not exist, it will create one.
--- music table in variadic argument must looks like this:
--
--  {
--      FileName = "medieval.mp3",
--      MaxDuration = 30,
--      StartPos = 10,
--  },
--
-- StartPos attribute is optional. If not specified, the music will start from the beginning.
-- @param factionid: string, faction key in faction tables
-- @param Situation: string, situation must be either: Deployment, FirstEngagement, Balanced, Losing, Winning
-- @param ...: music to be added (variadic arguments)
sneedio.AddMusicBattle = function (factionId, Situation, ...)
```

Go back to [Readme.md](..\readme.MD).