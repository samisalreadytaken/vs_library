-------------------------------------------------------------------------
--------------------- Copyright (c) samisalreadytaken -------------------
--- v0.1.3 --------------------------------------------------------------

local VER = "v0.1.3"

if not _VS then
	_VS = {}
elseif _VS[VER] then
	return _VS[VER]
end

local VS = {}
_VS[VER] = VS

-------------------------------------------------------------------------

MAX_COORD_FLOAT = 16384.0
MAX_TRACE_LENGTH = 56755.84086241697115430736
DEG2RAD = 0.01745329251994329576
RAD2DEG = 57.29577951308232087679
PI = 3.14159265358979323846
RAND_MAX = 0x7FFF

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

if SERVER_DLL then do ---------------------------------------------------

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
	   IsValidEntity(ply) and
	   not ply:IsNull() and
	   ply:GetClassname() == "player" then
		return Warning("VS::OnPlayerSpawn: player is already spawned\n")
	end

	local argv = pack(...)
	local func = argv[1]
	local info = debug.getinfo(func,"S")

	if argv.n == 0 or type(func) ~= "function" then
		return throw("VS::OnPlayerSpawn: invalid parameter 1 ["..info.short_src.."]\n")
	end

	for i = 1, #tQueue do
		if tQueue[tQueue[i]].source == info.source then
			return throw("VS::OnPlayerSpawn: found event from this file in the queue, aborting ["..info.short_src.."]\n")
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
		success = false,
		params = params,
		err_cb = err_cb,
		err_msg = err_msg,
		source = info.source,
		src = info.short_src,
		line = info.linedefined
	}

	Msg(msg.." ["..info.short_src.."]\n")

	return true

end

local function RunQueue()

	local len = #tQueue

	for i = 1, len do

		local f = tQueue[i]
		local t = tQueue[f]

		if not t.success then

			local p,r = t.params

			if p then
				r = f(unpack(p))
			else
				r = f()
			end

			if r or r == nil then

				t.success = true
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

if not _VS.__eventspawn and not Entities:GetLocalPlayer()then

	_VS.__eventspawn = ListenToGameEvent("player_connect_full", function()

		bPlayerSpawned = true

		if _VS.__dummy then
			_VS.__dummy:Kill()
			_VS.__dummy = nil
		end
		_VS.__dummy = Entities:CreateByClassname("soundent")

		FixLevelChange()

		if not RunQueue() then

			local nInitCount = 0

			_VS.__dummy:SetContextThink("", function()

				nInitCount = nInitCount+1

				if RunQueue() or nInitCount > 10 then

					if nInitCount > 10 then

						Warning(f("VS::PostPlayerSpawn: timeout, failed to execute %d function(s)\n",
						                                                   #tQueue-nCompletedInQueue))

						for i = 1, #tQueue do

							local t = tQueue[tQueue[i]]

							if not t.success then

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

					-- delete next frame to preserve other event listeners
					_VS.__dummy:SetContextThink( "R", function()
						StopListeningToGameEvent(_VS.__eventspawn)
						_VS.__eventspawn = nil
						_VS.__dummy:Kill()
						_VS.__dummy = nil
					end, 0.0 )

					return

				end

				return 1.0

			end, 1.0)

			Msg("VS::PostPlayerSpawn: running ("..tostring(_VS.__dummy:entindex())..")\n")

		else

			Destroy()
			_VS.__dummy:SetContextThink( "R", function()
				StopListeningToGameEvent(_VS.__eventspawn)
				_VS.__eventspawn = nil
				_VS.__dummy:Kill()
				_VS.__dummy = nil
			end, 0.0 )

		end

	end, nil)

end

end end -- SERVER_DLL

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
	local dist = v1:Dot( vPoint - vStartPos ) / ( v1l * v1l )
	if dist <= 0.0 then
		return vStartPos
	end

	if dist >= 1.0 then
		return vEndPos
	end

	return vStartPos + v1*dist
end

function VS.Approach( t, v, f )
	local dt = t - v
	if dt > f then
		return v + f
	end
	if dt < -f then
		return v - f
	end
	return t
end

function VS.ApproachAngle( t, v, f )
	t = t % 360.0
	if t > 180.0 then
		t = t - 360.0
	elseif t < -180.0 then
		t = t + 360.0
	end
	v = v % 360.0
	if v > 180.0 then
		v = v - 360.0
	elseif v < -180.0 then
		v = v + 360.0
	end
	local dt = t - v
	dt = dt % 360.0
	if dt > 180.0 then
		dt = dt - 360.0
	elseif dt < -180.0 then
		dt = dt + 360.0
	end
	if f < 0 then
		f = -f
	end
	if dt > f then
		return v + f
	end
	if dt < -f then
		return v - f
	end
	return t
end

function VS.AngleDiff( dst, src )
	local ang = dst - src
	ang = ang % 360.0
	if ang > 180.0 then
		return ang - 360.0
	end
	if ang < -180.0 then
		return ang + 360.0
	end
	return ang
end

function VS.AngleNormalize( ang )
	ang = ang % 360.0
	if ang > 180.0 then
		return ang - 360.0
	end
	if ang < -180.0 then
		return ang + 360.0
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

function VS.IsPointInBox( vec, min, max )

	return ( vec.x >= min.x and vec.x <= max.x and
	         vec.y >= min.y and vec.y <= max.y and
	         vec.z >= min.z and vec.z <= max.z )
end

function VS.IsBoxIntersectingBox( min1, max1, min2, max2 )
	if ( min1.x > max2.x ) or ( max1.x < min2.x ) then return false end
	if ( min1.y > max2.y ) or ( max1.y < min2.y ) then return false end
	if ( min1.z > max2.z ) or ( max1.z < min2.z ) then return false end
	return true
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
