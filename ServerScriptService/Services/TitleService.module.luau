--!nonstrict
--[[
	TitleService (ModuleScript)
	Mengelola semua logika untuk memberikan, mencabut, dan mengganti title.
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AchievementService = require(ServerScriptService.Services.AchievementService)
local TitlesData = require(ReplicatedStorage.Modules.TitlesData)

local TitleService = {}

local SUMMIT_ACHIEVEMENT_MILESTONES = {
	[5] = "011",
	[10] = "012",
	[25] = "013",
	[50] = "014",
	[100] = "015",
	[250] = "016",
}


-- Fungsi untuk memberikan title ke pemain. Ini akan digunakan oleh sistem otomatis dan manual.
function TitleService.GrantTitle(player, titleId)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData or not TitlesData[titleId] then return false end

	local unlockedTitles = playerData.Titles.Unlocked
	if unlockedTitles:FindFirstChild(titleId) then return false end

	local newTitleValue = Instance.new("BoolValue")
	newTitleValue.Name = titleId
	newTitleValue.Value = true
	newTitleValue.Parent = unlockedTitles

	print(("[TitleService] Title '" .. TitlesData[titleId].Name .. "' diberikan kepada " .. player.Name):format(titleId, player.Name))
	return true
end

function TitleService.CheckSummitTitles(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local summitsStat = leaderstats:FindFirstChild("Summits")
	if not summitsStat then return end

	local totalSummits = summitsStat.Value
	print(("[TitleService] Mengecek summit titles untuk %s (Total: %d)"):format(player.Name, totalSummits))

	for id, data in pairs(TitlesData) do
		if data.UnlockMethod == "Stat" and data.UnlockRequirement.StatName == "Summits" then
			if totalSummits >= data.UnlockRequirement.Value then
				TitleService.GrantTitle(player, id)
			end
		end
	end
end

-- Fungsi untuk mencabut title dari pemain (untuk admin/cmdr).
function TitleService.RevokeTitle(player, titleId)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData or not TitlesData[titleId] then return false end

	local unlockedTitles = playerData.Titles.Unlocked
	local titleValue = unlockedTitles:FindFirstChild(titleId)

	if not titleValue then return false end -- Tidak punya title ini

	if playerData.Titles.Equipped.Value == titleId then
		TitleService.EquipTitle(player, "T001")
	end

	titleValue:Destroy()
	print(("[TitleService] Title '" .. TitlesData[titleId].Name .. "' dicabut dari " .. player.Name):format(titleId, player.Name))
	return true
end

-- Fungsi untuk mengganti title yang sedang dipakai.
function TitleService.EquipTitle(player, titleId)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData or not TitlesData[titleId] then return false end

	-- Verifikasi penting: Apakah pemain memiliki title ini?
	if not playerData.Titles.Unlocked:FindFirstChild(titleId) then
		warn(("[TitleService] %s mencoba memakai title '%s' yang tidak dimiliki."):format(player.Name, titleId))
		return false
	end

	playerData.Titles.Equipped.Value = titleId
	print(("[TitleService] %s sekarang memakai title: '%s'"):format(player.Name, TitlesData[titleId].Name))
	return true
end

local function checkStatAchievements(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local summitsStat = leaderstats:FindFirstChild("Summits")
	if not summitsStat then return end

	local totalSummits = summitsStat.Value

	for milestone, achievementId in pairs(SUMMIT_ACHIEVEMENT_MILESTONES) do
		if totalSummits >= milestone then
			AchievementService.AwardAchievement(player, achievementId)
		end
	end
end

function TitleService.CheckAllUnlocks(player)
	print("Mengecek semua potensi title untuk: " .. player.Name)
	local leaderstats = player:WaitForChild("leaderstats")
	local achievementsFolder = player.PlayerData and player.PlayerData:FindFirstChild("Achievements")

	for id, data in pairs(TitlesData) do
		local alreadyOwned = player.PlayerData.Titles.Unlocked:FindFirstChild(id)
		if alreadyOwned then continue end

		local method = data.UnlockMethod
		local requirement = data.UnlockRequirement
		local shouldGrant = false

		if method == "Default" then
			shouldGrant = true
		elseif method == "Stat" and leaderstats and requirement then
			local stat = leaderstats:FindFirstChild(requirement.StatName)
			if stat and stat.Value >= requirement.Value then
				shouldGrant = true
			end
		elseif method == "Achievement" and achievementsFolder and requirement then
			if #achievementsFolder:GetChildren() >= requirement.AchievementCount then
				shouldGrant = true
			end
		elseif method == "Gamepass" and requirement then
			local success, hasPass = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, requirement.GamepassId)
			end)
			if success and hasPass then shouldGrant = true end
		elseif method == "Group" and requirement and requirement.Rank and requirement.GroupId then
			local success, playerRank = pcall(function()
				return player:GetRankInGroup(requirement.GroupId)
			end)
			if success and playerRank >= requirement.Rank then
				shouldGrant = true
			end
		end

		if shouldGrant then
			TitleService.GrantTitle(player, id)
		end
	end

	-- [PENTING] Setelah semua title dicek, baru kita cek achievement dari stat
	checkStatAchievements(player)
end

return TitleService
