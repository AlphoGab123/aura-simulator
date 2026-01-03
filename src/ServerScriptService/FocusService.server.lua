-- FocusService.server.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local FocusToggle = remoteFolder:WaitForChild("FocusToggle")
local FocusUpdate = remoteFolder:WaitForChild("FocusUpdate")

-- Settings (tune later)
local MAX_FOCUS = 100
local TICK = 0.25

local GAIN_IDLE = 1      -- per tick when not holding
local GAIN_HOLD = 4      -- per tick when holding
local DECAY_IDLE = 2     -- per tick decay when not holding and focus > 0

local function clamp(n, a, b)
	if n < a then return a end
	if n > b then return b end
	return n
end

local function getStateLabel(focus)
	if focus >= 80 then
		return "INSTINCT"
	elseif focus >= 40 then
		return "FOCUSED"
	else
		return "CALM"
	end
end

local function ensureLeaderstats(plr)
	local ls = plr:FindFirstChild("leaderstats")
	if not ls then
		ls = Instance.new("Folder")
		ls.Name = "leaderstats"
		ls.Parent = plr
	end

	local focusVal = ls:FindFirstChild("Focus")
	if not focusVal then
		focusVal = Instance.new("IntValue")
		focusVal.Name = "Focus"
		focusVal.Value = 0
		focusVal.Parent = ls
	end

	return focusVal
end

-- per-player runtime state
local holding = {} -- [player] = true/false

Players.PlayerAdded:Connect(function(plr)
	holding[plr] = false
	ensureLeaderstats(plr)
end)

Players.PlayerRemoving:Connect(function(plr)
	holding[plr] = nil
end)

FocusToggle.OnServerEvent:Connect(function(plr, isHolding)
	if typeof(isHolding) ~= "boolean" then return end
	holding[plr] = isHolding
end)

-- main loop
task.spawn(function()
	while true do
		task.wait(TICK)

		for _, plr in ipairs(Players:GetPlayers()) do
			local focusVal = ensureLeaderstats(plr)
			local f = focusVal.Value

			if holding[plr] then
				f = f + GAIN_HOLD
			else
				-- small idle gain + decay when not holding
				f = f + GAIN_IDLE
				if f > 0 then
					f = f - DECAY_IDLE
				end
			end

			f = clamp(f, 0, MAX_FOCUS)
			focusVal.Value = f

			-- Send to this player for UI
			local state = getStateLabel(f)
			FocusUpdate:FireClient(plr, f, MAX_FOCUS, state)

			-- Optional debug
			-- print(plr.Name .. " Focus:", f)
		end
	end
end)

print("[AuraSimulator] FocusService loaded")
