
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TipBroadcast = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TipBroadcast")
local TipsData = require(ReplicatedStorage.Modules.TipsData)

local BROADCAST_INTERVAL = 180
local tipIndex = 1

if not TipsData or #TipsData == 0 then
	warn("TipsData is empty or not found!")
	return
end

local function broadcastNextTip()
	local tip = TipsData[tipIndex]

	if tip then
		local success = pcall(function()
			TipBroadcast:FireAllClients(tip)
		end)

		if success then
			print("📢 Broadcasting tip:", tip)
		else
			warn("Failed to broadcast tip:", tip)
		end
	else
		warn("Tip not found at index:", tipIndex)
	end

	-- Move to next tip
	tipIndex = tipIndex + 1
	if tipIndex > #TipsData then
		tipIndex = 1
	end
end

task.spawn(function()
	while true do
		task.wait(BROADCAST_INTERVAL)
		broadcastNextTip()
	end
end)
