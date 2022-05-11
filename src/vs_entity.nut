//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
// Make EntFireByHandle allow default parameters
//-----------------------------------------------------------------------
::EntFireByHandle <- function( target, action, value = "", delay = 0.0, activator = null, caller = null )
	: (AddEvent)
{
	return AddEvent( target, ""+action, ""+value, delay, activator, caller );
}

//-----------------------------------------------------------------------
// Clone of the original EntFire, reduces 3 calls
//-----------------------------------------------------------------------
::EntFire <- function( target, action, value = "", delay = 0.0, activator = null/* , caller = null */ )
	: (DoEntFire)
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

// no PrecacheModel in Portal2
if ( "PrecacheModel" in CBaseEntity )
	::PrecacheModel <- function(s) : (World) return World.PrecacheModel(s);;

// PrecacheSoundScript is identical to PrecacheScriptSound on server
::PrecacheScriptSound <- function(s) : (World) return World.PrecacheSoundScript(s);

if (PORTAL2)
{
	VS.MakePersistent <- dummy;
}
else
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
// Adds output to the input entity
//
// Input  : handle [ entity ]
//          string [ output ]
//          string|closure [ target|function ]
//          string|table [ input|scope ]
//          string [ parameter override ]
//          float [ delay ]
//          int [ times to fire ]
// Output : table [ent scope]
//-----------------------------------------------------------------------
function VS::AddOutput( hEnt, szOutput, szTarget, szInput = "", szParameter = "", flDelay = 0.0, nTimes = -1 )
	: (Fmt, compilestring)
{
	switch ( typeof szTarget )
	{
		case "string":

			if ( szTarget.find("(") == null )
			{
				return hEnt.__KeyValueFromString(
					szOutput,
					Fmt( "%s,%s,%s,%f,%d",
						szTarget,
						szInput,
						szParameter,
						flDelay,
						nTimes ) );
			}
			else
			{
				// Target contains a function call.
				// Compile it and fall to function parameter -
				// which simply adds the !self,CallScriptFunction action
				szTarget = compilestring( szTarget );
			};

		case "function":

			// call env
			if ( szInput == "" )
				szInput = GetCaller();

			// assume szInput is valid

			if ( szParameter == "" )
				szParameter = false;

			hEnt.ValidateScriptScope();
			local sc = hEnt.GetScriptScope();
			sc[szOutput] <- szParameter ? szTarget : szTarget.bindenv( szInput );

			return hEnt.ConnectOutput( szOutput, szOutput );
			// return AddOutput( hEnt, szOutput, "!self", "CallScriptFunction", szOutput );

	}
}

//-----------------------------------------------------------------------
// CreateByClassname, set keyvalues, return handle
//
// Input  : string [ entity classname ]
//          table [ keyvalues ]
//          bool [ make persistent ]
// Output : handle [ entity ]
//-----------------------------------------------------------------------
function VS::CreateEntity( classname, keyvalues = null, preserve = false )
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
		case "float":
			return ent.__KeyValueFromFloat( key, val );

		case "integer":
		case "bool":
			return ent.__KeyValueFromInt( key, val.tointeger() );

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
function VS::DumpEnt( input = null ) : (Fmt)
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
//-----------------------------------------------------------------------
// Return an array of player and bot arrays.
//
// If bots have targetnames, they 'become' humans
//
// If the event listeners are NOT set up, named bots will be shown as players
//-----------------------------------------------------------------------
function VS::GetPlayersAndBots()
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
function VS::GetAllPlayers()
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
};; // !PORTAL2

//
// Deprecated.
// Use VS.GetPlayerByIndex(1) for multiplayer,
// ::player or ::GetPlayer() for singleplayer.
//
function VS::GetLocalPlayer(b=null)
{
	local e = GetPlayerByIndex(1);
	if ( e )
		SetName( e, "localplayer" );
	if ( b )
		::HPlayer <- e.weakref();
	return e;
}

//-----------------------------------------------------------------------
// PlayerInstanceFromIndex
//-----------------------------------------------------------------------
function VS::GetPlayerByIndex( entindex )
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
function VS::GetEntityByIndex( entindex, classname = "*" )
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

function VS::FindEntityNearestFacing( vOrigin, vFacing, fThreshold )
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

function VS::FindEntityClassNearestFacing( vOrigin, vFacing, fThreshold, szClassname )
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
function VS::FindEntityClassNearestFacingNearest( vOrigin, vFacing, fThreshold, szClassname, flRadius )
{
	local best_ent, ent;

	if ( !flRadius )
		flRadius = MAX_TRACE_LENGTH;

	while ( ent = Entities.FindByClassname(ent,szClassname) )
	{
		local to_ent = ent.GetOrigin() - vOrigin;
		local flDist = to_ent.Norm();
		local dot = vFacing.Dot(to_ent);

		if ( dot > fThreshold && flRadius > flDist )
		{
			best_ent = ent;
			flRadius = flDist;
		};
	}

	return best_ent;
}
