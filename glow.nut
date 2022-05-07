//-----------------------------------------------------------------------
//                       github.com/samisalreadytaken
//- v1.0.12 -------------------------------------------------------------
//
// Easy glow handling (using prop_dynamic_glow entities).
// It can be used on any entity that has a model.
//
// Glow.Set( hPlayer, color, nType, flDistance )
// Glow.Disable( hPlayer )
//

if ( !("Glow" in ::getroottable()) || typeof ::Glow != "table" || !("Set" in ::Glow) )
{
	local AddEvent = "DoEntFireByInstanceHandle" in getroottable() ?
		DoEntFireByInstanceHandle : EntFireByHandle;
	local Create = CreateProp;
	local _list = [];

	//-----------------------------------------------------------------------
	// Get the linked glow entity. null if none
	//
	// Input  : handle src_ent
	// Output : handle glow_ent
	//-----------------------------------------------------------------------
	local Get = function( src ) : ( _list )
	{
		if ( !src || !src.IsValid() || src.GetModelName() == "" )
			return;

		for ( local i = _list.len(); i--; )
		{
			local v = _list[i];
			if (v)
			{
				if ( v.GetOwner() == src )
					return v;
			}
			else _list.remove(i);
		}
	}

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
	local Set = function( src, color, style, dist ) : ( _list, AddEvent, Create, Get )
	{
		local glow = Get(src);

		if ( !glow )
		{
			foreach( v in _list )
				if ( v && !v.GetOwner() )
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

			// synchronous link
			glow.SetOwner( src );

			// MakePersistent
			glow.__KeyValueFromString( "classname", "soundent" );
		};

		switch ( typeof color )
		{
			case "string":
				glow.__KeyValueFromString( "glowcolor", color );
				break;
			case "Vector":
				glow.__KeyValueFromVector( "glowcolor", color );
				break;
			default:
				throw "parameter 2 has an invalid type '" + typeof color + "' ; expected 'string|Vector'";;
		}

		glow.__KeyValueFromInt( "glowstyle", style );
		glow.__KeyValueFromFloat( "glowdist", dist );
		glow.__KeyValueFromInt( "glowenabled", 1 );
		glow.__KeyValueFromInt( "effects", 18561 ); // (1<<0)|(1<<7)|(1<<11)|(1<<14)

		// Enable again asynchronously in case a Disable input was fired to this glow in this frame,
		// as disabling is not synchronous (clients need to have received the disable msg first,
		// which has to be via the input).
		AddEvent( glow, "SetGlowEnabled", "", 0.1, null, null );

		return glow;
	}

	//-----------------------------------------------------------------------
	// Disable and unlink if src has glow linked with it
	//
	// Input  : handle src_ent
	// Output : handle glow_ent
	//-----------------------------------------------------------------------
	local Disable = function( src ) : ( AddEvent, Get )
	{
		local glow = Get(src);

		if (glow)
		{
			glow.__KeyValueFromInt( "effects", 18593 ); // AddEffects( EF_NODRAW )
			AddEvent( glow, "SetParent", "", 0.0, null, null );
			AddEvent( glow, "SetGlowDisabled", "", 0.0, null, null );
			glow.SetOwner( null );
		};

		return glow;
	}

	::Glow <-
	{
		m_list = _list,

		Get = Get,
		Set = Set,
		Disable = Disable
	}
};;
