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

#ifdef _DEBUG
local gc = collectgarbage;
::collectgarbage = function() : (gc)
{
	local i = gc();
	::print(::format( "DEBUG: collectgarbage %d\n", i ));
	return i;
}

local print = print, Fmt = format, argv = [];
__DPrintf <- function( str, ... ) : ( print, Fmt, argv )
{
	argv.resize( vargc + 2 );
	argv[1] = str;
	for ( local i = vargc; i--; )
		argv[i+2] = vargv[i];
	print( Fmt.acall( argv ) );
	argv.clear();
}

#define DPrintf(...) __DPrintf( __VA_ARGS__ );
#else
#define DPrintf(...)
#endif


local VERSION = _VERSION; // "#.#.#";
local ROOT = getroottable();
local CONST = getconsttable();

// version check
if ( "VS" in ROOT )
{
	local gVS = ::VS;
	if ( typeof gVS == "table" )
	{
		// version strings match, check if this file is loaded
		if ( gVS.version == VERSION )
		{
			DPrintf( "VS: load version string match '%s'\n", VERSION )

			// no mask?
			if ( !(0 in gVS) )
				gVS[0] <- 0;

			// already loaded?
			if ( (gVS[0] & _MASK) == _MASK )
				return DPrintf( "(0x%X) already loaded\n", _MASK );

			// if this library is not loaded, there should be no conflicts
		}
	}
}
// need to declare it for delegation
else ::VS <- {};;


// function VS::(\w+)::(\w+)
// VS\.\1\.\2<\-function
local VS =
{
	[0] = _MASK,
	version = VERSION
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


if ( !PORTAL2 )
{
	// Portal 2 cannot serialise, let it lookup
	VS.Entities <- Entities;
};;


// ------------------------------------------------
// ------------------------------------------------


// merge after the library is loaded
{
	local gVS = ::VS;
	local loadtype;

	if ( "version" in gVS )
	{
		// version comparison to decide merge method
		local pVer1 = split( gVS.version, "." ), pVer2 = split( VS.version, "." );

		// undefined behaviour, corrupted version strings.
		if ( !((2 in pVer1) && (2 in pVer2)) )
			return DPrintf( "VS: load failure, corrupted version strings. [%s], [%s]\n", gVS.version, VS.version );

		DPrintf( "cmp [%s], [%s]\n", gVS.version, VS.version )

		local s = function(p)
		{
			// Strip text 'pre-#.#.#'
			local x = p[0].len();
			while ( 0 <=-- x )
			{
				local c = p[0][x];
				if ( c > '9' || c < '0' )
				{
					p[0] = p[0].slice( x, p[0].len() );
					break;
				};
			}

			// Strip text '#.#.#-post'
			x = 0;
			for ( local i = p.len()-1, l = p[i].len(); ++x < l; )
			{
				local c = p[i][x];
				if ( c > '9' || c < '0' )
				{
					p[i] = p[i].slice( 0, x );
					break;
				};
			}

#ifdef _DEBUG
			print("v "); foreach ( c in p ) print(c + " "); print("\n");
#endif
		}
		s(pVer1);
		s(pVer2);

		local l1 = pVer1.len(), l2 = pVer2.len();

		// resize to make comparison straightforward
		if ( l2 > l1 )
		{
			pVer1.resize( l2, 0 );
			l1 = l2;
		}
		else if ( l2 < l1 )
		{
			pVer2.resize( l1, 0 );
		};;

		local x = 0;
		do
		{
			local v1 = pVer1[x].tointeger(), v2 = pVer2[x].tointeger();
			if ( v2 != v1 )
			{
				// loading new over old
				loadtype = v2 > v1;
				break;
			}
		} while ( ++x < l1 );

		// Differing version strings, but matching version numbers.
		// Moving version comparison code before the load - on initial version check - would only make sense for this condition.
		// Still not very happy with all this...
		if ( loadtype == null )
		{
			if ( (gVS[0] & VS[0]) == VS[0] )
				return DPrintf( "(0x%X) already loaded\n", VS[0] );
		};
	};


	// Initial load
	if ( loadtype == null )
	{
		foreach( k, v in VS )
		{
			gVS.rawset( k, v );
		}

		print(format( "VS v%s [%Xh]\n", gVS.version, gVS[0] ));
	}
	// TODO: print message for changed functions
	// TODO: globals?
	else
	{
		local n = gVS[0] | VS[0];

		print(format( "VS v%s [%Xh] %d(%Xh|%Xh)\n", gVS.version, n, loadtype.tointeger(), gVS[0], VS[0] ));

		if ( loadtype )
		{
			// loading new over old

			// insert new
			// update old
			foreach( k, v in VS )
			{
				// TODO:
				if ( k == "Events" )
					continue;

				gVS.rawset( k, v );
			}
		}
		else
		{
			// loading old over new

			// insert removed functions
			foreach( k, v in VS )
			{
				if ( !(k in gVS) )
				{
					// TODO:
					if ( k == "Events" )
						continue;

					gVS.rawset( k, v );
				}
			}
		};

		gVS[0] = n;
	};

	VS = null;
	return collectgarbage();
}
// ------------
