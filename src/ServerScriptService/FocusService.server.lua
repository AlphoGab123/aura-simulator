-- FocusService.server.lua
-- Server-authoritative focus gain/decay. Listens to FocusToggle RemoteEvent.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local FocusToggle = remoteFolder:WaitForChild("FocusToggle")

-- CONFIG
local BASE_GAIN = 1
local DECAY = 0.5
local TICK = 0.1

local data = {}

local function setupLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local focusValue = Instance.new("IntValue")
	focusValue.Name = "Focus"
	focusValue.Value = 0
	focusValue.Parent = leaderstats

	return focusValue
end

Players.PlayerAdded:Connect(function(player)
	data[player] = {
		focus = 0,
		focusing = false,
		focusValue = setupLeaderstats(player),
		lastPrinted = -1,
	}
end)

Players.PlayerRemoving:Connect(function(player)
	data[player] = nil
end)

FocusToggle.OnServerEvent:Connect(function(player, isFocusing)
	local d = data[player]
	if not d then return end
	if typeof(isFocusing) ~= "boolean" then return end
	d.focusing = isFocusing
end)

print("[AuraSimulator] FocusService loaded")

task.spawn(function()
	while true do
		for player, d in pairs(data) do
			if d.focusing then
				d.focus += BASE_GAIN
			else
				d.focus = math.max(0, d.focus - DECAY)
			end

			local current = math.floor(d.focus)
			d.focusValue.Value = current

			if current > 0 and current % 20 == 0 and current ~= d.lastPrinted then
				d.lastPrinted = current
				print(player.Name, "Focus:", current)
			end
		end
		task.wait(TICK)
	end
end)
