//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------

::Ent  <- function( s, i = null ):(Entities){ return Entities.FindByName(i,s); }
::Entc <- function( s, i = null ):(Entities){ return Entities.FindByClassname(i,s); }

//-----------------------------------------------------------------------
// Input  : Vector
// Output : string
//-----------------------------------------------------------------------
::VecToString <- function( v ) : (Fmt)
{
	return Fmt( "Vector(%.6g, %.6g, %.6g)", v.x, v.y, v.z );
}


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------


if ( !("{F71A8D}" in ROOT) )
{
	// unique entity pools
	ROOT["{F71A8D}"] <- [];
	ROOT["{E3D627}"] <- [];
	ROOT["{5E457F}"] <- [];
	ROOT["{D9154C}"] <- [];
};;

local g_Players = ROOT["{F71A8D}"];
local g_Eyes = ROOT["{E3D627}"];
local g_GameUIs = ROOT["{5E457F}"];
local g_ViewEnts = ROOT["{D9154C}"]; // usually contains only 1 entity


local DoSetFOV = function( iFOV, flSpeed )
{
	SetFov( iFOV, flSpeed );
	SetOwner( null );
}

//
// FIXME: calling multiple times in a frame on different players
//
VS.SetPlayerFOV <- function( hPlayer, iFOV, flSpeed = 0.0 ) : (g_ViewEnts, AddEvent, DoSetFOV, Entities)
{
	if ( !hPlayer || !hPlayer.IsValid() || hPlayer.GetClassname() != "player" )
		return;

	local hView;

	for ( local i = g_ViewEnts.len(); i--; )
	{
		local v = g_ViewEnts[i];
		if ( !v )
		{
			g_ViewEnts.remove(i);
			continue;
		};

		local owner = v.GetOwner();
		if ( owner == hPlayer )
		{
			// called multiple times in a frame - still active on player
			DoSetFOV.call( v, iFOV, flSpeed );
			return v;
		};

		if ( !owner )
		{
			hView = v;
			// continue searching to see if owner == hPlayer
		};
	}

	if ( !hView )
	{
		hView = Entities.CreateByClassname( "point_viewcontrol" );
		MakePersistent( hView );
		// SF 0 makes the transition smooth; 7 overrides existing view owner, if exists
		hView.__KeyValueFromInt( "spawnflags", (1<<0)|(1<<7) );
		hView.__KeyValueFromInt( "effects", (1<<5) );
		hView.__KeyValueFromInt( "movetype", 8 );
		hView.__KeyValueFromInt( "renderamt", 0 );
		hView.__KeyValueFromInt( "rendermode", 2 );
		g_ViewEnts.insert( 0, hView.weakref() );
	};

	// This script takes advantage of how hViewEntity->m_hPlayer is not
	// nullified on disabling, and how ScriptSetFov() only calls pPlayer->SetFOV()
	hView.SetOwner( hPlayer );
	AddEvent( hView, "Enable", "", 0.0, hPlayer, null );
	AddEvent( hView, "Disable", "", 0.0, null, null );
	EventQueue.AddEvent( DoSetFOV, 0.0, [ hView, iFOV, flSpeed ] );
	return hView;

}.bindenv(::VS);



// used for async name setting
local SetNameSafe = function( ent, name )
{
	if ( ent && ent.IsValid() )
	{
		ent.__KeyValueFromString( "targetname", name );
	}
}

local NullSort = function( a, b )
{
	local oa = a && a.ref();
	local ob = b && b.ref();

	if ( oa && !ob )
		return 1;
	if ( !oa && ob )
		return -1;
	return 0;
}

local OwnerSort = function( a, b )
{
	local oa = a && a.ref() && a.ref().GetOwner();
	local ob = b && b.ref() && b.ref().GetOwner();

	if ( oa && !ob )
		return 1;
	if ( !oa && ob )
		return -1;
	return 0;
}

VS.ToExtendedPlayer <- function( hPlayer )
	: ( g_Players, g_Eyes, g_GameUIs, NullSort, OwnerSort, AddEvent, SetNameSafe, Entities, FrameTime )
{
	foreach( ply in g_Players )
		if ( ply.self == hPlayer || ply == hPlayer )
			return ply;

	if ( (typeof hPlayer != "instance") || !(hPlayer instanceof CBaseMultiplayerPlayer) || !hPlayer.IsValid() )
		return;

	// duplicated iteration to keep post-init calls as cheap as possible
	for ( local i = g_Players.len(); i--; )
	{
		if ( !g_Players[i].IsValid() )
			g_Players.remove(i);
	}

	hPlayer.ValidateScriptScope();
	local sc = hPlayer.GetScriptScope();

	if ( !("userid" in sc) )
		sc.userid <- -1;
	if ( !("networkid" in sc) )
		sc.networkid <- "";
	if ( !("name" in sc) )
		sc.name <- "";


	local eye;
	g_Eyes.sort( NullSort );
	g_Eyes.sort( OwnerSort );

	for ( local i = g_Eyes.len(); i--; )
	{
		local v = g_Eyes[i];
		if ( !v )
		{
			g_Eyes.remove(i);
			continue;
		};

		local owner = v.GetOwner();
		if ( !owner || owner == hPlayer )
		{
			eye = v;
			break;
		};
	}

	if ( !eye )
	{
		eye = Entities.CreateByClassname( "logic_measure_movement" );
		MakePersistent( eye );
		eye.__KeyValueFromInt( "measuretype", 1 );
		eye.__KeyValueFromString( "measurereference", "" );
		eye.__KeyValueFromString( "measureretarget", "" );
		eye.__KeyValueFromFloat( "targetscale", 1.0 );
		local name_eye = "vs.ref_" + UniqueString();
		eye.__KeyValueFromString( "targetname", name_eye );
		eye.__KeyValueFromString( "targetreference", name_eye );
		eye.__KeyValueFromString( "target", name_eye );
		AddEvent( eye, "SetMeasureReference", name_eye, 0.0, null, null );

		// Need to keep ent name because
		// CLogicMeasureMovement::InputSetMeasureTarget updates the references from targetname
		// EventQueue.AddEvent( SetNameSafe, FrameTime()+0.001, [ null, eye, "" ] );

		// always think
		AddEvent( eye, "Enable", "" , 0.0, null, null );

		g_Eyes.insert( 0, eye.weakref() );
	};

	{
		local name_old = hPlayer.GetName();
		local name_new = sc.__vname;
		hPlayer.__KeyValueFromString( "targetname", name_new );
		AddEvent( eye, "SetMeasureTarget", name_new, 0.0, null, null );
		EventQueue.AddEvent( SetNameSafe, FrameTime()+0.001, [ null, hPlayer, name_old ] );
	}

	eye.SetOwner( hPlayer );

	local bot = ( sc.networkid == "BOT" ) ? true : false;
	local uid = sc.userid;
	local nid = sc.networkid;
	local pnm = sc.name;

	// CExtendedPlayer
	class __player //extends CBaseMultiplayerPlayer
	{
		// static means const
		static self = hPlayer;
		static m_EntityIndex = hPlayer.entindex(); // m_EdictIndex
		static m_ScriptScope = sc;
		// static m_iszScriptId = sc.__vname;
		static userid = sc.userid; // m_UserID
		static networkid = sc.networkid; // m_szNetworkId
		static name = sc.name; // m_szNetname
		static bot = bot; // m_bFakePlayer

		IsBot = bot ? function() { return true; } : function() { return false; };
		function GetUserID() : (uid) { return uid; }
		function GetNetworkIDString() : (nid) { return nid; }
		function GetPlayerName() : (pnm) { return pnm; }

		EyeAngles = CBaseEntity.GetAngles.bindenv(eye);
		EyeForward = CBaseEntity.GetForwardVector.bindenv(eye);
		EyeRight = CBaseEntity.GetLeftVector.bindenv(eye);
		EyeUp = CBaseEntity.GetUpVector.bindenv(eye);

		//function CalcEntityToWorldTransform()
		//{
		//	local m = matrix3x4_t();
		//	VS.AngleMatrix( GetAngles(), GetOrigin(), m );
		//	return m;
		//}

		function SetName( sz )
		{
			return self.__KeyValueFromString( "targetname", sz );
		}

		function SetEffects( n )
		{
			return self.__KeyValueFromInt( "effects", n );
		}

		function SetMoveType( n )
		{
			return self.__KeyValueFromInt( "movetype", n );
		}

		function SetFOV( nFov, flRate )
		{
			return ::SetPlayerFOV( self, nFov, flRate );
		}

		function SetParent( hParent, szAttachment ) : (AddEvent)
		{
			AddEvent( self, "SetParent", "!activator", 0.0, hParent, null );
			if ( szAttachment != "" )
				AddEvent( self, "SetParentAttachment", szAttachment, 0.0, null, null );
		}

		_ui = null;

		function SetInputCallback( szInput, fn, env ) : (AddEvent, g_GameUIs, NullSort, OwnerSort)
		{
			if ( !_ui || !_ui.IsValid() )
			{
				g_GameUIs.sort( NullSort );
				g_GameUIs.sort( OwnerSort );
				for ( local i = g_GameUIs.len(); i--; )
				{
					local v = g_GameUIs[i];
					if ( !v )
					{
						g_GameUIs.remove(i);
						continue;
					};

					local owner = v.GetOwner();
					if ( !owner || owner == self )
					{
						v.SetTeam(0); // reset
						_ui = v;
						break;
					};
				}

				if ( !_ui )
				{
					_ui = Entities.CreateByClassname( "game_ui" );
					_ui.__KeyValueFromInt( "spawnflags", 128 );
					_ui.__KeyValueFromFloat( "fieldofview", -1 );
					VS.MakePersistent( _ui );
					_ui.__KeyValueFromString( "targetname", "" );
					g_GameUIs.insert( 0, _ui.weakref() );
					_ui.ValidateScriptScope();
				};

				_ui.SetOwner( self );
			};

			local sc = _ui.GetScriptScope();
			if ( !("m_pCallbacks" in sc) )
				sc.m_pCallbacks <- {};

			// turn off
			if ( !szInput )
			{
				if ( _ui.GetTeam() && _ui.GetOwner() )
				{
					AddEvent( _ui, "Deactivate", "", 0.0, self, null );
				};

				_ui.SetTeam(0);

				foreach( input, cb in sc.m_pCallbacks )
				{
					foreach( context, callback in cb )
						cb[context] = null;

					if ( input in sc )
						delete sc[input];

					_ui.DisconnectOutput( input, input );
				}
				return;
			};

			switch ( szInput )
			{
				case "+use":		szInput = "PlayerOff"; break;
				case "+attack":		szInput = "PressedAttack"; break;
				case "-attack":		szInput = "UnpressedAttack"; break;
				case "+attack2":	szInput = "PressedAttack2"; break;
				case "-attack2":	szInput = "UnpressedAttack2"; break;
				case "+forward":	szInput = "PressedForward"; break;
				case "-forward":	szInput = "UnpressedForward"; break;
				case "+back":		szInput = "PressedBack"; break;
				case "-back":		szInput = "UnpressedBack"; break;
				case "+moveleft":	szInput = "PressedMoveLeft"; break;
				case "-moveleft":	szInput = "UnpressedMoveLeft"; break;
				case "+moveright":	szInput = "PressedMoveRight"; break;
				case "-moveright":	szInput = "UnpressedMoveRight"; break;
				default: throw "invalid input";
			}

			local context;

			switch ( typeof env )
			{
				case "table":
				case "class":
				case "instance":
					context = 0;
					break;
				case "string":
					context = env;
					env = null;
					break;
				default:
					throw "invalid context param";
			}

			if ( !(szInput in sc.m_pCallbacks) )
				sc.m_pCallbacks[szInput] <- {};

			local cb = sc.m_pCallbacks[szInput];

			// disable input
			if ( !fn )
			{
				if ( context in cb )
				{
					delete cb[context];

					if ( !cb.len() )
					{
						delete sc.m_pCallbacks[szInput];

						if ( szInput != "PlayerOff" )
						{
							if ( szInput in sc )
								sc[szInput] = null;
							_ui.DisconnectOutput( szInput, szInput );
						};
					};
				};

				return;
			};

			if ( env )
			{
				cb[context] <- fn.bindenv(env);
			}
			else
			{
				cb[context] <- fn;
			};

			if ( (szInput != "PlayerOff") && ( !(szInput in sc) || !sc[szInput] ) )
			{
				sc[szInput] <- function() : (cb)
				{
					foreach( fn in cb )
						fn(this);
				}.bindenv(this);
				_ui.ConnectOutput( szInput, szInput );
			};

			if ( !("PlayerOff" in sc) || !sc.PlayerOff )
			{
				if ( !("PlayerOff" in sc.m_pCallbacks) )
					sc.m_pCallbacks.PlayerOff <- {};

				local cb = sc.m_pCallbacks.PlayerOff;
				sc.PlayerOff <- function() : (cb, _ui, AddEvent)
				{
					AddEvent( _ui, "Activate", "", 0.0, self, null );
					foreach( fn in cb )
						fn(this);
				}.bindenv(this);
				_ui.ConnectOutput( "PlayerOff", "PlayerOff" );
			};

			if ( !_ui.GetTeam() )
			{
				_ui.SetTeam(1);
				AddEvent( _ui, "Activate", "", 0.0, self, null );
			};
		}

		_tostring = hPlayer.tostring.bindenv( hPlayer );
		getclass = hPlayer.getclass.bindenv( hPlayer );
	}

	// Set native funcs after custom funcs to keep forward compatibility
	foreach( k,v in hPlayer.getclass() ) // CBaseMultiplayerPlayer
		__player[k] <- v.bindenv( hPlayer );

	local p = __player();
	g_Players.append(p);
	return p;

}.bindenv(::VS);


::SetPlayerFOV <- VS.SetPlayerFOV.weakref();
::ToExtendedPlayer <- VS.ToExtendedPlayer.weakref();

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------


//-----------------------------------------------------------------------
// Ray tracing
//-----------------------------------------------------------------------
local DoTrace1 = TraceLine;
local DoTrace2 = TraceLinePlayersIncluded;

const MASK_NPCWORLDSTATIC = 0x2000b;;
const MASK_SOLID = 0x200400b;;

class VS.TraceLine
{
	constructor( start, end, ent = null, nMask = MASK_NPCWORLDSTATIC ) : ( DoTrace1, DoTrace2 )
	{
		startpos = start;
		endpos = end;
		ignore = ent;
		mask = nMask;

		// Being too optimistic and adding mask parameter for future compatibility.
		switch ( nMask )
		{
		case MASK_NPCWORLDSTATIC:
			fraction = DoTrace1( startpos, endpos, ignore );
			return;
		case MASK_SOLID:
			fraction = DoTrace2( startpos, endpos, ignore );
			return;
		default:
			throw "invalid mask";
		}
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
	fraction = null;
	hitpos = null;
	normal = null;
	mask = null;
}

//-----------------------------------------------------------------------
// Set 'f' to limit the max distance
// Input  : Vector [ start pos ]
//          Vector [ normalised direction ]
//          handle [ to ignore ]
//          int [ trace mask ]
// Output : trace_t [ VS.TraceLine ]
//-----------------------------------------------------------------------
local CTrace = VS.TraceLine;

function VS::TraceDir( v1, vDir, f = MAX_TRACE_LENGTH, hEnt = null, mask = MASK_NPCWORLDSTATIC ):(CTrace)
{
	return CTrace( v1, v1 + (vDir * f), hEnt, mask );
}

// if direct LOS return false
function VS::TraceLine::DidHit()
{
	return fraction < 1.0;
}

// return hit entity handle, null if none
function VS::TraceLine::GetEnt( radius ) : (Entities)
{
	if ( !hitpos ) GetPos();
	return Entities.FindByClassnameNearest( "*", hitpos, radius );
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
		if ( fraction < 1.0 ) hitpos = startpos + (endpos - startpos) * fraction;
		else hitpos = endpos;
	};
	return hitpos;
}

// Get distance from startpos to hit position
function VS::TraceLine::GetDist()
{
	if ( !hitpos ) GetPos();
	return (startpos - hitpos).Length();
}

// Get distance squared. Useful for comparisons
function VS::TraceLine::GetDistSqr()
{
	if ( !hitpos ) GetPos();
	return (startpos - hitpos).LengthSqr();
}

// Get surface normal
function VS::TraceLine::GetNormal() : ( Vector, CTrace )
{
	if ( !normal )
	{
		local up = Vector( 0.0, 0.0, 0.1 );
		local dt = endpos - startpos;
		dt.Norm();
		GetPos();
		local v1 = startpos + dt.Cross(up);
		local v2 = startpos + up;
		normal = ( hitpos - CTrace( v1, v1 + dt * MAX_TRACE_LENGTH, ignore, mask ).GetPos() ).Cross(
			hitpos - CTrace( v2, v2 + dt * MAX_TRACE_LENGTH, ignore, mask ).GetPos() );
		normal.Norm();
	};

	return normal;
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
	return DoUniqueString("").slice( 0, -1 );
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
function VS::DumpScope( input, bPrintAll = false, bDeepPrint = true, bPrintGuides = true, nDepth = 0 )
{
	// non-native variables
	local _skip = ["Assert","Document","Documentation","PrintHelp","RetrieveNativeSignature","RegisterFunctionDocumentation","UniqueString","IncludeScript","Entities","CSimpleCallChainer","CCallChainer","LateBinder","__ReplaceClosures","__DumpScope","printl","VSquirrel_OnCreateScope","VSquirrel_OnReleaseScope","PrecacheCallChain","OnPostSpawnCallChain","DispatchOnPostSpawn","DispatchPrecache","OnPostSpawn","PostSpawn","Precache","PreSpawnInstance","__EntityMakerResult","__FinishSpawn","__ExecutePreSpawn","EntFireByHandle","EntFire","RAND_MAX","_version_","_intsize_","PI","_charsize_","_floatsize_","self","__vname","__vrefs","{847D4B}","{F71A8D}","{E3D627}","{5E457F}","{D9154C}","ToExtendedPlayer","SetPlayerFOV","VS","Chat","ChatTeam","TextColor","PrecacheModel","PrecacheScriptSound","delay","VecToString","HPlayer","Ent","Entc","Quaternion","matrix3x4_t","VMatrix","Ray_t","max","min","clamp","MAX_COORD_FLOAT","MAX_TRACE_LENGTH","DEG2RAD","RAD2DEG","CONST"];
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
						if ( val == SWorld )
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
						print(" = " + VecToString(val));
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
	foreach( i, v in a ) t[i] <- v;
	return t;
}

//
// print the stack
// NOTE: local variable order will be mixed up
// NOTE: weakrefs will not show as weakref
//
function VS::PrintStack( level = 0 ) : (Fmt, getstackinfos, ROOT, CBaseEntity)
{
	if ( level < 0 )
		level = 0;
	level += 2;

	// print(Fmt( "\nAN ERROR HAS OCCURED [%s]\n", err ));
	print("\nCALLSTACK\n");
	local si, stack = [];
	while ( si = getstackinfos(level++) )
	{
		if ( si.src == "NATIVE" && si.func == "pcall" )
			break;
		if ( level >= 12 )
			break;
		print(Fmt( "*FUNCTION [%s()] %s line [%d]\n", si.func, si.src, si.line ));
		stack.append(si);
	}
	print("\nLOCALS\n");
	foreach( si in stack )
	{
		local THIS;
		foreach( name, v in si.locals )
		{
			switch ( typeof v )
			{
			case "integer":
				print(Fmt( "[%s] %d\n", name, v ));
				break;
			case "float":
				print(Fmt( "[%s] %.14g\n", name, v ));
				break;
			case "string":
				print(Fmt( "[%s] \"%s\"\n", name, v ));
				break;
			case "table":
				if ( name == "this" )
				{
					THIS = v;
					break;
				};
				if ( v == ROOT )
				{
					print(Fmt( "[%s] TABLE (ROOT)\n", name ));
					break;
				};
				print(Fmt( "[%s] TABLE\n", name ));
				break;
			case "function":
				print(Fmt( "[%s] CLOSURE\n", name ));
				break;
			case "native function":
				print(Fmt( "[%s] NATIVECLOSURE\n", name ));
				break;
			case "bool":
				print(Fmt( "[%s] %s\n", name, ""+v ));
				break;
			// case "weakref":
			// 	local r = v.ref();
			// 	local t = typeof r;
			// 	if ( t == "instance" && r instanceof CBaseEntity )
			// 		t = "CBaseEntity";
			// 	print(Fmt( "[%s] WEAKREF [%s]\n", name, t ));
			// 	break;
			case "instance":
				if ( v instanceof CBaseEntity )
				{
					print(Fmt( "[%s] CBaseEntity\n", name ));
					break;
				};
			// case "null":
			// case "array":
			// case "generator":
			// case "thread":
			// case "class":
			default:
				print(Fmt( "[%s] %s\n", name, (typeof v).toupper() ));
			}
		}
		// print this at the stack base because table keys are mixed up
		if ( THIS )
		{
			if ( THIS == ROOT )
			{
				print( "[this] TABLE (ROOT)\n" );
			}
			else
			{
				local s;
				if ( s = GetVarName(THIS) )
				{
					print(Fmt( "[this] TABLE (%s)\n", s ));
				}
				else
				{
					print( "[this] TABLE\n" );
				}
			}
		}
	}
}

// return caller table
function VS::GetCaller() : (getstackinfos)
{
	return getstackinfos(3).locals["this"];
}

// (DEBUG) return caller function as string
function VS::GetCallerFunc() : (getstackinfos)
{
	return getstackinfos(3).func;
}

//-----------------------------------------------------------------------
// Input  : table
// Output : array containing the input's directory
//-----------------------------------------------------------------------
function VS::GetTableDir(input)
{
	if ( typeof input != "table" )
		throw "Invalid input type '" + typeof input + "' ; expected: 'table'";

	local a = [];
	local r = _10F07AD9(a,input);

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
function VS::_10F07AD9(bF, t, l = ROOT)
{
	foreach(v, u in l)
		if (typeof u == "table" && v != "VS" && v != "Documentation")
				if (u == t)
				{
					bF.append(v);
					return bF;
				}
				else
				{
					local r = _10F07AD9(bF, t, u);
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

	return _2E42074F(S);
}

// exclusive recursion function
function VS::_2E42074F(t, l = ROOT)
{
	if (t in l)
		return l[t];
	else
		foreach(v, u in l)
			if (typeof u == "table" && v != "VS" && v != "Documentation")
				{
					local r = _2E42074F(t, u);
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

	return _8B78B6AE(t, v);
}

// exclusive recursion function
function VS::_8B78B6AE(t, i, s = ROOT)
{
	foreach(k, v in s)
	{
		if (v == i)
			return k;

		if (typeof v == "table" && k != "VS" && k != "Documentation")
			{
				local r = _8B78B6AE(t, i, v);
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
::delay <- function( X, T = 0.0, E = World, A = null, C = null ):(AddEvent)
	return AddEvent( E, "RunScriptCode", ""+X, T, A, C );


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------


{
local EventQueue =
{
	m_flNextQueue = -1.0,
	m_flLastQueue = -1.0
}

VS.EventQueue <- EventQueue;

// enum
const m_pNext      = 0;
const m_flFireTime = 1;
const m_pPrev      = 2;
const m_hFunc      = 3;
const m_argv       = 4;
const m_Env        = 5;
const m_activator  = 6;
const m_caller     = 7;

local m_Events     = [null,null];
m_Events[ m_flFireTime ] = FLT_MAX_N;

VS.EventQueue.Dump <- function( bUseTicks = false, indent = 0 ) : ( m_Events, Time, Fmt, TICK_INTERVAL )
{
	local get = function(i):(Fmt)
	{
		if ( i == null )
			return "(NULL)";
		local s = "" + i;
		local t = s.find("0x");
		if ( t == null )
			return s;
		return Fmt("(%s)", s.slice( t, -1 ));
	}

	local TIME_TO_TICKS = function( dt ) : ( TICK_INTERVAL )
	{
		return ( (0.5 + dt) / TICK_INTERVAL ).tointeger();
	}

	local n = "";
	for ( local i = indent; i--; ) n += "    ";

	Msg(Fmt( n + "VS::EventQueue::Dump: %.6g : next(%.6g), last(%.6g)\n",
		bUseTicks ? TIME_TO_TICKS( Time() ) : Time(),
		bUseTicks ? ( m_flNextQueue == -1.0 ? -1.0 : TIME_TO_TICKS( m_flNextQueue ) ) : m_flNextQueue,
		bUseTicks ? TIME_TO_TICKS( m_flLastQueue ) : m_flLastQueue ));

	for ( local ev = m_Events; ev = ev[ m_pNext ]; )
	{
		local fn = ev[m_hFunc].getinfos().name;
		local ta = typeof ev[m_argv] == "array" && ev[m_argv].len();
		Msg(Fmt( n + "   (%s) func '%s'%s, %s '%s', activator '%s', caller '%s'\n",
			bUseTicks ? ""+TIME_TO_TICKS( ev[m_flFireTime] ) : Fmt( "%.2f", ev[m_flFireTime] ),
			fn ? fn : "<unnamed>", get( ev[m_hFunc] ),
			ta ? "arg" : "env",
			get( ta ? ev[m_argv][0] : ev[m_Env] ),
			get( ev[m_activator] ),
			get( ev[m_caller] ) ));
	}
	Msg( n + "VS::EventQueue::Dump: end.\n" );

}.bindenv(VS.EventQueue);

VS.EventQueue.Clear <- function() : ( m_Events )
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

VS.EventQueue.CancelEventsByInput <- function( f ) : ( m_Events )
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

VS.EventQueue.RemoveEvent <- function( ev ) : ( m_Events )
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
	( World, Time, AddEvent, m_Events, TICK_INTERVAL )
{
	local curtime = Time();
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
			AddEvent( World, "CallScriptFunction", "VS_EventQueue_ServiceEvents", 0.0, event[m_activator], event[m_caller] );
		}
		// Expect no event to be not fired for longer than a frame
		else if ( m_Events[ m_pNext ] && ( ( curtime - m_Events[ m_pNext ][ m_flFireTime ] - 0.001 ) >= TICK_INTERVAL ) )
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
	( AddEventInternal, ROOT )
{
	local event = CreateEvent( hFunc, argv , activator , caller );
	return AddEventInternal( event, flDelay );

}.bindenv(VS.EventQueue);

VS.EventQueue.CreateEvent <- function( hFunc, argv = null, activator = null, caller = null ) : ( ROOT )
{
	local event = [null,null,null,null,null,null,null,null];
	event[ m_hFunc ] = hFunc;
	event[ m_activator ] = activator;
	event[ m_caller ] = caller;

	switch ( typeof argv )
	{
		case "table":
		case "class":
		case "instance":
			event[ m_Env ] = argv;
			break;
		case "array":
			event[ m_argv ] = argv;
			break;
		default:
			event[ m_Env ] = ROOT;
	}

	return event;
}

VS.EventQueue.ServiceEvents <- function() : ( World, AddEvent, m_Events, Time )
{
	local curtime = Time();
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
			return AddEvent( World, "CallScriptFunction", "VS_EventQueue_ServiceEvents", f, ev[m_activator], ev[m_caller] );
		};
	}
	m_flNextQueue = -1.0;

}.bindenv(VS.EventQueue);

World.ValidateScriptScope();
World.GetScriptScope().VS_EventQueue_ServiceEvents <- VS.EventQueue.ServiceEvents.weakref();

}


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------


if (!PORTAL2){

::Chat      <- function(s) : (ScriptPrintMessageChatAll) return ScriptPrintMessageChatAll(" "+s);
::ChatTeam  <- function(i,s) : (ScriptPrintMessageChatTeam) return ScriptPrintMessageChatTeam(i," "+s);
::Alert     <- ScriptPrintMessageCenterAll;
::AlertTeam <- ScriptPrintMessageCenterTeam;

enum TextColor
{
	// NORMAL			= 1,
	Normal			= "\x1",	// white
	// USEOLDCOLORS	= 2,
	// RED				= 2,
	Red				= "\x2",	// red
	// PLAYERNAME		= 3,
	// PURPLE			= 3,
	Purple			= "\x3",	// purple
	// LOCATION		= 4,
	Location		= "\x4",	// dark green
	// ACHIEVEMENT		= 5,
	Achievement		= "\x5",	// light green
	// AWARD			= 6,
	Award			= "\x6",	// green
	// PENALTY			= 7,
	Penalty			= "\x7",	// light red
	// SILVER			= 8,
	Silver			= "\x8",	// grey
	// GOLD			= 9,
	Gold			= "\x9",	// yellow
	// COMMON			= 10,
	Common			= "\xA",	// grey blue
	// UNCOMMON		= 11,
	Uncommon		= "\xB",	// light blue
	// RARE			= 12,
	Rare			= "\xC",	// dark blue
	// MYTHICAL		= 13,
	Mythical		= "\xD",	// dark grey
	// LEGENDARY		= 14,
	Legendary		= "\xE",	// pink
	// ANCIENT			= 15,
	Ancient			= "\xF",	// orange red
	// IMMORTAL		= 16
	Immortal		= "\x10"	// orange
}

::TextColor <- CONST.TextColor;

};; // !PORTAL2

/*
::printf <- function( str, ... )
{
	// init on first call

	local print = print, Fmt = format, argv = [];
	::printf <- function( str, ... ) : ( print, Fmt, argv )
	{
		argv.resize( vargc + 2 );
		argv[1] = str;
		for ( local i = vargc; i--; )
			argv[i+2] = vargv[i];
		print( Fmt.acall( argv ) );
		argv.clear();
	}

	argv.resize( vargc + 2 );
	argv[1] = str;
	for ( local i = vargc; i--; )
		argv[i+2] = vargv[i];
	return printf.acall( argv );
}
*/

/*
// Template asynchronous loops for expensive functions.
// Place your logic inside the for loop.
// Special variables should not be moved.
// Expects increments ( nStartIndex < nTargetLimit )

function StartAsyncLoop( nStartIndex, nTargetLimit, nAsyncIncr )
{
	if ( bLoopInProgress )
		return;
	bLoopInProgress = true;

	if ( nStartIndex < nTargetLimit )
		throw "error";


	// times a loop is synchronously executed.
	// expected to be lower than target limit
	_AINCR = nAsyncIncr;

	// total loop count (async)
	_TGLIM = nTargetLimit;

	// internal asynchronous counters
	_ASIDX = nStartIndex; // cur idx
	_ASLIM = min( _AINCR, _TGLIM ); // cur lim


	// print how long it took
	flAsyncLoopStartTime <- Time();

	// start
	MyAsyncFunc();
}

function MyAsyncFunc()
{
	for ( local i = _ASIDX; i < _ASLIM; i += 1 ) // increment amount at user's discretion
	{
		// do
	}

	_ASIDX += _AINCR;
	_ASLIM = min( _ASLIM + _AINCR, _TGLIM );

	// complete
	if ( _ASIDX >= _ASLIM )
	{
		OnFinished();
		return;
	}
	return VS.EventQueue.AddEvent( MyAsyncFunc, 0.01, this );
}

function OnFinished()
{
	bLoopInProgress = false;

	local dt = Time() - flAsyncLoopStartTime
	print(format( "Async loop finished in %g seconds!\n", dt ))
}

// While this can be used for automating loop completion,
// threads or generators can be used for pausing on conditions when
// a loop is expected to run for long or to run an expensive function.

// If the functions called inside the loop are expected to suspend the loop
// instead of the main loop itself, use threads.
// To use threads, replace `yield` with `suspend()`, `resume` with `thread.wakeup()`

_thread <- null

function ThreadResume()
{
	resume _thread
	// _thread.wakeup()
}

function ThreadSleep( duration )
{
	suspend( VS.EventQueue.AddEvent( ThreadResume, duration, this ) );
}

function CreateThread( func, env = null )
{
	_thread = (func.bindenv( env ? env : VS.GetCaller() ))()
	// _thread = newthread( func.bindenv( env ? env : VS.GetCaller() ) )
}

function StartThread()
{
	resume _thread
	// _thread.call()
}

function MyThread()
{
	local i = 0
	while (++i)
	{
		if ( CheapCall() )
			continue

		if ( CheapCall() )
			continue

		// continue asynchronously before the expensive call
		yield VS.EventQueue.AddEvent( ThreadResume, 0.01, null )
		// ThreadSleep( 0.01 )

		ExpensiveCall()

		// continue asynchronously after the expensive call
		yield VS.EventQueue.AddEvent( ThreadResume, 0.01, null )
		// ThreadSleep( 0.01 )

		// fatal end
		if ( i >= 5000 )
		{
			local dt = Time() - flStartTime
			print(format( "Async thread finished in %g seconds!\n", dt ))
			return
		}
	}
}

function test()
{
	flStartTime <- Time();

	CreateThread( MyThread )
	StartThread()
}
*/
