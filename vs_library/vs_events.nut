//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------

if (!PORTAL2 && EVENTS){

VS.Events <- delegate VS :
{
	m_hProxy = null,
	m_flValidateTime = 0.0,
	m_SV = null // validatee
}

// array to store event data, user should never modify
if ( !("_xa9b2dfB7ffe" in ROOT) )
	::_xa9b2dfB7ffe <- [];

if ( !("OnGameEvent_player_spawn" in ROOT) )
	::OnGameEvent_player_spawn <- ::dummy;

if ( !("OnGameEvent_player_connect" in ROOT) )
	::OnGameEvent_player_connect <- ::dummy;

}; // !PORTAL2 && EVENTS

if (!PORTAL2){

//-----------------------------------------------------------------------
// Input  : int userid
// Output : player handle
//-----------------------------------------------------------------------

local Entities = ::Entities;

function VS::GetPlayerByUserid( userid ):(Entities)
{
	local ent;
	while ( ent = Entities.FindByClassname( ent, "player" ) )
	{
		local s = ent.GetScriptScope();
		if ( "userid" in s && s.userid == userid )
			return ent;
	}
	ent = null;
	while ( ent = Entities.FindByClassname( ent, "cs_bot" ) )
	{
		local s = ent.GetScriptScope();
		if ( "userid" in s && s.userid == userid )
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
	if ( data.networkid.len() )
	{
		if ( gEventData.len() > 128 )
		{
			for( local i = 64; i--; )
				gEventData.remove(0);

			::Msg("player_connect: ERROR!!! Player data is not being processed\n")
		};

		gEventData.append(data);

		return::OnGameEvent_player_connect(data);
	}
	else if ( m_SV )
	{
		local dt = Time() - m_flValidateTime;

		if ( !(dt > flTimeoutThold) )
		{
			m_SV.userid <- data.userid;

			if ( !("name" in m_SV) )
				m_SV.name <- "";
			if ( !("networkid" in m_SV) )
				m_SV.networkid <- "";
		}
		else::Msg("player_connect: Unexpected error! "+dt+"\n");

		m_SV = null;
		m_flValidateTime = 0.0;

		return;
	};;
}

// OnEvent player_spawn
// user function ::OnGameEvent_player_spawn will still be called
function VS::Events::player_spawn(data):(gEventData)
{
	if ( gEventData.len() ) foreach( i, d in gEventData ) if ( d.userid == data.userid )
	{
		local player = GetPlayerByIndex(d.index+1);

		if ( !player || !player.ValidateScriptScope() )
		{
			::Msg("player_connect: Invalid player entity\n");
			break;
		};

		local scope = player.GetScriptScope();

		if ( "networkid" in scope )
		{
			::Msg("player_connect: BUG!!! Something has gone wrong. ");

			if ( scope.networkid == d.networkid )
			{
				::Msg("Duplicated data!\n");
				gEventData.remove(i);
			}
			else
			{
				::Msg("Conflicting data!\n");
			};

			break;
		};

		if ( !d.networkid.len() )
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
function VS::ForceValidateUserid(ent):(AddEvent,Time)
{
	if ( !ent || !ent.IsValid() || ent.GetClassname() != "player" )
		return::Msg("ForceValidateUserid: Invalid input: "+E+"\n");

	// TODO: force reloading the library will overwrite this.
	// I believe referencing it using a targetname is more prone to user errors compared to
	// the rare case of the execution of VS.ForceReload()
	// ForceReload could be rewritten to clear instead of overwriting everything.
	if ( !Events.m_hProxy )
	{
		Events.m_hProxy = CreateEntity("info_game_event_proxy", {event_name = "player_connect"}, true).weakref();
	};

	Events.m_flValidateTime = Time();

	ent.ValidateScriptScope();
	Events.m_SV = ent.GetScriptScope();

	// don't quit, overwrite previous userid if exists
	// if ( "userid" in m_SV ) return

	AddEvent( Events.m_hProxy, "GenerateGameEvent", "", 0, ent, null );
}

function VS::ValidateUseridAll( bForce = 0 )
{
	local flFrameTime = ::FrameTime();
	local delay = EventQueue.AddEvent;
	local i = 0;

	foreach( v in GetAllPlayers() )
		if ( !("userid" in v.GetScriptScope()) || bForce )
			delay( ForceValidateUserid, i++*flFrameTime, [ this, v ] );
}

VS.Events.ForceValidateUserid <- VS.ForceValidateUserid.weakref();
VS.Events.ValidateUseridAll <- VS.ValidateUseridAll.weakref();

}; // EVENTS

}; // !PORTAL2
