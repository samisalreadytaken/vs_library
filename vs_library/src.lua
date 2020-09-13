-------------------------------------------------------------------------
--------------------- Copyright (c) samisalreadytaken -------------------
--- v0.1.1 --------------------------------------------------------------

local VER = "v0.1.1"

if not _VS then
	_VS = {}
elseif _VS[VER] then
	return _VS[VER]
end

local VS = {}
_VS[VER] = VS

-------------------------------------------------------------------------

VS.MAX_COORD_FLOAT = 16384.0
VS.MAX_TRACE_LENGTH = 56755.84086241697115430736
VS.DEG2RAD = 0.01745329251994329576
VS.RAD2DEG = 57.29577951308232087679
VS.PI = 3.14159265358979323846
VS.RAND_MAX = 0x7FFF

local Msg,Warning = Msg,Warning
local append,select,type,f,floor = table.insert,select,type,string.format,math.floor
local unpack,pack = unpack,function(...) return { n = select("#",...),... } end

if not table.pack then table.pack = pack end
if not table.unpack then table.unpack = unpack end

local throw = function(msg)

	local info = debug.getinfo(2,"Sl")
	Warning(msg)
	Warning(f("\t%s:%d\n",info.short_src,info.currentline))
	return false

end

if IsServer() then do ---------------------------------------------------

local tQueue = {}
local nCompletedInQueue = 0
local bPlayerSpawned = false

-------------------------------------------------------------------------
-- Input:  closure, string|closure error, params...
--
-- Output: true on success
-------------------------------------------------------------------------
function VS.OnPlayerSpawn(...)

	local ply = Entities:GetLocalPlayer()

	if bPlayerSpawned or ply and
	   type(ply) == "table" and
	   type(ply.__self) == "userdata" and
	   not ply:IsNull() and
	   ply:GetClassname() == "player" then
		return Warning("VS::OnPlayerSpawn: player is already spawned\n")
	end

	local argv = pack(...)
	local func = argv[1]

	if argv.n == 0 or type(func) ~= "function" then
		return throw("VS::OnPlayerSpawn: invalid parameter 1\n")
	end

	local info = debug.getinfo(func,"S")

	for i = 1, #tQueue do
		if tQueue[tQueue[i]].source == info.source then
			return throw("VS::OnPlayerSpawn: found event from this file in the queue, aborting\n")
		end
	end

	local msg = "VS::OnPlayerSpawn: closure added to queue"
	local err_cb,err_msg,params

	if argv.n > 1 then

		local typ = type(argv[2])

		if typ == "string" then
			err_msg = argv[2]
		elseif typ == "function" then
			err_cb = argv[2]
		elseif typ ~= "nil" then
			return throw("VS::OnPlayerSpawn: parameter 2 has an invalid type '"..typ.."' ; expected 'string|function'\n")
		end

		if argv.n > 2 then

			params = {}

			for i = 3, argv.n do
				append(params,argv[i])
			end

			msg = msg.." with "..tostring(#params).." parameter(s)"

		end

	end

	append(tQueue,func)
	tQueue[func] =
	{
		bSuccess = false,
		params = params,
		err_cb = err_cb,
		err_msg = err_msg,
		source = info.source,
		src = info.short_src,
		line = info.linedefined
	}

	Msg(msg.."\n")

	return true

end

local function RunQueue()

	local len = #tQueue

	for i = 1, len do

		local f = tQueue[i]
		local t = tQueue[f]

		if not t.bSuccess then

			local p,r = t.params

			if p then
				r = f(unpack(p))
			else
				r = f()
			end

			if r or r == nil then

				t.bSuccess = true
				nCompletedInQueue = nCompletedInQueue+1

			end

		end

	end

	if nCompletedInQueue == len then
		return true
	else
		return false
	end

end

local function FixLevelChange()

	local bIsTools = IsInToolsMode()
	local szMapName = GetMapName()

	if szMapName == "a1_intro_world" then

		local hCmd = Entities:FindByName(nil,"command_change_level")
		if hCmd then hCmd:Kill() end

		local ent = Entities:FindByName(nil,"relay_stun_player")
		if ent then

			ent:GetOrCreatePrivateScriptScope().OnTriggerLevelChange = function()

				ent:SetContextThink("VS_LevelChange",function()

					if bIsTools then
						SendToConsole("addon_tools_map a1_intro_world_2")
					else
						SendToConsole("addon_play a1_intro_world_2")
					end

				end,1.5)

			end

			ent:RedirectOutput("OnTrigger","OnTriggerLevelChange",ent)

		end

	end

end

local function Destroy()

	throw = nil
	tQueue = nil
	RunQueue = nil
	nCompletedInQueue = nil
	FixLevelChange = nil
	Destroy = nil

end

if not _VS.__iEventSpawn and not Entities:GetLocalPlayer()then

	_VS.__iEventSpawn = ListenToGameEvent("player_connect_full", function()

		bPlayerSpawned = true

		if _VS.__hSpawnInit then
			_VS.__hSpawnInit:Kill()
			_VS.__hSpawnInit = nil
		end

		FixLevelChange()

		if not RunQueue() then

			local nInitCount = 0

			_VS.__hSpawnInit = Entities:CreateByClassname("soundent")

			_VS.__hSpawnInit:SetContextThink("",function()

				nInitCount = nInitCount+1

				if RunQueue() or nInitCount > 10 then

					if nInitCount > 10 then

						Warning(f("VS::PostPlayerSpawn: timeout, failed to execute %d function(s)\n",
						                                                   #tQueue-nCompletedInQueue))

						for i = 1, #tQueue do

							local t = tQueue[tQueue[i]]

							if not t.bSuccess then

								if t.err_msg then
									Warning(t.err_msg.."\n")
								elseif t.err_cb then
									t.err_cb()
								else
									Warning(f("\t%s:%d\n",t.src,t.line))
								end

							end

						end

					end

					Destroy()
					nInitCount = nil
					_VS.__hSpawnInit:Kill()
					_VS.__hSpawnInit = nil
					StopListeningToGameEvent(_VS.__iEventSpawn)
					_VS.__iEventSpawn = nil

					return

				end

				return 1.0

			end,1.0)

			Msg("VS::PostPlayerSpawn: running ("..tostring(_VS.__hSpawnInit:entindex())..")\n")

		else

			Destroy()
			StopListeningToGameEvent(_VS.__iEventSpawn)
			_VS.__iEventSpawn = nil

		end

	end, nil)

end

end end -- IsServer

function VS.IsAddonEnabled(str)

	for addon in Convars:GetStr("default_enabled_addons_list"):gmatch("[^,]+") do
		if addon == str then
			return true
		end
	end
	return false

end

-------------------------------------------------------------------------
-- math.nut

function VS.IsInteger(f) return floor(f) == f end

function VS.IsLookingAt( vSrc, vTarget, vDir, cosTolerance )

	return (vTarget-vSrc):Normalized():Dot(vDir) >= cosTolerance

end

function VS.PointOnLineNearestPoint( vStartPos, vEndPos, vPoint )

	local v1 = vEndPos - vStartPos
	local v1l = v1:Length()
	local dist = v1:Dot(vPoint-vStartPos) / (v1l*v1l)

	if dist < 0.0 then
		return vStartPos
	elseif dist > 1.0 then
		return vEndPos
	else
		return vStartPos + v1 * dist
	end

end

function VS.Approach( tg, val, spd )

	local dt = tg - val

	if dt > spd then
		val = val + spd
	elseif dt < -spd then
		val = val - spd
	else
		val = tg
	end

	return val

end

function VS.ApproachAngle( tg, val, spd )

	tg = tg % 360.0

	if tg > 180.0 then
		tg = tg - 360.0
	elseif tg < -180.0 then
		tg = tg + 360.0
	end

	val = val % 360.0

	if val > 180.0 then
		val = val - 360.0
	elseif val < -180.0 then
		val = val + 360.0
	end

	local dt = tg - val

	dt = dt % 360.0

	if dt > 180.0 then
		dt = dt - 360.0
	elseif dt < -180.0 then
		dt = dt + 360.0
	end

	if spd < 0 then
		spd = -spd
	end

	if dt > spd then
		val = val + spd
	elseif dt < -spd then
		val = val - spd
	else
		val = tg
	end

	return val

end

function VS.AngleDiff( dst, src )

	local ang = dst - src

	ang = ang % 360.0

	if ang > 180.0 then
		ang = ang - 360.0
	elseif ang < -180.0 then
		ang = ang + 360.0
	end

	return ang

end

function VS.AngleNormalize( ang )

	ang = ang % 360.0

	if ang > 180.0 then
		ang = ang - 360.0
	elseif ang < -180.0 then
		ang = ang + 360.0
	end

	return ang

end

function VS.QAngleNormalize( ang )

	ang.x = ang.x % 360.0
	ang.y = ang.y % 360.0
	ang.z = ang.z % 360.0
	if ang.x > 180.0 then
		ang.x = ang.x - 360.0
	elseif ang.x < -180.0 then
		ang.x = ang.x + 360.0
	end
	if ang.y > 180.0 then
		ang.y = ang.y - 360.0
	elseif ang.y < -180.0 then
		ang.y = ang.y + 360.0
	end
	if ang.z > 180.0 then
		ang.z = ang.z - 360.0
	elseif ang.z < -180.0 then
		ang.z = ang.z + 360.0
	end

end

function VS.SnapDirectionToAxis( vDir, eps )

	local proj = 1.0 - eps

	local x if vDir.x < 0 then x = -vDir.x else x = vDir.x end

	if x > proj then

		if vDir.x < 0.0 then
			vDir.x = -1.0
		else
			vDir.x = 1.0
		end
		vDir.y = 0.0
		vDir.z = 0.0

		return vDir

	end

	local y if vDir.y < 0 then y = -vDir.y else y = vDir.y end

	if y > proj then

		if vDir.y < 0.0 then
			vDir.y = -1.0
		else
			vDir.y = 1.0
		end
		vDir.z = 0.0
		vDir.x = 0.0

		return vDir

	end

	local z if vDir.z < 0 then z = -vDir.z else z = vDir.z end

	if z > proj then

		if vDir.z < 0.0 then
			vDir.z = -1.0
		else
			vDir.z = 1.0
		end
		vDir.x = 0.0
		vDir.y = 0.0

		return vDir

	end

end

function VS.VectorsAreEqual( a, b, tolerance )

	if not tolerance then tolerance = 0 end

	local x = a.x - b.x
	if x < 0 then x = -x end

	local y = a.y - b.y
	if y < 0 then y = -y end

	local z = a.z - b.z
	if z < 0 then z = -z end

	return ( x <= tolerance and
	         y <= tolerance and
	         z <= tolerance )
end

-------------------------------------------------------------------------
-- utilsinit.lua

if package.loaded["utils.utilsinit"] then

function Deg2Rad(deg)
	return deg * 0.01745329251994329576
end

function Rad2Deg(rad)
	return rad * 57.29577951308232087679
end

function VectorDistanceSq(v1, v2)
	local l = (v1-v2):Length()
	return l*l
end

function VectorDistance(v1, v2)
	return (v1-v2):Length()
end

function VectorLerp(t, a, b)
	local c = (b-a)*t
	return a+c
end

end

-------------------------------------------------------------------------

return VS
