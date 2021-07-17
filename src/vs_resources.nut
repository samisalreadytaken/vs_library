//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------

local _ = ::getroottable();

// Don't load if the library is already loaded
if( "VS" in _ && typeof::VS == "table" &&
    "IsInteger" in ::VS && !::VS._reload )
	return;;

local __ = function(){}
local _f = __.getinfos().src;
_f = _f.slice(0,_f.find(".nut"));

// The rest is wrapped in this in the minified file.
// __ = function():(_f){}.call(_);

if( _f != "vs_library" )
	::print("Loading vs_library...\n");

local PORTAL2 = "CPortal_Player" in ::getroottable() &&
                "TurnOnPotatos" in ::CPortal_Player &&
                ::CPortal_Player.TurnOnPotatos.getinfos().native;

local EVENTS = !!::Entities.FindByClassname(null,"logic_eventlistener");

::VS <-
{
	version = "vs_library v#.#.#",
	_reload = false
}

// reduce a call on Msg
if( ::print.getinfos().native )
	::Msg <- ::print;

if( ::EntFireByHandle.getinfos().native )
	::DoEntFireByInstanceHandle <- ::EntFireByHandle;

local TICK_INTERVAL = FrameTime();

// FIXME:
// The very first local server,
// default to 64 tick for now.
if ( TICK_INTERVAL == 0.0 )
	TICK_INTERVAL = 0.015625

local ROOT = getroottable();
::CONST <- getconsttable();
::MAX_COORD_FLOAT <- 16384.0;
::MAX_TRACE_LENGTH <- 56755.84086241; 	// sqrt(0x0003) * 0x0002 * 0x4000 = 56755.84086241697115430736
::DEG2RAD <- 0.01745329;				// 0.01745329251994329576
::RAD2DEG <- 57.29577951; 				// 57.29577951308232087679
// PI 									3.14159265358979323846
// RAND_MAX 							0x7FFF

::collectgarbage();
