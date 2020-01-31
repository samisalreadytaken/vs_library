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
	DoEntFireByInstanceHandle( target, action.tostring(), value.tostring(), delay, activator, caller )
}

::EntFire <- function( target, action, value = "", delay = 0.0, activator = null, caller = null )
{
	DoEntFire( target, action.tostring(), value.tostring(), delay, activator, caller )
}

::EntFireHandle <- ::EntFireByHandle

//-----------------------------------------------------------------------

::PrecacheModel <- function( str )
{
	ENT_SCRIPT.PrecacheModel(str)
}

::PrecacheScriptSound <- function( str )
{
	ENT_SCRIPT.PrecacheScriptSound(str)
}

//-----------------------------------------------------------------------
// Prevent the entity to be released every round
//-----------------------------------------------------------------------
function VS::MakePermanent( handle )
{
	SetKeyString( handle, "classname", "soundent" )
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
	if( !hParent ) return::EntFireByHandle( hChild, "setparent", "" )
	return::EntFireByHandle( hChild, "setparent", "!activator", 0.0, hParent )
}

//-----------------------------------------------------------------------
// Create and return a game_text entity with the input keyvalues
//
// Input  : string [ targetname ]
// Output : table [ keyvalues ]
//-----------------------------------------------------------------------
function VS::CreateGameText( targetname = null, kv = null )
{
	return CreateEntity("game_text", _GUN( targetname, "game_text" ), kv)
}

//-----------------------------------------------------------------------
// Create and return an env_hudhint entity
//
// Input  : string [ targetname ]
//          string [ message ]
// Output : handle [ entity ]
//-----------------------------------------------------------------------
function VS::CreateHudHint( targetname = null, msg = "" )
{
	return CreateEntity("env_hudhint", _GUN( targetname, "hudhint" ), {message = msg})
}

//-----------------------------------------------------------------------
// Show hudhint
// if ent == handle, set msg
//-----------------------------------------------------------------------
function VS::ShowHudHint( hEnt, hTarget, msg = null, delay = 0.0 )
{
	if( msg ) SetKeyString( hEnt, "message", msg )
	::EntFireByHandle( hEnt, "ShowHudHint", "", delay, hTarget )
}

//-----------------------------------------------------------------------
// Hide hudhint
//-----------------------------------------------------------------------
function VS::HideHudHint( hEnt, hTarget, delay = 0.0 )
{
	::EntFireByHandle( hEnt, "HideHudHint", "", delay, hTarget )
}

//-----------------------------------------------------------------------
// Create logic_measure_movement
//
// Input  : string [ target targetname ] (e.g. player targetname)
//          string [ logic_measure entity name ] (optional)
// Output : array [ handle reference, handle measure ]
//-----------------------------------------------------------------------
function VS::CreateMeasure(g,n=null)
{
	local r = "vs_ref_"+UniqueString(),
	      t = CreateEntity( "logic_script",r ),
	      e = CreateEntity( "logic_measure_movement",
	                        _GUN(n,"measure"),
	                        { measuretype = 1,
	                          measurereference = "",
	                          targetreference = r,
	                          target = r,
	                          measureretarget = "" } )

	::EntFireByHandle(e,"setmeasurereference",r)

	::EntFireByHandle(e,"setmeasuretarget",g)

	::EntFireByHandle(e,"enable")

	return[t,e]
}

//-----------------------------------------------------------------------
// Start measuring new target
//
// Input  : handle [ logic_measure_movement ]
// Output : string [ player_targetname ]
//-----------------------------------------------------------------------
function VS::SetMeasure(h,s)
{
	::EntFireByHandle(h,"setmeasuretarget",s)
}

//-----------------------------------------------------------------------
// Input  : string [ targetname ]
//          float [ refire time ]
//          float [ lower (randomtime, used when refire == null) ]
//          float [ upper (randomtime, used when refire == null) ]
//          bool [ oscillator (alternate between OnTimerHigh and OnTimerLow outputs) ]
//          bool [ start disabled ? ]
// Output : entity
//-----------------------------------------------------------------------
function VS::CreateTimer( targetname = null, refire = 1, lower = 1, upper = 5, oscillator = 0, disabled = true )
{
	local ent = CreateEntity( "logic_timer",
	                          _GUN( targetname, "timer" ),
	                          { UseRandomTime = 0,
	                            LowerRandomBound = lower,
	                            UpperRandomBound = upper } )

	if( refire )
		SetKeyFloat( ent, "RefireTime", refire.tofloat() )
	else
	{
		SetKeyInt( ent, "UseRandomTime", 1 )
		SetKeyInt( ent, "spawnflags", oscillator )
	}

	::EntFireByHandle( ent, disabled ? "disable" : "enable" )

	return ent
}

//-----------------------------------------------------------------------
// Create and return a timer that executes Func
// VS.Timer( false, 0.5, Think )
// VS.Timer( bDisabled, fInterval, Func, tScope = this, bExecInEnt = false )
//-----------------------------------------------------------------------
function VS::Timer(b,f,s,t=null,e=false)
{
	local h = CreateTimer(null,f,0,0,0,b)
	OnTimer(h,s,t?t:GetCaller(),e)
	return h
}

//-----------------------------------------------------------------------
// Add OnTimer output to the timer entity to execute the input function
// Input  : handle [ entity ]
//          string OR closure [ function ]
// Output :
//-----------------------------------------------------------------------
function VS::OnTimer( hEnt, Func, tScope = null, bExecInEnt = false )
{
	return AddOutput( hEnt, "OnTimer", Func, tScope ? tScope : GetCaller(), bExecInEnt )
}

function VS::OnTimerHigh( hEnt, Func, tScope = null, bExecInEnt = false )
{
	return AddOutput( hEnt, "OnTimerHigh", Func, tScope ? tScope : GetCaller(), bExecInEnt )
}

function VS::OnTimerLow( hEnt, Func, tScope = null, bExecInEnt = false )
{
	return AddOutput( hEnt, "OnTimerLow", Func, tScope ? tScope : GetCaller(), bExecInEnt )
}

//-----------------------------------------------------------------------
// Adds output in the chosen entity
// Executes the given function in the given scope
//
// Input  : handle [ entity ]
//          string [ output ]
//          string OR closure [ function ]
//          table [ scope ] // null === this
//          bool [ bool ] // execute the function in the scope of hEnt
//-----------------------------------------------------------------------
function VS::AddOutput( hEnt, sOutput, Func, tScope = null, bExecInEnt = false )
{
	if( !hEnt.ValidateScriptScope() ) throw "Invalid entity"

	if( !tScope ) tScope = GetCaller()

	if( typeof Func == "string" )
		Func = tScope[Func]
	else if( typeof Func != "function" )
		throw "Invalid function type " + typeof Func

	hEnt.GetScriptScope()[sOutput] <- bExecInEnt ? Func : Func.bindenv(tScope)

	hEnt.ConnectOutput(sOutput, sOutput)

	// print("** Adding output '" + sOutput + "' to '" + hEnt.GetName() + "'. Execute '" + GetFuncName(Func) + "()' in '" + (bExecInEnt?hEnt.GetScriptScope():GetTableName(tScope)) + ".'\n")
}

//-----------------------------------------------------------------------
// Use to add outputs with parameters
//
// caller is the output owner
// activator is the script owner
//-----------------------------------------------------------------------
function VS::AddOutput2( hEnt, sOutput, Func, tScope = null, bExecInEnt = false )
{
	if( typeof Func == "function" )
		return AddOutput( hEnt, sOutput, Func, tScope, bExecInEnt )

	if( typeof Func != "string" )
		throw "Invalid function type " + typeof Func

	if( !tScope ) tScope = GetCaller()

	if( !("self" in tScope) )
		throw "Invalid function path"

	::DoEntFireByInstanceHandle( hEnt,"addoutput",sOutput+" "+(bExecInEnt?hEnt.GetName():tScope.self.GetName())+":runscriptcode:"+Func,0.0,tScope.self,hEnt )
}

//-----------------------------------------------------------------------
// CreateByClassname, set keyvalues, return handle
//
// Input  : string [ entity classname ]
//          string [ entity targetname ]
//          table [ keyvalues ] // { speed = speed, health = 1337 }
// Output : handle [ entity ]
//-----------------------------------------------------------------------
function VS::CreateEntity( classname, targetname = null, keyvalues = null )
{
	local ent = ::Entities.CreateByClassname( classname )
	if( targetname ) SetName( ent, targetname )
	if( typeof keyvalues == "table" ) foreach( k, v in keyvalues ) SetKey( ent, k, v )
	return ent
}

// Get Unique Name
function VS::_GUN( targetname, keyword = "" )
{
	if( typeof targetname == "string" ) return targetname
	else return "vs_" + keyword + "_" + UniqueString()
}

//-----------------------------------------------------------------------
// Input  : handle [ entity ]
//          string [ key ]
//          string/int/float/bool/vector [ value ]
//-----------------------------------------------------------------------
function VS::SetKey( ent, key, val )
{
	switch( typeof val )
	{
		case "bool":
		case "integer":
			return ent.__KeyValueFromInt( key, val.tointeger() )

		case "float":
			return ent.__KeyValueFromFloat( key, val )

		case "string":
			return ent.__KeyValueFromString( key, val )

		case "Vector":
			return ent.__KeyValueFromVector( key, val )

		default:
			throw "Invalid input type: " + typeof(val)
	}
}

function VS::SetKeyInt( ent, key, val )
{ ent.__KeyValueFromInt( key, val.tointeger() ) }

function VS::SetKeyFloat( ent, key, val )
{ ent.__KeyValueFromFloat( key, val.tofloat() ) }

function VS::SetKeyString( ent, key, val )
{ ent.__KeyValueFromString( key, val.tostring() ) }

function VS::SetKeyVector( ent, key, val )
{ ent.__KeyValueFromVector( key, val ) }

// Set targetname
function VS::SetName( ent, name )
{ ent.__KeyValueFromString("targetname",name) }

//-----------------------------------------------------------------------
// ent_script_dump
// Dump all entities whose script scopes are already created.
// Input an entity handle or string to dump its scope.
// String example: "([2] player: targetname)"
//-----------------------------------------------------------------------
function VS::DumpEnt( input = null )
{
	if( !input )
	{
		local ent
		while( ent = ::Entities.Next(ent) )
		{
			local s = ent.GetScriptScope()
			if( s ) ::printl(ent + " :: " + s.__vname)//GetTableName(s))
		}
	}
	else if( typeof input == "instance" || typeof input == "string" )
	{
		if( typeof input == "string" )
			input = FindEntityByString(input)

		local s
		try(s=input.GetScriptScope())catch(e)
		{return::printl("Entity has no script scope! " + input)}

		::printl("--- Script dump for entity "+input)
		DumpScope(s,0,1,0,1)
		::printl("--- End script dump")
	}
	else if( input )
	{
		local ent
		while( ent = ::Entities.Next(ent) )
		{
			local s = ent.GetScriptScope()
			if( s )
			{
				::printl("\n--- Script dump for entity "+ent)
				DumpScope(s,0,1,0,1)
				::printl("--- End script dump")
			}
		}
	}
}

//-----------------------------------------------------------------------
// Return an array of player and bot arrays.
//
// If bots have targetnames, they 'become' players
// Don't name your bots, use their handles.
//
// The only other way of differentiating named bots from players is
// checking their networkid.
//
// If your bots are named and you've set up the event listeners,
// set the 'validated' parameter to true.
//
//-----------------------------------------------------------------------
//
// scope.bot <- scope.networkid == "BOT" ? true : false
//
function VS::GetPlayersAndBots( validated = false )
{
	local ent, ply = [], bot = []
	while( ent = ::Entities.FindByClassname(ent, "cs_bot") ) bot.append(ent)
	ent = null
	while( ent = ::Entities.FindByClassname(ent, "player") )
	{
		if( validated && ent.GetScriptScope().networkid == "BOT" ) bot.append(ent)
		else ply.append(ent)
	}

	return [ply,bot]
}

//-----------------------------------------------------------------------
// Get every player and bot in a single array
//-----------------------------------------------------------------------
function VS::GetAllPlayers()
{
	local e, a = []
	while( e = ::Entities.Next(e) )
		if( e.GetClassname() == "player" )
			a.append(e)
	return a
}

//-----------------------------------------------------------------------
// DumpEnt only players and bots
//
// If your bots are named and you've set up the event listeners,
// set the 'validated' parameter to true.
//
// Otherwise the named bots will be shown as players.
//-----------------------------------------------------------------------
function VS::DumpPlayers( dumpscope = false, validated = false )
{
	local a = GetPlayersAndBots(validated), p = a[0], b = a[1]

	::print("\n===\n" + p.len()+" players found\n" + b.len()+" bots found\n")

	local c = function( _s, _a, d = dumpscope )
	{
		foreach( e in _a )
		{
			local s = e.GetScriptScope()
			try( s = GetTableName(s) ) catch(e){ s = "null" }
			::printl( _s+"- " + e + " :: " + s )
			if( d && s != "null" ) DumpEnt( e )
		}
	}

	c("[BOT]    ",b)
	c("[PLAYER] ",p)
	::print("===\n")
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
	local e, i, c = 0

	while( i = Entc("player", i) ) c++

	if( c > 1 ) ::printl("[VS::GetLocalPlayer] More than 1 player detected!")

	e = Entc("player")

	if( e != GetPlayerByIndex(1) )
		::printl("[VS::GetLocalPlayer] Discrepancy detected!")

	if( !e || !e.IsValid() )
		return::printl( "[VS::GetLocalPlayer] No player found!" )

	if( !e.ValidateScriptScope() )
		return::printl( "[VS::GetLocalPlayer] Failed to validate player scope!" )

	SetName( e, "player" )

	::SPlayer <- e.GetScriptScope()
	::HPlayer <- e

	return e
}

function VS::GetPlayerByIndex( entindex )
{
	local e; while( e = ::Entities.Next(e) ) if( e.GetClassname() == "player" ) if( e.entindex() == entindex ) return e
}

function VS::FindEntityByIndex( entindex, classname = "*" )
{
	local e; while( e = ::Entities.FindByClassname(e, classname) ) if( e.entindex() == entindex ) return e
}

//-----------------------------------------------------------------------
// String input such as "([2] player)" and "([88] func_button: targetname)"
// Return entity handle
//-----------------------------------------------------------------------
function VS::FindEntityByString( str )
{
	local e; while( e = ::Entities.Next(e) ) if( e.tostring() == str ) return e
}

function VS::IsPointSized( h )
{
	return VectorIsZero( h.GetBoundingMaxs() )
}

function VS::FindEntityNearestFacing( vOrigin, vFacing, fThreshold )
{
	local bestDot = fThreshold,
	      best_ent, ent

	while( ent = ::Entities.Next(ent) )
	{
		// skip all point sized entitites
		if( IsPointSized( ent ) ) continue

		// skip only worldspawn and soundent
		// if( ent.GetClassname() == "worldspawn" || ent.GetClassname() == "soundent" ) continue

		local to_ent = ent.GetOrigin() - vOrigin

		to_ent.Norm()

		local dot = vFacing.Dot( to_ent )

		if( dot > bestDot )
		{
			bestDot = dot
			best_ent = ent
		}
	}

	return best_ent
}

function VS::FindEntityClassNearestFacing( vOrigin, vFacing, fThreshold, sClassname )
{
	local bestDot = fThreshold,
	      best_ent, ent

	// for( local ent = ::Entities.First(); ent; ent = ::Entities.Next(ent) )
	// while( ent = ::Entities.Next(ent) )
	while( ent = ::Entities.FindByClassname(ent,sClassname) )
	{
		// if( ent.GetClassname() != sClassname ) continue

		local to_ent = ent.GetOrigin() - vOrigin

		to_ent.Norm()

		local dot = vFacing.Dot( to_ent )

		if( dot > bestDot )
		{
			bestDot = dot
			best_ent = ent
		}
	}

	return best_ent
}

// When two candidate entities are in front of each other, pick the closer one
// Not perfect, but it works to some extent
function VS::FindEntityClassNearestFacingNearest( vOrigin, vFacing, fThreshold, sClassname, flRadius )
{
	local best_ent, ent

	local flMaxDist2 = flRadius * flRadius
	if( !flMaxDist2 )
		flMaxDist2 = 3.22122e+09; // MAX_TRACE_LENGTH * MAX_TRACE_LENGTH

	while( ent = ::Entities.FindByClassname(ent,sClassname) )
	{
		local to_ent = ent.GetOrigin() - vOrigin
		to_ent.Norm()
		local dot = vFacing.Dot( to_ent )

		if( dot > fThreshold )
		{
			local flDist2 = (ent.GetOrigin() - vOrigin).LengthSqr()

			if( flMaxDist2 > flDist2 )
			{
				best_ent = ent
				flMaxDist2 = flDist2
			}
		}
	}

	return best_ent
}
