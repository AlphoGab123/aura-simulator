-- Initializes shared RemoteEvents required by the game.
-- Keeps compatibility with existing FocusToggle remotes and adds FocusUpdate.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "RemoteEvents"
    remotesFolder.Parent = ReplicatedStorage
end

local function ensureRemoteEvent(name)
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

ensureRemoteEvent("FocusToggle")
ensureRemoteEvent("FocusUpdate")
