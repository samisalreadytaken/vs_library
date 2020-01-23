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
if( ::EntFireByHandle.getinfos().native )
	::DoEntFireByInstanceHandle <- ::EntFireByHandle

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
//
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
	if( !hParent ) return::EntFireHandle( hChild, "setparent", "" )
	return::EntFireHandle( hChild, "setparent", "!activator", 0.0, hParent )
}

//-----------------------------------------------------------------------
// Create and return a game_text entity with the input keyvalues
// Uncomment and change the keyvalues you wish to change from their default values
/*

VS.CreateGameText(null,{
	// channel = 1,
	// color = "100 100 100",
	// color2 = "240 110 0",
	// effect = 0,
	// fadein = 1.5,
	// fadeout = 0.5,
	// fxtime = 0.25,
	// holdtime = 1.2,
	// x = -1,
	// y = -1,
	// spawnflags = 0,
	// message = ""
})

*/
// Change the message using one of two methods:
//  	VS.SetKeyString( gametext, "message", "<your message>" )
//  	EntFireHandle( gametext, "SetText", "<your message>" )
//
// Display it to hPlayer:
//  	EntFireHandle( gametext, "display", "", 0, hPlayer )
//
// Input  : string [ targetname ]
// Output : table [ keyvalues ]
//-----------------------------------------------------------------------
function VS::CreateGameText( targetname = "", kv = null )
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
function VS::CreateHudHint( targetname = "", msg = "" )
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
	::EntFireHandle( hEnt, "ShowHudHint", "", delay, hTarget )
}

//-----------------------------------------------------------------------
// Hide hudhint
//-----------------------------------------------------------------------
function VS::HideHudHint( hEnt, hTarget, delay = 0.0 )
{
	::EntFireHandle( hEnt, "HideHudHint", "", delay, hTarget )
}

//-----------------------------------------------------------------------
// Create logic_measure_movement
//
// You can disable the measuring entity to stop the measure.
// The reference will keep the last measured values.
//
// local arr = VS.CreateMeasure(str)
//
// ent_refernc = arr[0]
// ent_measure = arr[1]
//
//
// Example get player eye angles:
//
/*

player <- VS.GetLocalPlayer()

player_eye <- VS.CreateMeasure( player.GetName() )[0]

printl("Player eye angles: " + player_eye.GetAngles() )

*/
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

	::EntFireHandle(e,"setmeasurereference",r)

	::EntFireHandle(e,"setmeasuretarget",g)

	::EntFireHandle(e,"enable")

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
	::EntFireHandle(h,"setmeasuretarget",s)
}

//-----------------------------------------------------------------------
// Input  : string [ targetname ]
//          float [ refire time ]
//          float [ lower (randomtime, used when refire == null) ]
//          float [ upper (randomtime, used when refire == null) ]
//          bool [ oscillator (alternate between OnTimerHigh and OnTimerLow outputs) ]
//          bool [ start disabled ? ]
// Output : array [ entity, entity_scope ]
//-----------------------------------------------------------------------
function VS::CreateTimer( targetname = "", refire = 1, lower = 1, upper = 5, oscillator = 0, disabled = 1 )
{
	local ent = CreateEntity( "logic_timer",
	                          _GUN( targetname, "timer" ),
	                          { UseRandomTime = 0,
	                            LowerRandomBound = lower,
	                            UpperRandomBound = upper } )

	if( !refire )
	{
		SetKeyInt( ent, "UseRandomTime", 1 )
		SetKeyInt( ent, "spawnflags", oscillator )
	}
	else SetKeyFloat( ent, "RefireTime", refire.tofloat() )

	::EntFireHandle( ent, disabled ? "disable" : "enable" )

	return ent
}

//-----------------------------------------------------------------------
// Create and return a timer that executes sFunc
// VS.Timer( false, 0.5, "Think" )
// VS.Timer( bDisabled, fInterval, sFunc, tScope = this, bExecInEnt = false )
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
//          string [ function ]
// Output : table [ scope ]
//-----------------------------------------------------------------------
function VS::OnTimer( hEnt, sFunc, tScope = null, bExecInEnt = false )
{
	return AddOutput( hEnt, "OnTimer", sFunc, tScope ? tScope : GetCaller(), bExecInEnt )
}

function VS::OnTimerHigh( hEnt, sFunc, tScope = null, bExecInEnt = false )
{
	return AddOutput( hEnt, "OnTimerHigh", sFunc, tScope ? tScope : GetCaller(), bExecInEnt )
}

function VS::OnTimerLow( hEnt, sFunc, tScope = null, bExecInEnt = false )
{
	return AddOutput( hEnt, "OnTimerLow", sFunc, tScope ? tScope : GetCaller(), bExecInEnt )
}

//-----------------------------------------------------------------------
// Adds output in the chosen entity
// Executes the given function in the given scope
// Example:
//  	VS.AddOutput( hTimer, "OnTimer", "MyFunction" )
//
// Or execute the function that is in tScope, in the scope of hEnt
// Example:
//  	let function MyFunction(){ print(self.GetName()) }
//  	VS.AddOutput( hButton, "OnPressed", "MyFunction", null, true )
// When the button is fired the Pressed input, it prints <hButton.GetName()>
//
//  	VS.AddOutput( hButton, "OnPressed", "MyFunction" )
// In this case the button prints <this.self.GetName()>
//
// ! Doesn't support function parameters
//
// Input  : handle [ entity ]
//          string [ output ]
//          string [ function ]
//          table [ scope ] // null === this
//          bool [ bool ] // execute the function in the scope of hEnt
//-----------------------------------------------------------------------
function VS::AddOutput( hEnt, sOutput, sFunc, tScope = null, bExecInEnt = false )
{
	if( !hEnt.ValidateScriptScope() ) throw "Invalid entity."

	local skope, scope = hEnt.GetScriptScope()

	if( !tScope ) tScope = GetCaller()

	if( "self" in tScope && tScope.self.IsValid() ) skope = ::getroottable()[tScope.__vname]
	else
	{
		local d = GetTableDir(tScope), l = d.len()
		if( l == 1 ) skope = ::getroottable()
		else if( l == 2 ) skope = ::getroottable()[d[1]]
		else if( l == 3 ) skope = ::getroottable()[d[1]][d[2]]
		else if( l == 4 ) skope = ::getroottable()[d[1]][d[2]][d[3]]
		else if( l == 5 ) skope = ::getroottable()[d[1]][d[2]][d[3]][d[4]]
		else if( l == 6 ) skope = ::getroottable()[d[1]][d[2]][d[3]][d[4]][d[5]]
		else if( l == 7 ) skope = ::getroottable()[d[1]][d[2]][d[3]][d[4]][d[5]][d[6]]
		else if( l == 8 ) skope = ::getroottable()[d[1]][d[2]][d[3]][d[4]][d[5]][d[6]][d[7]]
	}

	scope[sOutput] <- bExecInEnt ? skope[sFunc] : skope[sFunc].bindenv(tScope)

	hEnt.ConnectOutput( sOutput, sOutput )

	// print( "** Adding output '" + sOutput + "' to '" + hEnt.GetName() + "'. Execute '" + sFunc + "()' in '" + skope  + ".'\n" )

	return true
}

// example
//
//  	VS.AddOutput2( hTimer,"ontimer","printl(self)",null,true )
//
// caller is the output owner
// activator is the script owner
function VS::AddOutput2( hEnt, sOutput, sFunc, tScope = null, bExecInEnt = false )
{
	if( !tScope ) tScope = GetCaller()
	if( !("self" in tScope) ) throw"Invalid function path"
	::DoEntFireByInstanceHandle( hEnt,"addoutput",sOutput+" "+(bExecInEnt?hEnt.GetName():tScope.self.GetName())+":runscriptcode:"+sFunc,0.0,tScope.self,hEnt )
	return true
}

//-----------------------------------------------------------------------
// CreateByClassname, set keyvalues, create script scope, return handle
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

// Change targetname
function VS::ChangeName( oldname, newname )
{ ::Entities.FindByName(null,oldname).__KeyValueFromString("targetname",newname) }

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
// But this requires you to have validated their userids first, using
//  	VS.ValidateUserid( handle )
// or
//  	VS.ValidateUseridAll()
//
// To prevent common issues with validating userids,
// check the vs_events file documentation.
//
// If your bots are named and you've validated userids,
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
// Iterate through every player and bot, and apply the input function on them
// Example ( these 2 snippets do the same thing ):
/*

	VS.GetAllPlayers( function( player ) {
		player.SetHealth(1)
	} )

//---------------

	foreach( player in VS.GetAllPlayers() ) {
		player.SetHealth(1)
	}

*/
//-----------------------------------------------------------------------
function VS::GetAllPlayers( closure = null )
{
	local e, a = []
	while( e = ::Entities.Next(e) )
		if( e.GetClassname() == "player" )
			if( closure )
				closure( e )
			else a.append(e)
	return a
}

//-----------------------------------------------------------------------
// DumpEnt only players and bots
//
// If your bots are named and you've validated userids,
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

function VS::FindEntityByIndex( entindex, classname = null )
{
	local e; while( e = ::Entities.FindByClassname(e, classname ? classname : "*") ) if( e.entindex() == entindex ) return e
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

function VS::FindEntityGeneric( hStartEntity, sName )
{
	local ent

	ent = ::Entities.FindByName( hStartEntity, sName )

	if( !ent )
		ent = ::Entities.FindByClassname( hStartEntity, sName )

	return ent
}

function VS::FindEntityClassNearestFacing( vOrigin, vFacing, fThreshold, sClassname )
{
	local bestDot = fThreshold,
	      best_ent, ent

	// for( local ent = ::Entities.First(); ent; ent = ::Entities.Next(ent) )
	while( ent = ::Entities.Next(ent) )
	{
		if( ent.GetClassname() != sClassname ) continue

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

// When two candidate entities are in front of each other, pick the closer one
// Not perfect, but it works to some extent
function VS::FindEntityClassNearestFacingNearest( vOrigin, vFacing, fThreshold, sClassname, flRadius )
{
	local best_ent, ent

	local flMaxDist2 = flRadius * flRadius
	if( !flMaxDist2 )
		flMaxDist2 = 3.22122e+09; // MAX_TRACE_LENGTH * MAX_TRACE_LENGTH

	while( ent = ::Entities.Next(ent) )
	{
		if( ent.GetClassname() != sClassname ) continue

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
