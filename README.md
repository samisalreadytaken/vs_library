# VScript Library
[![ver][]](CHANGELOG.txt) [![size][]](/../../raw/master/vs_library.nut)

High-performance vscript libraries; written mainly for CSGO, compatible with Portal 2.

See the [**hlvr**](https://github.com/samisalreadytaken/vs_library/tree/hlvr) branch for usage in Half-Life Alyx.

[ver]: https://img.shields.io/badge/vs__library-v2.40.0-informational
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
Set up these event listeners to automatically validate player userids. This will let you access player userid, SteamID, and Steam names.

Entity targetnames are arbitrary.
```
logic_eventlistener:
	targetname: player_connect
	EventName:  player_connect
	FetchEventData: Yes

	OnEventFired > player_connect > RunScriptCode > ::VS.Events.player_connect(event_data)

logic_eventlistener:
	targetname: player_spawn
	EventName:  player_spawn
	FetchEventData: Yes

	OnEventFired > player_spawn   > RunScriptCode > ::VS.Events.player_spawn(event_data)
```

You can get the player handle from their userid.
```lua
local player = VS.GetPlayerByUserid(userid)
```

You can access the player data from their script scope.
```cs
local scope = player.GetScriptScope()

scope.userid
scope.networkid
scope.name
```

Use `VS.DumpPlayers(1)` to print every player data.
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
   networkid = "STEAM_1:0:0"
   userid = 14
   name = "Sam"
--- End script dump
=======================================
```

#### Use on dedicated servers

The player_connect event is fired only once when a player connects to the server. For this reason, it is not possible to get the Steam name and SteamIDs of players that were connected to the server prior to a map change. This data will only be available for players that connect to the server while your map is running. This is generally not an issue for singleplayer and coop maps that are locally hosted, unless the map is changed while another is loaded.

This also breaks automatic userid validation, requiring manual work. To manually validate every player, you can execute `VS.ValidateUseridAll()` on an event such as `round_start` or `round_freeze_end`; this is dependant on your map and how the data is used. Note that this validation is asynchronous, meaning you cannot access player userids in the same frame as validating them.

### Listening for events fired multiple times in a frame

Run `VS.FixupEventListener()` on each round start on the event listeners you expect to be fired multiple times in a frame.

```cpp
VS.FixupEventListener( Ent("bullet_impact") )
```

It is harmless to run it on all event listeners.

```cpp
for ( local ent; ent = Entities.FindByClassname( ent, "logic_eventlistener" ); )
{
	VS.FixupEventListener( ent )
}
```

Alternatively you can create a script file with this execution, and attach it to your event listeners. Example file `fixupeventlistener.nut` and its content:

```cpp
IncludeScript("vs_library")
VS.FixupEventListener( self )
```

Using this fixup there can only be _one_ event listener output with event_data access. Details and the reason is explained in the documentation.

## Changelog
See [CHANGELOG.txt](CHANGELOG.txt)

## License
You are free to use, modify and share this library under the terms of the MIT License. The only condition is keeping the copyright notice, and state whether or not the code was modified. See [LICENSE](LICENSE) for details.

[![](http://hits.dwyl.com/samisalreadytaken/vs_library.svg)](https://hits.dwyl.com/samisalreadytaken/vs_library)

________________________________

## See also
* [**vscripts repository**][vscripts]: Some of my projects using this library
* [**YouTube channel**][youtube]
* [**Notepad++ syntax highlighter**][npp]

[vscripts]: https://github.com/samisalreadytaken/vscripts
[youtube]: https://www.youtube.com/channel/UCHOaOBOuH02ZW44SG201d-g
[npp]: https://gist.github.com/samisalreadytaken/5bcf322332074f31545ccb6651b88f2d
