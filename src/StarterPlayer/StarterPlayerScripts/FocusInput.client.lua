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
