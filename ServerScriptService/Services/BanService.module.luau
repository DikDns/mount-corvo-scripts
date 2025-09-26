--!nonstrict
--[[
	BanService
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local banDataStore = DataStoreService:GetDataStore("Bans_V1")

local BanService = {}

function BanService.Ban(targetPlayer: Player, bannerPlayer: Player, durationHours: number, reason: string)
	if not targetPlayer then return false, "Target player not found." end

	local banInfo = {
		Reason = reason or "No reason provided.",
		Banner = bannerPlayer.Name,
		BanTime = os.time(),
		DurationHours = durationHours,
		UnbanTime = (durationHours == -1) and -1 or (os.time() + durationHours * 3600), -- -1 for permanent
	}

	local success, err = pcall(function()
		banDataStore:SetAsync("User-" .. targetPlayer.UserId, banInfo)
	end)

	if success then
		local durationText = (durationHours == -1) and "permanently" or ("for %d hours"):format(durationHours)
		targetPlayer:Kick(("You have been banned %s by %s.\nReason: %s"):format(durationText, bannerPlayer.Name, banInfo.Reason))
		return true
	else
		warn("Failed to save ban data:", err)
		return false, "Failed to save ban data."
	end
end

-- Fungsi untuk memeriksa apakah seorang pemain di-ban
function BanService.IsBanned(player)
	local success, banInfo = pcall(function()
		return banDataStore:GetAsync("User-" .. player.UserId)
	end)

	if success and banInfo then
		if banInfo.UnbanTime == -1 then -- Ban permanen
			return true, banInfo
		end

		if os.time() < banInfo.UnbanTime then -- Masih dalam durasi ban
			return true, banInfo
		else
			-- Ban sudah kedaluwarsa, hapus datanya
			banDataStore:RemoveAsync("User-" .. player.UserId)
			return false
		end
	end

	return false
end

function BanService.Unban(targetUserId)
	if type(targetUserId) ~= "number" then
		return false, "Invalid UserId provided."
	end

	local success, err = pcall(function()
		banDataStore:RemoveAsync("User-" .. targetUserId)
	end)

	if success then
		print("Ban data removed for UserId:", targetUserId)
		return true
	else
		warn("Failed to remove ban data for UserId:", targetUserId, "| Error:", err)
		return false, "Failed to remove ban data from DataStore."
	end
end


return BanService
