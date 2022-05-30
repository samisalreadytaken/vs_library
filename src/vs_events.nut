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

local OnPlayerBan = function( event )
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

local ValidateUserid = function( ent ) : ( AddEvent, Fmt, Entities )
{
	if ( !ent || !ent.IsValid() || (ent.GetClassname() != "player") || !ent.ValidateScriptScope() )
		return Msg(Fmt( "VS::ValidateUserid: invalid input: %s\n", ""+ent ));

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
	// in the same frame this function is called

	if ( !m_hProxy )
	{
		local h = Entities.CreateByClassname( "info_game_event_proxy" );
		h.__KeyValueFromString( "event_name", "player_connect" );
		MakePersistent( h );
		m_hProxy = h.weakref();
	};

	return AddEvent( m_hProxy, "GenerateGameEvent", "", 0, ent, null );
}.bindenv( VS.Events );

// gross hack
local __RemovePooledString = function(sz)
{
	__rem = sz;
	m_pSpawner.SpawnEntity();
	__rem = null;
}.bindenv( VS.Events );

local SpawnEntity = function( eventname ) : (Entities)
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
		return pEnt.Destroy();
	};

	if ( !vs.s_szEventName )
	{
		Msg( "VS::Events::PreSpawn: invalid call origin\n" );
		return pEnt.Destroy();
	};

	pEnt.__KeyValueFromString( "targetname", "" );
	pEnt.__KeyValueFromString( "EventName", vs.s_szEventName );
	pEnt.__KeyValueFromInt( "FetchEventData", 1 );
	pEnt.__KeyValueFromInt( "IsEnabled", 1 );
	pEnt.__KeyValueFromInt( "TeamNum", -1 );

	__EntityMakerResult = { [""] = null }
}

local __FinishSpawn = function()
{
	__EntityMakerResult = null;
}

local PostSpawn = function( pp )
{
	local ent = pp[""];

		s_hListener = ent;
		MakePersistent(ent);

		ent.ValidateScriptScope();
		local sc = ent.GetScriptScope();

		delegate delegate delegate sc.parent :
		{
			_delslot = function( k )
			{
				delete parent.parent[k];
			}
		} : {
			_newslot = null,
			["{7D6E9A}"] = null
		} : sc;

		sc.rawdelete("event_data");

		if ( !s_fnSynchronous )
		{
			local cache = [];
			if ( !m_ppCache )
				m_ppCache = [];
			m_ppCache.append( cache.weakref() );

			sc.parent._newslot = function( k, v ) : (cache)
			{
				if ( k == "event_data" )
					return cache.insert( 0, v );
				return rawset( k, v );
			}

			sc.parent._get <- function( k ) : (cache)
			{
				if ( k == "event_data" )
					return cache.pop();
				return rawget(k);
			}

			local name = sc.__vname;

			// naming it with the event name and UID makes debugging easier
			local i = name.find("_");
			name = s_szEventName + "_" + name.slice( 0, i );

			ent.__KeyValueFromString( "targetname", name );
			ent.__KeyValueFromString( "OnEventFired", name+",CallScriptFunction," );
			sc[""] <- null;
		};

}.bindenv( VS.Events );

local OnPostSpawn = function() : (__RemovePooledString, OnPlayerConnect, OnPlayerSpawn, OnPlayerBan, ValidateUserid)
{
	local VS = VS;

	if ( !VS.Events.m_bFixedUp )
	{
		VS.Events.m_bFixedUp = true;
		Msg( "VS::Events init '"+VS.version+"'\n" );

		VS.StopListeningToAllGameEvents( "VS::Events" );

		VS.ListenToGameEvent( "player_connect", OnPlayerConnect, "VS::Events" );
		VS.ListenToGameEvent( "player_spawn", OnPlayerSpawn, "VS::Events" );
		VS.ListenToGameEvent( "server_addban", OnPlayerBan, "VS::Events" );

		VS.ListenToGameEvent( "player_activate", function(ev) : (ValidateUserid)
		{
			foreach( i, v in GetAllPlayers() )
			{
				local t = v.GetScriptScope();
				if ( !("userid" in t) || t.userid == -1 )
					ValidateUserid( v );
			}
		}.bindenv(VS), "VS::Events" );

		if ( VS.Events.m_DeferredReg )
		{
			foreach ( p in VS.Events.m_DeferredReg )
				VS.ListenToGameEvent.pacall(p);
			VS.Events.m_DeferredReg = null;
		};
	};

	// Clear the cache on round start
	local players = VS.Events.m_Players;
	if ( players && players.len() )
	{
		local t = [];

		foreach ( k, v in players )
			if ( !v || !v.IsValid() )
				t.append(k);

		foreach ( v in t )
			delete players[v];
	};

	if ( VS.Events.__tmp )
		__RemovePooledString( VS.Events.__tmp );
	VS.Events.__tmp = __vname;
}

VS.ListenToGameEvent <- function( szEventName, fnCallback, pContext, bSynchronous = 0 ) : (SpawnEntity)
{
	local err, paramCount;

	if ( (typeof fnCallback != "function") && (typeof fnCallback != "native function") )
	{
		err = "invalid callback param";
	}
	else
	{
		paramCount = fnCallback.getinfos().parameters.len();

		if ( paramCount != 2 && paramCount != 1 )
			err = "invalid callback param: wrong number of parameters";
	};

	if ( typeof pContext != "string" )
		err = "invalid context param";

	if ( typeof szEventName != "string" )
		err = "invalid eventname param";

	if ( err )
	{
		Msg(format( "\nAN ERROR HAS OCCURED [%s]\n", err ));
		return PrintStack();
	};

	if ( !m_pListeners )
		m_pListeners = {};

	if ( !(szEventName in m_pListeners) )
		m_pListeners[szEventName] <- {};

	local pListener = m_pListeners[szEventName];
	if ( !(pContext in pListener) )
		pListener[pContext] <- null;

	if ( !m_bFixedUp )
	{
		// Defer registration to fix events not registering on initial server launch.

		if ( !m_DeferredReg )
			m_DeferredReg = [];
		m_DeferredReg.append( [this, szEventName, fnCallback, pContext, bSynchronous] );

		//Msg(Fmt( "VS::ListenToGameEvent: defer %s:%s\n", szEventName, pContext ));
		return;
	};

	local p = pListener[pContext];
	if ( !p || !p.IsValid() )
	{
		// library functions are synchronous
		if ( bSynchronous || pContext == "VS::Events" )
		{
			s_fnSynchronous = fnCallback;
		}
		else
		{
			s_fnSynchronous = null;
		};

		if ( !(p = SpawnEntity( szEventName )) )
			return Msg("VS::ListenToGameEvent: ERROR!!! NULL ent!\n");

		pListener[pContext] = p.weakref();

		if ( s_fnSynchronous )
		{
			s_fnSynchronous = null;

			if ( pContext == "VS::Events" )
			{
				p.GetScriptScope().parent._newslot = function( k, v ) : (fnCallback)
				{
					if ( k == "event_data" )
						return fnCallback(v);
				}
				return;
			};
		};
	};

	local sc = p.GetScriptScope();

	if ( !!bSynchronous == sc.parent.rawin("_get") )
	{
		Msg( "VS::ListenToGameEvent: changing synchronicity of "+szEventName+":"+pContext+"\n" );
		p.Destroy();
		return ListenToGameEvent( szEventName, fnCallback, pContext, bSynchronous );
	};

	if ( !bSynchronous )
	{
		// Support for parameterless event callback.
		// Useful if the event does not contain any data or the user is not interested in it.
		if ( paramCount == 1 )
		{
			sc[""] = fnCallback;
		}
		else
		{
			sc[""] = function() : (fnCallback) return fnCallback( event_data );
		};
	}
	else
	{
		if ( paramCount == 1 )
		{
			sc.parent._newslot = function( k, v ) : (fnCallback, szEventName, pContext)
			{
				if ( k == "event_data" )
					try fnCallback() catch(x)
						return print(format( "\nAN ERROR HAS OCCURED [%s] ON EVENT [%s:%s]\n\n", x, szEventName, pContext ));
				// else return rawset( k, v );
			}
		}
		else
		{
			sc.parent._newslot = function( k, v ) : (fnCallback, szEventName, pContext)
			{
				if ( k == "event_data" )
					try fnCallback(v) catch(x)
						return print(format( "\nAN ERROR HAS OCCURED [%s] ON EVENT [%s:%s]\n\n", x, szEventName, pContext ));
				// else return rawset( k, v );
			}
		};
	};
}.bindenv( VS.Events );

VS.StopListeningToAllGameEvents <- function( context ) : (dummy)
{
	if ( m_pListeners )
	{
		foreach( listener in m_pListeners )
		{
			if ( context in listener )
			{
				local p = listener[context];
				if ( (typeof p == "instance") && p.IsValid() )
				{
					// UTIL_Remove is not immediate, this event can still fire until it is removed.
					p.GetScriptScope().parent._newslot = dummy;
					p.Destroy();
				};
				delete listener[context];
				// Msg(Fmt( "Stopped listening to %s:%s\n", eventname, context ));
			}
		}
	}
}.bindenv( VS.Events );

VS.Events.DumpListeners <- function()
{
	if ( m_pListeners && m_pListeners.len() )
	{
		local list = [];
		foreach ( eventname, listener in m_pListeners )
			list.append( eventname );

		list.sort();
		local Fmt = format;
		foreach ( eventname in list )
		{
			local listener = m_pListeners[eventname];
			foreach ( context, p in listener )
			{
				if ( context != "VS::Events" )
				{
					if ( p && (typeof p == "instance") && p.IsValid() )
					{
						Msg(Fmt( "  %-32.32s  | %-32.64s |  '%.64s'\n", eventname, context, p.GetName() ));
					}
					else
					{
						Msg(Fmt( "  %-32.32s  | %-32.64s |  <null>\n", eventname, context ));
					};
				};
			}
		}
	}
}.bindenv( VS.Events );

VS.Events.InitTemplate <- function( scope )
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
					foreach ( kk,vv in v )
					{
						Msg( "\t{\n" );
						foreach ( kkk, vvv in vv )
							Msg(format( "\t\t%s : %s\n", ""+kkk, ""+vvv ));
						Msg( "\t}\n" );
					}
					Msg( "}\n" );
				};
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
