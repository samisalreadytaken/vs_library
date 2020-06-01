//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//
//                       github.com/samisalreadytaken
//
// This project is licensed under the terms of the MIT License.
// See <README.md> or <LICENSE> for details.
//-----------------------------------------------------------------------

// Don't load if the library is already loaded
if("VS"in::getroottable()&&typeof::VS=="table"&&"_xa9b2dfB7ffe"in::getroottable()&&!::VS._reload&&::ENT_SCRIPT.IsValid())return/*::printl("vs_library is already loaded.")*/;;local _v2=function(){}local _f=_v2.getinfos().src;_f=_f.slice(0,_f.find(".nut"));if(this!=::getroottable())return::DoIncludeScript(_f,::getroottable());;if(_f!="vs_library")::print("Loading vs_library...\n");;

::VS <-
{
	// entity scope
	slots_entity = ["DispatchOnPostSpawn","self","__vname","PrecacheCallChain","OnPostSpawnCallChain","__vrefs","DispatchPrecache","activator","caller","OnPostSpawn","PostSpawn","Precache","PreSpawnInstance","__EntityMakerResult","__FinishSpawn","__ExecutePreSpawn"],

	// root (CSGO)
	slots_root = ["CHostage","split","Vector","print","_floatsize_","ScriptIsLocalPlayerUsingController","GetDeveloperLevel","ScriptGetBestTrainingCourseTime","exp","CSceneEntity","ScriptCoopMissionRespawnDeadPlayers","DispatchParticleEffect","CTriggerCamera","DoEntFire","seterrorhandler","RandomFloat","CBasePlayer","VSquirrel_OnReleaseScope","ScriptCoopMissionSetNextRespawnIn","assert","atan2","ScriptCoopMissionSpawnNextWave","DoUniqueString","_charsize_","asin","atan","CBaseAnimating","cos","ScriptPrintMessageCenterTeam","EntFireByHandle","PI","Entities","SendToConsole","TraceLine","strip","ScriptCoopMissionGetMissionNumber","newthread","lstrip","ScriptCoopSetBotQuotaAndRefreshSpawns","ScriptPrintMessageChatTeam","IncludeScript","format","rstrip","acos","ScriptGetPlayerCompletedTraining","Documentation","__DumpScope","CEntities","abs","PrintHelp","ScriptPrintMessageCenterAllWithParams","CBaseEntity","FrameTime","Time","Assert","ScriptCoopGiveC4sToCTs","DebugDrawBox","DebugDrawLine","ScriptHighlightAmmoCounter","Document","_intsize_","collectgarbage","setroottable","ScriptSetMiniScoreHidden","ScriptCoopCollectBonusCoin","CBaseFlex","ScriptPrintMessageCenterAll","ScriptSetRadarHidden","enabledebuginfo","setdebughook","ceil","log10","CGameSurvivalLogic","RecordAchievementEvent","RAND_MAX","rand","srand","GetFunctionSignature","suspend","ScriptIsWarmupPeriod","VSquirrel_OnCreateScope","ScriptShowFinishMsgBox","developer","CEnvEntityMaker","__ReplaceClosures","compilestring","RetrieveNativeSignature","ScriptShowExitDoorMsg","SendToConsoleServer","GetMapName","EntFire","Msg","UniqueString","sqrt","ScriptGetRoundsPlayed","floor","CreateSceneEntity","getstackinfos","ScriptGetGameType","log","fabs","dummy","DoIncludeScript","LateBinder","getroottable","tan","ShowMessage","array","LoopSinglePlayerMaps","_version_","ScriptGetValveTrainingCourseTime","setconsttable","CreateProp","printl","CFuncTrackTrain","sin","getconsttable","pow","CGameCoopMissionManager","ScriptSetPlayerCompletedTraining","CBaseMultiplayerPlayer","RegisterFunctionDocumentation","CPlayerVoiceListener","ScriptSetBestTrainingCourseTime","ScriptTrainingGivePlayerAmmo","ScriptCoopResetRoundStartTime","CScriptKeyValues","type","CCallChainer","CSimpleCallChainer","ScriptPrintMessageChatAll","ScriptGetGameMode","regexp","RandomInt","ScriptCoopMissionSpawnFirstEnemies","ScriptCoopExtendRoundDurationTime","ScriptCoopToggleEntityOutlineHighlights","ScriptMissionResetDangerZones","ScriptMissionCreateAndDetonateDangerZone","ScriptCoopMissionSetDeadPlayerRespawnEnabled"],

	// root (vs_library)
	slots_VS = ["_xa9b2dfB7ffe","VS","DoEntFireByInstanceHandle","ClearChat","Chat","ChatTeam","txt","Alert","AlertTeam","PrecacheModel","PrecacheScriptSound","delay","OnGameEvent_player_spawn","OnGameEvent_player_connect","VecToString","ENT_SCRIPT","HPlayer","SPlayer","Ent","Entc","max","min","clamp","MAX_COORD_FLOAT","MAX_TRACE_LENGTH","DEG2RAD","RAD2DEG","CONST","vs_library"],

	// combined
	slots_valve = [],

	// combined ( +vs_library )
	slots_default = [],

	Events = {},
	Log =
	{
		condition=false,
		export=false,
		filePrefix="vs.log",
		L=[],
		filter="VFLTR"
	},
	_reload = false
}

VS.slots_valve.extend(VS.slots_entity);
VS.slots_valve.extend(VS.slots_root);
VS.slots_default.extend(VS.slots_valve);
VS.slots_default.extend(VS.slots_VS);

// reduce a call on Msg
if( ::print.getinfos().native )
	::Msg <- ::print;;

if( ::EntFireByHandle.getinfos().native )
	::DoEntFireByInstanceHandle <- ::EntFireByHandle;;

::CONST <- getconsttable();
::vs_library <- "vs_library v#.#.#";
::MAX_COORD_FLOAT <- 16384.0;
::MAX_TRACE_LENGTH <- 56755.84086241; // sqrt(0x0003) * 0x0002 * 0x4000 = 56755.84086241697115430736
::DEG2RAD <- 0.01745329;  // 0.01745329251994329576
::RAD2DEG <- 57.29577951; // 57.29577951308232087679
// PI 3.14159265358979323846
// RAND_MAX 0x7FFF

// array to store event data, user should never modify
if( !("_xa9b2dfB7ffe" in getroottable()) ) ::_xa9b2dfB7ffe <- [];;

if( !("OnGameEvent_player_spawn" in getroottable()) ) ::OnGameEvent_player_spawn <- ::dummy;;
if( !("OnGameEvent_player_connect" in getroottable()) ) ::OnGameEvent_player_connect <- ::dummy;;

// wrapped to call later because it uses some functions declared later
local _v0 = function()
{
	if( ::ENT_SCRIPT <- ::Entc("worldspawn") )
	{
		::ENT_SCRIPT.ValidateScriptScope();
		::VS.slots_default.append(::VS.GetVarName(::ENT_SCRIPT.GetScriptScope()));
	}
	else
	{
		(::ENT_SCRIPT<-::VS.CreateEntity("soundent")).ValidateScriptScope();
		::VS._ENT_SCRIPT <- ::ENT_SCRIPT;
		::print("ERROR: Could not find worldspawn\n");
	};

	::collectgarbage();
}

function VS::ForceReload():(_f)
{
	_reload = true;
	::print("Reloading vs_library...\n");
	return::DoIncludeScript(_f,::getroottable());
}
