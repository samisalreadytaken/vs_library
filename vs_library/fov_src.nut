//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//- v1.0.3 --------------------------------------------------------------
//
// ::SetPlayerFOV( hPlayer, iFOV, flSpeed = 0 )
//

IncludeScript("vs_library");

if ( !("SetPlayerFOV" in ::getroottable()) || typeof::SetPlayerFOV != "function" )
{
	local m_list = [];
	local AddEvent = ::DoEntFireByInstanceHandle;
	local DoSetFOV = function( hView, iFOV, flSpeed )
	{
		return hView.SetFov( iFOV, flSpeed );
	}

	::SetPlayerFOV <- function( hPlayer, iFOV, flSpeed = 0.0 ) : (m_list, AddEvent, DoSetFOV)
	{
		local hView;

		if( !hPlayer || hPlayer.GetClassname() != "player" )
			throw "SetPlayerFOV: Invalid source entity";

		for( local i = m_list.len(); i--; )
		{
			local h = m_list[i];
			if(h)
			{
				if( h.GetOwner() == hPlayer )
				{
					hView = h;
					break;
				};
			}
			else m_list.remove(i);
		}

		if( !hView )
		{
			foreach( h in m_list ) if(h)
				if( !h.GetOwner() )
				{
					hView = h;
					break;
				};;
		};

		if( hView )
		{
			if( !iFOV )
			{
				hView.SetFov( 0, flSpeed );
				hView.SetOwner( null );
				return;
			};
		}
		else
		{
			// 0 makes the transition smooth; 7 overrides existing view owner, if exists
			hView = ::VS.CreateEntity( "point_viewcontrol",
			{
				spawnflags = (1<<0)|(1<<7)
				effects    = (1<<5),
				movetype   = 8,
				renderamt  = 0,
				rendermode = 10 // 2
			},true );
			m_list.append( hView.weakref() );
		};

		// This script takes advantage of how hViewEntity->m_hPlayer is not
		// nullified on disabling, and how ScriptSetFov() only calls pPlayer->SetFOV()
		hView.SetOwner( hPlayer );
		AddEvent( hView, "Enable", "", 0.0, hPlayer, null );
		AddEvent( hView, "Disable", "", 0.0, hPlayer, null );
		::VS.EventQueue.AddEvent( DoSetFOV, 0.0, [ null, hView, iFOV, flSpeed ] );

		return hView;
	}
};;
