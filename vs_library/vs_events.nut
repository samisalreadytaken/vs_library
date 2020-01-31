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
// For vs_library documentation, see
//  	https://github.com/samisalreadytaken/vs_library/blob/master/Documentation.md
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
function VS::Events::player_connect(data)
{
	if(::_xa9b2dfB7ffe.len()>128)
	{
		for(local i=0;i<64;i++)::_xa9b2dfB7ffe.remove(0)
		::Msg("[player_connect] ERROR!!! Player data is not being processed.")
	}
	::_xa9b2dfB7ffe.append(data)

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
		{
			::Msg("[player_connect] Invalid player entity.\n")
			break
		}

		local scope = player.GetScriptScope()

		if( "networkid" in scope )
		{
			::Msg("[player_connect] BUG!!! Something has gone wrong. "+(scope.networkid==d.networkid?"Duplicated data!":"Conflicting data!")+"\n")
			break
		}

		if( !d.networkid.len() )
			::Msg("[player_connect] could not get event data.\n")

		scope.userid <- d.userid
		scope.name <- d.name
		scope.networkid <- d.networkid
		::_xa9b2dfB7ffe.remove(i)
		return::OnGameEvent_player_spawn(data); // break
	}

	return::OnGameEvent_player_spawn(data)
}
