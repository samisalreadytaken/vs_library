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
if ( !("{847D4B}" in ROOT) )
	ROOT["{847D4B}"] <- array(64);

if ( !("OnGameEvent_player_spawn" in ROOT) )
	::OnGameEvent_player_spawn <- dummy;

if ( !("OnGameEvent_player_connect" in ROOT) )
	::OnGameEvent_player_connect <- dummy;

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
// Only allows 64 unprocessed entries to be held
// This limit realistically will never be reached (unless the player_spawn listener
// was never created or correctly set up). It's a just-in-case check.
//
// When the limit is reached, the oldest 32 entries are deleted.

local gEventData = ROOT["{847D4B}"];
local flTimeoutThold = TICK_INTERVAL*2;
local Time = Time;
local Fmt = ::format;

function VS::Events::player_connect( event ) : ( gEventData, Time, flTimeoutThold, Fmt )
{
	if ( event.networkid != "" )
	{
		local idx;

		foreach( i,v in gEventData )
			if ( !gEventData[i] )
			{
				idx = i;
				break;
			};

		if ( idx == null )
		{
			// memmove( gEventData, gEventData + 32, 32 )
			for ( local i = 32; i < 64; ++i )
			{
				gEventData[i-32] = gEventData[i];
				gEventData[i] = null;
			}

			idx = 0;
			::Msg( "player_connect: ERROR!!! Player data is not being processed\n" );
		};

		gEventData[idx] = event;

		return::OnGameEvent_player_connect(event);
	}
	else if ( m_SV )
	{
		local dt = Time() - m_flValidateTime;

		if ( dt <= flTimeoutThold )
		{
			m_SV.userid <- event.userid;

			if ( !("name" in m_SV) )
				m_SV.name <- "";
			if ( !("networkid" in m_SV) )
				m_SV.networkid <- "";
		}
		else::Msg(Fmt( "player_connect: Unexpected error! %g (%d)\n", dt, (0.5+(dt/::FrameTime())).tointeger() ));

		m_SV = null;
		m_flValidateTime = 0.0;

		return;
	};;
}

// OnEvent player_spawn
// user function ::OnGameEvent_player_spawn will still be called
function VS::Events::player_spawn( event ) : ( gEventData )
{
	foreach( i, data in gEventData )
	{
		if ( !data )
			break;

		else if ( data.userid == event.userid )
		{
			local player = GetPlayerByIndex( data.index+1 );

			if ( !player || !player.ValidateScriptScope() )
			{
				::Msg("player_connect: Invalid player entity\n");
				break;
			};

			local scope = player.GetScriptScope();

			if ( "networkid" in scope )
			{
				::Msg("player_connect: BUG!!! Something has gone wrong. ");

				if ( scope.networkid == data.networkid )
				{
					gEventData[i] = null;
					::Msg("Duplicated data!\n");
				}
				else
				{
					::Msg("Conflicting data!\n");
				};

				break;
			};

			if ( data.networkid == "" )
				::Msg("player_connect: could not get event data\n");

			scope.userid <- data.userid;
			scope.name <- data.name;
			scope.networkid <- data.networkid;
			gEventData[i] = null;
			break;
		};;
	}

	return::OnGameEvent_player_spawn(event);
}

// if something has gone wrong with automatic validation, force add userid
//
// Calling multiple times in a frame will cause problems; either delay, or use ValidateUseridAll.
//
function VS::ForceValidateUserid( ent ) : ( AddEvent, Time, Fmt )
{
	if ( !ent || !ent.IsValid() || ent.GetClassname() != "player" )
		return::Msg(Fmt( "ForceValidateUserid: Invalid input: %s\n", ""+E ));

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

//-----------------------------------------------------------------------
//
// While event listeners dump the event data whenever events are fired,
// entity outputs are added to the event queue to be executed in the next frame.
// Because of this delay, when an event is fired multiple times before
// the output is fired - before the script function is executed via the output - previous events would be lost.
//
// This function catches each event data dump, saving it for the next time it is
// fetched by user script which is called by the event listener output.
// Because of this save-restore action, the event data can only be fetched once.
// This means there can only be 1 event listener output with event_data access.
//
// Run this function on each round start on the event listeners you expect to be fired multiple times in a frame.
//
//		VS.FixupEventListener( Ent("bullet_impact") )
//
// It is harmless to run it on all event listeners.
//
//		for ( local ent; ent = Entities.FindByClassname( ent, "logic_eventlistener" ); )
//			VS.FixupEventListener( ent )
//
// Alternatively you can create a script file with this execution, and attach it to your event listeners. (fixupeventlistener.nut)
//
//		IncludeScript("vs_library")
//		VS.FixupEventListener( self )
//
//-----------------------------------------------------------------------
function VS::FixupEventListener( ent )
{
	if ( !ent || !ent.IsValid() ||
		(ent.GetClassname() != "logic_eventlistener") || !ent.ValidateScriptScope() )
		return Msg("VS::FixupEventListener: invalid event listener input\n");

	local sc = ent.GetScriptScope();

	if ( sc.parent.rawin( "{7D6E9A}" ) )
		return Msg("VS::FixupEventListener: already fixed up " + ent + "\n");

	local cache = [];
	// sc.rawset( "event_cache", cache );
	sc.rawdelete("event_data");

	// Table looks for parent's metamethods.
	// They are called in child's environment.
	delegate ( delegate ( delegate sc.parent :
	{
		_delslot = function( k )
		{
			delete parent.parent[k];
		}
	} ) :
	{
		_newslot = function( k, v ) : (cache)
		{
			if ( k == "event_data" )
			{
				cache.insert( 0, v );
			}
			else
			{
				rawset( k, v );
			}
		},
		_get = function( k ) : (cache)
		{
			if ( k == "event_data" )
			{
				return cache.pop();
			};
			return rawget(k); // throw
		},
		["{7D6E9A}"] = null
	} ) : sc
}

}; // EVENTS

}; // !PORTAL2
