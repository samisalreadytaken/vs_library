//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//- v1.0.4 --------------------------------------------------------------
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
		hView.SetFov( iFOV, flSpeed );
		hView.SetOwner( null );
		return hView;
	}

	::SetPlayerFOV <- function( hPlayer, iFOV, flSpeed = 0.0 ) : (m_list, AddEvent, DoSetFOV)
	{
		local hView;

		if( !hPlayer || !hPlayer.IsValid() || hPlayer.GetClassname() != "player" )
			return;

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
			foreach( h in m_list )
				if( h && !h.GetOwner() )
				{
					hView = h;
					break;
				};;
		};

		if( hView )
		{
			if( !iFOV )
			{
				return DoSetFOV( hView, 0, flSpeed );
			};
		}
		else
		{
			// SF 0 makes the transition smooth; 7 overrides existing view owner, if exists
			hView = ::VS.CreateEntity( "point_viewcontrol",
			{
				spawnflags = (1<<0)|(1<<7),
				effects    = (1<<5),
				movetype   = 8,
				renderamt  = 0,
				rendermode = 10 // 2
			},true );
			m_list.insert( m_list.len(), hView.weakref() );
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
