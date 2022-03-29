# <img src="extras/logosmall.png" width="64" /> Libsneedio

## Version
Version a0.4.1 seems stable enough for me.  

## Steam Workshop
https://steamcommunity.com/sharedfiles/filedetails/?id=2784691287

## What is it? 
it's a music and audio library to enable custom music and audio for your dudes.  

## for average normal user  
Go to this page for installation instructions: [install.md](doc/install.md)  
This mod doesn't come with music packs, you have to make your own or download them from the workshop or somewhere else.

## modders? 
Please check out the [Documentation](doc/sneedio.md) for API usage and examples.  
You can also follow getting started guide [here](doc/modder-getting-started.md).

## how does it work?  
when sneedio.lua loaded, it tries to execute `require` (or `require2`) function to load the entry point dll `(libsneedio.dll)`  
after that sneedio.lua will control what music and audio should be played.  
other dlls such as SDL.dll are used as codecs, removing one of these may cause incompatibilty with certain audio file (such as .ogg)  

## how to build?
run make.bat+install.bat  
or apply patches to external folder, then open the solution to build the binaries  
don't forget to pack the script and install them in your game.  

## bug report?   
You can report it by creating new issue with the log file (and with video if possible). If you want full debug output, you can edit the debug  
parameter in the sneedio.lua script `SNEEDIO_DEBUG = true;` or set your system enviroment `SNEEDIO_DEBUG` to `1`.  

## contributing  
YES PLEASE! I suck at programming and I really appreaciate your help.  

## brought to you by: 
twg™  
/g/  

logo is courtesy of anonymous.  
paper icon is courtesy of https://iconarchive.com/show/hyperion-icons-by-icondesigner.net/Sidebar-Documents-icon.html