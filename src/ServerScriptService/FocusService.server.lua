local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)

local TICK_RATE = 0.1
local FOCUS_GAIN = 1
local FOCUS_DECAY = -0.5
local REBIRTH_COOLDOWN = 1
local FOCUS_CAP_FOR_REBIRTH = 100
local MULTIPLIER_STEP = 0.25

local focusData = {}
local FocusUpdate = Remotes.FocusUpdate
local RebirthRequest = Remotes.RebirthRequest

local function updateMultiplier(data)
    data.multiplier = 1 + (data.rebirths * MULTIPLIER_STEP)
    data.stats.Multiplier.Value = string.format("x%.2f", data.multiplier)
end

local function initializePlayer(player)
    local statsFolder = Instance.new("Folder")
    statsFolder.Name = "leaderstats"
    statsFolder.Parent = player

    local focusStat = Instance.new("NumberValue")
    focusStat.Name = "Focus"
    focusStat.Value = 0
    focusStat.Parent = statsFolder

    local rebirthsStat = Instance.new("IntValue")
    rebirthsStat.Name = "Rebirths"
    rebirthsStat.Value = 0
    rebirthsStat.Parent = statsFolder

    local multiplierStat = Instance.new("StringValue")
    multiplierStat.Name = "Multiplier"
    multiplierStat.Value = "x1.00"
    multiplierStat.Parent = statsFolder

    local multiplier = 1

    focusData[player] = {
        value = 0,
        focusing = false,
        nextDebugThreshold = 20,
        rebirths = 0,
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

local function onRebirthRequest(player)
    local data = focusData[player]
    if not data then
        return
    end

    local now = os.clock()
    if now - data.lastRebirth < REBIRTH_COOLDOWN then
        return
    end

    if data.value < FOCUS_CAP_FOR_REBIRTH then
        return
    end

    data.lastRebirth = now
    data.value = 0
    data.rebirths += 1
    data.nextDebugThreshold = 20

    data.stats.Focus.Value = 0
    data.stats.Rebirths.Value = data.rebirths

    updateMultiplier(data)

    FocusUpdate:FireClient(player, math.floor(data.value), data.multiplier)
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
        data.value = math.max(0, data.value + delta)

        data.stats.Focus.Value = math.floor(data.value)

        FocusUpdate:FireClient(player, math.floor(data.value), data.multiplier)

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
