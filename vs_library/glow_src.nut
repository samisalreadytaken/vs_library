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
//
//-----------------------------------------------------------------------

if(!("Glow" in ::getroottable()) || typeof::Glow != "table" || !("Set" in ::Glow))
{
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
		function Set(src,color,style,dist)
		{
			local glow = Get(src);

			if(glow)
			{
				::print("Glow::Set: Found linked glow, updating.\n");
			}
			else
			{
				foreach( e in _list ) if( e.IsValid() )
				{
					local p = e.GetMoveParent();
					if( !p || !p.IsValid() )
					{
						glow = e;
						break;
					};
				};

				if(glow)
				{
					glow.SetModel(src.GetModelName());
				}
				else
				{
					glow = ::CreateProp("prop_dynamic_glow", src.GetOrigin(), src.GetModelName(), 0);
					_list.append(glow);
				};

				::VS.SetKeyInt(glow, "rendermode", 6);
				::VS.SetKeyInt(glow, "renderamt", 0);
				::VS.SetParent(glow, src);
				::VS.MakePermanent(glow);
			};

			if( typeof color == "string" )
				::VS.SetKeyString(glow, "glowcolor", color);
			else if( typeof color == "Vector" )
				::VS.SetKeyVector(glow, "glowcolor", color);
			else throw "parameter 2 has an invalid type '" + typeof color + "' ; expected 'string|Vector'";;
			::VS.SetKeyInt(glow, "glowstyle", style);
			::VS.SetKeyInt(glow, "glowdist", dist);
			::VS.SetKeyInt(glow, "glowenabled", 1);
			::VS.SetKeyInt(glow, "effects", EF_DEFAULT);

			return glow;
		}

		//-----------------------------------------------------------------------
		// Disable and unlink if src has glow linked with it
		//
		// Input  : handle src_ent
		// Output : handle glow_ent
		//-----------------------------------------------------------------------
		function Disable(src)
		{
			local glow = Get(src);

			if(glow)
			{
				::VS.SetKeyInt(glow, "effects", EF_DEFAULT|EF_NODRAW);
				::VS.SetParent(glow, null);
				::EntFireByHandle(glow,"setglowdisabled");
			}
			else
			{
				::print("Glow::Disable: No glow found.\n");
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

			foreach( i,p in _list ) if( p.IsValid() )
			{
				if( p.GetMoveParent() == src )
					return p;
			}
			else _list.remove(i);

		// old algorithm, looks through children
		// doesn't work when glow props are made permanent, because
		// when entities are reset, movement hierarchies are also reset
		//	local p, i = src.FirstMoveChild();
		//	do
		//	{
		//		foreach( e in _list ) if( e == i )
		//			return i;
		//		if( p == i ) break;
		//		p = i;
		//	} while( i.NextMovePeer() )
		}

		EF_DEFAULT = (1<<0|1<<11)|1<<14,
		EF_NODRAW = 1<<5,
		_list = []
	}
};;
