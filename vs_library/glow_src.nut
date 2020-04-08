//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------
//
// Easy glow handling library.
// Can be used on any entity that has a model.
//
//    Glow.Set(player, "255 138 0", 1, 2048)
//    Glow.Disable(player)
//    Glow.Enable(player)
//
//-----------------------------------------------------------------------

if("Glow" in ::getroottable())
	if(typeof::Glow == "table")
		if("Set" in ::Glow)
			return;;;;

::Glow <-
{
	//-----------------------------------------------------------------------
	// Set glow. Update if src already has a linked glow. Enable if disabled.
	//
	// Input  : handle src_ent
	//          string/Vector colour
	//          int style: 0 (Default (through walls))
	//                     1 (Shimmer (doesn't glow through walls))
	//                     2 (Outline (doesn't glow through walls))
	//                     3 (Outline Pulse (doesn't glow through walls))
	//          float distance
	// Output : handle glow_ent
	//-----------------------------------------------------------------------
	function Set(src,color,style,dist)
	{
		local glow = Get(src);

		if(glow)
		{
			::print("Glow.Set: Entity already has a linked glow; enabling.\n");
		}
		else
		{
			// if there is any not in use, choose it
			while( glow = ::Ent(_NAME_,glow) )
			{
				local p = glow.GetMoveParent();
				if( !p || !p.IsValid() )
					break;
			}

			if(glow)
			{
				glow.SetModel(src.GetModelName());
			}
			else
			{
				glow = ::CreateProp("prop_dynamic_glow", src.GetOrigin(), src.GetModelName(), 0);
				::VS.SetName(glow,_NAME_);
			};

			::VS.SetKeyInt(glow, "rendermode", 6);
			::VS.SetKeyInt(glow, "renderamt", 0);
			::VS.SetParent(glow, src);
			::VS.MakePermanent(glow);
		};

		::Assert(glow.GetName() == _NAME_);

		::VS.SetKeyInt(glow, "glowstyle", style);
		::VS.SetKeyInt(glow, "glowdist", dist);
		::VS.SetKey(glow, "glowcolor", color);
		::VS.SetKeyInt(glow, "glowenabled", 1);
		::VS.SetKeyInt(glow, "effects", EF_DEFAULT);

		return glow;
	}

	//-----------------------------------------------------------------------
	// Enable if src has glow linked with it
	//
	// Input  : handle src_ent
	// Output : handle glow_ent
	//-----------------------------------------------------------------------
	function Enable(src)
	{
		local glow = Get(src);

		if( glow )
		{
			::VS.SetKeyInt(glow, "effects", EF_DEFAULT);
			::VS.SetKeyInt(glow, "glowenabled", 1);
		}
		else
		{
			::print("Glow.Enable: No glow found.\n");
		};

		return glow;
	}

	//-----------------------------------------------------------------------
	// Disable and unlink if src has glow linked with it
	//
	// Input  : handle src_ent
	//          bool free_ent
	// Output : handle glow_ent
	//-----------------------------------------------------------------------
	function Disable(src)
	{
		local glow = Get(src);

		if( glow )
		{
			::VS.SetKeyInt(glow, "effects", EF_DEFAULT|EF_NODRAW);
			::VS.SetParent(glow, null);
			::EntFireByHandle(glow,"setglowdisabled");
		}
		else
		{
			::print("Glow.Disable: No glow found.\n");
		};

		return glow;
	}

	//-----------------------------------------------------------------------
	// Get the linked glow entity. null if none
	//
	// Input  : handle src_ent
	// Output : handle glow_ent
	//-----------------------------------------------------------------------
	function Get(src)
	{
		if( ::VS.IsPointSized(src) || !src.GetModelName().len() )
			throw "Glow: Invalid source entity";

		local p;
		while( p = ::Ent(_NAME_,p) )
			if( p.GetMoveParent() == src )
				return p;

	// old algorithm, looks through children
	// doesn't work when glow props are perm'd, because
	// when entities are being reset, movement hierarchies are also reset
	//	local p, i = src.FirstMoveChild();
	//	do
	//	{
	//		if( i.GetName() == _NAME_ )
	//			return i;
	//		if( p == i ) break;
	//		p = i;
	//	} while( i.NextMovePeer() )
	}

	_NAME_ = "vs.glow",
	EF_DEFAULT = (1<<0|1<<11)|1<<14,
	EF_NODRAW = 1<<5
}
