//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//- v1.0.6 --------------------------------------------------------------
if(!("Glow"in::getroottable())||typeof::Glow!="table"||!("Set"in::Glow)){::Glow<-{function Set(I,c,s,d){local g=Get(I);if(g){if(DEBUG)::print("Glow::Set: Updating glow ["+I.entindex()+"]\n")}else{if(DEBUG)::print("Glow::Set: Setting glow ["+I.entindex()+"]\n");foreach(e in _list)if(e)if(!e.GetMoveParent()){g=e;break};;if(g){g.SetModel(I.GetModelName())}else{g=::CreateProp("prop_dynamic_glow",I.GetOrigin(),I.GetModelName(),0);_list.append(g.weakref())};g.__KeyValueFromInt("rendermode",6);g.__KeyValueFromInt("renderamt",0);::VS.SetParent(g,I);::VS.MakePermanent(g)};if(typeof c=="string")g.__KeyValueFromString("glowcolor",c);else if(typeof c=="Vector")g.__KeyValueFromVector("glowcolor",c);else throw"parameter 2 has an invalid type '"+typeof c+"' ; expected 'string|Vector'";;g.__KeyValueFromInt("glowstyle",s);g.__KeyValueFromFloat("glowdist",d);g.__KeyValueFromInt("glowenabled",1);g.__KeyValueFromInt("effects",18433);return g}function Disable(I){local g=Get(I);if(g){g.__KeyValueFromInt("effects",18465);::VS.SetParent(g,null);::EntFireByHandle(g,"setglowdisabled");if(DEBUG)::print("Glow::Disable: Disabled glow ["+I.entindex()+"]\n")}else{if(DEBUG)::print("Glow::Disable: No glow found ["+I.entindex()+"]\n")};return g}function Get(I){if(!I||!I.GetModelName().len())throw"Glow: Invalid source entity";for(local i=_list.len();i--;){local g=_list[i];if(g){if(g.GetMoveParent()==I)return g}else _list.remove(i)}}DEBUG=false,_list=[]}};;