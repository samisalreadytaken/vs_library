//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//
//                       github.com/samisalreadytaken
//
// This project is licensed under the terms of the MIT License.
// See <README.md> or <LICENSE> for details.
//-----------------------------------------------------------------------
//
// To force reload the library:
/*
	VS.ForceReload()
*/

// Don't load if the library is already loaded
if("VS"in::getroottable()&&typeof::VS=="table"&&"_xa9b2dfB7ffe"in::getroottable()&&!::VS._reload&&::ENT_SCRIPT.IsValid())return/*::printl("vs_library is already loaded.")*/;;local _v2=function(){}local _f=_v2.getinfos().src;for(local j=_f.len()-1;j>=0;--j)if(_f[j]==46){_f=_f.slice(0,j);break};;if(this!=::getroottable())return::DoIncludeScript(_f,::getroottable());;if(_f!="vs_library")printl("Loading vs_library...")

::VS<-{Events={},Log={}}

// entity scope
VS.slots_entity <- ["DispatchOnPostSpawn","self","__vname","PrecacheCallChain","OnPostSpawnCallChain","__vrefs","DispatchPrecache","activator","caller","OnPostSpawn","PostSpawn","Precache","PreSpawnInstance","__EntityMakerResult","__FinishSpawn","__ExecutePreSpawn"]

// root table (csgo)
VS.slots_root <- ["CHostage","split","Vector","print","_floatsize_","ScriptIsLocalPlayerUsingController","GetDeveloperLevel","ScriptGetBestTrainingCourseTime","exp","CSceneEntity","ScriptCoopMissionRespawnDeadPlayers","DispatchParticleEffect","CTriggerCamera","DoEntFire","seterrorhandler","RandomFloat","CBasePlayer","VSquirrel_OnReleaseScope","ScriptCoopMissionSetNextRespawnIn","assert","atan2","ScriptCoopMissionSpawnNextWave","DoUniqueString","_charsize_","asin","atan","CBaseAnimating","cos","ScriptPrintMessageCenterTeam","EntFireByHandle","PI","Entities","SendToConsole","TraceLine","strip","ScriptCoopMissionGetMissionNumber","newthread","lstrip","ScriptCoopSetBotQuotaAndRefreshSpawns","ScriptPrintMessageChatTeam","IncludeScript","format","rstrip","acos","ScriptGetPlayerCompletedTraining","Documentation","__DumpScope","CEntities","abs","PrintHelp","ScriptPrintMessageCenterAllWithParams","CBaseEntity","FrameTime","Time","Assert","ScriptCoopGiveC4sToCTs","DebugDrawBox","DebugDrawLine","ScriptHighlightAmmoCounter","Document","_intsize_","collectgarbage","setroottable","ScriptSetMiniScoreHidden","ScriptCoopCollectBonusCoin","CBaseFlex","ScriptPrintMessageCenterAll","ScriptSetRadarHidden","enabledebuginfo","setdebughook","ceil","log10","CGameSurvivalLogic","RecordAchievementEvent","RAND_MAX","rand","srand","GetFunctionSignature","suspend","ScriptIsWarmupPeriod","VSquirrel_OnCreateScope","ScriptShowFinishMsgBox","developer","CEnvEntityMaker","__ReplaceClosures","compilestring","RetrieveNativeSignature","ScriptShowExitDoorMsg","SendToConsoleServer","GetMapName","EntFire","Msg","UniqueString","sqrt","ScriptGetRoundsPlayed","floor","CreateSceneEntity","getstackinfos","ScriptGetGameType","log","fabs","dummy","DoIncludeScript","LateBinder","getroottable","tan","ShowMessage","array","LoopSinglePlayerMaps","_version_","ScriptGetValveTrainingCourseTime","setconsttable","CreateProp","printl","CFuncTrackTrain","sin","getconsttable","pow","CGameCoopMissionManager","ScriptSetPlayerCompletedTraining","CBaseMultiplayerPlayer","RegisterFunctionDocumentation","CPlayerVoiceListener","ScriptSetBestTrainingCourseTime","ScriptTrainingGivePlayerAmmo","ScriptCoopResetRoundStartTime","CScriptKeyValues","type","CCallChainer","CSimpleCallChainer","ScriptPrintMessageChatAll","ScriptGetGameMode","regexp","RandomInt","ScriptCoopMissionSpawnFirstEnemies","ScriptCoopExtendRoundDurationTime","ScriptCoopToggleEntityOutlineHighlights"]

// root table (VS additions)
VS.slots_VS <- ["_xa9b2df87ffe","_xa9b2dfB7ffe","VS","DoEntFireByInstanceHandle","ClearChat","Chat","ChatTeam","txt","toDeg","toRad","Alert","AlertTeam","EntFireHandle","PrecacheModel","PrecacheScriptSound","delay","OnGameEvent_player_spawn","OnGameEvent_player_connect","VecToString","ENT_SCRIPT","HPlayer","SPlayer","Ent","Entc","max","min","clamp","MAX_COORD_FLOAT","MAX_TRACE_LENGTH","DEG2RAD","RAD2DEG","CONST","vs_library"]

// combined
VS.slots_valve <- []
foreach( k in VS.slots_entity ) VS.slots_valve.append(k)
VS.slots_valve.extend(VS.slots_root)

// combined ( +VS )
VS.slots_default <- []
foreach( k in VS.slots_entity ) VS.slots_default.append(k)
VS.slots_default.extend(VS.slots_root)
VS.slots_default.extend(VS.slots_VS)

//-----------------------------------------------------------------------

::CONST <- getconsttable()

::vs_library <- "vs_library v#.#.#"

::MAX_COORD_FLOAT <- 16384.0

::MAX_TRACE_LENGTH <- 56755.8; // sqrt(0x0003) * 0x0002 * 0x4000

::DEG2RAD <- 0.01745329;  // 0.01745329251994329576
::RAD2DEG <- 57.29577951; // 57.29577951308232087679

VS.bF <- []
VS.Log.L <- []
VS.Log.filter <- "VFLTR"
VS.Log.conn <- " "
VS.Log.devlvl <- 0
VS.Log.fT4 <- FrameTime() * 4

if( !("_xa9b2dfB7ffe" in getroottable()) ) ::_xa9b2dfB7ffe <- []
if( !("_xa9b2df87ffe" in getroottable()) ) ::_xa9b2df87ffe <- null
if( !("_xffcd55c01dd" in VS.Log) ) VS.Log._xffcd55c01dd <- null

if( !("OnGameEvent_player_spawn" in getroottable()) ) ::OnGameEvent_player_spawn <- _FN1
if( !("OnGameEvent_player_connect" in getroottable()) ) ::OnGameEvent_player_connect <- _FN1

local _v0 = function()
{
	collectgarbage()

	if( ::ENT_SCRIPT <- Entc("logic_script") ) return
	else if( ::ENT_SCRIPT <- Ent("vs_script") ) return::ENT_SCRIPT.ValidateScriptScope()
	else if( ::ENT_SCRIPT <- Entc("worldspawn") )
	{
		::ENT_SCRIPT.ValidateScriptScope()
		VS.slots_default.append(VS.GetTableName(::ENT_SCRIPT.GetScriptScope()))
		return
	}
	else
	{
		(::ENT_SCRIPT<-::Entities.CreateByClassname("soundent")).ValidateScriptScope()
		::ENT_SCRIPT.__KeyValueFromString("targetname","vs_script")
		printl("ERROR: Could not find worldspawn")
	}
}()

local _VEC = Vector()
local _FN1 = function(d){}

VS._reload <- false

function VS::ForceReload(f=_f)
{
	VS._reload = true
	printl("Reloading vs_library...")
	DoIncludeScript(f,getroottable())
}
