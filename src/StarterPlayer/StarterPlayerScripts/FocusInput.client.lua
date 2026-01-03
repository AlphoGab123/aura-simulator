local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))

local function onInputBegan(input, gameProcessedEvent)
    if gameProcessedEvent then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Remotes.FocusToggle:FireServer(true)
    end
end

local function onInputEnded(input, gameProcessedEvent)
    if gameProcessedEvent then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Remotes.FocusToggle:FireServer(false)
    end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)
-- FocusInput.client.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local FocusToggle = remoteFolder:WaitForChild("FocusToggle")

local holding = false

local function setHolding(on)
	if holding == on then return end
	holding = on
	FocusToggle:FireServer(holding)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		setHolding(true)
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		setHolding(false)
	end
end)

print("[AuraSimulator] FocusInput loaded (client)")
