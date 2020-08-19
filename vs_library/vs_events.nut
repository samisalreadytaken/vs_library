//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//
//                       github.com/samisalreadytaken
//
// This project is licensed under the terms of the MIT License.
// See <README.md> or <LICENSE> for details.
//-----------------------------------------------------------------------

if (!PORTAL2){

//-----------------------------------------------------------------------
// Input  : int userid
// Output : player handle
//-----------------------------------------------------------------------

local Entities = ::Entities;

function VS::GetPlayerByUserid( userid ):(Entities)
{
	local ent;

	while( ent = Entities.Next(ent) ) if( ent.GetClassname() == "player" )
	{
		local s = ent.GetScriptScope();
		if( "userid" in s && s.userid == userid )
			return ent;
	}
}

if (EVENTS){

// OnEvent player_connect
// user function ::OnGameEvent_player_connect will still be called
//
// If events are correctly set up, add the userid, networkid (steamID32) and name to the player scope
// Bot networkid is "BOT"
//
// Only allows 128 unprocessed entries to be held
// This limit realistically will never be reached (unless the player_spawn listener
// was never created or correctly set up). It's a just-in-case check.
//
// When the limit is reached, the oldest 64 entries are deleted.

local gEventData = ::_xa9b2dfB7ffe;
local flTimeoutThold = ::FrameTime()*2;
local Time = ::Time;

function VS::Events::player_connect(data):(gEventData,Time,flTimeoutThold)
{
	if( data.networkid.len() )
	{
		if( gEventData.len() > 128 )
		{
			for( local i = 64; i--; )
				gEventData.remove(0);

			::Msg("player_connect: ERROR!!! Player data is not being processed\n")
		};

		gEventData.append(data);

		return::OnGameEvent_player_connect(data);
	}
	else if( _SV )
	{
		local dt = Time() - flValidateTime;

		if( !(dt > flTimeoutThold) )
		{
			_SV.userid <- data.userid;

			if( !("name" in _SV) )
				_SV.name <- "";
			if( !("networkid" in _SV) )
				_SV.networkid <- "";
		}
		else::Msg("player_connect: Unexpected error! "+dt+"\n");

		_SV = null;
		flValidateTime = 0.0;

		return;
	};;
}

// OnEvent player_spawn
// user function ::OnGameEvent_player_spawn will still be called
function VS::Events::player_spawn(data):(gEventData)
{
	if( gEventData.len() ) foreach( i, d in gEventData ) if( d.userid == data.userid )
	{
		local player = ::VS.GetPlayerByIndex(d.index+1);

		if( !player || !player.ValidateScriptScope() )
		{
			::Msg("player_connect: Invalid player entity\n");
			break;
		};

		local scope = player.GetScriptScope();

		if( "networkid" in scope )
		{
			::Msg("player_connect: BUG!!! Something has gone wrong. ");

			if( scope.networkid==d.networkid )
			{
				::Msg("Duplicated data!\n");
				gEventData.remove(i);
			}
			else::Msg("Conflicting data!\n");

			break;
		};

		if( !d.networkid.len() )
			::Msg("player_connect: could not get event data\n");

		scope.userid <- d.userid;
		scope.name <- d.name;
		scope.networkid <- d.networkid;
		gEventData.remove(i);
		break;
	};;

	return::OnGameEvent_player_spawn(data);
}

// if something has gone wrong with automatic validation, force add userid
//
// Calling multiple times in a frame will cause problems; either delay, or use ValidateUseridAll.
//
function VS::Events::ForceValidateUserid(ent):(AddEvent,Time)
{
	if( !ent || !ent.IsValid() || ent.GetClassname() != "player" )
		return::Msg("ForceValidateUserid: Invalid input: "+E+"\n");

	// todo: force reloading the library will overwrite this.
	// I believe referencing it using a targetname is more prone to user errors compared to
	// the rare case of the execution of VS.ForceReload()
	// ForceReload could be rewritten to clear instead of overwriting everything.
	if( !hProxy )
	{
		hProxy = ::VS.CreateEntity("info_game_event_proxy", {event_name = "player_connect"}, true).weakref();
	};

	flValidateTime = Time();

	ent.ValidateScriptScope();
	_SV = ent.GetScriptScope();

	// don't quit, overwrite previous userid if exists
	// if( "userid" in _SV ) return

	AddEvent(hProxy, "generategameevent", "", 0, ent, null);
}

function VS::Events::ValidateUseridAll(force = 0)
{
	local flFrameTime = ::FrameTime();
	local delay = ::delay;
	local ENT_SCRIPT = ::ENT_SCRIPT;
	local i = 0;

	foreach( v in ::VS.GetAllPlayers() )
		if( !("userid" in v.GetScriptScope()) || force )
			delay("::VS.Events.ForceValidateUserid(activator)", i++*flFrameTime, ENT_SCRIPT, v);
}

}; // EVENTS

};; // !PORTAL2
