//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------
//

local Events = delegate ::VS :
{
	m_hProxy = null,
	m_bFixedUp = false,
	m_SV = null, // validatee queue
	m_Players = null,
	m_pSpawner = null,
	m_pListeners = null,
	s_szEventName = null,
	s_hListener = null,
	s_fnSynchronous = null,
	__rem = null,
	__tmp = null,

	Msg = Msg
}

VS.Events <- Events;


if ( !("{847D4B}" in ROOT) )
	ROOT["{847D4B}"] <- array(64);
local gEventData = ROOT["{847D4B}"];

//-----------------------------------------------------------------------
// Input  : int userid
// Output : player handle
//-----------------------------------------------------------------------
VS.GetPlayerByUserid <- function( userid ) : (Entities)
{
	// cache on lookup
	// Alternatively cache on userid registration

	if ( m_Players && userid in m_Players )
		return m_Players[userid];

	if ( !m_Players )
		m_Players = {};

	local ent;
	while ( ent = Entities.FindByClassname( ent, "player" ) )
	{
		local s = ent.GetScriptScope();
		if ( "userid" in s && s.userid == userid )
		{
			m_Players[userid] <- ent.weakref();
			return ent;
		}
	}
	ent = null;
	while ( ent = Entities.FindByClassname( ent, "cs_bot" ) )
	{
		local s = ent.GetScriptScope();
		if ( "userid" in s && s.userid == userid )
		{
			m_Players[userid] <- ent.weakref();
			return ent;
		}
	}
}.bindenv( VS.Events );

// OnEvent player_connect
//
// If events are correctly set up, add the userid, networkid (steamID32) and name to the player scope
// Bot networkid is "BOT"
//
// Only allows 64 unprocessed entries to be held
// This limit realistically will never be reached (unless the player_spawn listener
// was never created or correctly set up). It's a just-in-case check.
//
// When the limit is reached, the oldest 32 entries are deleted.
VS.Events.player_connect <- function( event ) : ( gEventData, ROOT, SendToConsole )
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

			idx = 32;
			Msg( "player_connect: ERROR!!! Player data is not being processed\n" );
		};

		gEventData[idx] = event;

		// if using the old method
		if ( !m_pListeners )
		{
			local caller = GetCaller();
			if ( !caller.parent || !caller.parent.rawin( "{7D6E9A}" ) )
			{
				Msg( "player_connect: Warning: event listener is not fixed up!\n" );
				m_bFixedUp = false;
			}
			else
			{
				m_bFixedUp = true;
			};

			if ( "OnGameEvent_player_connect" in ROOT )
				::OnGameEvent_player_connect(event);
		};

		return true;
	};

	if ( m_SV )
	{
		local sc = m_SV.remove(0);
		if ( !sc || !("self" in sc) )
			return Msg("VS::ForceValidateUserid: invalid scope in validation\n");

		if ( !sc.__vrefs || !sc.self || !sc.self.IsValid() )
			return Msg("VS::ForceValidateUserid: invalid entity in validation\n");

		if ( "userid" in sc && sc.userid != event.userid )
			Msg("VS::ForceValidateUserid: ERROR!!! conflict! ["+ sc.userid +", "+ event.userid +"]\n");

		//if ( event.userid in m_Players )
		//{
		//	if ( m_Players[event.userid] != sc.self )
		//		Msg("VS::ForceValidateUserid: ERROR!!! conflict! ["+ sc.self +", "+ m_Players[event.userid] +"]\n");
		//}
		//else
		//{
		//	m_Players[event.userid] <- sc.self.weakref();
		//};

		sc.userid <- event.userid;

		if ( !("name" in sc) )
			sc.name <- "";
		if ( !("networkid" in sc) )
			sc.networkid <- "";

		// 'banid' is not whitelisted. SendToConsoleServer always checks the whitelist,
		// point_servercommand checks it when the server is not listen server.
		// Try ClientCommand to see if it's a listen server, then fetch the networkid.
		// ban for 3 seconds, no kick. min duration is 0.01
		SendToConsole( "banid 0.05 " + event.userid );

		// finished the queue
		if ( !(0 in m_SV) )
			m_SV = null;
	}

}.bindenv( VS.Events );

VS.Events.server_addban <- function( event )
{
	// not playing
	if ( !event.userid )
		return;

	// don't bother
	if ( event.kicked )
		return;

	local ply = GetPlayerByUserid( event.userid );
	if ( !ply )
		return Msg("VS::Events: validation failed to find player! ["+event.userid+"]\n");

	local sc = ply.GetScriptScope();

	//if ( sc.name != "" )
	//	Msg(format( "VS::Events: validation: [%d] overwriting name '%s' -> '%s'\n", event.userid, sc.name, event.name ));

	//if ( sc.networkid != "" )
	//	Msg(format( "VS::Events: validation: [%d] overwriting networkid '%s' -> '%s'\n", event.userid, sc.networkid, event.networkid ));

	sc.name = event.name;
	sc.networkid = event.networkid;

}.bindenv( VS.Events );

// OnEvent player_spawn
VS.Events.player_spawn <- function( event ) : ( gEventData, Fmt, ROOT )
{
	foreach( i, data in gEventData )
	{
		if ( !data )
			break;

		if ( data.userid == event.userid )
		{
			local player = GetPlayerByIndex( data.index+1 );

			if ( !player || !player.ValidateScriptScope() )
			{
				gEventData[i] = null;
				Msg( "player_connect: invalid player entity [" + data.userid + "] [" + (data.index+1) + "]\n" );
				break;
			};

			local scope = player.GetScriptScope();

			if ( "networkid" in scope &&
				scope.networkid != "" ) // if the existing networkid is empty, fall through and update
			{
				Msg("player_connect: ERROR!!! Something has gone wrong! ");

				if ( scope.networkid == data.networkid )
				{
					gEventData[i] = null;
					Msg(Fmt( "Duplicated data. [%d]\n", data.userid ));
				}
				else
				{
					Msg(Fmt( "Conflicting data. [%d] ('%s', '%s')\n", data.userid, scope.networkid, data.networkid ));
				};
				break;
			};

			scope.userid <- data.userid;
			scope.name <- data.name;
			scope.networkid <- data.networkid;
			gEventData[i] = null;

			// remove gaps if the listener was not fixed up
			gEventData.sort();
			// default sort puts null before instances, reverse it
			gEventData.reverse();

			//m_Players[scope.userid] <- player.weakref();

			break;
		};
	}

	// if using the old method
	if ( !m_pListeners )
	{
		local caller = GetCaller();
		if ( !caller.parent || !caller.parent.rawin( "{7D6E9A}" ) )
			Msg( "player_spawn: Warning: event listener is not fixed up!\n" );
		if ( "OnGameEvent_player_spawn" in ROOT )
			return ::OnGameEvent_player_spawn(event);
	};
}.bindenv( VS.Events );

//
// if something has gone wrong with automatic validation, force add userid
//
VS.ForceValidateUserid <- function( ent ) : ( AddEvent, Fmt )
{
	if ( !ent || !ent.IsValid() || (ent.GetClassname() != "player") || !ent.ValidateScriptScope() )
		return Msg(Fmt( "VS::ForceValidateUserid: invalid input: %s\n", ""+ent ));

	if ( !m_SV )
		m_SV = [];

	local sc = ent.GetScriptScope();
	local b = 1;
	foreach( v in m_SV )
		if ( v == sc )
		{
			b = 0;
			break;
		};

	if (b)
		m_SV.append( sc.weakref() );
	// UNDONE: fail condition when the event queue is reset (round end)
	// in the same frame VS.ForceValidateUserid is called

	if ( !m_hProxy )
	{
		m_hProxy =
			CreateEntity("info_game_event_proxy", { event_name = "player_connect" }, true).weakref();
	};

	return AddEvent( m_hProxy, "GenerateGameEvent", "", 0, ent, null );
}.bindenv( VS.Events );

function VS::ValidateUseridAll()
{
	if ( Events.m_bFixedUp )
	{
		foreach( i, v in GetAllPlayers() )
			if ( !("userid" in v.GetScriptScope()) )
				ForceValidateUserid( v );
	}
	// fallback and force validate even though there will be other issues
	else
	{
		Msg( "VS::ValidateUseridAll: Warning: player_connect event listener is not fixed up!" );

		local delay = ::delay; // not using EventQueue for standalone version
		local t = ::FrameTime();
		foreach( i, v in GetAllPlayers() )
			delay( "::VS.ForceValidateUserid(self)", i * t, v );
	};
}

VS.Events.ForceValidateUserid <- VS.ForceValidateUserid.weakref();
VS.Events.ValidateUseridAll <- VS.ValidateUseridAll.weakref();

//-----------------------------------------------------------------------
//
// NOTE: not needed if using VS.ListenToGameEvent
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
				// This can of course be used as a manager and call callbacks added with a unique function, but
				// that would not be compatible with the current method of using outputs, and
				// be generally pointless as CSGO does not have an addon system where independent scripts
				// are likely to be run in parallel. The lack of an error handler is also an important problem.
				// Events can only be listened by spawning a map-created event listener, and
				// event listeners are guaranteed to be only used by mappers.
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

// gross hack
local __RemovePooledString = function(sz)
{
	__rem = sz;
	m_pSpawner.SpawnEntity();
	__rem = null;
}.bindenv( VS.Events );

function VS::Events::SpawnEntity( eventname )
{
	if ( !m_pSpawner )
	{
		m_pSpawner =
			CreateEntity( "env_entity_maker", { EntityTemplate = "vs.eventlistener" }, true ).weakref();
	};
	s_szEventName = eventname;
	m_pSpawner.SpawnEntity();
	local r = s_hListener;
	s_szEventName = s_hListener = null;
	return r;
}

function VS::Events::__ExecutePreSpawn( pEnt )
{
	local vs = VS.Events;

	if ( vs.__rem )
	{
		pEnt.__KeyValueFromString( "targetname", vs.__rem );
		pEnt.__KeyValueFromString( "EventName", "player_connect" ); // suppress warnings
		pEnt.Destroy();
		return;
	};

	local eventname = vs.s_szEventName;
	if ( !eventname )
	{
		pEnt.Destroy();
		return Msg( "VS::Events::PreSpawn: invalid call origin\n" );
	};

	pEnt.__KeyValueFromString( "EventName", eventname );
	pEnt.__KeyValueFromInt( "FetchEventData", 1 );
	pEnt.__KeyValueFromInt( "IsEnabled", 1 );
	pEnt.__KeyValueFromInt( "TeamNum", -1 );

	__EntityMakerResult = {}
}

function VS::Events::__FinishSpawn()
{
	__EntityMakerResult = null;
}

VS.Events.PostSpawn <- function( pEntities ) : (AddEvent)
{
	foreach( ent in pEntities )
	{
		s_hListener = ent;
		FixupEventListener(ent);
		MakePersistent(ent);
		local sc = ent.GetScriptScope();

		// synchronous callbacks, not possible to dump call stack when exception is thrown
		if ( s_fnSynchronous )
		{
			SetName( ent, "" );
			delete sc.parent._get;
			sc.parent._newslot = function( k, v ) : (s_fnSynchronous)
			{
				if ( k == "event_data" )
				{
					//try
					//{
						return s_fnSynchronous(v);
					//}
					//catch( err )
					//{
					//	print(format( "\nAN ERROR HAS OCCURED [%s]\n", err ));
					//}
				};
				return rawset( k, v );
			}
		}
		// asynchronous callbacks
		else
		{
			// naming it with the event name and UID makes debugging easier
			local name = sc.__vname;
			local i = name.find("_");
			name = s_szEventName + "_" + name.slice( 0, i );
			SetName( ent, name );
			AddEvent(
				ent,
				"AddOutput",
				"OnEventFired "+name+",CallScriptFunction,OnEventFired",
				0.0, null, ent );
			sc.OnEventFired <- null;
		}
	}
}.bindenv( VS.Events );


VS.Events.OnPostSpawn <- function() : (__RemovePooledString)
{
	local VS = VS;

	if ( !VS.Events.m_bFixedUp )
	{
		VS.Events.m_bFixedUp = true;
		Msg("VS::Events init\n");

		VS.StopListeningToAllGameEvents( "VS::Events" );

		VS.ListenToGameEvent( "player_connect", VS.Events.player_connect, "VS::Events" );
		VS.ListenToGameEvent( "player_spawn", VS.Events.player_spawn, "VS::Events" );
		VS.ListenToGameEvent( "server_addban", VS.Events.server_addban, "VS::Events" );

		VS.ListenToGameEvent( "player_activate", function(ev)
		{
			return ValidateUseridAll();
		}.bindenv(VS), "VS::Events" );

		VS.ListenToGameEvent( "player_disconnect", function(ev)
		{
			if ( m_Players && ev.userid in m_Players )
			{
				delete m_Players[ev.userid];
			}
		}.bindenv( VS.Events ), "VS::Events" );
	};

	if ( VS.Events.__tmp )
		__RemovePooledString( VS.Events.__tmp );
	VS.Events.__tmp = __vname;
}


VS.ListenToGameEvent <- function( szEventname, fnCallback, pContext )
{
	if ( (typeof fnCallback != "function") && (typeof fnCallback != "native function") )
		throw "invalid callback param";

	if ( typeof pContext != "string" )
		throw "invalid context param";

	if ( typeof szEventname != "string" )
		throw "invalid eventname param";

	if ( !m_pListeners )
		m_pListeners = {};

	if ( !(szEventname in m_pListeners) )
		m_pListeners[szEventname] <- {};

	local pListener = m_pListeners[szEventname];
	if ( !(pContext in pListener) )
		pListener[pContext] <- null;

	local p = pListener[pContext];
	if ( !p )
	{
		// library functions are synchronous
		if ( pContext == "VS::Events" )
		{
			s_fnSynchronous = fnCallback;
		}
		else
		{
			s_fnSynchronous = null;
		};

		if ( !(p = SpawnEntity( szEventname )) )
			return Msg("VS::ListenToGameEvent: ERROR!!! NULL ent!\n");
		pListener[pContext] = p.weakref();

		if ( s_fnSynchronous )
		{
			s_fnSynchronous = null;
			return;
		};
	};

	local sc = p.GetScriptScope();
	sc.OnEventFired <- function() : (fnCallback)
	{
		return fnCallback( event_data );
	}
}.bindenv( VS.Events );


VS.StopListeningToAllGameEvents <- function( context ) : (__RemovePooledString)
{
	if ( m_pListeners )
	{
		foreach( listener in m_pListeners )
		{
			if ( context in listener )
			{
				local p = listener[context];
				if ( p && (typeof p == "instance") && p.IsValid() )
				{
					__RemovePooledString( "OnEventFired "+p.GetName()+",CallScriptFunction,OnEventFired" );
					p.Destroy();
				};
				delete listener[context];
				// Msg( "Stopped listening to [" + context + "]" + eventname + "\n" );
			}
		}
	}
}.bindenv( VS.Events );


local __ExecutePreSpawn = delete VS.Events.__ExecutePreSpawn;
local __FinishSpawn = delete VS.Events.__FinishSpawn;
local PostSpawn = delete VS.Events.PostSpawn;
local OnPostSpawn = delete VS.Events.OnPostSpawn;

function VS::Events::InitTemplate( scope )
	: (__ExecutePreSpawn, __FinishSpawn, PostSpawn, OnPostSpawn)
{
	local self;
	if ( !("self" in scope) || !(self = scope.self) ||
		!self.IsValid() || self.GetClassname() != "point_template" )
		throw "VS::Events::InitTemplate: invalid entity";

	self.__KeyValueFromInt( "spawnflags", 0 );
	self.__KeyValueFromString( "targetname", "vs.eventlistener" );
	scope.__EntityMakerResult <- null;
	scope.__ExecutePreSpawn <- __ExecutePreSpawn;
	scope.__FinishSpawn <- __FinishSpawn;
	scope.PreSpawnInstance <- 1;
	scope.PostSpawn <- PostSpawn;
	scope.OnPostSpawn <- OnPostSpawn.bindenv(scope);
}
