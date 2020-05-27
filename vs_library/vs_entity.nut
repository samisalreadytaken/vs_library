//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//
//                       github.com/samisalreadytaken
//
// This project is licensed under the terms of the MIT License.
// See <README.md> or <LICENSE> for details.
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
// Make EntFireByHandle allow default parameters
//-----------------------------------------------------------------------
::EntFireByHandle <- function( target, action, value = "", delay = 0.0, activator = null, caller = null )
{
	return::DoEntFireByInstanceHandle( target, action.tostring(), value.tostring(), delay, activator, caller );
}

//-----------------------------------------------------------------------

::PrecacheModel <- function( str )
{
	::ENT_SCRIPT.PrecacheModel(str);
}

::PrecacheScriptSound <- function( str )
{
	::ENT_SCRIPT.PrecacheScriptSound(str);
}

//-----------------------------------------------------------------------
// Prevent the entity from being released every round
// MakePersistent
//-----------------------------------------------------------------------
function VS::MakePermanent( handle )
{
	return handle.__KeyValueFromString( "classname", "soundent" );
}

//-----------------------------------------------------------------------
// Set child's parent
// if parent == null, unparent child
//
// Input  : handle [ child entity ]
// Output : handle [ parent entity ]
//-----------------------------------------------------------------------
function VS::SetParent( hChild, hParent )
{
	if( !hParent ) return::EntFireByHandle( hChild, "setparent", "" );
	return::EntFireByHandle( hChild, "setparent", "!activator", 0.0, hParent );
}

//-----------------------------------------------------------------------
// Show game_text
// if msg, set msg
//-----------------------------------------------------------------------
function VS::ShowGameText( hEnt, hTarget, msg = null, delay = 0.0 )
{
	if( msg ) hEnt.__KeyValueFromString( "message", ""+msg );
	return::EntFireByHandle( hEnt, "display", "", delay, hTarget );
}

//-----------------------------------------------------------------------
// Show hudhint
// if msg, set msg
//-----------------------------------------------------------------------
function VS::ShowHudHint( hEnt, hTarget, msg = null, delay = 0.0 )
{
	if( msg ) hEnt.__KeyValueFromString( "message", ""+msg );
	return::EntFireByHandle( hEnt, "ShowHudHint", "", delay, hTarget );
}

//-----------------------------------------------------------------------
// Hide hudhint
//-----------------------------------------------------------------------
function VS::HideHudHint( hEnt, hTarget, delay = 0.0 )
{
	return::EntFireByHandle( hEnt, "HideHudHint", "", delay, hTarget );
}

//-----------------------------------------------------------------------
// Create logic_measure_movement, measure eye angles
//
// Input  : string [ target targetname ] (e.g. player targetname)
//          string [ reference entity name ] (optional)
//          bool   [ make the reference entity permanent ]
//          bool   [ measure eyes ]
//          float  [ scale ]
// Output : handle reference
//-----------------------------------------------------------------------
function VS::CreateMeasure( g, n = null, p = false, e = true, s = 1.0 )
{
	local r = e ? n ? n.tostring() : "vs.ref_"+UniqueString() : n ? n.tostring() : null;

	if(!r || !r.len()) throw "Invalid targetname";

	local e = CreateEntity( "logic_measure_movement",
	                        { measuretype = e ? 1 : 0,
	                          measurereference = "",
	                          targetreference = r,
	                          target = r,
	                          measureretarget = "",
	                          targetscale = s.tofloat(),
	                          targetname = e?r:null }, p );

	::EntFireByHandle(e,"setmeasurereference",r);

	::EntFireByHandle(e,"setmeasuretarget",g);

	::EntFireByHandle(e,"enable");

	return e;
}

//-----------------------------------------------------------------------
// Start measuring new target
//
// Input  : handle [ logic_measure_movement ]
//          string [ player_targetname ]
// Output :
//-----------------------------------------------------------------------
function VS::SetMeasure(h,s)
{
	return::EntFireByHandle(h,"setmeasuretarget",s);
}

//-----------------------------------------------------------------------
// Input  : bool [ start disabled ]
//          float [ refire time ]
//          float [ lower (randomtime, used when refire == null) ]
//          float [ upper (randomtime, used when refire == null) ]
//          bool [ oscillator (alternate between OnTimerHigh and OnTimerLow outputs) ]
//          bool [ make permanent ]
// Output : entity
//-----------------------------------------------------------------------
function VS::CreateTimer( bDisabled, flInterval, flLower = null, flUpper = null, bOscillator = false, bMakePerm = false )
{
	local ent = CreateEntity( "logic_timer", null, bMakePerm );

	if( flInterval )
	{
		ent.__KeyValueFromInt( "UseRandomTime", 0 );
		ent.__KeyValueFromFloat( "RefireTime", flInterval.tofloat() );
	}
	else
	{
		ent.__KeyValueFromFloat( "LowerRandomBound", flLower.tofloat() );
		ent.__KeyValueFromFloat( "UpperRandomBound", flUpper.tofloat() );
		ent.__KeyValueFromInt( "UseRandomTime", 1 );
		ent.__KeyValueFromInt( "spawnflags", bOscillator.tointeger() );
	};

	::EntFireByHandle( ent, bDisabled ? "disable" : "enable" );

	return ent;
}

//-----------------------------------------------------------------------
// Create and return a timer that executes Func
// VS.Timer( false, 0.5, Think )
//-----------------------------------------------------------------------
function VS::Timer( bDisabled, flInterval, Func = null, tScope = null, bExecInEnt = false, bMakePerm = false )
{
	if(!flInterval)
	{
		::print("\nERROR:\nRefire time cannot be null in VS.Timer\nUse VS.CreateTimer for randomised fire times.\n");
		throw"NULL REFIRE TIME";
	};

	local h = CreateTimer(bDisabled, flInterval, null, null, null, bMakePerm);
	OnTimer(h, Func, tScope ? tScope : GetCaller(), bExecInEnt);
	return h;
}

//-----------------------------------------------------------------------
// Add OnTimer output to the timer entity to execute the input function
//
// Input  : handle [ entity ]
//          string|closure [ function ]
// Output : table [ent scope]
//-----------------------------------------------------------------------
function VS::OnTimer( hEnt, Func, tScope = null, bExecInEnt = false )
{
	return AddOutput( hEnt, "OnTimer", Func, tScope ? tScope : GetCaller(), bExecInEnt );
}

//-----------------------------------------------------------------------
// Adds output in the chosen entity
// Executes the given function in the given scope
// Accepts function parameters
//
// Input  : handle [ entity ]
//          string [ output ]
//          string|closure [ function ]
//          table [ scope ] // null === this
//          bool [ bool ] // execute the function in the scope of hEnt
// Output : table [ent scope]
//-----------------------------------------------------------------------
function VS::AddOutput( hEnt, sOutput, Func, tScope = null, bExecInEnt = false )
{
	if( !tScope ) tScope = GetCaller();

	if( Func )
	{
		if( typeof Func == "string" )
		{
			if( Func.find("(") != null )
				Func = ::compilestring(Func);
			else
				Func = tScope[Func];
		}
		else if( typeof Func != "function" )
			throw "Invalid function type " + typeof Func;;
	}
	else
	{
		Func = null;
		bExecInEnt = true; // to be able to assign Func (null) below
	};

	hEnt.ValidateScriptScope();

	local r = hEnt.GetScriptScope();

	r[sOutput] <- bExecInEnt ? Func : Func.bindenv(tScope);

	hEnt.ConnectOutput(sOutput, sOutput);

	// print("** Adding output '" + sOutput + "' to '" + hEnt.GetName() + "'. Execute '" + GetFuncName(Func) + "()' in '" + (bExecInEnt?hEnt.GetScriptScope():GetVarName(tScope)) + ".'\n");

	return r;
}

// This could still be useful in specific scenarios
function VS::AddOutput2( hEnt, sOutput, Func, tScope = null, bExecInEnt = false )
{
	if( hEnt.GetScriptScope() || typeof Func == "function" )
		return AddOutput( hEnt, sOutput, Func, tScope, bExecInEnt );

	if( typeof Func != "string" )
		throw "Invalid function type " + typeof Func;

	if( !tScope ) tScope = GetCaller();

	if( !bExecInEnt )
	{
		if( !("self" in tScope) )
		{
			throw "Invalid function path. Not an entity";
		};

		::DoEntFireByInstanceHandle( hEnt,"addoutput",sOutput+" "+tScope.self.GetName()+",runscriptcode,"+Func,0.0,tScope.self,hEnt );
	}
	else
	{
		local name = hEnt.GetName();
		if( !name.len() )
		{
			name = UniqueString();
			SetName(hEnt, name);
		};

		::DoEntFireByInstanceHandle( hEnt,"addoutput",sOutput+" "+name+",runscriptcode,"+Func,0.0,null,hEnt );
	};
}

/*
function VS::AddInput( hEnt, sInput, Func, tScope = null, bExecInEnt = false )
{
	if( !hEnt.ValidateScriptScope() ) throw "Invalid entity";

	if( !tScope ) tScope = GetCaller();

	if( typeof Func == "string" )
		Func = tScope[Func];
	else if( typeof Func != "function" )
		throw "Invalid function type " + typeof Func;;

	hEnt.GetScriptScope()["Input"+sInput] <- bExecInEnt ? Func : Func.bindenv(tScope);

	// print("** Adding input '" + sInput + "' to '" + hEnt.GetName() + "'. Execute '" + GetFuncName(Func) + "()' in '" + (bExecInEnt?hEnt.GetScriptScope():GetVarName(tScope)) + ".'\n");
}
*/

//-----------------------------------------------------------------------
// CreateByClassname, set keyvalues, return handle
//
// Input  : string [ entity classname ]
//          table [ keyvalues ] // { speed = speed, health = 1337 }
//          bool [ make permanent ]
// Output : handle [ entity ]
//-----------------------------------------------------------------------
function VS::CreateEntity( classname, keyvalues = null, perm = false )
{
	local ent = ::Entities.CreateByClassname(classname);
	if( typeof keyvalues == "table" ) foreach( k, v in keyvalues ) SetKey(ent, k, v);
	if(perm) MakePermanent(ent);
	return ent;

	// It is better to use entity weak references to store entity handles.
	//
	// Using strong refs, when an entity is killed (UTIL_Remove), user variable will
	// point to an invalid CBaseEntity instance, forcing the user to check for validity using IsValid()
	//
	// Using weak refs, when an entity is killed, user variable will lose its reference and become null,
	// greatly simplifying the validity check of entities, and free the invalid instance.
	//
	// There may or may not be unforeseen consequences of using weakrefs,
	// but I haven't had any problems after using them for months.
	//
	// I cannot make this change in the library, because a weak ref acts like a strong ref only when stored (non-local var).
	// This means that local variables will be weakref objects that do not have the reference object's functions
	//
	// For example, the following code will throw an error
	//   local ent = VS.CreateEntity().weakref()
	//   printl( ent.GetOrigin() )
	//
	// But this will not
	//   ent <- VS.CreateEntity().weakref()
	//   printl( ent.GetOrigin() )
	//   local e = ent
	//   printl( e.GetOrigin() )
	//
	// So, the user has to manage this themselves.

	// return ent.weakref();
}

//-----------------------------------------------------------------------
// Input  : handle [ entity ]
//          string [ key ]
//          string/int/float/bool/Vector [ value ]
//-----------------------------------------------------------------------
function VS::SetKey( ent, key, val )
{
	switch( typeof val )
	{
		case "bool":
		case "integer":
			return ent.__KeyValueFromInt( key, val.tointeger() );

		case "float":
			return ent.__KeyValueFromFloat( key, val );

		case "string":
			return ent.__KeyValueFromString( key, val );

		case "Vector":
			return ent.__KeyValueFromVector( key, val );

		case "null":
			return true;

		default:
			throw "Invalid input type: " + typeof val;
	}
}

// Set targetname
function VS::SetName( ent, name )
{
	return ent.__KeyValueFromString("targetname",name.tostring());
}

//-----------------------------------------------------------------------
// ent_script_dump
// Dump all entities whose script scopes are already created.
// Input an entity handle or string to dump its scope.
// String example: "([2] player: targetname)"
//-----------------------------------------------------------------------
function VS::DumpEnt( input = null )
{
	// dump only scope names
	if( !input )
	{
		local ent;
		while( ent = ::Entities.Next(ent) )
		{
			local s = ent.GetScriptScope();
			if(s) ::print(ent + " :: " + s.__vname+"\n"); // GetVarName(s)
		}

		return;
	};

	if( typeof input == "string" )
		input = FindEntityByString(input);

	// dump input scope
	if( typeof input == "instance" )
	{
		if(input.IsValid())
		{
			local s = input.GetScriptScope();
			if(s)
			{
				::print("--- Script dump for entity "+input+"\n");
				DumpScope(s,0,1,0,1);
				::print("--- End script dump\n");
			}
			else return::print("Entity has no script scope! " + input + "\n");
		}
		else return::print("Invalid entity!\n");
	}

	// dump all scopes
	else if( input )
	{
		local ent;
		while( ent = ::Entities.Next(ent) )
		{
			local s = ent.GetScriptScope();
			if(s)
			{
				::print("\n--- Script dump for entity "+ent+"\n");
				DumpScope(s,0,1,0,1);
				::print("--- End script dump\n");
			};
		}
	};;
}

//-----------------------------------------------------------------------
// Return an array of player and bot arrays.
//
// If bots have targetnames, they 'become' humans
//
// If the event listeners are NOT set up, named bots will be shown as players
//-----------------------------------------------------------------------
//
// scope.bot <- scope.networkid == "BOT";
//
function VS::GetPlayersAndBots()
{
	local ent, Ent = ::Entities, ply = [], bot = [];
	while( ent = Ent.FindByClassname(ent, "cs_bot") ) bot.append(ent.weakref());
	ent = null;
	while( ent = Ent.FindByClassname(ent, "player") )
	{
		local s = ent.GetScriptScope();
		if( "networkid" in s && s.networkid == "BOT" ) bot.append(ent.weakref());
		else ply.append(ent.weakref());
	}

	return [ply,bot];
}

//-----------------------------------------------------------------------
// Get every player and bot in a single array
//-----------------------------------------------------------------------
function VS::GetAllPlayers()
{
	local e, E = ::Entities, a = [];
	while( e = E.Next(e) )
		if( e.GetClassname() == "player" )
			a.append(e.weakref());
	return a;
}

//-----------------------------------------------------------------------
// DumpEnt only players and bots
//
// If bots have targetnames, they 'become' humans
//
// If the event listeners are not set up, named bots will be shown as players
//-----------------------------------------------------------------------
function VS::DumpPlayers( dumpscope = false )
{
	local a = GetPlayersAndBots(), p = a[0], b = a[1];

	::print("\n=======================================\n" + p.len()+" players found\n" + b.len()+" bots found\n");

	local c = function( _s, _a ):(dumpscope)
	{
		foreach( e in _a )
		{
			local s = e.GetScriptScope();
			if(s) s = GetVarName(s);
			if(!s) s = "null";
			::print( _s+"- " + e + " :: " + s +"\n");
			if( dumpscope && s != "null" ) DumpEnt(e);
		}
	}

	c("[BOT]    ",b);
	c("[PLAYER] ",p);

	::print("=======================================\n");
}

//-----------------------------------------------------------------------
// return the only / the first connected player in the server
//
// exposes:
// handle HPlayer -> player handle
// table  SPlayer -> player scope
//-----------------------------------------------------------------------
function VS::GetLocalPlayer()
{
	if( GetPlayersAndBots()[0].len() > 1 )
		::print("GetLocalPlayer: More than 1 player detected!\n");

	local e = Entc("player");

	if( e != GetPlayerByIndex(1) )
		::print("GetLocalPlayer: Discrepancy detected!\n");

	if( !e || !e.IsValid() )
		return::print("GetLocalPlayer: No player found!\n");

	if( !e.ValidateScriptScope() )
		return::print("GetLocalPlayer: Failed to validate player scope!\n");

	SetName(e, "localplayer");

	::SPlayer <- e.GetScriptScope();
	::HPlayer <- e.weakref();

	return e;
}

function VS::GetPlayerByIndex( entindex )
{
	local e, E = ::Entities; while( e = ::Entities.Next(e) ) if( e.GetClassname() == "player" ) if( e.entindex() == entindex ) return e;
}

function VS::FindEntityByIndex( entindex, classname = "*" )
{
	local e, E = ::Entities; while( e = E.FindByClassname(e, classname) ) if( e.entindex() == entindex ) return e;
}

//-----------------------------------------------------------------------
// String input such as "([2] player)" and "([88] func_button: targetname)"
// Return entity handle
//-----------------------------------------------------------------------
function VS::FindEntityByString( str )
{
	local e, E = ::Entities; while( e = E.Next(e) ) if( e.tostring() == str ) return e;
}

function VS::IsPointSized( h )
{
	return VectorIsZero( h.GetBoundingMaxs() );
}

function VS::FindEntityNearestFacing( vOrigin, vFacing, fThreshold )
{
	local bestDot = fThreshold,
	      best_ent, ent, Ent = ::Entities;

	while( ent = Ent.Next(ent) )
	{
		// skip all point sized entitites
		if( IsPointSized(ent) ) continue;

		// skip only worldspawn and soundent
		// if( ent.GetClassname() == "worldspawn" || ent.GetClassname() == "soundent" ) continue;

		local to_ent = ent.GetOrigin() - vOrigin;

		to_ent.Norm();

		local dot = vFacing.Dot(to_ent);

		if( dot > bestDot )
		{
			bestDot = dot;
			best_ent = ent;
		};
	}

	return best_ent;
}

function VS::FindEntityClassNearestFacing( vOrigin, vFacing, fThreshold, sClassname )
{
	local bestDot = fThreshold,
	      best_ent, ent, Ent = ::Entities;

	// for( local ent; ent = ::Entities.Next(ent); )
	while( ent = Ent.FindByClassname(ent,sClassname) )
	{
		local to_ent = ent.GetOrigin() - vOrigin;

		to_ent.Norm();

		local dot = vFacing.Dot(to_ent);

		if( dot > bestDot )
		{
			bestDot = dot;
			best_ent = ent;
		};
	}

	return best_ent;
}

// When two candidate entities are in front of each other, pick the closer one
// Not perfect, but it works to some extent
function VS::FindEntityClassNearestFacingNearest( vOrigin, vFacing, fThreshold, sClassname, flRadius )
{
	local best_ent, ent, Ent = ::Entities;

	local flMaxDistSqr = flRadius * flRadius;
	if( !flMaxDistSqr )
		flMaxDistSqr = 3.22122e+09; // MAX_TRACE_LENGTH * MAX_TRACE_LENGTH

	while( ent = Ent.FindByClassname(ent,sClassname) )
	{
		local to_ent = ent.GetOrigin() - vOrigin;
		to_ent.Norm();
		local dot = vFacing.Dot(to_ent);

		if( dot > fThreshold )
		{
			local flDistSqr = (ent.GetOrigin() - vOrigin).LengthSqr();

			if( flMaxDistSqr > flDistSqr )
			{
				best_ent = ent;
				flMaxDistSqr = flDistSqr;
			};
		};
	}

	return best_ent;
}
