//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------
//
//
//
// vs_math		(1 << 1)
// vs_utility	(1 << 2)
// vs_entity	(1 << 3)
// vs_events	(1 << 4)
// vs_log		(1 << 5)
//

local _VERSION = "vs_library v#.#.#";
local ROOT = getroottable();
local CONST = getconsttable();

// version check
if ( "VS" in ROOT && typeof ::VS == "table" )
{
	// version strings match, check if this file is loaded
	if ( ::VS.version == _VERSION )
	{
		// no mask?
		if ( !(0 in ::VS) )
			::VS[0] <- 0;

		// already loaded?
		if ( ::VS[0] & _MASK )
		// if ( ::VS[0] >= _MASK ) // NOTE: only valid where all files combined
			return;

		// if this file is not loaded, there should be no conflicts
	}
	// if version strings don't match, compare versions in the end
}
// need to declare it for delegation
else ::VS <- {};;


// function VS::(\w+)::(\w+)
// VS\.\1\.\2<\-function
local VS =
{
	[0] = 0,
	version = _VERSION
}

// reduce a call on Msg
if ( ::print.getinfos().native )
	::Msg <- ::print;;

if ( ::EntFireByHandle.getinfos().native )
	::DoEntFireByInstanceHandle <- ::EntFireByHandle;;

local AddEvent = ::DoEntFireByInstanceHandle;
local Fmt = ::format;
local TICK_INTERVAL = ::FrameTime();

// FIXME:
// The very first local server,
// default to 64 tick for now.
if ( TICK_INTERVAL == 0.0 )
	TICK_INTERVAL = 0.015625;;



local PORTAL2 =
	"CPortal_Player" in ROOT &&
	"TurnOnPotatos" in ::CPortal_Player &&
	::CPortal_Player.TurnOnPotatos.getinfos().native;


// ------------------------------------------------
// ------------------------------------------------


// merge after the library is loaded
// TODO: this is all a mess that may break easily
// notably the combined file needs to check special cases
{
	local gVS = ::VS;

	// initial load
	if ( !gVS.len() )
	{
		foreach( k, v in VS )
		{
			gVS[k] <- v;
		}
		return ::collectgarbage();
	};

	// Assert : is the environment messed up?
	if ( VS == gVS )
		return ::collectgarbage();

	// merge
	if ( gVS.version == VS.version )
	{
		local n = gVS[0] | VS[0];
		foreach( k, v in VS )
		{
			// TODO:
			// if ( k == "Events" )
			// 	continue;

			gVS[k] <- v;
		}
		gVS[0] = n;
		return ::collectgarbage();
	};

	local verNum_target = "";
	local ver_target = gVS.version;
	local c = ver_target.len();
	for ( local i = 0; i < c; ++i )
	{
		local ch = ver_target[i];
		if ( ch >= '0' && ch <= '9' )
			verNum_target += ch.tochar();
	}
	if ( verNum_target == "" )
	{
		verNum_target = 0;
		Msg("VS: invalid version number ("+ver_target+")!\n");
	};
	verNum_target = verNum_target.tointeger();

	local verNum_this = "";
	local ver_this = VS.version;
	c = ver_this.len();
	for ( local i = 0; i < c; ++i )
	{
		local ch = ver_this[i];
		if ( ch >= '0' && ch <= '9' )
			verNum_this += ch.tochar();
	}
	if ( verNum_this == "" )
	{
		verNum_this = 0;
		Msg("VS: invalid version number ("+ver_this+")\n");
	};
	verNum_this = verNum_this.tointeger();

	if ( verNum_target == verNum_this )
	{
		// the version string was changed but not the version number
		Msg("VS: non-matching version strings!\n");
		return ::collectgarbage();
	};

	// TODO: print message for changed functions
	// TODO: globals?
	if ( verNum_target < verNum_this )
	{
		// loading new over old

		// insert new
		// update old
		foreach( k, v in VS )
		{
			// TODO:
			if ( k == "Events" )
				continue;

			gVS[k] <- v;
		}
	}
	else
	{
		// loading old over new

		// insert removed functions
		foreach( k, v in VS )
		{
			// TODO:
			if ( k == "Events" )
				continue;

			if ( !(k in gVS) )
			{
				gVS[k] <- v;
			}
		}
	};
	VS = null;
	return ::collectgarbage();
}
// ------------

