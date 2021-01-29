//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//-----------------------------------------------------------------------

local _ = ::getroottable();

// Don't load if the library is already loaded
if( "VS" in _ && typeof::VS == "table" &&
    "IsInteger" in ::VS && !::VS._reload )
	return;;

local __ = function(){}
local _f = __.getinfos().src;
_f = _f.slice(0,_f.find(".nut"));

// The rest is wrapped in this in the minified file.
// __ = function():(_f){}.call(_);

if( _f != "vs_library" )
	::print("Loading vs_library...\n");

local PORTAL2 = "CPortal_Player" in ::getroottable() &&
                "TurnOnPotatos" in ::CPortal_Player &&
                ::CPortal_Player.TurnOnPotatos.getinfos().native;

local EVENTS = !!::Entities.FindByClassname(null,"logic_eventlistener");

::VS <-
{
	version = "vs_library v#.#.#",
	_reload = false
}

// reduce a call on Msg
if( ::print.getinfos().native )
	::Msg <- ::print;

if( ::EntFireByHandle.getinfos().native )
	::DoEntFireByInstanceHandle <- ::EntFireByHandle;

local TICK_INTERVAL = FrameTime();
local ROOT = getroottable();
::CONST <- getconsttable();
::MAX_COORD_FLOAT <- 16384.0;
::MAX_TRACE_LENGTH <- 56755.84086241; 	// sqrt(0x0003) * 0x0002 * 0x4000 = 56755.84086241697115430736
::DEG2RAD <- 0.01745329;				// 0.01745329251994329576
::RAD2DEG <- 57.29577951; 				// 57.29577951308232087679
// PI 									3.14159265358979323846
// RAND_MAX 							0x7FFF

::collectgarbage();

// Native functions added by Valve below. Kept here as reference.

// CSGO
	// ["CHostage","Vector","ScriptIsLocalPlayerUsingController","GetDeveloperLevel","ScriptGetBestTrainingCourseTime","CSceneEntity","ScriptCoopMissionRespawnDeadPlayers","DispatchParticleEffect","CTriggerCamera","DoEntFire","RandomFloat","CBasePlayer","VSquirrel_OnReleaseScope","ScriptCoopMissionSetNextRespawnIn","ScriptCoopMissionSpawnNextWave","DoUniqueString","CBaseAnimating","ScriptPrintMessageCenterTeam","EntFireByHandle","Entities","SendToConsole","TraceLine","ScriptCoopMissionGetMissionNumber","ScriptCoopSetBotQuotaAndRefreshSpawns","ScriptPrintMessageChatTeam","IncludeScript","ScriptGetPlayerCompletedTraining","Documentation","__DumpScope","CEntities","PrintHelp","ScriptPrintMessageCenterAllWithParams","CBaseEntity","FrameTime","Time","Assert","ScriptCoopGiveC4sToCTs","DebugDrawBox","DebugDrawLine","ScriptHighlightAmmoCounter","Document","ScriptSetMiniScoreHidden","ScriptCoopCollectBonusCoin","CBaseFlex","ScriptPrintMessageCenterAll","ScriptSetRadarHidden","CGameSurvivalLogic","RecordAchievementEvent","GetFunctionSignature","ScriptIsWarmupPeriod","VSquirrel_OnCreateScope","ScriptShowFinishMsgBox","developer","CEnvEntityMaker","__ReplaceClosures","RetrieveNativeSignature","ScriptShowExitDoorMsg","SendToConsoleServer","GetMapName","EntFire","Msg","UniqueString","ScriptGetRoundsPlayed","CreateSceneEntity","ScriptGetGameType","DoIncludeScript","LateBinder","ShowMessage","LoopSinglePlayerMaps","ScriptGetValveTrainingCourseTime","CreateProp","printl","CFuncTrackTrain","CGameCoopMissionManager","ScriptSetPlayerCompletedTraining","CBaseMultiplayerPlayer","RegisterFunctionDocumentation","CPlayerVoiceListener","ScriptSetBestTrainingCourseTime","ScriptTrainingGivePlayerAmmo","ScriptCoopResetRoundStartTime","CScriptKeyValues","CCallChainer","CSimpleCallChainer","ScriptPrintMessageChatAll","ScriptGetGameMode","RandomInt","ScriptCoopMissionSpawnFirstEnemies","ScriptCoopExtendRoundDurationTime","ScriptCoopToggleEntityOutlineHighlights","ScriptMissionResetDangerZones","ScriptMissionCreateAndDetonateDangerZone","ScriptCoopMissionSetDeadPlayerRespawnEnabled","ScriptLobbyMapVetoFinished"];

// PORTAL2
	// ["__ReplaceClosures","GetDeveloperLevel","CSceneEntity","MarkMapComplete","CTriggerCamera","DoEntFire","RandomFloat","CBasePlayer","VSquirrel_OnReleaseScope","IsLevelComplete","CBaseMultiplayerPlayer","PrecacheMovie","CBaseAnimating","GetNumMapsPlayed","EntFireByHandle","Entities","SendToConsole","RegisterFunctionDocumentation","IncludeScript","SetMapAsPlayed","UpgradePlayerPortalgun","__DumpScope","CEntities","PrintHelp","RetrieveNativeSignature","ScriptSteamShowURL","UpgradePlayerPotatogun","FrameTime","Time","Assert","RequestMapRating","PlayerVoiceListener","DebugDrawBox","LoopSinglePlayerMaps","Document","GetCoopSectionIndex","SetHaveSeenDLCTubesReveal","CoopSetMapRunTime","AddGladosSpokenFlags","CoopSetCameFromLastDLCMap","IsPlayerBranchComplete","CoopGladosBlowUpBots","IsBranchComplete","NotifySpeedRunSuccess","CoopGetNumPortalsPlaced","CoopGetBranchTotalLevelCount","GetNumPlayersConnected","IsLocalSplitScreen","GetPlayerDeathCount","GetGladosSpokenFlags","GetHaveSeenDLCTubesReveal","CoopGetLevelsCompletedThisBranch","GetCameFromLastDLCMap","SaveMPStatsData","GivePlayerPortalgun","CLinkedPortalDoor","UniqueString","GetCoopBranchLevelIndex","SetDucking","CSimpleCallChainer","CCallChainer","GetPlayer","RecordAchievementEvent","IsMultiplayer","GetFunctionSignature","IsPlayerLevelComplete","VSquirrel_OnCreateScope","developer","CEnvEntityMaker","GetPlayerSilenceDuration","TryDLC1InstalledOrCatch","GetMapName","EntFire","Msg","CreateSceneEntity","player","AddCoopCreditsName","GetMapIndexInPlayOrder","GetOrangePlayerIndex","CPortal_Player","CPlayerVoiceListener","LateBinder","ShowMessage","CreateProp","TraceLine","printl","ScriptShowHudMessageAll","DebugDrawLine","GetHighestActiveBranch","Documentation","CBaseEntity","CPropLinkedPortalDoor","DoIncludeScript","CScriptKeyValues","GetBluePlayerIndex","DoUniqueString","CBaseFlex","AddBranchLevelName","RandomInt","Vector"];
