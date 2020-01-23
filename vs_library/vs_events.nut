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
// add the following outputs on your player_connect and player_spawn event listeners
//  	OnEventFired @event_connect RunScriptCode VS.Events.player_connect(event_data)
//  	OnEventFired @event_spawn   RunScriptCode VS.Events.player_spawn(event_data)
//
// You can still execute your arbitrary code on these events by
// simply creating the ::OnGameEvent_player_spawn(data) functions
//
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
// Input  : int userid
// Output : player handle
//-----------------------------------------------------------------------
function VS::GetPlayerByUserid( userid )
{
	local ent

	while( ent =::Entities.Next(ent) ) if( ent.GetClassname() == "player" )
	{
		local s = ent.GetScriptScope()
		if( s && s.userid == userid )
			return ent
	}
}

//-----------------------------------------------------------------------

// OnEvent player_connect

// If events are correctly set up, add the userid, networkid (steamID32) and name to the player scope
// Bot networkid is "BOT"

// user function ::OnGameEvent_player_connect will still be called
// Only allows 512 unprocessed entries to be held
function VS::Events::player_connect(data)
{
	if(::_xa9b2dfB7ffe.len()>512)for(local i=0;i<8;i++)::_xa9b2dfB7ffe.remove(0);::_xa9b2dfB7ffe.append(data)

	return::OnGameEvent_player_connect(data)
}

// OnEvent player_spawn
// user function ::OnGameEvent_player_spawn will still be called
function VS::Events::player_spawn(data)
{
	if( ::_xa9b2dfB7ffe.len() ) foreach( i, d in ::_xa9b2dfB7ffe ) if( d.userid == data.userid )
	{
		local player = ::VS.GetPlayerByIndex(d.index+1)

		if( !player.ValidateScriptScope() )
			return::printl("[player_connect]: Invalid player entity.")

		local scope = player.GetScriptScope()

		if( "userid" in scope )
			return::OnGameEvent_player_spawn(data)

		if( !d.networkid.len() )
			::printl("[player_connect]: could not get event data.")

		scope.userid <- d.userid
		scope.name <- d.name
		scope.networkid <- d.networkid
		::_xa9b2dfB7ffe.remove(i)
		return::OnGameEvent_player_spawn(data)
	}

	return::OnGameEvent_player_spawn(data)
}
