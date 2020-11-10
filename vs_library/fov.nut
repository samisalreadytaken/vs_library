//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//- v1.0.3 --------------------------------------------------------------
//
// ::SetPlayerFOV( hPlayer, iFOV, flSpeed = 0 )
//
IncludeScript("vs_library");if(!("SetPlayerFOV"in::getroottable())||typeof::SetPlayerFOV!="function"){local l=[],A=::DoEntFireByInstanceHandle,S=function(e,f,s)return e.SetFov(f,s);::SetPlayerFOV<-function(p,f,s=0.0):(l,A,S){local e;if(!p||p.GetClassname()!="player")throw"SetPlayerFOV: Invalid source entity";for(local i=l.len();i--;){local h=l[i];if(h){if(h.GetOwner()==p){e=h;break}}else l.remove(i)}if(!e){foreach(h in l)if(h)if(!h.GetOwner()){e=h;break}};if(e){if(!f){e.SetFov(0,s);e.SetOwner(null);return}}else{e=::VS.CreateEntity("point_viewcontrol",{spawnflags=(1<<0)|(1<<7)effects=1<<5,movetype=8,renderamt=0,rendermode=10},true);l.append(e.weakref())};e.SetOwner(p);A(e,"Enable","",0.0,p,null);A(e,"Disable","",0.0,p,null);::VS.EventQueue.AddEvent(S,0.0,[null,e,f,s]);return e}};;
