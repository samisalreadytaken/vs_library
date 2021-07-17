//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//- v1.0.4 --------------------------------------------------------------
//
// ::SetPlayerFOV( hPlayer, iFOV, flSpeed = 0 )
//
IncludeScript("vs_library");if(!("SetPlayerFOV"in::getroottable())||typeof::SetPlayerFOV!="function"){local l=[],A=::DoEntFireByInstanceHandle,S=function(w,v,r){w.SetFov(v,r);w.SetOwner(null);return w}::SetPlayerFOV<-function(y,v,r=0.0):(l,A,S){local w;if(!y||!y.IsValid()||y.GetClassname()!="player")return;for(local i=l.len();i--;){local h=l[i];if(h){if(h.GetOwner()==y){w=h;break}}else l.remove(i)}if(!w){foreach(h in l)if(h&&!h.GetOwner()){w=h;break}};if(w){if(!v)return S(w,0,r)}else{w=::VS.CreateEntity("point_viewcontrol",{spawnflags=129,effects=32,movetype=8,renderamt=0,rendermode=10},true);l.insert(l.len(),w.weakref())};w.SetOwner(y);A(w,"Enable","",0.0,y,null);A(w,"Disable","",0.0,y,null);::VS.EventQueue.AddEvent(S,0.0,[null,w,v,r]);return w}};;
