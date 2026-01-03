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
