-- Initializes shared RemoteEvents required by the game.
-- Keeps compatibility with Focus remotes and includes rebirth support.

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
ensureRemoteEvent("RebirthRequest")
-- ServerInit.server.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function ensureFolder(parent, name)
	local f = parent:FindFirstChild(name)
	if f and f:IsA("Folder") then return f end
	if f then f:Destroy() end
	f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

local function ensureRemoteEvent(parent, name)
	local r = parent:FindFirstChild(name)
	if r and r:IsA("RemoteEvent") then return r end
	if r then r:Destroy() end
	r = Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = parent
	return r
end

-- Create ReplicatedStorage.RemoteEvents
local remoteFolder = ensureFolder(ReplicatedStorage, "RemoteEvents")

-- Create needed remotes
ensureRemoteEvent(remoteFolder, "FocusToggle")  -- client -> server (start/stop holding)
ensureRemoteEvent(remoteFolder, "FocusUpdate")  -- server -> client (send focus value)

print("[AuraSimulator] ServerInit loaded")
