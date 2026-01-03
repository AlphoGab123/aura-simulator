local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remotesFolder
if RunService:IsServer() then
    remotesFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "RemoteEvents"
        remotesFolder.Parent = ReplicatedStorage
    end
else
    remotesFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
end

local function ensureRemoteEvent(name)
    if RunService:IsServer() then
        local remote = remotesFolder:FindFirstChild(name)
        if remote and not remote:IsA("RemoteEvent") then
            remote:Destroy()
            remote = nil
        end

        if not remote then
            remote = Instance.new("RemoteEvent")
            remote.Name = name
            remote.Parent = remotesFolder
        end

        return remote
    end

    return remotesFolder:WaitForChild(name)
end

local focusToggle = ensureRemoteEvent("FocusToggle")
local focusUpdate = ensureRemoteEvent("FocusUpdate")
local rebirthRequest = ensureRemoteEvent("RebirthRequest")

return {
    FocusToggle = focusToggle,
    FocusUpdate = focusUpdate,
    RebirthRequest = rebirthRequest,
    Folder = remotesFolder,
}
