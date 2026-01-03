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
