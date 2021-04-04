//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//- v1.0.10 -------------------------------------------------------------
//
// ::Glow.Set( hPlayer, color, nType, flDistance )
// ::Glow.Disable( hPlayer )
//
if(!("Glow"in::getroottable())||typeof::Glow!="table"||!("Set"in::Glow)){local A="DoEntFireByInstanceHandle"in getroottable()?DoEntFireByInstanceHandle:EntFireByHandle,C=CreateProp,l=[];::Glow<-{m_list=l,Get=null,Set=null,Disable=null}function Glow::Get(s):(l){if(!s||!s.IsValid()||s.GetModelName()=="")return;for(local i=l.len();i--;){local h=l[i];if(h){if(h.GetMoveParent()==s)return h}else l.remove(i)}}local G=::Glow.Get;function Glow::Set(s,c,t,d):(l,A,C,G){local h=G(s),o=typeof c;if(!h){foreach(v in l)if(v&&!v.GetMoveParent()){h=v;break};if(h)h.SetModel(s.GetModelName());else{h=C("prop_dynamic_glow",s.GetOrigin(),s.GetModelName(),0);l.insert(l.len(),h.weakref())};h.__KeyValueFromInt("rendermode",6);h.__KeyValueFromInt("renderamt",0);A(h,"SetParent","!activator",0.0,s,null);h.__KeyValueFromString("classname","soundent")};if(o=="string")h.__KeyValueFromString("glowcolor",c);else if(o=="Vector")h.__KeyValueFromVector("glowcolor",c);else throw"parameter 2 has an invalid type '"+o+"' ; expected 'string|Vector'";;h.__KeyValueFromInt("glowstyle",t);h.__KeyValueFromFloat("glowdist",d);h.__KeyValueFromInt("glowenabled",1);h.__KeyValueFromInt("effects",18433);return h}function Glow::Disable(s):(A,G){local h=G(s);if(h){h.__KeyValueFromInt("effects",18465);A(h,"ClearParent","",0.0,null,null);A(h,"SetGlowDisabled","",0.0,null,null)};return h}}
