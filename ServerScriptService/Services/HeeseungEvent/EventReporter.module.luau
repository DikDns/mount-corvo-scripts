-- ===================================================================
-- EventReporter.module.luau
-- Mengambil data semua peserta event dari DataStore dan memformatnya
-- menjadi laporan yang rapi untuk admin.
-- ===================================================================

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Config = require(script.Parent.EventConfig)

local photoDataStore = DataStoreService:GetDataStore(Config.DATASTORE_NAME)
local EventReporter = {}

-- Mengambil dan memformat data semua peserta.
function EventReporter:GetAllParticipantsFormatted()
	local reportLines = {"=== Laporan Peserta Heeseung's Memory Trail ==="}
	local participantsFound = 0

	local success, pages = pcall(function()
		return photoDataStore:ListKeysAsync()
	end)

	if not success then
		warn("[EventReporter] Gagal mengakses DataStore untuk daftar keys:", pages)
		return "Gagal mengambil data dari DataStore."
	end

	while true do
		local items = pages:GetCurrentPage()
		for _, keyInfo in ipairs(items) do
			local keyName = keyInfo.KeyName
			local _, _, userId = keyName:find("Player_(%d+)")

			if userId then
				userId = tonumber(userId)
				local dataSuccess, data = pcall(function() return photoDataStore:GetAsync(keyName) end)
				local nameSuccess, playerName = pcall(function() return Players:GetNameFromUserIdAsync(userId) end)

				if dataSuccess and data and nameSuccess then
					participantsFound = participantsFound + 1
					local collectedCount = #data.collectedPhotos
					local totalCount = Config.TOTAL_PHOTOS_TO_FIND
					local status = (collectedCount >= totalCount) and "SELESAI" or "BERLANGSUNG"

					local line = string.format("- %s (ID: %d) | Progres: %d/%d | Status: %s",
						playerName or "N/A",
						userId,
						collectedCount,
						totalCount,
						status
					)
					table.insert(reportLines, line)
				end
			end
		end

		if pages.IsFinished then
			break
		end

		pages:AdvanceToNextPageAsync()
	end

	if participantsFound == 0 then
		return "Belum ada pemain yang memulai event Heeseung's Memory Trail."
	end

	table.insert(reportLines, "=============================================")
	return table.concat(reportLines, "\n")
end

return EventReporter
