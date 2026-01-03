-- FocusUI.client.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local FocusUpdate = remoteFolder:WaitForChild("FocusUpdate")

-- Build simple UI
local gui = Instance.new("ScreenGui")
gui.Name = "FocusHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 1)
frame.Position = UDim2.new(0.5, 0, 0.95, 0)
frame.Size = UDim2.new(0, 320, 0, 60)
frame.BackgroundTransparency = 0.25
frame.Parent = gui

local barBg = Instance.new("Frame")
barBg.Position = UDim2.new(0, 10, 0, 30)
barBg.Size = UDim2.new(1, -20, 0, 18)
barBg.BackgroundTransparency = 0.35
barBg.Parent = frame

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.Parent = barBg

local label = Instance.new("TextLabel")
label.Position = UDim2.new(0, 10, 0, 5)
label.Size = UDim2.new(1, -20, 0, 20)
label.BackgroundTransparency = 1
label.TextScaled = true
label.Text = "Focus: 0"
label.Parent = frame

local function setFill(focus, maxFocus, state)
	local ratio = 0
	if maxFocus > 0 then ratio = math.clamp(focus / maxFocus, 0, 1) end
	barFill.Size = UDim2.new(ratio, 0, 1, 0)
	label.Text = string.format("%s  |  Focus: %d / %d", tostring(state), focus, maxFocus)
end

FocusUpdate.OnClientEvent:Connect(function(focus, maxFocus, state)
	if typeof(focus) ~= "number" then return end
	if typeof(maxFocus) ~= "number" then maxFocus = 100 end
	setFill(focus, maxFocus, state or "FOCUS")
end)

print("[AuraSimulator] FocusUI loaded (client)")
