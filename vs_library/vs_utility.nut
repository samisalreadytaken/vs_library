//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------

local Entities = ::Entities;
local DebugDrawBox = ::DebugDrawBox;
local DoUniqueString = ::DoUniqueString;
local Fmt = ::format;

::Ent  <- function( s, i = null ):(Entities){ return Entities.FindByName(i,s); }
::Entc <- function( s, i = null ):(Entities){ return Entities.FindByClassname(i,s); }

//-----------------------------------------------------------------------
// Input  : Vector
// Output : string
//-----------------------------------------------------------------------
::VecToString <- function( vec, prefix = "Vector(", separator = ",", suffix = ")" ) : (Fmt)
{
	return Fmt( "%s%g%s%g%s%g%s", prefix, vec.x, separator, vec.y, separator, vec.z, suffix );
}

//-----------------------------------------------------------------------
// Draw entity's AABB
// ent_bbox
//-----------------------------------------------------------------------
function VS::DrawEntityBBox( time, ent, r = 255, g = 138, b = 0, a = 0 ):(DebugDrawBox)
{
	return DebugDrawBox(ent.GetOrigin(),ent.GetBoundingMins(),ent.GetBoundingMaxs(),r,g,b,a,time);
}

//-----------------------------------------------------------------------
// Ray tracing
/*

local trace = VS.TraceLine( v1, v2 )

trace.DidHit()
trace.GetEnt( search_radius )
trace.GetPos()
trace.GetDist()
trace.GetNormal()

trace.fraction
trace.startpos
trace.endpos
trace.hitpos
trace.normal

*/
//-----------------------------------------------------------------------
local Trace = ::TraceLine;

class::VS.TraceLine
{
	constructor( start = null, end = null, ent = null ):(Vector,Trace)
	{
		if ( !start )
		{
			local v = Vector();
			startpos = v;
			endpos = v;
			ignore = ent;
			fraction = 1.0;
			return;
		};

		startpos = start;
		endpos = end;
		ignore = ent;
		fraction = Trace( startpos, endpos, ignore );
	}

	function _cmp(d) { if ( fraction < d.fraction ) return -1; if ( fraction > d.fraction ) return 1; return 0; }
	function _add(d) { return fraction + d.fraction; }
	function _sub(d) { return fraction - d.fraction; }
	function _mul(d) { return fraction * d.fraction; }
	function _div(d) { return fraction / d.fraction; }
	function _modulo(d) { return fraction % d.fraction; }
	function _unm() { return -fraction; }
	function _typeof() { return "trace_t"; }

	startpos = null;
	endpos = null;
	ignore = null;
	fraction = 0.0;
	hitpos = null;
	normal = null;

	m_Delta = null;
	m_IsSwept = null;
	m_Extents = null;
	m_IsRay = null;
	m_StartOffset = null;
	m_Start = null;
}

//-----------------------------------------------------------------------
// Set 'f' to limit the max distance
// Input  : Vector [ start pos ]
//          Vector [ normalised direction ]
//          handle [ to ignore ]
// Output : trace_t [ VS.TraceLine ]
//-----------------------------------------------------------------------
local CTrace = ::VS.TraceLine;

function VS::TraceDir( v1, vDir, f = MAX_TRACE_LENGTH, hEnt = null ):(CTrace)
{
	return CTrace( v1, v1 + (vDir * f), hEnt );
}

// if direct LOS return false
function VS::TraceLine::DidHit()
{
	return fraction < 1.0;
}

// return hit entity handle, null if none
function VS::TraceLine::GetEnt( radius )
{
	return GetEntByClassname( "*", radius );
}

// GetEnt, find by name
function VS::TraceLine::GetEntByName( targetname, radius ):(Entities)
{
	if ( !hitpos ) GetPos();
	return Entities.FindByNameNearest( targetname, hitpos, radius );
}

// GetEnt, find by classname
function VS::TraceLine::GetEntByClassname( classname, radius ):(Entities)
{
	if ( !hitpos ) GetPos();
	return Entities.FindByClassnameNearest( classname, hitpos, radius );
}

// return hit position (hitpos)
function VS::TraceLine::GetPos()
{
	if ( !hitpos )
	{
		if ( DidHit() ) hitpos = startpos + (endpos - startpos) * fraction;
		else hitpos = endpos;
	};
	return hitpos;
}

// Get distance from startpos to hit position
function VS::TraceLine::GetDist()
{
	return (startpos-GetPos()).Length();
}

// Get distance squared. Useful for comparisons
function VS::TraceLine::GetDistSqr()
{
	return (startpos-GetPos()).LengthSqr();
}

local TraceDir = ::VS.TraceDir;

// Get surface normal
function VS::TraceLine::GetNormal():(Vector,TraceDir)
{
	if ( !normal )
	{
		local u = Vector(0.0,0.0,0.5),
			  d = endpos - startpos;
		d.Norm();
		GetPos();
		normal = (hitpos-TraceDir(startpos+d.Cross(u),d).GetPos()).Cross(hitpos-TraceDir(startpos+u,d).GetPos());
		normal.Norm();
	};

	return normal;
}

// initiate ray tracing
function VS::TraceLine::Ray( mins =::Vector(), maxs =::Vector() )
{
	m_Delta = endpos - startpos;
	m_IsSwept = m_Delta.LengthSqr() != 0.0;
	m_Extents = (maxs - mins) * 0.5;
	m_IsRay = m_Extents.LengthSqr() < 1.e-6;
	m_StartOffset = (mins + maxs) * 0.5;
	m_Start = startpos + m_StartOffset;
	m_StartOffset *= -1.0;
	return this;
}

// VECTOR_CONE_1DEGREES  = Vector( 0.00873, 0.00873, 0.00873 )
// VECTOR_CONE_2DEGREES  = Vector( 0.01745, 0.01745, 0.01745 )
// VECTOR_CONE_3DEGREES  = Vector( 0.02618, 0.02618, 0.02618 )
// VECTOR_CONE_4DEGREES  = Vector( 0.03490, 0.03490, 0.03490 )
// VECTOR_CONE_5DEGREES  = Vector( 0.04362, 0.04362, 0.04362 )
// VECTOR_CONE_6DEGREES  = Vector( 0.05234, 0.05234, 0.05234 )
// VECTOR_CONE_7DEGREES  = Vector( 0.06105, 0.06105, 0.06105 )
// VECTOR_CONE_8DEGREES  = Vector( 0.06976, 0.06976, 0.06976 )
// VECTOR_CONE_9DEGREES  = Vector( 0.07846, 0.07846, 0.07846 )
// VECTOR_CONE_10DEGREES = Vector( 0.08716, 0.08716, 0.08716 )
// VECTOR_CONE_15DEGREES = Vector( 0.13053, 0.13053, 0.13053 )
// VECTOR_CONE_20DEGREES = Vector( 0.17365, 0.17365, 0.17365 )

//function VS::ApplySpread(vecShotDirection, vecSpread, bias = 1.0)
//{
//	// get circular gaussian spread
//	local x, y, z;
//
//	if ( bias > 1.0 )
//		bias = 1.0;
//	else if ( bias < 0.0 )
//		bias = 0.0;;
//
//	local shotBiasMin = -1.0;
//	local shotBiasMax = 1.0;
//
//	// 1.0 gaussian, 0.0 is flat, -1.0 is inverse gaussian
//	local shotBias = ( ( shotBiasMax - shotBiasMin ) * bias ) + shotBiasMin;
//
//	local flatness = ( fabs(shotBias) * 0.5 );
//
//	do
//	{
//		x = RandomFloat(-1.0,1.0) * flatness + RandomFloat(-1.0,1.0) * (1.0 - flatness);
//		y = RandomFloat(-1.0,1.0) * flatness + RandomFloat(-1.0,1.0) * (1.0 - flatness);
//		if ( shotBias < 0.0 )
//		{
//			x = ( x >= 0.0 ) ? 1.0 - x : -1.0 - x;
//			y = ( y >= 0.0 ) ? 1.0 - y : -1.0 - y;
//		};
//		z = x*x+y*y;
//	} while (z > 1)
//
//	local vecRight = Vector(), vecUp = Vector();
//	VectorVectors(vecShotDirection, vecRight, vecUp);
//
//	return vecShotDirection + x * vecSpread.x * vecRight + y * vecSpread.y * vecUp;
//}

//-----------------------------------------------------------------------
// UniqueString without _ in the end
//-----------------------------------------------------------------------
function VS::UniqueString():(DoUniqueString)
{
	local s = DoUniqueString("");
	return s.slice(0,s.len()-1);
}

//-----------------------------------------------------------------------
// FindInArray
// arr.find( val )
//
// linear search
// if value found in array, return index
// else return null
//-----------------------------------------------------------------------
function VS::arrayFind( arr, val )
{
	foreach( i, v in arr )
		if ( v == val )
			return i;
}

//-----------------------------------------------------------------------
// arr.apply( func(v) )
// apply the input function to every element in the input array
//-----------------------------------------------------------------------
function VS::arrayApply( arr, func )
{
	foreach( i, v in arr )
		arr[i] = func( v );
}

//-----------------------------------------------------------------------
// arr.map( func(v) )
// Same as arrayApply, but return a new array. Doesn't modify the input array
//-----------------------------------------------------------------------
local array = ::array;

function VS::arrayMap( arr, func ):(array)
{
	local new = array(arr.len());

	foreach( i, v in arr )
		new[i] = func( v );
	return new;
}

//-----------------------------------------------------------------------
// Debug dump scope. expensive
//
// < VS.DumpScope(input, 1, 1, 0, nDepth) > is equivalent to <__DumpScope(nDepth, input)>
//
// Input  : array/table [ array or table to dump ]
//          bool [ print default (native) variables ]
//          bool [ expand nested tables and arrays ]
//          bool [ --- ]
//          integer [ indent ]
//-----------------------------------------------------------------------
local print = ::print;
function VS::DumpScope( input, bPrintAll = false, bDeepPrint = true, bPrintGuides = true, nDepth = 0 ):(print)
{
	// non-native variables
	local _skip = ["Assert","Document","PrintHelp","RetrieveNativeSignature","UniqueString","IncludeScript","Entities","CSimpleCallChainer","CCallChainer","LateBinder","__ReplaceClosures","__DumpScope","printl","VSquirrel_OnCreateScope","VSquirrel_OnReleaseScope","PrecacheCallChain","OnPostSpawnCallChain","DispatchOnPostSpawn","DispatchPrecache","OnPostSpawn","PostSpawn","Precache","PreSpawnInstance","__EntityMakerResult","__FinishSpawn","__ExecutePreSpawn","EntFireByHandle","EntFire","RAND_MAX","_version_","_intsize_","PI","_charsize_","_floatsize_","self","__vname","__vrefs","_xa9b2dfB7ffe","VS","Chat","ChatTeam","txt","PrecacheModel","PrecacheScriptSound","delay","OnGameEvent_player_spawn","OnGameEvent_player_connect","VecToString","HPlayer","Ent","Entc","Quaternion","matrix3x4","max","min","clamp","MAX_COORD_FLOAT","MAX_TRACE_LENGTH","DEG2RAD","RAD2DEG","CONST"];
	local indent = function(c) for( local i = c; i--; ) print("   ");
	local SWorld = Entities.First().GetScriptScope();
	if ( bPrintGuides ) print(" ------------------------------\n");
	if ( input )
	{
		foreach( key, val in input )
		{
			local type = typeof val;
			local bSkip = false;

			if ( !bPrintAll )
			{
				switch ( type )
				{
					case "native function":
						bSkip = true;
						break;

					case "class":
						foreach ( k,v in val )
						{
							if ( typeof v == "native function" )
							{
								bSkip = true;
								break;
							};
						}
						break;

					case "table":
						if ( SWorld && (val == SWorld) )
						{
							bSkip = true;
						};
						break;
				}

				// final check for varied types
				if ( !bSkip )
				{
					foreach ( k in _skip ) if ( key == k )
					{
						bSkip = true;
						break;
					};
				};
			}
			// skip these even if printing all
			else if ( key == "VS" || key == "Documentation" )
			{
				bSkip = true;
			};;

			if ( !bSkip )
			{
				indent(nDepth);
				print(key);

				switch ( type )
				{
					case "table":
						print("(TABLE) : " + val.len());
						if (!bDeepPrint) break;
						print("\n");
						indent(nDepth);
						print("{\n");
						DumpScope( val, bPrintAll, bDeepPrint, false, nDepth + 1 );
						indent(nDepth);
						print("}");
						break;

					case "array":
						print("(ARRAY) : " + val.len());
						if (!bDeepPrint) break;
						print("\n");
						indent(nDepth);
						print("[\n");
						DumpScope( val, bPrintAll, bDeepPrint, false, nDepth + 1 );
						indent(nDepth);
						print("]");
						break;

					case "string":
						print(" = \"" + val + "\"");
						break;

					case "Vector":
						print(" = " + ::VecToString(val));
						break;

					default:
						print(" = " + val);
				}
				print("\n");
			};
		}
	}
	else print("(NULL)\n");
	if ( bPrintGuides ) print(" ------------------------------\n");
}

//-----------------------------------------------------------------------
// Input  : array [ input ]
// Output : table [ clone of the input ]
//-----------------------------------------------------------------------
function VS::ArrayToTable( a )
{
	local t = {}
	foreach( i, v in a ) t[v] <- i;
	return t;
}

//-----------------------------------------------------------------------
// Put in the function you want to get stack info from
// if bDeepPrint && scope not roottable, bDeepPrint
/*
Engine function calls are done through Call(...), that's why these 2 stacks are excluded.
	 ---
	line = -1
	locals(TABLE) : 0
	src = "NATIVE"
	func = "pcall"
	 ---
	line = 360
	locals(TABLE) : 5
	{
	   i = 0
	   args(ARRAY) : 0
	   this = (instance : 0x00000000)
	   result = (null : 0x00000000)
	   func = (function : 0x00000000)
	}
	src = "unnamed"
	func = "Call"
	 ---
*/
//-----------------------------------------------------------------------
function VS::GetStackInfo( bDeepPrint = false, bPrintAll = false )
{
	::print(" --- STACKINFO ----------------\n");
	local s, j = 2;
	while( s =::getstackinfos(j++) )
	{
		if ( s.func == "pcall" && s.src == "NATIVE" ) break;
		::print(" ("+(j-1)+")\n");
		local w, m = s.locals;
		if ( "this" in m && typeof m["this"] == "table" )
		{
			if (m["this"] == ::getroottable())
			{
				w = "roottable";
			}
			else
			{
				if ( w = GetVarName(m["this"]) )
				{
					m[w] <- delete m["this"];
				};
			};
		};
		if ( w == "roottable" ) DumpScope(s, bPrintAll, 0, 0);
		else DumpScope(s, bPrintAll, bDeepPrint, 0);
		if (w)::print("scope = \""+w+"\"\n");
	}
	::print(" --- STACKINFO ----------------\n");
}

local Stack = ::getstackinfos;

// return caller table
function VS::GetCaller():(Stack) return Stack(3).locals["this"];

// (DEBUG) return caller function as string
function VS::GetCallerFunc():(Stack) return Stack(3).func;

//-----------------------------------------------------------------------
// Input  : table
// Output : array containing the input's directory
//-----------------------------------------------------------------------
function VS::GetTableDir(input)
{
	if ( typeof input != "table" )
		throw "Invalid input type '" + typeof input + "' ; expected: 'table'";

	local a = [];
	local r = _f627f40d21a6(a,input);

	if (r)
	{
		r.insert( r.len(), "roottable" );
		r.reverse();
	}
	else
	{
		r = a;
		r.clear();
		r.resize(1);
		r[0] = "roottable";
	};

	return r;
}

// exclusive recursion function
function VS::_f627f40d21a6(bF, t, l = ROOT)
{
	foreach(v, u in l)
		if (typeof u == "table")
			if (v != "VS" && v != "Documentation")
				if (u == t)
				{
					bF.append(v);
					return bF;
				}
				else
				{
					local r = _f627f40d21a6(bF, t, u);
					if (r)
					{
						bF.append(v);
						return r;
					};
				};;;
}

//-----------------------------------------------------------------------
// Input  : string [variable]
// Output : variable
//-----------------------------------------------------------------------
function VS::FindVarByName(S)
{
	if (typeof S != "string")
		throw "Invalid input type '" + typeof S + "' ; expected: 'string'";

	return _fb3k55Ir91t7(S);
}

// exclusive recursion function
function VS::_fb3k55Ir91t7(t, l = ROOT)
{
	if (t in l)
		return l[t];
	else
		foreach(v, u in l)
			if (typeof u == "table")
				if (v != "VS" && v != "Documentation")
				{
					local r = _fb3k55Ir91t7(t, u);
					if (r) return r;
				};;;
}

//-----------------------------------------------------------------------
// Doesn't work with primitive variables if
// there are multiple variables with the same value.
// But it can work if the value is unique, like a unique string.
//-----------------------------------------------------------------------
function VS::GetVarName(v)
{
	local t = typeof v;

	if ( t == "function" || t == "native function" )
		return v.getinfos().name;

	return _fb3k5S1r91t7(t, v);
}

// exclusive recursion function
function VS::_fb3k5S1r91t7(t, i, s = ROOT)
{
	foreach(k, v in s)
	{
		if (v == i)
			return k;

		if (typeof v == "table")
			if (k != "VS" && k != "Documentation")
			{
				local r = _fb3k5S1r91t7(t, i, v);
				if (r) return r;
			};;
	}
}

local World;
{
	World = Entc("worldspawn");
	if ( !World )
	{
		Msg("ERROR: could not find worldspawn\n");
		World = VS.CreateEntity("soundent");
	};
}

//-----------------------------------------------------------------------
// Deprecated. Use VS.EventQueue.AddEvent instead.
//
//  	VS.EventQueue.AddEvent( MyFunc, 0.5 )
//  	VS.EventQueue.AddEvent( MyFunc, 0.5, this )
//  	VS.EventQueue.AddEvent( MyFunc, 0.5, null )
//  	VS.EventQueue.AddEvent( MyFunc, 0.5, [ this, "param1", "param2" ] )
//  	VS.EventQueue.AddEvent( MyFunc, 0.5, [ this, "param1", "param2" ], activator, caller )
//
//
// Each string is allocated and added to the game string pool.
//-----------------------------------------------------------------------
local AddEvent = ::DoEntFireByInstanceHandle;
::delay <- function( X, T = 0.0, E = World, A = null, C = null ):(AddEvent)
	return AddEvent( E, "RunScriptCode", ""+X, T, A, C );


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------


{
VS.EventQueue <-
{
	m_flNextQueue = -1.0,
	m_flLastQueue = -1.0
}

// enum
local m_pNext      = 0;
local m_flFireTime = 1;
local m_pPrev      = 2;
local m_hFunc      = 3;
local m_argv       = 4;
local m_Env        = 5;
local m_activator  = 6;
local m_caller     = 7;

local curtime   = Time;

local m_Events     = [null,null];
m_Events[ m_flFireTime ] = -1.E+37; // -FLT_MAX

VS.EventQueue.Dump <- function( bUseTicks = false ) :
( m_Events, m_flFireTime, m_pNext, m_hFunc, m_argv, m_Env, m_activator, m_caller, curtime, Fmt, TICK_INTERVAL )
{
	local get = function(i):(Fmt)
	{
		if ( i == null )
			return "(NULL)";
		local s = "" + i;
		local t = s.find("0x");
		if ( t == null )
			return s;
		return Fmt("(%s)", s.slice( t, s.len()-1 ));
	}

	local TIME_TO_TICKS = function( dt ) : ( TICK_INTERVAL )
	{
		return ( 0.5 + dt / TICK_INTERVAL ).tointeger();
	}

	Msg(Fmt( "VS::EventQueue::Dump: %g : next(%g), last(%g)\n",
		bUseTicks ? TIME_TO_TICKS( curtime() ) : curtime(),
		bUseTicks ? ( m_flNextQueue == -1.0 ? -1.0 : TIME_TO_TICKS( m_flNextQueue ) ) : m_flNextQueue,
		bUseTicks ? TIME_TO_TICKS( m_flLastQueue ) : m_flLastQueue ));

	for ( local ev = m_Events; ev = ev[ m_pNext ]; )
	{
		Msg(Fmt( "   (%s) func '%s', %s '%s', activator '%s', caller '%s'\n",
			bUseTicks ? ""+TIME_TO_TICKS( ev[m_flFireTime] ) : Fmt( "%.2f", ev[m_flFireTime] ),
			get( ev[m_hFunc] ),
			((typeof ev[m_argv] == "array") && ev[m_argv].len()) ? "arg" : "env",
			get( ((typeof ev[m_argv] == "array") && ev[m_argv].len()) ? ev[m_argv][0] : ev[m_Env] ),
			get( ev[m_activator] ),
			get( ev[m_caller] ) ));
	}
	Msg( "VS::EventQueue::Dump: end.\n" );

}.bindenv(VS.EventQueue);

VS.EventQueue.Clear <- function() : ( m_Events, m_pNext, m_pPrev )
{
	local ev = m_Events[ m_pNext ];
	while ( ev )
	{
		local next = ev[ m_pNext ];
		ev[ m_pNext ] = null;
		ev[ m_pPrev ] = null;
		ev = next;
	}
	m_Events[ m_pNext ] = null;
	m_flNextQueue = -1.0;
	m_flLastQueue = -1.0;

}.bindenv(VS.EventQueue);

VS.EventQueue.CancelEventsByInput <- function( f ) : ( m_Events, m_pNext, m_pPrev, m_hFunc )
{
	local ev = m_Events;
	while ( ev = ev[ m_pNext ] )
	{
		if ( f == ev[ m_hFunc ] )
		{
			ev[ m_pPrev ][ m_pNext ] = ev[ m_pNext ];
			if ( ev[ m_pNext ] )
				ev[ m_pNext ][ m_pPrev ] = ev[ m_pPrev ];
		};
	}

	if ( !m_Events[m_pNext] )
		m_flNextQueue = -1.0;

}.bindenv(VS.EventQueue);

VS.EventQueue.RemoveEvent <- function( ev ) : ( m_Events, m_pNext, m_pPrev )
{
	if ( typeof ev == "weakref" )
		ev = ev.ref();

	local pe = m_Events;
	while ( pe = pe[ m_pNext ] )
	{
		if ( ev == pe )
		{
			ev[ m_pPrev ][ m_pNext ] = ev[ m_pNext ];
			if ( ev[ m_pNext ] )
				ev[ m_pNext ][ m_pPrev ] = ev[ m_pPrev ];

			if ( !m_Events[m_pNext] )
				m_flNextQueue = -1.0;

			return;
		};
	}
}.bindenv(VS.EventQueue);

VS.EventQueue.AddEventInternal <- function( event, flDelay ) :
( World, curtime, AddEvent, m_Events, m_pNext, m_pPrev, m_flFireTime, m_activator, m_caller, TICK_INTERVAL )
{
	local curtime = curtime();
	local flFireTime = curtime + flDelay;
	event[ m_flFireTime ] = flFireTime;

	local ev = m_Events;
	while ( ev[ m_pNext ] )
	{
		if ( event[ m_flFireTime ] < ev[ m_pNext ][ m_flFireTime ] )
			break;
		ev = ev[ m_pNext ];
	}

	event[ m_pNext ] = ev[ m_pNext ];
	event[ m_pPrev ] = ev;
	ev[ m_pNext ] = event;

	if ( m_flLastQueue != curtime )
	{
		m_flLastQueue = curtime;

		if ( (m_flNextQueue == -1.0) || (flFireTime < m_flNextQueue) )
		{
			m_flNextQueue = flFireTime;
			AddEvent( World, "RunScriptCode", "::VS.EventQueue.ServiceEvents()", 0.0, event[m_activator], event[m_caller] );
		}
		// Expect no event to be not fired for longer than a frame
		else if ( m_Events[ m_pNext ] && ( ( curtime - m_Events[ m_pNext ][ m_flFireTime ] ) >= TICK_INTERVAL ) )
		{
			// Game eventqueue is reset, or something has gone wrong.
			// Reset
			Clear();
			return AddEventInternal( event, flDelay );
		};;
	};

	return event.weakref();

}.bindenv(VS.EventQueue);

local AddEventInternal = VS.EventQueue.AddEventInternal;

VS.EventQueue.AddEvent <- function( hFunc, flDelay, argv = null, activator = null, caller = null ) :
( AddEventInternal, m_flFireTime, m_hFunc, m_Env, m_argv, m_activator, m_caller, ROOT )
{
	local event = CreateEvent( hFunc, argv , activator , caller );
	return AddEventInternal( event, flDelay );

}.bindenv(VS.EventQueue);

VS.EventQueue.CreateEvent <- function( hFunc, argv = null, activator = null, caller = null ) :
( m_flFireTime, m_hFunc, m_Env, m_argv, m_activator, m_caller, ROOT )
{
	local event = [null,null,null,null,null,null,null,null];
	event[ m_hFunc ] = hFunc;
	event[ m_activator ] = activator;
	event[ m_caller ] = caller;

	local typeofArgs = typeof argv;
	if ( typeofArgs == "table" )
	{
		event[ m_Env ] = argv;
	}
	else if ( typeofArgs == "array" )
	{
		event[ m_argv ] = argv;
	}
	else
	{
		event[ m_Env ] = ROOT;
	};;

	return event;
}

VS.EventQueue.ServiceEvents <- function() :
( World, AddEvent, m_Events, m_pNext, m_pPrev, m_flFireTime, m_hFunc, m_Env, m_argv, m_activator, m_caller, curtime )
{
	local curtime = curtime();
	local ev = m_Events;
	while ( ev = ev[ m_pNext ] )
	{
		local f = ev[ m_flFireTime ];
		if ( f <= curtime )
		{
			local f = ev[ m_hFunc ];
			if ( f )
			{
				local p = ev[ m_argv ];
				if ( p ) f.acall( p );
				else f.call( ev[ m_Env ] );
			};
			ev[ m_pPrev ][ m_pNext ] = ev[ m_pNext ];
			if ( ev[ m_pNext ] )
				ev[ m_pNext ][ m_pPrev ] = ev[ m_pPrev ];
			ev = m_Events;
		}
		else
		{
			m_flNextQueue = f;
			f -= curtime;
			AddEvent( World, "RunScriptCode", "::VS.EventQueue.ServiceEvents()", f, ev[m_activator], ev[m_caller] );
			return;
		};
	}
	m_flNextQueue = -1.0;

}.bindenv(VS.EventQueue);
}


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------


//-----------------------------------------------------------------------
// Frame times:
//
// 64.0  tick : 0.01562500
// 102.4 tick : 0.00976563
// 128.0 tick : 0.00781250
//-----------------------------------------------------------------------
local flTickRate = 1.0 / TICK_INTERVAL;
function VS::GetTickrate():(flTickRate)
{
	return flTickRate;
}

if (!PORTAL2){

// The initialisation of this function is asynchronous.
// It takes 12 seconds to finalise on map spawn auto-load,
// and 1-5 frames on manual execution on post map spawn.
// VS.flCanCheckForDedicatedAfterSec can be used for delayed initialisation needs.
// 		VS.EventQueue.AddEvent( Init, VS.flCanCheckForDedicatedAfterSec, this )
function VS::IsDedicatedServer()
{
	throw "not ready";
}

local TIMESTART = 4.0;
local TIMEOUT = 12.0;
local _TIMEOUT = TIMEOUT+TICK_INTERVAL*4;

::VS.flCanCheckForDedicatedAfterSec <- fabs(clamp(Time(),0,_TIMEOUT)-_TIMEOUT);

::_VS_DS_Init <- function():(TIMESTART,TIMEOUT)
{
	if (::_VS_DS_bInitDone)
	{
		::VS.flCanCheckForDedicatedAfterSec = 0.0;

		delete::_VS_DS_Init;
		delete::_VS_DS_IsListen;
		delete::_VS_DS_bInitDone;
		delete::_VS_DS_bExecOnce;
		return;
	};

	local time = ::Time();

	if ( time > TIMESTART )
	{
		::SendToConsole("script _VS_DS_IsListen()");

		if ( time > TIMEOUT )
		{
			::VS.IsDedicatedServer = function() return true;
			::_VS_DS_bInitDone = true;
		};
	};

	::VS.EventQueue.AddEvent( ::_VS_DS_Init, 0.1, this ); // delay value should not be less than 5 frames (SendToConsole delay)
}

::_VS_DS_IsListen <- function()
{
	::VS.IsDedicatedServer = function() return false;
	::_VS_DS_bInitDone = true;
}

// extra protection
if ( !("_VS_DS_bExecOnce" in ROOT) )
{
	::_VS_DS_bExecOnce <- true;
	::_VS_DS_bInitDone <- false;
};

if (::_VS_DS_bExecOnce)
{
	local time = ::Time();

	// on map load
	if ( time < TIMESTART )
	{
		::VS.EventQueue.AddEvent( ::_VS_DS_Init, TIMESTART-time, this );
	}
	// late execution
	else
	{
		::_VS_DS_Init();
	};

	::_VS_DS_bExecOnce = false;
};

}; // !PORTAL2

if (!PORTAL2){

local Chat = ::ScriptPrintMessageChatAll;
local ChatTeam = ::ScriptPrintMessageChatTeam;

::Chat      <- function(s):(Chat) return Chat(" "+s);
::ChatTeam  <- function(i,s):(ChatTeam) return ChatTeam(i," "+s);
::Alert     <- ::ScriptPrintMessageCenterAll;
::AlertTeam <- ::ScriptPrintMessageCenterTeam;

::txt <-
{
	invis      = "\x00",
	white      = "\x01",
	red        = "\x02",
	purple     = "\x03",
	green      = "\x04",
	lightgreen = "\x05",
	limegreen  = "\x06",
	lightred   = "\x07",
	grey       = "\x08",
	yellow     = "\x09",
	lightblue  = "\x0a",
	blue       = "\x0b",
	darkblue   = "\x0c",
	darkgrey   = "\x0d",
	pink       = "\x0e",
	orangered  = "\x0f",
	orange     = "\x10"
}

}; // !PORTAL2
