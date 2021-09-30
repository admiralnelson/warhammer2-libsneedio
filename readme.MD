#Libsneedio

##What is it? 
it's a music and audio library to enable custom music and audio for your dudes.  

##how to build?
run make.bat+install.bat  
or apply patches to external folder, then open the solution to build the binaries  
don't forget to pack the script and install them in your game.  

##for average normal user  
go to release page, download the zip, extract it into your total warhammer 2 folder.  
BEFORE LAUNCHING, make sure to make any adjustment in `user-sneedio.json` file.  
Here's an example of `user-sneedio.json` file to add music to Gigachad Louen:  
```json
{
  "FrontEndMusic": {
    "FileName": "Empire Earth Main Theme.mp3",
    "MaxDuration": 302
  },
  "FactionMusic": {
    "wh_main_brt_bretonnia": [
      {
        "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - Bard's Tale.mp3",
        "MaxDuration": 170
      },
      {
        "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - Castle Dance.mp3",
        "MaxDuration": 140
      },
      {
        "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - Dove in the Sky.mp3",
        "MaxDuration": 120
      },
      {
        "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - Echo in Eternity.mp3",
        "MaxDuration": 200
      },
      {
        "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - Knight's Fall.mp3",
        "MaxDuration": 170
      },
      {
        "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - Where my Heart is.mp3",
        "MaxDuration": 110
      }
    ],
  },
  "BattleMusic": {
    "wh_main_brt_bretonnia": {
      "Deployment": [
        {
          "FileName": "music/deploy/15 Medieval II Total War 3 m 29 s.mp3",
          "MaxDuration": 210
        },
        {
          "FileName": "music/deploy/23 Medieval II Total War 3 m 01 s.mp3",
          "MaxDuration": 182
        },
        {
          "FileName": "music/deploy/24 Medieval II Total War (Battle Deployment) 2 m 57s.mp3",
          "MaxDuration": 177
        },
        {
          "FileName": "music/deploy/30 Medieval II Total War (Battle Deployement) 2m 41s.mp3",
          "MaxDuration": 162
        }
      ],
      "FirstEngagement": [
        {
          "FileName": "music/first_engage/35 Medieval II Total War (First Engagement) 3m 41s.mp3",
          "MaxDuration": 222
        },
        {
          "FileName": "music/first_engage/06 Guillotine.mp3",
          "MaxDuration": 222
        },
        {
          "FileName": "music/first_engage/07 Honor.mp3",
          "MaxDuration": 81
        },
        {
          "FileName": "music/first_engage/17 The Fallen (alternative).mp3",
          "MaxDuration": 158
        },
        {
          "FileName": "music/first_engage/36 Medieval II Total War (First Engagement) 3m 29s.mp3",
          "MaxDuration": 210
        }
      ],
      "Balanced": [
        {
          "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - The Die is Cast.mp3",
          "MaxDuration": 135
        },
        {
          "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - The Die is Cast.mp3",
          "MaxDuration": 135
        },
        {
          "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - Crusade.mp3",
          "MaxDuration": 188
        },
        {
          "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - Crusade.mp3",
          "MaxDuration": 188
        },
        {
          "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - March of Honor.mp3",
          "MaxDuration": 138
        },

        {
          "FileName": "music/balanced/34 Medieval II Total War (Balanced) 4m 08s.mp3",
          "MaxDuration": 248
        },
        {
          "FileName": "music/balanced/46 Medieval II Total War (Balanced) 3m 29s.mp3",
          "MaxDuration": 210
        },
        {
          "FileName": "music/balanced/47 Medieval II Total War (Balanced) 3m 57s.mp3",
          "MaxDuration": 237
        },
        {
          "FileName": "music/balanced/36 Medieval II Total War (winning) 3m 10s.mp3",
          "MaxDuration": 185
        },
        {
          "FileName": "music/balanced/37 Fight While Mounted 1.mp3",
          "MaxDuration": 180
        },
        {
          "FileName": "music/balanced/43 Fight 2.mp3",
          "MaxDuration": 117
        },
        {
          "FileName": "music/balanced/58 Ambushed By Rhodok.mp3",
          "MaxDuration": 120
        },
        {
          "FileName": "music/balanced/57 Ambushed By Swadian.mp3",
          "MaxDuration": 103
        }
      ],
      "Losing": [
        {
          "FileName": "music/losing/44 Medieval II Total War (losing) 3m 26s.mp3",
          "MaxDuration": 207
        },
        {
          "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - Vulture's Lair.mp3",
          "MaxDuration": 110
        },
        {
          "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - Last Fortress.mp3",
          "MaxDuration": 246
        }
      ],
      "Winning": [
        {
          "FileName": "music/first_engage/07 Honor.mp3",
          "MaxDuration": 81
        },
        {
          "FileName": "music/knightsofhonour/Knights of Honor Soundtrack - Pride or Pain.mp3",
          "MaxDuration": 272
        }
      ]
    },
    
  },
  "OverrideAllModMusic": false,
  "AlwaysMuteWarscapeMusic": false
}
```
make sure the files do exist in specified `FileName` otherwise you may  hear nothing or there could be a playback bug in the playlist.  
`MaxDuration` is how long your music should play, it's in second, it's recommended that your music has silent padding at the end, 
to smooth out the transition. So if your music is 180 seconds long (that with 10 seconds silent padding at the end), you set the `MaxDuration` to 175
You can also set your own frontend music here, pretty neat.  
when in the launcher, check sneedio.pack  

##how does it work?  
when sneedio.lua loaded, it tries to execute `require` (or `require2`) function to load the entry point dll `(libsneedio.dll)`  
after that sneedio.lua will control what music and audio should be played.  
other dlls such as SDL.dll are used as codecs, removing one of this may cause incompatibilty which certain audio file (such as .ogg)  

##modders? 
Yes, my script is not really documented, but you can see how I use it on sketch folder.  
You can use my library to:  
 - Play audio when a unit is selected  
 - Play audio when a unit is ordered to attack  
 - Play audio when a unit is ordered to move  
 - Play audio when a unit is ordered to use ability  
 - Play audio when a unit is idling, attacking, or routing  
 - Play audio diplomacy audio in the campaign map  
don't worry, documentation is a must and I'll make it soon.  

##bug report?   
You can report it by creating new issue with the log file (and with video if possible). If you want full debug output, you can edit the debug  
parameter in the sneedio.lua script `SNEEDIO_DEBUG = true;` or set your system enviroment `SNEEDIO_DEBUG` to `1`.  

##contributing  
YES PLEASE! I suck at programming and I really appreaciate your help.  

##brought to you by: 
twg™  
/g/  

