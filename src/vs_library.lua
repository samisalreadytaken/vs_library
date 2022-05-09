-------------------------------------------------------------------------
--------------------- Copyright (c) samisalreadytaken -------------------
-------------------------------------------------------------------------

local VER = "0.1.4"

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

			msg = f( "%s with %d parameter(s)", msg, #params )

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

	Msg(f( "%s [%s]\n", msg, info.short_src ))

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
