local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShowNotificationEvent = ReplicatedStorage.Remotes.ShowNotification
local AchievementsData = require(ReplicatedStorage.Modules.AchievementsData)

local AchievementService = {}
local SUMMIT_ACHIEVEMENT_MILESTONES = {
	[5] = "011",
	[10] = "012",
	[25] = "013",
	[50] = "014",
	[100] = "015",
	[1000] = "016",
}


function AchievementService.CheckSummitAchievements(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local summitsStat = leaderstats:FindFirstChild("Summits")
	if not summitsStat then return end

	local totalSummits = summitsStat.Value
	print(("[AchievementService] Mengecek summit achievements untuk %s (Total: %d)"):format(player.Name, totalSummits))

	for milestone, achievementId in pairs(SUMMIT_ACHIEVEMENT_MILESTONES) do
		if totalSummits >= milestone then
			AchievementService.AwardAchievement(player, achievementId)
		end
	end
end


function AchievementService.AwardAchievement(player, achievementId)
	if not player or not achievementId then return end

	local achievementInfo = AchievementsData[achievementId]
	if not achievementInfo then
		warn("Mencoba memberikan achievement yang tidak ada: " .. achievementId)
		return
	end

	local playerData = player:WaitForChild("PlayerData")
	local achievementsFolder = playerData:WaitForChild("Achievements")
	if not achievementsFolder then
		warn("Folder PlayerAchievements tidak ditemukan untuk pemain: " .. player.Name)
		return
	end

	if achievementsFolder:FindFirstChild(achievementId) then
		return
	end

	print("Memberikan achievement '" .. achievementInfo.Name .. "' kepada " .. player.Name)

	-- 1. Memberikan Roblox Badge
	local badgeId = achievementInfo.BadgeId
	if badgeId and badgeId ~= 0 then
		local success, result = pcall(function()
			BadgeService:AwardBadge(player.UserId, badgeId)
		end)

		if not success then
			warn("Gagal memberikan badge ID " .. badgeId .. " kepada pemain " .. player.Name .. ": " .. tostring(result))
		else
			print("Badge ID " .. badgeId .. " berhasil diberikan.")
		end
	end

	local achievementValue = Instance.new("BoolValue")
	achievementValue.Name = achievementId
	achievementValue.Value = true
	achievementValue.Parent = achievementsFolder

	ShowNotificationEvent:FireClient(player, {
		title = "Achievement Unlocked!",
		subtitle = achievementInfo.Name,
		icon = achievementInfo.IconId,
	})

	return true
end

return AchievementService
