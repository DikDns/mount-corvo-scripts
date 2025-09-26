--!nonstrict
--[[
	SpecialAchievementHandler
]]

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AchievementService = require(ServerScriptService.Services.AchievementService)
local PermissionData = require(ReplicatedStorage.Modules.CmdrPermissionData)

local DEV_ACHIEVEMENT_ID = "017"

local function onPlayerAdded(joiningPlayer)
	local playerRank = joiningPlayer:GetRankInGroup(PermissionData.GroupId)

	if playerRank >= PermissionData.Ranks.Developer then
		print(("[Event] Seorang Developer telah bergabung: %s"):format(joiningPlayer.Name))

		task.wait(2)

		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer ~= joiningPlayer then
				AchievementService.AwardAchievement(otherPlayer, DEV_ACHIEVEMENT_ID)
			end
		end
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)

print("✅ SpecialAchievementHandler is running.")
