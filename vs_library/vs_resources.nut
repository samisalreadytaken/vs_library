//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//
//                       github.com/samisalreadytaken
//
// This project is licensed under the terms of the MIT License.
// See <README.md> or <LICENSE> for details.
//-----------------------------------------------------------------------

// Don't load if the library is already loaded
if( "VS" in ::getroottable() && typeof::VS == "table" &&
    "MAX_COORD_FLOAT" in ::getroottable() && !::VS._reload && ::ENT_SCRIPT.IsValid() )
	return;;

local _v2 = function(){}
local _f = _v2.getinfos().src;
_f = _f.slice(0,_f.find(".nut"));

if( this != ::getroottable() )
	return::DoIncludeScript(_f,::getroottable());;
if( _f != "vs_library" )
	::print("Loading vs_library...\n");;

local PORTAL2 = "CPortal_Player" in ::getroottable() &&
                "TurnOnPotatos" in ::CPortal_Player &&
                ::CPortal_Player.TurnOnPotatos.getinfos().native;

local EVENTS = !!::Entities.FindByClassname(null,"logic_eventlistener");

::VS <-
{
	Log =
	{
		condition = false,
		export = false,
		file_prefix = "vs.log",
		filter = "VL",
		L = []
	},

	_reload = false
}

local slots_default;
{
	// root (SQ)
	local slots_sq = ["split","print","_floatsize_","exp","seterrorhandler","assert","atan2","_charsize_","asin","atan","cos","PI","strip","newthread","lstrip","format","rstrip","acos","abs","_intsize_","collectgarbage","setroottable","enabledebuginfo","setdebughook","ceil","log10","RAND_MAX","rand","srand","suspend","compilestring","sqrt","floor","getstackinfos","log","fabs","dummy","getroottable","tan","array","_version_","setconsttable","sin","getconsttable","pow","type","regexp"];

	// entity scope
	local slots_ent = ["DispatchOnPostSpawn","self","__vname","PrecacheCallChain","OnPostSpawnCallChain","__vrefs","DispatchPrecache","OnPostSpawn","PostSpawn","Precache","PreSpawnInstance","__EntityMakerResult","__FinishSpawn","__ExecutePreSpawn"];

	// root (vs_library)
	local slots_VS = ["_xa9b2dfB7ffe","VS","DoEntFireByInstanceHandle","ClearChat","Chat","ChatTeam","txt","Alert","AlertTeam","PrecacheModel","PrecacheScriptSound","delay","OnGameEvent_player_spawn","OnGameEvent_player_connect","VecToString","ENT_SCRIPT","HPlayer","Ent","Entc","Quaternion","matrix3x4","max","min","clamp","MAX_COORD_FLOAT","MAX_TRACE_LENGTH","DEG2RAD","RAD2DEG","CONST","vs_library"];

	local slots_root;

if (!PORTAL2){

	// root (valve)
	slots_root = ["CHostage","Vector","ScriptIsLocalPlayerUsingController","GetDeveloperLevel","ScriptGetBestTrainingCourseTime","CSceneEntity","ScriptCoopMissionRespawnDeadPlayers","DispatchParticleEffect","CTriggerCamera","DoEntFire","RandomFloat","CBasePlayer","VSquirrel_OnReleaseScope","ScriptCoopMissionSetNextRespawnIn","ScriptCoopMissionSpawnNextWave","DoUniqueString","CBaseAnimating","ScriptPrintMessageCenterTeam","EntFireByHandle","Entities","SendToConsole","TraceLine","ScriptCoopMissionGetMissionNumber","ScriptCoopSetBotQuotaAndRefreshSpawns","ScriptPrintMessageChatTeam","IncludeScript","ScriptGetPlayerCompletedTraining","Documentation","__DumpScope","CEntities","PrintHelp","ScriptPrintMessageCenterAllWithParams","CBaseEntity","FrameTime","Time","Assert","ScriptCoopGiveC4sToCTs","DebugDrawBox","DebugDrawLine","ScriptHighlightAmmoCounter","Document","ScriptSetMiniScoreHidden","ScriptCoopCollectBonusCoin","CBaseFlex","ScriptPrintMessageCenterAll","ScriptSetRadarHidden","CGameSurvivalLogic","RecordAchievementEvent","GetFunctionSignature","ScriptIsWarmupPeriod","VSquirrel_OnCreateScope","ScriptShowFinishMsgBox","developer","CEnvEntityMaker","__ReplaceClosures","RetrieveNativeSignature","ScriptShowExitDoorMsg","SendToConsoleServer","GetMapName","EntFire","Msg","UniqueString","ScriptGetRoundsPlayed","CreateSceneEntity","ScriptGetGameType","DoIncludeScript","LateBinder","ShowMessage","LoopSinglePlayerMaps","ScriptGetValveTrainingCourseTime","CreateProp","printl","CFuncTrackTrain","CGameCoopMissionManager","ScriptSetPlayerCompletedTraining","CBaseMultiplayerPlayer","RegisterFunctionDocumentation","CPlayerVoiceListener","ScriptSetBestTrainingCourseTime","ScriptTrainingGivePlayerAmmo","ScriptCoopResetRoundStartTime","CScriptKeyValues","CCallChainer","CSimpleCallChainer","ScriptPrintMessageChatAll","ScriptGetGameMode","RandomInt","ScriptCoopMissionSpawnFirstEnemies","ScriptCoopExtendRoundDurationTime","ScriptCoopToggleEntityOutlineHighlights","ScriptMissionResetDangerZones","ScriptMissionCreateAndDetonateDangerZone","ScriptCoopMissionSetDeadPlayerRespawnEnabled"];

}else{ // PORTAL2

	slots_root = ["__ReplaceClosures","GetDeveloperLevel","CSceneEntity","MarkMapComplete","CTriggerCamera","DoEntFire","RandomFloat","CBasePlayer","VSquirrel_OnReleaseScope","IsLevelComplete","CBaseMultiplayerPlayer","PrecacheMovie","CBaseAnimating","GetNumMapsPlayed","EntFireByHandle","Entities","SendToConsole","RegisterFunctionDocumentation","IncludeScript","SetMapAsPlayed","UpgradePlayerPortalgun","__DumpScope","CEntities","PrintHelp","RetrieveNativeSignature","ScriptSteamShowURL","UpgradePlayerPotatogun","FrameTime","Time","Assert","RequestMapRating","PlayerVoiceListener","DebugDrawBox","LoopSinglePlayerMaps","Document","GetCoopSectionIndex","SetHaveSeenDLCTubesReveal","CoopSetMapRunTime","AddGladosSpokenFlags","CoopSetCameFromLastDLCMap","IsPlayerBranchComplete","CoopGladosBlowUpBots","IsBranchComplete","NotifySpeedRunSuccess","CoopGetNumPortalsPlaced","CoopGetBranchTotalLevelCount","GetNumPlayersConnected","IsLocalSplitScreen","GetPlayerDeathCount","GetGladosSpokenFlags","GetHaveSeenDLCTubesReveal","CoopGetLevelsCompletedThisBranch","GetCameFromLastDLCMap","SaveMPStatsData","GivePlayerPortalgun","CLinkedPortalDoor","UniqueString","GetCoopBranchLevelIndex","SetDucking","CSimpleCallChainer","CCallChainer","GetPlayer","RecordAchievementEvent","IsMultiplayer","GetFunctionSignature","IsPlayerLevelComplete","VSquirrel_OnCreateScope","developer","CEnvEntityMaker","GetPlayerSilenceDuration","TryDLC1InstalledOrCatch","GetMapName","EntFire","Msg","CreateSceneEntity","player","AddCoopCreditsName","GetMapIndexInPlayOrder","GetOrangePlayerIndex","CPortal_Player","CPlayerVoiceListener","LateBinder","ShowMessage","CreateProp","TraceLine","printl","ScriptShowHudMessageAll","DebugDrawLine","GetHighestActiveBranch","Documentation","CBaseEntity","CPropLinkedPortalDoor","DoIncludeScript","CScriptKeyValues","GetBluePlayerIndex","DoUniqueString","CBaseFlex","AddBranchLevelName","RandomInt","Vector"];

};; // !PORTAL2

	slots_default = [];

	slots_default.extend(slots_sq);
	slots_default.extend(slots_ent);
	slots_default.extend(slots_root);
	slots_default.extend(slots_VS);
}

// reduce a call on Msg
if( ::print.getinfos().native )
	::Msg <- ::print;;

if( ::EntFireByHandle.getinfos().native )
	::DoEntFireByInstanceHandle <- ::EntFireByHandle;;

::CONST <- getconsttable();
::vs_library <- "vs_library v#.#.#";
::MAX_COORD_FLOAT <- 16384.0;
::MAX_TRACE_LENGTH <- 56755.84086241; 	// sqrt(0x0003) * 0x0002 * 0x4000 = 56755.84086241697115430736
::DEG2RAD <- 0.01745329;				// 0.01745329251994329576
::RAD2DEG <- 57.29577951; 				// 57.29577951308232087679
// PI 									3.14159265358979323846
// RAND_MAX 							0x7FFF

if (!PORTAL2 && EVENTS){

VS.Events <- delegate VS :
{
	hProxy = null,
	flValidateTime = 0.0,
	_SV = null
}

// array to store event data, user should never modify
if( !("_xa9b2dfB7ffe" in getroottable()) )
	::_xa9b2dfB7ffe <- [];

if( !("OnGameEvent_player_spawn" in getroottable()) )
	::OnGameEvent_player_spawn <- ::dummy;

if( !("OnGameEvent_player_connect" in getroottable()) )
	::OnGameEvent_player_connect <- ::dummy;

};; // !PORTAL2 && EVENTS

::collectgarbage();

function VS::ForceReload():(_f)
{
	_reload = true;
	::print("Reloading vs_library...\n");
	return::DoIncludeScript(_f,::getroottable());
}
