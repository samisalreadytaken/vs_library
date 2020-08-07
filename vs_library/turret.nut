//-----------------------------------------------------------------------
//------------------- Copyright (c) samisalreadytaken -------------------
//                       github.com/samisalreadytaken
//- v0.5.2 --------------------------------------------------------------
//
// Player controlled turret (multiplayer compatible)
//
// Required entities (targetnames are arbitrary):
//
//	prop_dynamic:                      (gun model prop)
//		targetname: turret_gun_0
//		model: models/weapons/w_mach_m249.mdl
//
//	env_gunfire:                       (fire origin, place in front of the gun barrel)
//		targetname: turret_fire_0
//		parentname: turret_gun_0       (gun model prop)
//		target:     turret_target_0    (aim target)
//		weaponname: weapon_p90         (determines the damage)
//		StartDisabled: 1
//		maxburstdelay: 0
//		minburstdelay: 0
//
//	info_target:                       (aim target, placement does not matter)
//		targetname: turret_target_0
//
//	func_button:                       (to use the turret)
//		OnPressed > !activator > RunScriptCode > ::_TURRET_.Use(#YOUR_TURRET_VAR#)
//
// Create your turret in your script
//
//	#YOUR_TURRET_VAR# <- ::_TURRET_.Create("turret_gun_0","turret_fire_0","turret_target_0");
//
// Disable on round start to make sure there are no players left using the
// turret from the previous round
//	::OnGameEvent_round_start <- function(data)
//	{
//		::_TURRET_.Disable(#YOUR_TURRET_VAR#)
//	}
//
// If there are multiple turrets in the map, set the user name as well
//
//	hTurret1 <- ::_TURRET_.Create("turret_gun_1","turret_fire_1","turret_target_1","turret_user_1");
//	hTurret2 <- ::_TURRET_.Create("turret_gun_2","turret_fire_2","turret_target_2","turret_user_2");
//
// Crosshair overlay and sounds can also be set exclusively for each turret
//
//	hTurret2 <- ::_TURRET_.Create("turret_gun_2",
//	                              "turret_fire_2",
//	                              "turret_target_2",
//	                              "turret_user_2",
//	                              "mymap/overlay",
//	                              "Weapon_M249.Pump");
//	                              "Weapon_AK47.Single");
//

// option defaults
local SND_USE = "Weapon_M249.Pump";
local SND_FIRE = "Weapon_M249.Single";
local TURRET_USE_OVERLAY = "";
local TURRET_USER_NAME = "turret_user";

IncludeScript("vs_library");

if( !("_TURRET_" in getroottable()) )
{
::_TURRET_ <- {}

local __init__ = function():(SND_USE,SND_FIRE,TURRET_USER_NAME,TURRET_USE_OVERLAY){

local m_list = {}
local m_hCommand = ::VS.CreateEntity("point_clientcommand",null,true);

function Create(sNameGunMDL,
				sNameGunFire,
				sNameGunTarget,
				sUserName = TURRET_USER_NAME,
				sOverlayOn = TURRET_USE_OVERLAY,
				sSndUse = SND_USE,
				sSndFire = SND_FIRE):(m_list)
{
	local hGunProp = ::Ent(sNameGunMDL);
	local hGunFire = ::Ent(sNameGunFire);
	local hTarget = ::Ent(sNameGunTarget);

	if( !hGunProp || !hTarget || !hGunFire )
		throw "TURRET: could not find entities";

	local bCreateNew = true;
	local hCtrl;

	foreach( k,v in m_list )
	{
		if( k.GetScriptScope().m_hGunProp.GetName() == sNameGunMDL )
		{
			bCreateNew = false;
			hCtrl = k;
			break;
		};
	}

	if( bCreateNew )
	{
		local hEye = ::VS.CreateMeasure(sUserName,null,true);
		hCtrl = ::VS.CreateEntity("game_ui",{ spawnflags = (1<<5)|(1<<6)|(1<<7), fieldofview = -1.0 },true);

		m_list[hCtrl] <-
		{
			sSndFire = sSndFire,
			sSndUse = sSndUse,
			sOverlayOn = sOverlayOn,
			sUserName = sUserName,
			hEye = hEye.weakref(),
			sNameGunMDL = sNameGunMDL,
			sNameGunFire = sNameGunFire,
			sNameGunTarget = sNameGunTarget
		}
	};

	Reset(hCtrl);

	return hCtrl;
}

function Reset(hCtrl):(m_list)
{
	hCtrl.ValidateScriptScope();
	local sc = hCtrl.GetScriptScope();
	local ls = m_list[hCtrl];

	local hGunProp = ::Ent(ls.sNameGunMDL);
	local hGunFire = ::Ent(ls.sNameGunFire);
	local hTarget = ::Ent(ls.sNameGunTarget);

	sc.m_bShooting <- false;
	sc.m_hUser <- null;
	sc.m_hEye <- ls.hEye.weakref();
	sc.m_hGunProp <- hGunProp.weakref();
	sc.m_hGunFire <- hGunFire.weakref();
	sc.m_hTarget <- hTarget.weakref();
	sc.m_sUserName <- ls.sUserName;
	sc.m_sOverlayOn <- ls.sOverlayOn;
	sc.m_sSndFire <- ls.sSndFire;
	sc.m_sSndUse <- ls.sSndUse;

	AddOutputs(hCtrl);

	for( local ent; ent = ::Entities.FindByName(ent,sc.m_sUserName); )
		::VS.SetName(ent,"");
}

function Disable(hCtrl,bForceDeactivate = true):(m_hCommand)
{
	local sc = hCtrl.GetScriptScope();

	if(sc.m_hUser)
	{
		// +use already deactivates itself (spawnflag 7)
		// but this is required if the player did not deactivate, but was killed or round ended
		if(bForceDeactivate) ::DoEntFireByInstanceHandle(hCtrl,"deactivate","",0,sc.m_hUser,null);

		::DoEntFireByInstanceHandle(m_hCommand,"command","r_screenoverlay\"\"",0,sc.m_hUser,null);
		::VS.SetName(sc.m_hUser,"");

//		local scPlayer = sc.m_hUser.GetScriptScope();
//		if( "hControlledTurret" in scPlayer )
//		{
//			scPlayer.hControlledTurret = null;
//		};

		sc.m_hUser = null;
	};

	for( local ent; ent = ::Entities.FindByName(ent,sc.m_sUserName); )
		::VS.SetName(ent,"");

	if(sc.m_hGunFire)
		::EntFireByHandle(sc.m_hGunFire, "disable");

	sc.m_bShooting = false;
	sc.m_hUser = null;
}

function Use(hCtrl,ply = null)
{
	if( !ply )
	{
		try(ply = activator)
		catch(e)
		{
			e = null;
			throw "TURRET: could not find player to use";
		}
	};

	local sc = hCtrl.GetScriptScope();

	// this block will not be called because +use already disables the turret (spawnflag 7)
	if( sc.m_hUser == ply )
	{
		::print("TURRET: unexpected execution!");
		::DoEntFireByInstanceHandle(sc.self, "deactivate", "", 0, ply, null);
		return;
	}
	else if( sc.m_hUser )
	{
		return::print("TURRET: Someone tried to use the turret while it was already in use\n");
	};;

	if( ply && ply.IsValid() && ply.GetClassname() == "player" )
	{
		// round restart, gunfire and prop are respawned, previous references are invalid
		if( !sc.m_hGunFire )
		{
			Reset(hCtrl);
		};

		::DoEntFireByInstanceHandle(sc.self, "activate", "", 0, ply, null);

//		local scPlayer = ply.GetScriptScope();
//		if( scPlayer )
//		{
//			scPlayer.hControlledTurret <- sc.self.weakref();
//		};
	};
}

// internal functions --------------------------------------

function OnUse():(m_hCommand)
{
	m_hUser = activator.weakref();
	m_bShooting = false;

	::VS.SetName(m_hUser,m_sUserName);
	::VS.SetMeasure(m_hEye,m_sUserName);

	::EntFireByHandle(m_hGunFire, "disable");
	::DoEntFireByInstanceHandle(m_hCommand,"command","r_screenoverlay\""+m_sOverlayOn+"\"",0,m_hUser,null);

	m_hGunProp.EmitSound(m_sSndUse);
	Think();
}

function OnAttack()
{
	::EntFireByHandle(m_hGunFire, "enable");
	m_bShooting = true;
}

function OnAttackRelease()
{
	::EntFireByHandle(m_hGunFire, "disable");
	m_bShooting = false;
}

local TraceDir = ::VS.TraceDir.bindenv(::VS);
local delay = ::delay;

function Think():(TraceDir,delay)
{
	if( !m_hUser )
		return;

	if( !m_hUser.GetHealth() )
		return::_TURRET_.Disable(self);

//	if( m_nFireCount ++>= m_nCooldownLimit )
//	{
//		return delay("Think()",m_flRecoverTime,self);
//	};

	local vecTargetPos = TraceDir(m_hUser.EyePosition(),m_hEye.GetForwardVector()).GetPos();
	m_hTarget.SetOrigin(vecTargetPos);

	// get the correct shooting angle
	// This will cause the gun orientation to 'jump' as it aims at where the target is
	// local vAng = ::VS.GetAngle(m_hGunProp.GetOrigin(),vecTargetPos);

	// Player eye angle can be used to keep the movement smooth, but misaligned with shot direction
	// (shots will not come straight out of the barrel)
	local vAng = m_hEye.GetAngles();

	m_hGunProp.SetAngles(vAng.x,vAng.y,vAng.z);

	if( m_bShooting )
	{
		m_hGunProp.EmitSound(m_sSndFire);
	};

	return delay("Think()",0.05,self);
}

function AddOutputs(hCtrl)
{
	::VS.AddOutput(hCtrl,"PressedAttack",OnAttack,null,true);
	::VS.AddOutput(hCtrl,"UnpressedAttack",OnAttackRelease,null,true);
	::VS.AddOutput(hCtrl,"PlayerOn",OnUse,null,true);
	::VS.AddOutput(hCtrl,"PlayerOff",function(){::_TURRET_.Disable(self,false)},null,true);

	hCtrl.GetScriptScope().Think <- Think.bindenv(hCtrl.GetScriptScope());
}

}.call(::_TURRET_);
};;
