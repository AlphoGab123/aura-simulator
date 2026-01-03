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

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "Remotes"
    remotesFolder.Parent = ReplicatedStorage
end

local focusToggle = remotesFolder:FindFirstChild("FocusToggle")
if not focusToggle or not focusToggle:IsA("RemoteEvent") then
    if focusToggle and not focusToggle:IsA("RemoteEvent") then
        focusToggle:Destroy()
    end

    focusToggle = Instance.new("RemoteEvent")
    focusToggle.Name = "FocusToggle"
    focusToggle.Parent = remotesFolder
end

return {
    FocusToggle = focusToggle,
}
