# VScript Library
[![ver][]](CHANGELOG.txt)

High-performance vscript libraries; written mainly for CS:GO, compatible with Portal 2.

See the [**hlvr**](https://github.com/samisalreadytaken/vs_library/tree/hlvr) branch for usage in Half-Life Alyx.

[ver]: https://img.shields.io/badge/vs__library-v2.43.1-informational


## Documentation
See [Documentation.md](Documentation.md)

## Installation
Decide on which library you are going to use, download the file and place it in your vscripts directory `/csgo/scripts/vscripts/`
- [`vs_math.nut`][vs_math]: Standalone math library. Game independent.
- [`vs_events.nut`][vs_events]: Standalone game events library. CSGO only.
- [`vs_library.nut`][vs_library]: All libraries. Includes unique utility functions.
- [`glow.nut`][glow]: Standalone easy glow handling library.

[vs_math]: https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/vs_math.nut
[vs_events]: https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/vs_events.nut
[vs_library]: https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/vs_library.nut
[glow]: https://raw.githubusercontent.com/samisalreadytaken/vs_library/master/glow.nut

## Usage
Include the library file at the beginning of your script: `IncludeScript("vs_library")`

Done!

It only needs to be included once in the lifetime of the map running in the server. Including it more than once does not affect the performance.

### Player eye angles
Use `ToExtendedPlayer()` to access some of the missing player functions in CSGO. See the [documentation](/Documentation.md#f_ToExtendedPlayer) for details.

```cs
local player = ToExtendedPlayer( VS.GetPlayerByIndex(1) );

print(format( "Draw view frustum of [%s] %s\n", player.GetNetworkIDString(), player.GetPlayerName() ));

VS.DrawViewFrustum( player.EyePosition(), player.EyeForward(), player.EyeRight(), player.EyeUp(),
	90.0, 1.7778, 2.0, 16.0, 255, 0, 0, false, 5.0 );

DebugDrawBoxAngles( player.EyePosition(), Vector(2,-1,-1), Vector(32,1,1), player.EyeAngles(), 0, 255, 0, 16, 5.0 );
```

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
IncludeScript("vs_events");
VS.Events.InitTemplate(this);
```

Get the player handle from their userid, and access player data from their script scope.
```cs
local player = VS.GetPlayerByUserid( userid );
local scope = player.GetScriptScope();

printl( scope.userid );
printl( scope.networkid );
printl( scope.name );
```

Use `VS.ListenToGameEvent` to register, `VS.StopListeningToAllGameEvents` to unregister any events dynamically from script.
```cs
VS.ListenToGameEvent( "bullet_impact", function( event )
{
	local pos = Vector( event.x, event.y, event.z );
	local ply = VS.GetPlayerByUserid( event.userid );

	DebugDrawLine( ply.EyePosition(), pos, 255,0,0,false, 2.0 );
	DebugDrawBox( pos, Vector(-2,-2,-2), Vector(2,2,2), 255,0,255,127, 2.0 );
}, "DrawImpact" );
```

#### Use on dedicated servers
It is not possible to get the Steam name and SteamIDs of human players that were connected to a server prior to a map change because the player_connect event is fired only once when a player connects to the server. This data will only be available for players that connect to the server while your map is running.

This issue is fixed in listen servers.

## Changelog
See [CHANGELOG.txt](CHANGELOG.txt)

## License
You are free to use, modify and share this library under the terms of the MIT License. The only condition is keeping the copyright notice, and stating whether or not the code was modified. See [LICENSE](LICENSE) for details.

[![](http://hits.dwyl.com/samisalreadytaken/vs_library.svg)](https://hits.dwyl.com/samisalreadytaken/vs_library)

________________________________

## See also
* [**Notepad++ syntax highlighter**][npp]

[npp]: https://gist.github.com/samisalreadytaken/5bcf322332074f31545ccb6651b88f2d
