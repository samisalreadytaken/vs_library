//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
// Make EntFireByHandle allow default parameters
//-----------------------------------------------------------------------
::EntFireByHandle <- function( target, action, value = "", delay = 0.0, activator = null, caller = null ):(AddEvent)
{
	return AddEvent( target, ""+action, ""+value, delay, activator, caller );
}

//-----------------------------------------------------------------------
// Reduce 3 calls
//-----------------------------------------------------------------------
::EntFire <- function( target, action, value = "", delay = 0.0, activator = null ) : (DoEntFire)
{
	if ( !value )
	{
		value = "";
	};

	local caller;
	if ( "self" in this )
	{
		caller = self;
		if ( !activator )
		{
			activator = self;
		};
	};

	return DoEntFire( ""+target, ""+action, ""+value, delay, activator, caller );
}

::PrecacheModel <- function(s) : (World)
{
	World.PrecacheModel(s);
}

::PrecacheScriptSound <- function(s) : (World)
{
	World.PrecacheSoundScript(s); // identical to PrecacheScriptSound on server
}

//-----------------------------------------------------------------------
// Prevent the entity from being reset every round
//-----------------------------------------------------------------------
function VS::MakePersistent(ent)
{
	// choose one from s_PreserveEnts
	return ent.__KeyValueFromString( "classname", "soundent" );
}

//-----------------------------------------------------------------------
// Set child's parent
// if parent == null, unparent child
//
// Input  : handle [ child entity ]
// Output : handle [ parent entity ]
//-----------------------------------------------------------------------
function VS::SetParent( hChild, hParent ):(AddEvent)
{
	if ( hParent ) return AddEvent( hChild, "SetParent", "!activator", 0.0, hParent, null );
	return AddEvent( hChild, "ClearParent", "", 0.0, null, null );
}

//-----------------------------------------------------------------------
// Deprecated. Use `ToExtendedPlayer`.
//
// Create logic_measure_movement, measure eye angles
//
// Input  : string [ target targetname ] (e.g. player targetname)
//          string [ reference entity name ] (optional)
//          bool   [ make the reference entity persistent ]
//          bool   [ measure eyes ]
//          float  [ scale ]
// Output : handle reference
//-----------------------------------------------------------------------
function VS::CreateMeasure( g, n = null, p = false, e = true, s = 1.0 ):(AddEvent)
{
	local r = e ? n ? n+"" : "vs.ref_"+UniqueString() : n ? n+"" : null;

	if ( !r || !r.len() )
		throw "Invalid targetname";

	local e = CreateEntity( "logic_measure_movement",
	                        { measuretype = e ? 1 : 0,
	                          measurereference = "",
	                          targetreference = r,
	                          target = r,
	                          measureretarget = "",
	                          targetscale = s.tofloat(),
	                          targetname = e?r:null }, p );

	AddEvent( e, "SetMeasureReference", r, 0.0, null, null );
	AddEvent( e, "SetMeasureTarget", g, 0.0, null, null );
	AddEvent( e, "Enable", "" , 0.0, null, null );

	return e;
}

//-----------------------------------------------------------------------
// Deprecated. Use `ToExtendedPlayer`.
//
// Start measuring new target
//
// Input  : handle [ logic_measure_movement ]
//          string [ player_targetname ]
// Output :
//-----------------------------------------------------------------------
function VS::SetMeasure(h,s):(AddEvent)
{
	return AddEvent( h, "SetMeasureTarget", s, 0.0, null, null );
}

//-----------------------------------------------------------------------
// Input  : bool [ start disabled ]
//          float [ refire time ]
//          float [ lower (randomtime, used when refire == null) ]
//          float [ upper (randomtime, used when refire == null) ]
//          bool [ oscillator (alternate between OnTimerHigh and OnTimerLow outputs) ]
//          bool [ make persistent ]
// Output : entity
//-----------------------------------------------------------------------
function VS::CreateTimer( bDisabled, flInterval, flLower = null, flUpper = null, bOscillator = false, bMakePersistent = false ):(AddEvent)
{
	local ent = CreateEntity( "logic_timer", null, bMakePersistent );

	if ( flInterval != null )
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

	AddEvent( ent, bDisabled ? "Disable" : "Enable", "", 0.0, null, null );

	return ent;
}

//-----------------------------------------------------------------------
// Create and return a timer that executes Func
// VS.Timer( false, 0.5, Think )
//-----------------------------------------------------------------------
function VS::Timer( bDisabled, flInterval, Func = null, tScope = null, bExecInEnt = false, bMakePersistent = false )
{
	if ( flInterval == null )
	{
		Msg("\nERROR:\nRefire time cannot be null in VS.Timer\nUse VS.CreateTimer for randomised fire times.\n");
		throw "NULL REFIRE TIME";
	};

	local h = CreateTimer( bDisabled, flInterval, null, null, null, bMakePersistent );
	OnTimer( h, Func, tScope ? tScope : GetCaller(), bExecInEnt );
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
function VS::AddOutput( hEnt, szOutput, Func, tScope = null, bExecInEnt = false ) : (compilestring)
{
	if ( !tScope )
		tScope = GetCaller();

	if ( Func )
	{
		if ( typeof Func == "string" )
		{
			if ( Func.find("(") != null )
				Func = compilestring(Func);
			else
				Func = tScope[Func];
		}
		else if ( typeof Func != "function" )
			throw "Invalid function type " + typeof Func;;
	}
	else
	{
		Func = null;
		bExecInEnt = true; // to be able to assign Func (null) below
	};

	hEnt.ValidateScriptScope();

	local r = hEnt.GetScriptScope();

	r[szOutput] <- bExecInEnt ? Func : Func.bindenv(tScope);

	hEnt.ConnectOutput(szOutput, szOutput);

	return r;
}

/*
function VS::AddOutput2( hEnt, szOutput, szTarget, szInput, szParameter = "", flDelay = 0.0, nTimes = -1 ) : (AddEvent, Fmt)
{
	return AddEvent(
		hEnt,
		"AddOutput",
		Fmt(
			"%s %s,%s,%s,%f,%d",
			szOutput,
			szTarget,
			szInput,
			szParameter,
			flDelay,
			nTimes ),
		0.0,
		null,
		hEnt );
}
*/

//-----------------------------------------------------------------------
// CreateByClassname, set keyvalues, return handle
//
// Input  : string [ entity classname ]
//          table [ keyvalues ] // { speed = speed, health = 1337 }
//          bool [ make persistent ]
// Output : handle [ entity ]
//-----------------------------------------------------------------------
function VS::CreateEntity( classname, keyvalues = null, preserve = false ):(Entities)
{
	local ent = Entities.CreateByClassname(classname);

	if ( typeof keyvalues == "table" )
		foreach( k, v in keyvalues )
			SetKeyValue(ent, k, v);

	if (preserve)
		MakePersistent(ent);

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
	//   ent.GetOrigin()
	//
	// But this will not
	//   ent <- VS.CreateEntity().weakref()
	//   ent.GetOrigin()
	//
	//   local e = ent
	//   e.GetOrigin()
	//
	// So, the user has to manage this themselves.
	//

	// return ent.weakref();
}

//-----------------------------------------------------------------------
// Input  : handle [ entity ]
//          string [ key ]
//          string/int/float/bool/Vector [ value ]
//-----------------------------------------------------------------------
function VS::SetKeyValue( ent, key, val )
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
	return ent.__KeyValueFromString("targetname",""+name);
}

//-----------------------------------------------------------------------
// ent_script_dump
// Dump all entities whose script scopes are already created.
// Input an entity handle or string to dump its scope.
// String example: "([2] player: targetname)"
//-----------------------------------------------------------------------
function VS::DumpEnt( input = null ) : (Entities, Fmt)
{
	// dump only scope names
	if ( !input )
	{
		local ent;
		while ( ent = Entities.Next(ent) )
		{
			local s = ent.GetScriptScope();
			if (s) Msg(Fmt( "%s :: %s\n", ""+ent, s.__vname ));
		}

		return;
	};

	if ( typeof input == "string" )
	{
		local ent;
		while ( ent = Entities.Next(ent) )
			if (""+ent == input)
				input = ent;
	};

	// dump input scope
	if ( typeof input == "instance" )
	{
		if (input.IsValid())
		{
			local s = input.GetScriptScope();
			if (s)
			{
				Msg(Fmt( "--- Script dump for entity %s\n", ""+input ));
				DumpScope(s,0,1,0,1);
				Msg("--- End script dump\n");
			}
			else return Msg(Fmt( "Entity has no script scope! %s\n", ""+input ));
		}
		else return Msg("Invalid entity!\n");
	}

	// dump all scopes
	else if ( input )
	{
		local ent;
		while ( ent = Entities.Next(ent) )
		{
			local s = ent.GetScriptScope();
			if (s)
			{
				Msg(Fmt( "\n--- Script dump for entity %s\n", ""+ent ));
				DumpScope(s,0,1,0,1);
				Msg("--- End script dump\n");
			};
		}
	};;
}


if (!PORTAL2){

// return the only / the first connected player in the server
function VS::GetLocalPlayer( bAddGlobal = true )
{
	local e = ::Entc("player");

	if ( !e )
		returnMsg("GetLocalPlayer: No player found!\n");

	if ( e != GetPlayerByIndex(1) )
		Msg("GetLocalPlayer: Discrepancy!\n");

	SetName(e, "localplayer");

	if (bAddGlobal)
		::HPlayer <- e.weakref();

	return e;
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
function VS::GetPlayersAndBots():(Entities)
{
	local ent, ply = [], bot = [];

	while ( ent = Entities.FindByClassname(ent, "cs_bot") )
	{
		bot.append(ent.weakref());
	}

	ent = null;

	while ( ent = Entities.FindByClassname(ent, "player") )
	{
		local s = ent.GetScriptScope();

		if ( "networkid" in s && s.networkid == "BOT" )
			bot.append(ent.weakref());
		else
			ply.append(ent.weakref());
	}

	return [ply,bot];
}

//-----------------------------------------------------------------------
// Get every player and bot in a single array
//-----------------------------------------------------------------------
function VS::GetAllPlayers():(Entities)
{
	local e, a = [];
	while ( e = Entities.FindByClassname(e,"player") )
		a.append(e.weakref());
	e = null;
	while ( e = Entities.FindByClassname(e,"cs_bot") )
		a.append(e.weakref());
	return a;
}

//-----------------------------------------------------------------------
// DumpEnt only players and bots
//-----------------------------------------------------------------------
function VS::DumpPlayers( bDumpScope = false ) : (Fmt)
{
	local a = GetPlayersAndBots(), p = a[0], b = a[1];

	Msg(Fmt( "\n=======================================\n%d players found\n%d bots found\n", p.len(), b.len() ));

	local c = function( _s, _a ):(bDumpScope, Fmt)
	{
		foreach( e in _a )
		{
			local s = e.GetScriptScope();
			if (s) s = GetVarName(s);
			if (!s) s = "null";
			Msg(Fmt( "%s - %s :: %s\n", _s, ""+e, s ));
			if ( bDumpScope && s != "null" ) DumpEnt(e);
		}
	}

	c("[BOT]   ",b);
	c("[PLAYER]",p);

	Msg("=======================================\n");
}

}else{ // PORTAL2

// vscript in singleplayer games already puts the local player in ::player
// and they also have native functions for getting it:
// (Portal2) GetPlayer()
// (Source2) Entities:GetLocalPlayer()
function VS::GetLocalPlayer()
{
	local e;

	if ( ::IsMultiplayer() )
	{
		e = ::Entc("player");
	}
	else
	{
		e = ::GetPlayer();

		if ( e != ::player )
			Msg("GetLocalPlayer: Discrepancy!\n");
	};

	SetName(e, "localplayer");

	return e;
}

};;

//-----------------------------------------------------------------------
// PlayerInstanceFromIndex
//-----------------------------------------------------------------------
function VS::GetPlayerByIndex( entindex ) : (Entities)
{
	local e;
	while ( e = Entities.FindByClassname( e, "player" ) )
		if ( e.entindex() == entindex )
			return e;
	e = null;
	while ( e = Entities.FindByClassname( e, "cs_bot" ) )
		if ( e.entindex() == entindex )
			return e;
}

//-----------------------------------------------------------------------
// EntIndexToHScript
//-----------------------------------------------------------------------
function VS::GetEntityByIndex( entindex, classname = "*" ) : (Entities)
{
	local e;
	while ( e = Entities.FindByClassname(e, classname) )
		if ( e.entindex() == entindex )
			return e;
}

// ::EntIndexToHScript <- VS.GetEntityByIndex.weakref();
// ::PlayerInstanceFromIndex <- VS.GetPlayerByIndex.weakref();


function VS::IsPointSized( h )
{
	return VectorIsZero( h.GetBoundingMaxs() );
}

function VS::FindEntityNearestFacing( vOrigin, vFacing, fThreshold ):(Entities)
{
	local bestDot = fThreshold,
		best_ent, ent = Entities.First();

	while ( ent = Entities.Next(ent) )
	{
		// skip all point sized entitites
		if ( IsPointSized(ent) )
			continue;

		// skip only worldspawn and soundent
		// if ( ent.GetClassname() == "worldspawn" || ent.GetClassname() == "soundent" ) continue;

		local to_ent = ent.GetOrigin() - vOrigin;

		to_ent.Norm();

		local dot = vFacing.Dot(to_ent);

		if ( dot > bestDot )
		{
			bestDot = dot;
			best_ent = ent;
		};
	}

	return best_ent;
}

function VS::FindEntityClassNearestFacing( vOrigin, vFacing, fThreshold, szClassname ):(Entities)
{
	local bestDot = fThreshold,
		best_ent, ent;

	while ( ent = Entities.FindByClassname(ent,szClassname) )
	{
		local to_ent = ent.GetOrigin() - vOrigin;

		to_ent.Norm();

		local dot = vFacing.Dot(to_ent);

		if ( dot > bestDot )
		{
			bestDot = dot;
			best_ent = ent;
		};
	}

	return best_ent;
}

// When two candidate entities are in front of each other, pick the closer one
// Not perfect, but it works to some extent
function VS::FindEntityClassNearestFacingNearest( vOrigin, vFacing, fThreshold, szClassname, flRadius ):(Entities)
{
	local flMaxDistSqr, best_ent, ent;

	if ( flRadius )
	{
		flMaxDistSqr = flRadius * flRadius;
	}
	else
	{
		flMaxDistSqr = 3.22122e+09; // MAX_TRACE_LENGTH * MAX_TRACE_LENGTH
	};

	while ( ent = Entities.FindByClassname(ent,szClassname) )
	{
		local to_ent = ent.GetOrigin() - vOrigin;

		to_ent.Norm();

		local dot = vFacing.Dot(to_ent);

		if ( dot > fThreshold )
		{
			local flDistSqr = (ent.GetOrigin() - vOrigin).LengthSqr();

			if ( flMaxDistSqr > flDistSqr )
			{
				best_ent = ent;
				flMaxDistSqr = flDistSqr;
			};
		};
	}

	return best_ent;
}
