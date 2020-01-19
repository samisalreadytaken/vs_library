//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//
//                       github.com/samisalreadytaken
//
// This project is licensed under the terms of the MIT License.
// See <README.md> or <LICENSE> for details.
//-----------------------------------------------------------------------
//
// For CS:GO event examples, see the example map at
//   	https://github.com/samisalreadytaken/vscripts
//
//-----------------------------------------------------------------------
//
// Return player handle
//  	VS.GetPlayerByUserid( int userid )
//
// Input player handle, add their userid, networkid (steamID32) and name in their scope
//  	VS.ValidateUserid( handle entity )
//
// Validate every player and bot's userid
//  	VS.ValidateUseridAll()
//
// Dump every player and bot scopes
//  	VS.DumpPlayers(1)
//
//---------------
//
// Adding event listeners to work with vscripts:
//
// In your script, declare your functions in the global scope like so:
//  	::OnGameEvent_<event_name> <- function(data)
//
// On your logic_eventlisteners, add the following output:
//  	OnEventFired <self_name> RunScriptCode ::OnGameEvent_<event_name>(event_data)
//
// Example:
//  	logic_eventlistener:
//  		targetname = "@event_impact"
//  		EventName = "bullet_impact"
//  		FetchEventData = 1
//  	OnEventFired @event_impact RunScriptCode ::OnGameEvent_bullet_impact(event_data)
//
// This will call your function OnGameEvent_bullet_impact(data), with the event data as the parameter.
// You can see what's inside the event data by putting VS.DumpScope(data) in your function.
//
//---------------
// (vs_library required)
//
// If you'd like to get the userid, networkid (steamID32) and name of players,
// add the following outputs on your player_connect and player_info event listeners
//  	OnEventFired @event_connect RunScriptCode ::VS.Events.player_connect(event_data)
//  	OnEventFired @event_info    RunScriptCode ::VS.Events.player_info(event_data)
//
// You can still execute your arbitrary code on these events by
// simply creating ::OnGameEvent_<event_name>(data) functions
//
// When you call VS.ValidateUserid( hPLAYER ) with a player handle as a parameter,
// that player's known info will be put into the player scope. ( userid, networkid, name )
//
// IMPORTANT: You cannot validate every player at the same frame,
// there needs to be at least one frame time delay between each validation.
//
// You can add your delay like so:
//  	delay( "VS.ValidateUserid( VS.FindEntityByString(\""+hPLAYER+"\") )", FrameTime() * _COUNTER )
// or
//  	delay( "VS.ValidateUserid( activator )", FrameTime() * _COUNTER, ENT_SCRIPT, hPLAYER )
//
//
// You can automate this by putting this as a game_playerjoin output: VS.ValidateUserid( activator )
// Note that this won't work for bots. You would have to use one of the other methods for them.
//
// An example of this game_playerjoin automation (in script) can be seen in this following code:
// The same can be done inside Hammer as well by adding the VS.ValidateUserid(activator) output on game_playerjoin.
/*

if( !Entities.FindByName(null, "game_playerjoin") )
	VS.CreateEntity("trigger_brush","game_playerjoin").GetScriptScope().OnUse <- function(){VS.ValidateUserid( activator )}

*/
//
// Or execute this every round to make sure every player and bot in the server has their userid set up:
//  	logic_auto output:
//  	OnMapSpawn <any_script_entity> RunScriptCode ::VS.ValidateUseridAll()
//
// Or put a trigger_multiple on every spawn point in the map with this output:
//  	OnStartTouch !self      RunScriptCode ::VS.ValidateUserid(activator)
// or
//  	OnStartTouch !activator RunScriptCode ::VS.ValidateUserid(self)
//
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
// Input  : int userid
// Output : player handle
//-----------------------------------------------------------------------
function VS::GetPlayerByUserid( userid )
{
	local ent

	// find players only
	// while( ent = Entities.FindByClassname(ent, "player") )

	// find players and bots
	while( ent = Entities.Next(ent) ) if( ent.GetClassname() == "player" )

	{local s = ent.GetScriptScope(); if( s && s.userid == userid ) return ent}
}

//-----------------------------------------------------------------------
// Input  : player handle, add its userid in its scope
// Output : return ent scope if ent is valid
//-----------------------------------------------------------------------
function VS::ValidateUserid( ent )
{
	if( !ent.ValidateScriptScope() ) return printl("Userid validation failed: Invalid player entity.")
	local scope = ent.GetScriptScope()
	if( "userid" in scope ) return scope
	Events.SValidatee <- scope
	EntFireHandle( Events.proxy, "generategameevent", "", 0.0, ent )
	return scope
}

//-----------------------------------------------------------------------
// Validate every player and bot's userid
//-----------------------------------------------------------------------
function VS::ValidateUseridAll()
{
	local i = 0, f = FrameTime()
	foreach( e in GetAllPlayers() )
		delay( "VS.ValidateUserid(activator)", f * i++, ENT_SCRIPT, e )
}

//-----------------------------------------------------------------------

// If events are correctly set up, add the userid, networkid (steamID32) and name to the player scope
// if not, just add the userid
// Bot networkid is "BOT"
function VS::Events::Info( data )
{
	SValidatee.networkid <- ""
	SValidatee.name <- ""
	SValidatee.userid <- data.userid

	if( ::_xa9b2dfB7ffe.len() ) foreach( i, t in ::_xa9b2dfB7ffe ) if( t.userid == data.userid )
	{
		SValidatee.networkid = t.networkid
		SValidatee.name = t.name
		::_xa9b2dfB7ffe.remove(i)
		break
	}
}

// OnEvent player_connect
// user function ::OnGameEvent_player_connect will still be called
// Only allows 512 unprocessed entries to be held
function VS::Events::player_connect(data)
{
	if(::_xa9b2dfB7ffe.len()>512)for(local i=0;i<8;i++)::_xa9b2dfB7ffe.remove(0);::_xa9b2dfB7ffe.append(data)

	::OnGameEvent_player_connect(data)
}

// OnEvent player_info
// user function ::OnGameEvent_player_info will still be called
function VS::Events::player_info(data)
{
	Info(data)

	::OnGameEvent_player_info(data)
}
