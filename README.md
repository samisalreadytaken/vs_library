# VScript Library
[![ver][]](CHANGELOG.txt)

High-performance vscript libraries; written mainly for CSGO, compatible with Portal 2.

See the [**hlvr**](https://github.com/samisalreadytaken/vs_library/tree/hlvr) branch for usage in Half-Life Alyx.

[ver]: https://img.shields.io/badge/vs__library-v2.41.1-informational


## Documentation
See [Documentation.md](Documentation.md)

## Installation
Decide which library you are going to use, download the file and place it in your vscripts directory `/csgo/scripts/vscripts/`
- [`vs_math.nut`][vs_math]: Standalone math library. Game independent.
- [`vs_events.nut`][vs_events]: Standalone game events library. CSGO only.
- [`vs_library.nut`][vs_library]: All libraries. Includes unique utility functions.
- [`glow.nut`][glow]: Standalone easy glow handling library.
- [`fov.nut`][fov]: Utility for setting player FOV. Requires `vs_library.nut`.

[vs_math]: https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/vs_math.nut
[vs_events]: https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/vs_events.nut
[vs_library]: https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/vs_library.nut
[glow]: https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/glow.nut
[fov]: https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/fov.nut

## Usage
Include the library file at the top of your script: `IncludeScript("vs_library")`

Done!

It only needs to be included once in the lifetime of the map running in the server. Including it more than once does not affect the performance.


### Event listener setup
[![](https://img.shields.io/badge/video-red?logo=youtube)](https://www.youtube.com/watch?v=JGnBQ1lwzzg)

Setting up these 2 entities will automatically acquire player userid, SteamID and Steam names; and also expose event listener registration from script with `VS.ListenToGameEvent`.

```
logic_eventlistener:
	targetname: vs.eventlistener

point_template:
	Entity Scripts: vs_eventlistener.nut
	Template01: vs.eventlistener
```

`vs_eventlistener.nut` file contents should read:
```cpp
IncludeScript("vs_events")
VS.Events.InitTemplate(this)
```

Get the player handle from their userid, and access player data from their script scope.
```cs
local player = VS.GetPlayerByUserid( userid )
local scope = player.GetScriptScope()

printl( scope.userid )
printl( scope.networkid )
printl( scope.name )
```

Use `VS.ListenToGameEvent` to register, `VS.StopListeningToAllGameEvents` to unregister any events dynamically from script.
```cs
VS.ListenToGameEvent( "bullet_impact", function( event )
{
	local vec = Vector( event.x, event.y, event.z )
	DebugDrawBox( vec, Vector(-2,-2,-2), Vector(2,2,2), 255,0,255,127, 2.0 )
}, "impact" )

VS.ListenToGameEvent( "player_say", function( event )
{
	local ply = VS.GetPlayerByUserid( event.userid )
	local name = ply.GetScriptScope().name
	local msg = event.text;

	switch (msg)
	{
		case "stop impact":
			VS.StopListeningToAllGameEvents( "impact" )
			return
	}
	ScriptPrintMessageChatAll(format( "%s says: \"%s\"", name, msg ))
}, "" )
```

#### Use on dedicated servers
The player_connect event is fired only once when a player connects to the server. For this reason, it is not possible to get the Steam name and SteamIDs of players that were connected to the server prior to a map change. This data will only be available for players that connect to the server while your map is running.

## Changelog
See [CHANGELOG.txt](CHANGELOG.txt)

## License
You are free to use, modify and share this library under the terms of the MIT License. The only condition is keeping the copyright notice, and state whether or not the code was modified. See [LICENSE](LICENSE) for details.

[![](http://hits.dwyl.com/samisalreadytaken/vs_library.svg)](https://hits.dwyl.com/samisalreadytaken/vs_library)

________________________________

## See also
* [**Notepad++ syntax highlighter**][npp]

[npp]: https://gist.github.com/samisalreadytaken/5bcf322332074f31545ccb6651b88f2d
