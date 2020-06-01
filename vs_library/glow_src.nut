//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//- v1.0.6 --------------------------------------------------------------
//
// Easy glow handling library.
// Can be used on any entity that has a model.
//
//    Glow.Set(player, Vector(255,138,0), 1, 2048)
//    Glow.Disable(player)
//
//    Glow.DEBUG = true
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
				if(DEBUG)::print("Glow::Set: Updating glow ["+src.entindex()+"]\n");
			}
			else
			{
				if(DEBUG)::print("Glow::Set: Setting glow ["+src.entindex()+"]\n");

				foreach( e in _list ) if(e)
					if(!e.GetMoveParent())
					{
						glow = e;
						break;
					};;

				if(glow)
				{
					glow.SetModel(src.GetModelName());
				}
				else
				{
					glow = ::CreateProp("prop_dynamic_glow", src.GetOrigin(), src.GetModelName(), 0);
					_list.append(glow.weakref());
				};

				glow.__KeyValueFromInt("rendermode", 6);
				glow.__KeyValueFromInt("renderamt", 0);
				::VS.SetParent(glow, src);
				::VS.MakePermanent(glow);
			};

			if( typeof color == "string" )
				glow.__KeyValueFromString("glowcolor", color);
			else if( typeof color == "Vector" )
				glow.__KeyValueFromVector("glowcolor", color);
			else throw "parameter 2 has an invalid type '" + typeof color + "' ; expected 'string|Vector'";;
			glow.__KeyValueFromInt("glowstyle", style);
			glow.__KeyValueFromFloat("glowdist", dist);
			glow.__KeyValueFromInt("glowenabled", 1);
			glow.__KeyValueFromInt("effects", 18433); // EF_DEFAULT

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
				glow.__KeyValueFromInt("effects", 18465); // EF_DEFAULT|EF_NODRAW
				::VS.SetParent(glow, null);
				::EntFireByHandle(glow,"setglowdisabled");

				if(DEBUG)::print("Glow::Disable: Disabled glow ["+src.entindex()+"]\n");
			}
			else
			{
				if(DEBUG)::print("Glow::Disable: No glow found ["+src.entindex()+"]\n");
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
			if( !src || !src.GetModelName().len() )
				throw "Glow: Invalid source entity";

			for( local i = _list.len(); i--; )
			{
				local g = _list[i];
				if(g)
				{
					if( g.GetMoveParent() == src )
						return g;
				}
				else _list.remove(i);
			}
		}

		// EF_DEFAULT = (1<<0)|(1<<11)|(1<<14),
		// EF_NODRAW = (1<<5),
		DEBUG = false,
		_list = []
	}
};;
