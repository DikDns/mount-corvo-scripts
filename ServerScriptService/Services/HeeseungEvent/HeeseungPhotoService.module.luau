-- ===================================================================
-- HeeseungPhotoService.module.luau (Modul Utama/Controller)
-- Mengorkestrasi semua sub-modul untuk menjalankan event.
-- Ini adalah satu-satunya modul yang perlu diakses dari luar.
-- ===================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Memuat semua modul pembantu
local Config = require(script.Parent.EventConfig)
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)
local PhotoInstanceManager = require(script.Parent.PhotoInstanceManager)
local PhotoStreamer = require(script.Parent.PhotoStreamer)
local EventReporter = require(script.Parent.EventReporter)
local PlayerReportGenerator = require(script.Parent.PlayerReportGenerator)
local EventTime = require(ReplicatedStorage.Modules.HeeseungEvent.EventTime)
local DiscordLogService = require(ServerScriptService.Services.DiscordLogService)
local DiscordEmbeds = require(ServerScriptService.Services.DiscordEmbeds)

local ShowNotification = ReplicatedStorage.Remotes:WaitForChild("ShowNotification")
local SyncPlayerDataEvent = ReplicatedStorage.HeeseungEventRemotes:WaitForChild("SyncPlayerData")

local HeeseungPhotoService = {}

-- Inisialisasi service, terutama untuk memulai loop streaming
function HeeseungPhotoService:Init()
	PhotoStreamer:Init()

	-- Menangani pemain yang sudah ada di server saat skrip dimuat
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			self:CheckAndResumeHunt(player)
		end)
	end

	Players.PlayerAdded:Connect(function(player)
		self:CheckAndResumeHunt(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		-- Tidak perlu cleanup instance di sini karena streamer akan menanganinya
	end)
end

-- API Publik yang diekspos ke skrip lain
function HeeseungPhotoService:GetPlayerQuestStatus(player)
	return PlayerDataHandler:GetPlayerQuestStatus(player)
end

function HeeseungPhotoService:StartHunt(player)
	if Config.DEBUG_MODE then print(`[Service] Memulai perburuan untuk {player.Name}`) end

	local newData = PlayerDataHandler:GenerateInitialHuntData()
	local success = PlayerDataHandler:SavePlayerData(player, newData)

	if success then
		local eventPeriod = EventTime:getEventPeriod()
		PhotoInstanceManager:CreatePhotosForPlayer(player, newData.pendingPhotos, eventPeriod)

		local embed = DiscordEmbeds:AdminEventLog(player, "Player Started Event")
		DiscordLogService:SendEmbedLog("admin", embed)

		SyncPlayerDataEvent:FireClient(player, newData)
	end
end

function HeeseungPhotoService:OnPhotoCollected(player, photoModel, iconId)
	if not photoModel or not photoModel:IsA("Model") then return end

	local photoIdToCollect = photoModel:GetAttribute("PhotoId")
	if not photoIdToCollect then return end

	local data = PlayerDataHandler:GetPlayerData(player)
	if not data then return end

	local foundPhotoData
	for i, photoData in ipairs(data.pendingPhotos) do
		if photoData.id == photoIdToCollect then
			foundPhotoData = table.remove(data.pendingPhotos, i)
			break
		end
	end

	if foundPhotoData then
		foundPhotoData.collectedTimestamp = os.time()
		table.insert(data.collectedPhotos, foundPhotoData)
		PlayerDataHandler:SavePlayerData(player, data)
		photoModel:Destroy()

		SyncPlayerDataEvent:FireClient(player, data)

		local collectedCount = #data.collectedPhotos
		local totalCount = Config.TOTAL_PHOTOS_TO_FIND

		local loc = foundPhotoData.location
		local details = {
			["Photo ID"] = foundPhotoData.id,
			["Photo Position"] = string.format("`X: %.1f, Y: %.1f, Z: %.1f`", loc.x, loc.y, loc.z),
			["Photo Decals"] = "`" .. iconId .. "`",
			["Progress"] = "`" .. collectedCount .. '/' .. totalCount .. "`",
		}
		local imageUrl = Config.PHOTO_ASSETS[iconId].imageUrl
		local adminEmbed = DiscordEmbeds:AdminEventLog(player, "Player Collected Photo", details, imageUrl)

		print(adminEmbed)
		DiscordLogService:SendEmbedLog("admin", adminEmbed)

		if collectedCount >= totalCount then
			ShowNotification:FireClient(player, {
				icon = iconId,
				title = "Quest Complete!",
				subtitle = "Congratulations! You have found all the photos.",
			})

			local completedAdminEmbed = DiscordEmbeds:AdminEventLog(player, "Player Completed Event")
			DiscordLogService:SendEmbedLog("admin", completedAdminEmbed)
		else
			ShowNotification:FireClient(player, {
				icon = iconId,
				title = "Photo Collected!",
				subtitle = string.format("You have found %d out of %d photos.", collectedCount, totalCount)
			})
		end

		print(player.Name .. " mengoleksi foto #" .. photoIdToCollect .. "! (" .. collectedCount .. "/" .. totalCount .. ")")
	end
end

function HeeseungPhotoService:CheckAndResumeHunt(player)
	if Config.DEBUG_MODE then print(`[Service] Memeriksa dan melanjutkan perburuan untuk {player.Name}`) end
	local data = PlayerDataHandler:GetPlayerData(player)
	if data and data.pendingPhotos and #data.pendingPhotos > 0 then
		SyncPlayerDataEvent:FireClient(player, data)
		local eventPeriod = EventTime:getEventPeriod()
		PhotoInstanceManager:CreatePhotosForPlayer(player, data.pendingPhotos, eventPeriod)
	end
end

function HeeseungPhotoService:Admin_ResetPlayerData(player)
	if Config.DEBUG_MODE then print(`[Service] Mereset data untuk {player.Name}`) end

	local success = PlayerDataHandler:ResetPlayerData(player)

	if success then
		SyncPlayerDataEvent:FireClient(player, { pendingPhotos = {}, collectedPhotos = {} })
		PhotoInstanceManager:CleanupPhotosForPlayer(player)
		PhotoStreamer:CleanupStreamedPhotosForPlayer(player)
	end
end

function HeeseungPhotoService:Admin_GetParticipantList()
	if Config.DEBUG_MODE then print("[Service] Membuat laporan peserta...") end
	return EventReporter:GetAllParticipantsFormatted()
end

function HeeseungPhotoService:Admin_GetPlayerReport(player)
	if Config.DEBUG_MODE then print(`[Service] Membuat laporan detail untuk {player.Name}...`) end
	return PlayerReportGenerator:GenerateReportForPlayer(player)
end

return HeeseungPhotoService
