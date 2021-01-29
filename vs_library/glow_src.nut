//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//- v1.0.9 --------------------------------------------------------------
//
// Easy glow handling library.
// Can be used on any entity that has a model.
//
// ::Glow.Set( hPlayer, color, nType, flDistance )
// ::Glow.Disable( hPlayer )
//

if ( !("Glow" in ::getroottable()) || typeof::Glow != "table" || !("Set" in ::Glow) )
{
	local AddEvent = "DoEntFireByInstanceHandle" in getroottable() ?
		DoEntFireByInstanceHandle : EntFireByHandle;
	local Create = ::CreateProp;
	local _list = [];

	::Glow <-
	{
		// EF_DEFAULT = (1<<0)|(1<<11)|(1<<14),
		// EF_NODRAW = (1<<5),
		m_list = _list,

		Get = null,
		Set = null,
		Disable = null
	}

	//-----------------------------------------------------------------------
	// Get the linked glow entity. null if none
	//
	// Input  : handle src_ent
	// Output : handle glow_ent
	//-----------------------------------------------------------------------
	function Glow::Get( src ) : ( _list )
	{
		if( !src || src.GetModelName() == "" )
			throw "Glow: Invalid source entity";

		for( local i = _list.len(); i--; )
		{
			local h = _list[i];
			if (h)
			{
				if( h.GetMoveParent() == src )
					return h;
			}
			else _list.remove(i);
		}
	}

	local Get = ::Glow.Get;

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
	function Glow::Set( src, color, style, dist ) : ( _list, AddEvent, Create, Get )
	{
		local glow = Get(src);

		if ( !glow )
		{
			foreach( v in _list )
				if( v && !v.GetMoveParent() )
				{
					glow = v;
					break;
				};

			if (glow)
			{
				glow.SetModel( src.GetModelName() );
			}
			else
			{
				glow = Create( "prop_dynamic_glow", src.GetOrigin(), src.GetModelName(), 0 );
				_list.insert( _list.len(), glow.weakref() );
			};

			glow.__KeyValueFromInt( "rendermode", 6 );
			glow.__KeyValueFromInt( "renderamt", 0 );

			// SetParent
			AddEvent( glow, "SetParent", "!activator", 0.0, src, null );

			// MakePersistent
			glow.__KeyValueFromString( "classname", "soundent" );
		};

		local o = typeof color;
		if( o == "string" )
			glow.__KeyValueFromString( "glowcolor", color );
		else if( o == "Vector" )
			glow.__KeyValueFromVector( "glowcolor", color );
		else throw "parameter 2 has an invalid type '" + o + "' ; expected 'string|Vector'";;
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
	function Glow::Disable( src ) : ( AddEvent, Get )
	{
		local glow = Get(src);

		if (glow)
		{
			glow.__KeyValueFromInt( "effects", 18465 ); // EF_DEFAULT|EF_NODRAW
			AddEvent( glow, "ClearParent", "", 0.0, null, null );
			AddEvent( glow, "SetGlowDisabled", "", 0.0, null, null );
			// glow.SetAbsOrigin( MAX_COORD_VEC );
		};

		return glow;
	}
};;
