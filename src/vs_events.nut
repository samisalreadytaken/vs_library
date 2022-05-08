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
	m_ppCache = null,
	m_pSpawner = null,
	m_pListeners = null,
	s_szEventName = null,
	s_hListener = null,
	s_fnSynchronous = null,
	__rem = null,
	__tmp = null,

	m_DeferredReg = null,

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

	if ( userid in m_Players )
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

local OnPlayerConnect = function( event ) : ( gEventData, ROOT, SendToConsole )
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
			Msg( "VS::OnPlayerConnect: ERROR!!! Player data is not being processed\n" );
		};

		gEventData[idx] = event;
		return;
	};

	if ( m_SV )
	{
		local sc = m_SV.remove(0);
		if ( !sc || !("self" in sc) )
			return Msg("VS::Events: invalid scope in validation\n");

		if ( !sc.__vrefs || !sc.self || !sc.self.IsValid() )
			return Msg("VS::Events: invalid entity in validation\n");

		if ( "userid" in sc && sc.userid != event.userid && sc.userid != -1 )
		{
			Msg("VS::Events: ERROR!!! conflict! ["+ sc.userid +", "+ event.userid +"]\n");

			// if (sc.userid == -1) then ToExtendedPlayer() was called before the player was spawned
			// where the player was connected before map change.
		};

		if ( event.userid in m_Players && m_Players[event.userid] != sc.self )
		{
			Msg("VS::Events: ERROR!!! conflict! ["+ sc.self +", "+ m_Players[event.userid] +"]\n");
		};

		sc.userid <- event.userid;

		if ( !("name" in sc) )
			sc.name <- "";
		if ( !("networkid" in sc) )
			sc.networkid <- "";

		// 'banid' is not whitelisted. SendToConsoleServer always checks the whitelist,
		// point_servercommand checks it when the server is not listen server.
		// Try ClientCommand to see if it's a listen server, then fetch the networkid.
		// ban for 3 seconds, no kick. min duration is 0.01
		// Command is invalid in sv_lan 1 servers.
		SendToConsole( "banid 0.05 " + event.userid );

		// finished the queue
		if ( !(0 in m_SV) )
			m_SV = null;
	}
}.bindenv( VS.Events );

VS.Events.OnPlayerBan <- function( event )
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

	if ( sc.name != "" && sc.name != event.name )
		Msg(format( "VS::Events: validation: [%d] overwriting name '%s' -> '%s'\n", event.userid, sc.name, event.name ));

	if ( sc.networkid != "" && sc.networkid != event.networkid )
		Msg(format( "VS::Events: validation: [%d] overwriting networkid '%s' -> '%s'\n", event.userid, sc.networkid, event.networkid ));

	sc.name = event.name;
	sc.networkid = event.networkid;

}.bindenv( VS.Events );

local OnPlayerSpawn = function( event ) : ( gEventData, Fmt, ROOT )
{
	foreach( i, data in gEventData )
	{
		if ( !data )
			return;

		if ( data.userid == event.userid )
		{
			local player = GetPlayerByIndex( data.index+1 );

			if ( !player || !player.ValidateScriptScope() )
			{
				gEventData[i] = null;
				Msg( "VS::OnPlayerConnect: invalid player entity [" + data.userid + "] [" + (data.index+1) + "]\n" );
				return;
			};

			local scope = player.GetScriptScope();

			if ( "networkid" in scope &&
				scope.networkid != "" ) // if the existing networkid is empty, fall through and update
			{
				Msg("VS::OnPlayerConnect: ERROR!!! Something has gone wrong! ");

				if ( scope.networkid == data.networkid )
				{
					gEventData[i] = null;
					Msg(Fmt( "Duplicated data. [%d]\n", data.userid ));
				}
				else
				{
					Msg(Fmt( "Conflicting data. [%d] ('%s', '%s')\n", data.userid, scope.networkid, data.networkid ));
				};
				return;
			};

			scope.userid <- data.userid;
			scope.name <- data.name;
			scope.networkid <- data.networkid;
			gEventData[i] = null;

			// remove gaps if the listener was not fixed up
			gEventData.sort();
			// default sort puts null before instances, reverse it
			gEventData.reverse();

			return;
		};
	}
}.bindenv( VS.Events );

//
// Deprecated. Manual calls to this are not necessary.
//
VS.ForceValidateUserid <- function( ent, internal = 0 ) : ( AddEvent, Fmt, Entities )
{
	if ( !internal )
		Msg("Warning: VS::ForceValidateUserid is deprecated!\n");

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
	// UNDONE: fail condition when the event queue is reset
	// in the same frame VS.ForceValidateUserid is called

	if ( !m_hProxy )
	{
		local h = Entities.CreateByClassname( "info_game_event_proxy" );
		h.__KeyValueFromString( "event_name", "player_connect" );
		MakePersistent( h );
		m_hProxy = h.weakref();
	};

	return AddEvent( m_hProxy, "GenerateGameEvent", "", 0, ent, null );
}.bindenv( VS.Events );

//
// Deprecated. Manual calls to this are not necessary.
//
function VS::ValidateUseridAll()
{
	Msg("Warning: VS::ValidateUseridAll is deprecated!\n");

	if ( Events.m_bFixedUp )
	{
		foreach( i, v in GetAllPlayers() )
			if ( !("userid" in v.GetScriptScope()) )
				ForceValidateUserid( v );
	}
	// fallback and force validate even though there will be other issues
	else
	{
		Msg( "Warning: VS::ValidateUseridAll: incorrect eventlistener setup!\n" );

		local t = ::FrameTime();
		foreach( i, v in GetAllPlayers() )
			DoEntFireByInstanceHandle( v, "RunScriptCode", "VS.ForceValidateUserid(self)", i * t, v, v );
	};
}

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

	if ( !m_ppCache )
		m_ppCache = [];
	m_ppCache.append( cache.weakref() );

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
				// No error handler, cannot call callbacks here.
				return cache.insert( 0, v );
			return rawset( k, v );
		},
		_get = function( k ) : (cache)
		{
			if ( k == "event_data" )
				return cache.pop();
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

function VS::Events::SpawnEntity( eventname ) : (Entities)
{
	if ( !m_pSpawner )
	{
		local p = Entities.CreateByClassname( "env_entity_maker" );
		p.__KeyValueFromString( "EntityTemplate", "vs.eventlistener" );
		MakePersistent( p );
		m_pSpawner = p.weakref();
	};
	s_szEventName = eventname;
	m_pSpawner.SpawnEntity();
	local r = s_hListener;
	s_szEventName = s_hListener = null;
	return r;
}

local __ExecutePreSpawn = function( pEnt )
{
	local vs = VS.Events;

	if ( vs.__rem )
	{
		pEnt.__KeyValueFromString( "targetname", vs.__rem );
		pEnt.__KeyValueFromString( "EventName", "player_connect" ); // suppress warnings
		pEnt.Destroy();
		return;
	};

	if ( !vs.s_szEventName )
	{
		pEnt.Destroy();
		return Msg( "VS::Events::PreSpawn: invalid call origin\n" );
	};

	pEnt.__KeyValueFromString( "EventName", vs.s_szEventName );
	pEnt.__KeyValueFromInt( "FetchEventData", 1 );
	pEnt.__KeyValueFromInt( "IsEnabled", 1 );
	pEnt.__KeyValueFromInt( "TeamNum", -1 );

	__EntityMakerResult = {}
}

local __FinishSpawn = function()
{
	__EntityMakerResult = null;
}

local PostSpawn = function( pEntities )
{
	foreach( ent in pEntities )
	{
		s_hListener = ent;
		FixupEventListener(ent);
		MakePersistent(ent);
		local sc = ent.GetScriptScope();

		// asynchronous callbacks
		if ( !s_fnSynchronous )
		{
			// naming it with the event name and UID makes debugging easier
			local name = sc.__vname;
			local i = name.find("_");
			name = s_szEventName + "_" + name.slice( 0, i );
			SetName( ent, name );
			ent.__KeyValueFromString( "OnEventFired", name+",CallScriptFunction,OnEventFired" );
			sc.OnEventFired <- null;
		}
		// synchronous callbacks, not possible to dump call stack when exception is thrown
		else
		{
			m_ppCache.pop();

			SetName( ent, "" );
			delete sc.parent._get;
			sc.parent._newslot = function( k, v ) : (s_fnSynchronous)
			{
				if ( k == "event_data" )
					return s_fnSynchronous(v);
				return rawset( k, v );
			}
		}
	}
}.bindenv( VS.Events );

local OnPostSpawn = function() : (__RemovePooledString, OnPlayerConnect, OnPlayerSpawn)
{
	local VS = VS;

	if ( !VS.Events.m_bFixedUp )
	{
		VS.Events.m_bFixedUp = true;
		Msg( "VS::Events init '"+VS.version+"'\n" );

		VS.StopListeningToAllGameEvents( "VS::Events" );

		VS.ListenToGameEvent( "player_connect", OnPlayerConnect, "VS::Events" );
		VS.ListenToGameEvent( "player_spawn", OnPlayerSpawn, "VS::Events" );
		VS.ListenToGameEvent( "server_addban", VS.Events.OnPlayerBan, "VS::Events" );

		VS.ListenToGameEvent( "player_activate", function(ev)
		{
			foreach( i, v in GetAllPlayers() )
			{
				local t = v.GetScriptScope();
				if ( !("userid" in t) || t.userid == -1 )
					ForceValidateUserid( v, 1 );
			}
		}.bindenv(VS), "VS::Events" );

		VS.ListenToGameEvent( "player_disconnect", function(ev)
		{
			if ( m_Players && ev.userid in m_Players )
			{
				delete m_Players[ev.userid];
			}
		}.bindenv( VS.Events ), "VS::Events" );

		if ( VS.Events.m_DeferredReg )
		{
			foreach ( p in VS.Events.m_DeferredReg )
				VS.ListenToGameEvent.pacall(p);
			VS.Events.m_DeferredReg = null;
		};
	};

	if ( VS.Events.__tmp )
		__RemovePooledString( VS.Events.__tmp );
	VS.Events.__tmp = __vname;
}

VS.ListenToGameEvent <- function( szEventname, fnCallback, pContext )
{
	local err;

	if ( (typeof fnCallback != "function") && (typeof fnCallback != "native function") )
		err = "invalid callback param";

	if ( typeof pContext != "string" )
		err = "invalid context param";

	if ( typeof szEventname != "string" )
		err = "invalid eventname param";

	if ( err )
	{
		Msg(format( "\nAN ERROR HAS OCCURED [%s]\n", err ));
		return PrintStack();
	};

	if ( !m_pListeners )
		m_pListeners = {};

	if ( !(szEventname in m_pListeners) )
		m_pListeners[szEventname] <- {};

	local pListener = m_pListeners[szEventname];
	if ( !(pContext in pListener) )
		pListener[pContext] <- null;

	if ( !m_bFixedUp )
	{
		// Defer registration to fix events not registering on initial server launch.

		if ( !m_DeferredReg )
			m_DeferredReg = [];
		m_DeferredReg.append( [this, szEventname, fnCallback, pContext] );

		return; //Msg("VS::ListenToGameEvent: defer {'"+pContext+"'}\n");
	};

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

	//local paramCount = fnCallback.getinfos().parameters.len();
	//if ( paramCount == 1 )
	//{
	//	sc.OnEventFired <- fnCallback;
	//}
	//else
	//{
		sc.OnEventFired <- function() : (fnCallback)
		{
			return fnCallback( event_data );
		}
	//};
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
					p.Destroy();
				};
				delete listener[context];
				// Msg( "Stopped listening to [" + context + "]" + eventname + "\n" );
			}
		}
	}
}.bindenv( VS.Events );

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
	// Mulitple callbacks are not supported to keep the purpose of the template entity simple.
	//if ( scope.OnPostSpawnCallChain.chain.find(OnPostSpawn) == null )
	//	scope.OnPostSpawnCallChain.chain.push( OnPostSpawn );
	scope.OnPostSpawn <- OnPostSpawn.bindenv(scope);

	// Clear game events that were not fired due to the
	// event queue being cleared on round start.
	// MapEntity_ParseAllEntities is called right after g_EventQueue.Clear()
	if ( m_ppCache )
	{
		for ( local i = m_ppCache.len(); i--; )
		{
			local v = m_ppCache[i];
			if ( v )
			{
#ifdef _DEBUG
				if ( v.len() )
				{
					Msg( "Discarding unhandled game event:\n{\n" );
					foreach ( k,vv in v )
						Msg(format( "\t%s : %s\n", k, ""+vv ));
					Msg( "}\n" );
				}
#endif
				v.clear();
			}
			else
			{
				m_ppCache.remove(i);
			}
		}
	};

	if ( "EventQueue" in VS )
	{
#ifdef _DEBUG
		VS.EventQueue.Dump();
#endif
		// NOTE: SetNameSafe calls from ToExtendedPlayer might also be removed if
		// they were called in an event that was cancelled.
		// This only results in temporary garbage targetnames on bots not being cleared. It's not harmful.
		VS.EventQueue.Clear();
	};
}
