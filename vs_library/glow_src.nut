//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//- v1.0.8 --------------------------------------------------------------
//
// Easy glow handling library.
// Can be used on any entity that has a model.
//
// ::Glow.Set( hPlayer, color, nType, flDistance )
// ::Glow.Disable( hPlayer )
//
// ::Glow.DEBUG = true
//

IncludeScript("vs_library");

if( !("Glow" in ::getroottable()) || typeof::Glow != "table" || !("Set" in ::Glow) )
{
	local AddEvent = ::DoEntFireByInstanceHandle;
	local Create = ::CreateProp;

	::Glow <-
	{
		//-----------------------------------------------------------------------
		// Set glow. Update if src already has a linked glow.
		//
		// Input  : handle src_ent
		//          string|Vector colour
		//          int style: 0 (Default (through walls))
		//                     1 (Shimmer (doesn't glow through walls))
		//                     2 (Outline (doesn't glow through walls))
		//                     3 (Outline Pulse (doesn't glow through walls))
		//          float distance
		// Output : handle glow_ent
		//-----------------------------------------------------------------------
		function Set( src, color, style, dist ) : (Create)
		{
			local glow = Get(src);

			if (glow)
			{
				if (DEBUG) Msg("Glow::Set: Updating glow ["+src.entindex()+"]\n");
			}
			else
			{
				if (DEBUG) Msg("Glow::Set: Setting glow ["+src.entindex()+"]\n");

				foreach( e in m_list ) if(e)
					if( !e.GetMoveParent() )
					{
						glow = e;
						break;
					};;

				if (glow)
				{
					glow.SetModel( src.GetModelName() );
				}
				else
				{
					glow = Create( "prop_dynamic_glow", src.GetOrigin(), src.GetModelName(), 0 );
					m_list.append( glow.weakref() );
				};

				glow.__KeyValueFromInt( "rendermode", 6 );
				glow.__KeyValueFromInt( "renderamt", 0 );
				::VS.SetParent( glow, src );
				::VS.MakePersistent( glow );
			};

			if( typeof color == "string" )
				glow.__KeyValueFromString( "glowcolor", color );
			else if( typeof color == "Vector" )
				glow.__KeyValueFromVector( "glowcolor", color );
			else throw "parameter 2 has an invalid type '" + typeof color + "' ; expected 'string|Vector'";;
			glow.__KeyValueFromInt( "glowstyle", style );
			glow.__KeyValueFromFloat( "glowdist", dist );
			glow.__KeyValueFromInt( "glowenabled", 1 );
			glow.__KeyValueFromInt( "effects", 18433 ); // EF_DEFAULT

			return glow;
		}

		//-----------------------------------------------------------------------
		// Disable and unlink if src has glow linked with it
		//
		// Input  : handle src_ent
		// Output : handle glow_ent
		//-----------------------------------------------------------------------
		function Disable( src ) : (AddEvent)
		{
			local glow = Get(src);

			if (glow)
			{
				glow.__KeyValueFromInt( "effects", 18465 ); // EF_DEFAULT|EF_NODRAW
				::VS.SetParent( glow, null );
				AddEvent( glow, "SetGlowDisabled", "", 0.0, null, null );
				// glow.SetAbsOrigin(MAX_COORD_VEC);

				if (DEBUG) Msg("Glow::Disable: Disabled glow ["+src.entindex()+"]\n");
			}
			else
			{
				if (DEBUG) Msg("Glow::Disable: No glow found ["+src.entindex()+"]\n");
			};

			return glow;
		}

		//-----------------------------------------------------------------------
		// Get the linked glow entity. null if none
		//
		// Input  : handle src_ent
		// Output : handle glow_ent
		//-----------------------------------------------------------------------
		function Get( src )
		{
			if( !src || !src.GetModelName().len() )
				throw "Glow: Invalid source entity";

			for( local i = m_list.len(); i--; )
			{
				local g = m_list[i];
				if (g)
				{
					if( g.GetMoveParent() == src )
						return g;
				}
				else m_list.remove(i);
			}
		}

		// MAX_COORD_VEC = Vector(MAX_COORD_FLOAT-1,MAX_COORD_FLOAT-1,MAX_COORD_FLOAT-1);
		// EF_DEFAULT = (1<<0)|(1<<11)|(1<<14),
		// EF_NODRAW = (1<<5),
		Msg = ::print,
		DEBUG = false,
		m_list = []
	}
};;
