local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)

local TICK_RATE = 0.1
local FOCUS_GAIN = 1
local FOCUS_DECAY = -0.5
local MAX_FOCUS = 100
local REBIRTH_COOLDOWN = 1
local MULTIPLIER_STEP = 0.25

local focusData = {}
local FocusUpdate = Remotes.FocusUpdate
local RebirthRequest = Remotes.RebirthRequest

local function computeMultiplier(rebirths)
    return 1 + (rebirths * MULTIPLIER_STEP)
end

local function initializePlayer(player)
    local statsFolder = player:FindFirstChild("leaderstats")
    if not statsFolder then
        statsFolder = Instance.new("Folder")
        statsFolder.Name = "leaderstats"
        statsFolder.Parent = player
    end

    local focusStat = statsFolder:FindFirstChild("Focus")
    if not focusStat or not focusStat:IsA("IntValue") then
        if focusStat then
            focusStat:Destroy()
        end
        focusStat = Instance.new("IntValue")
        focusStat.Name = "Focus"
        focusStat.Parent = statsFolder
    end
    focusStat.Value = 0

    local rebirthsStat = statsFolder:FindFirstChild("Rebirths")
    if not rebirthsStat or not rebirthsStat:IsA("IntValue") then
        if rebirthsStat then
            rebirthsStat:Destroy()
        end
        rebirthsStat = Instance.new("IntValue")
        rebirthsStat.Name = "Rebirths"
        rebirthsStat.Parent = statsFolder
    end
    rebirthsStat.Value = rebirthsStat.Value or 0

    local multiplierStat = statsFolder:FindFirstChild("Multiplier")
    if not multiplierStat or not multiplierStat:IsA("NumberValue") then
        if multiplierStat then
            multiplierStat:Destroy()
        end
        multiplierStat = Instance.new("NumberValue")
        multiplierStat.Name = "Multiplier"
        multiplierStat.Parent = statsFolder
    end

    local rebirths = rebirthsStat.Value or 0
    local multiplier = computeMultiplier(rebirths)
    multiplierStat.Value = multiplier

    focusData[player] = {
        value = 0,
        focusing = false,
        nextDebugThreshold = 20,
        rebirths = rebirths,
        multiplier = multiplier,
        lastRebirth = 0,
        stats = {
            Focus = focusStat,
            Rebirths = rebirthsStat,
            Multiplier = multiplierStat,
        },
    }

    updateMultiplier(focusData[player])
end

local function cleanupPlayer(player)
    focusData[player] = nil
end

local function onFocusToggle(player, isFocusing)
    local data = focusData[player]
    if not data then
        return
    end

    data.focusing = isFocusing and true or false
end

local function updateMultiplier(data)
    data.multiplier = computeMultiplier(data.rebirths)
    data.stats.Multiplier.Value = data.multiplier
end

local function onRebirthRequest(player)
    local data = focusData[player]
    if not data then
        return
    end

    local now = os.clock()
    if now - data.lastRebirth < REBIRTH_COOLDOWN then
        return
    end

    if data.value < MAX_FOCUS then
        return
    end

    data.lastRebirth = now
    data.value = 0
    data.rebirths += 1
    data.nextDebugThreshold = 20

    data.stats.Focus.Value = 0
    data.stats.Rebirths.Value = data.rebirths

    updateMultiplier(data)

    FocusUpdate:FireClient(player, data.stats.Focus.Value, data.multiplier, data.rebirths)
end

Players.PlayerAdded:Connect(initializePlayer)
Players.PlayerRemoving:Connect(cleanupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    initializePlayer(player)
end

Remotes.FocusToggle.OnServerEvent:Connect(onFocusToggle)
RebirthRequest.OnServerEvent:Connect(onRebirthRequest)

local function updateFocus()
    for player, data in pairs(focusData) do
        local delta = data.focusing and (FOCUS_GAIN * data.multiplier) or FOCUS_DECAY
        data.value = math.clamp(data.value + delta, 0, MAX_FOCUS)

        data.stats.Focus.Value = math.floor(data.value)

        FocusUpdate:FireClient(player, data.stats.Focus.Value, data.multiplier, data.rebirths)

        if data.value >= data.nextDebugThreshold then
            print(string.format("%s Focus: %s", player.Name, data.value))
            data.nextDebugThreshold += 20
        end
    end
end

while true do
    updateFocus()
    task.wait(TICK_RATE)
end
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
