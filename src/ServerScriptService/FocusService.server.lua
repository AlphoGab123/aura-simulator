local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes)

local TICK_RATE = 0.1
local FOCUS_GAIN = 1
local FOCUS_DECAY = -0.5

local focusData = {}
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local FocusUpdate = remoteEvents:WaitForChild("FocusUpdate")

local function initializePlayer(player)
    focusData[player] = {
        value = 0,
        focusing = false,
        nextDebugThreshold = 20,
    }
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

Players.PlayerAdded:Connect(initializePlayer)
Players.PlayerRemoving:Connect(cleanupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    initializePlayer(player)
end

Remotes.FocusToggle.OnServerEvent:Connect(onFocusToggle)

local function updateFocus()
    for player, data in pairs(focusData) do
        local delta = data.focusing and FOCUS_GAIN or FOCUS_DECAY
        data.value = math.max(0, data.value + delta)

        FocusUpdate:FireClient(player, math.floor(data.value))

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
