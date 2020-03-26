# VScript Library
[![ver][]](https://github.com/samisalreadytaken/vs_library) [![size][]](/../../raw/master/vs_library.nut)

High-performance, powerful vscript libraries; written mainly for CSGO.

It is advised to always use the latest version.

[ver]: https://img.shields.io/badge/vs__library-v2.35.0-informational
[size]: https://img.shields.io/github/size/samisalreadytaken/vs_library/vs_library.nut

## Documentation
See [Documentation.md](Documentation.md)

## Installation
Place `vs_library.nut` in your vscripts directory `/csgo/scripts/vscripts/`

### Downloading
**Method 1.**
Manually download the library by right clicking [**HERE**](https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/vs_library.nut), and choosing _"Save Link As..."_.  
After acquiring the file, place it in your vscripts directory: `/csgo/scripts/vscripts/`

**Method 2.**
On Windows 10 17063 or later, run the [`install_vs_library.bat`](https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/install_vs_library.bat) file to automatically download the library into your game files. It can also be used to update the library.

**Method 3.**
In bash, after changing the directory below to your Steam game library directory, use the following commands to install the library into your game files.
```
cd "C:/Program Files/Steam/steamapps/common/Counter-Strike Global Offensive/csgo/scripts/vscripts/" && 
curl -O https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/vs_library.nut
```

## Usage
Add this following line in the beginning of your script: `IncludeScript("vs_library")`

Done!

It only needs to be included once in the lifetime of the map running in the server. Including it more than once does not affect the performance. 

### Setting up basis event listeners
Set up these event listeners to automatically validate player userids. This will let you access player userids, SteamIDs, and Steam names.

Entity targetnames are arbitrary.
```
logic_eventlistener:
	targetname: player_connect
	EventName:  player_connect
	FetchEventData: Yes

	OnEventFired > player_connect > RunScriptCode > VS.Events.player_connect(event_data)

logic_eventlistener:
	targetname: player_spawn
	EventName:  player_spawn
	FetchEventData: Yes

	OnEventFired > player_spawn   > RunScriptCode > VS.Events.player_spawn(event_data)
```

You can access the player data via their scope.
```cs
player.GetScriptScope().userid
player.GetScriptScope().networkid
player.GetScriptScope().name
```

You can get the player handle from their userid.
```lua
local player = VS.GetPlayerByUserid(userid)
```

Use `VS.DumpPlayers(1)` to see every player data.
```
] script VS.DumpPlayers(1)

=======================================
1 players found
2 bots found
[BOT]    - ([2] player) :: 8b4f4f2f171_player
--- Script dump for entity ([2] player)
   networkid = "BOT"
   userid = 24
   name = "Chet"
--- End script dump
[BOT]    - ([3] player) :: b02f4f5e377_player
--- Script dump for entity ([3] player)
   networkid = "BOT"
   userid = 25
   name = "Vitaliy"
--- End script dump
[PLAYER] - ([1] player) :: b3ff40ba523_player
--- Script dump for entity ([1] player)
   networkid = "STEAM_1:0:11101"
   userid = 14
   name = "Sam"
--- End script dump
=======================================
```

## Changelog
See [CHANGELOG.txt](CHANGELOG.txt)

## License
You are free to use, modify and share this library under the terms of the MIT License. The only condition is keeping the copyright notice, and state whether or not the code was modified. See [LICENSE](LICENSE) for details.

[![](http://hits.dwyl.com/samisalreadytaken/vs_library.svg)](https://hits.dwyl.com/samisalreadytaken/vs_library)

________________________________

## See also
* [**vscripts repository**][vscripts]: Some of my projects using this library
* [**YouTube channel**][youtube]: Related videos and tutorials
* [**Notepad++ syntax highlighter**][npp]

[vscripts]: https://github.com/samisalreadytaken/vscripts
[youtube]: https://www.youtube.com/channel/UCHOaOBOuH02ZW44SG201d-g
[npp]: https://gist.github.com/samisalreadytaken/5bcf322332074f31545ccb6651b88f2d
