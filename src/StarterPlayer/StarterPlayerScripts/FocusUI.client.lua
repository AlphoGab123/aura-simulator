-- Renders a simple focus progress UI and updates it from server events.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local focusUpdateEvent = remoteEvents:WaitForChild("FocusUpdate")

local function createBar(parent)
    local container = Instance.new("Frame")
    container.Name = "FocusBar"
    container.Size = UDim2.new(0, 320, 0, 18)
    container.AnchorPoint = Vector2.new(0.5, 1)
    container.Position = UDim2.new(0.5, 0, 1, -40)
    container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    container.BorderSizePixel = 0
    container.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(70, 70, 70)
    stroke.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0
    fill.Parent = container

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fill

    return container, fill
end

local function createLabel(name, text, position, parent)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0, 200, 0, 18)
    label.Position = position
    label.AnchorPoint = Vector2.new(0.5, 1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Text = text
    label.Parent = parent
    return label
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FocusUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local barContainer, barFill = createBar(screenGui)

local stateLabel = createLabel(
    "StateLabel",
    "State: Calm",
    barContainer.Position - UDim2.new(0, 0, 0, 20),
    screenGui
)

local focusLabel = createLabel(
    "FocusLabel",
    "Focus: 0",
    barContainer.Position + UDim2.new(0, 0, 0, 4),
    screenGui
)
focusLabel.TextSize = 12
focusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

local function getStateText(focusValue)
    if focusValue >= 60 then
        return "Instinct"
    elseif focusValue >= 25 then
        return "Focused"
    else
        return "Calm"
    end
end

local function updateUI(focusValue)
    local clampedPercent = math.clamp(focusValue, 0, 100) / 100
    barFill.Size = UDim2.new(clampedPercent, 0, 1, 0)

    stateLabel.Text = string.format("State: %s", getStateText(focusValue))
    focusLabel.Text = string.format("Focus: %d", math.floor(focusValue))
end

focusUpdateEvent.OnClientEvent:Connect(updateUI)

-- Initialize with zero focus.
updateUI(0)
