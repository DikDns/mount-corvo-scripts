-- ===================================================================
-- PlayerDataHandler.module.luau
-- Mengelola semua operasi DataStore untuk progres event pemain.
-- ===================================================================

local DataStoreService = game:GetService("DataStoreService")
local GroupService = game:GetService("GroupService")
local Config = require(script.Parent.EventConfig)

local photoDataStore = DataStoreService:GetDataStore(Config.DATASTORE_NAME)
local PlayerDataHandler = {}

-- Menghasilkan data awal (lokasi acak) untuk pemain.
function PlayerDataHandler:GenerateInitialHuntData()
	local spawnsCopy = table.clone(Config.POTENTIAL_SPAWNS)
	local decalsCopy = table.clone(Config.PHOTO_DECAL_ASSETS)
	local pendingPhotos = {}
	for i = 1, Config.TOTAL_PHOTOS_TO_FIND do
		if #spawnsCopy == 0 or #decalsCopy == 0 then break end
		local randomSpawnIndex = math.random(#spawnsCopy)
		local randomDecalIndex = math.random(#decalsCopy)
		local vec3 = spawnsCopy[randomSpawnIndex]
		local serializableLocation = { x = vec3.X, y = vec3.Y, z = vec3.Z }

		table.insert(pendingPhotos, {
			id = i,
			location = serializableLocation,
			decalId = decalsCopy[randomDecalIndex]
		})

		table.remove(spawnsCopy, randomSpawnIndex)
		table.remove(decalsCopy, randomDecalIndex)
	end
	return { pendingPhotos = pendingPhotos, collectedPhotos = {} }
end

-- Mendapatkan data pemain dari DataStore.
function PlayerDataHandler:GetPlayerData(player)
	local key = "Player_" .. player.UserId
	local success, data = pcall(function() return photoDataStore:GetAsync(key) end)
	if not success then
		warn(`[DataHandler] Gagal mengambil data untuk {player.Name}`)
		return nil
	end
	return data
end

-- Menyimpan data pemain ke DataStore.
function PlayerDataHandler:SavePlayerData(player, data)
	local key = "Player_" .. player.UserId
	local success, err = pcall(function() photoDataStore:SetAsync(key, data) end)
	if not success then
		warn(`[DataHandler] Gagal menyimpan data untuk {player.Name}: {err}`)
	end
	return success
end

-- Menghapus data pemain dari DataStore.
function PlayerDataHandler:ResetPlayerData(player)
	local key = "Player_" .. player.UserId
	local success, err = pcall(function() photoDataStore:RemoveAsync(key) end)
	if not success then
		warn(`[DataHandler] Gagal mereset data untuk {player.Name}: {err}`)
	end
	return success
end

-- Mendapatkan status quest detail pemain.
function PlayerDataHandler:GetPlayerQuestStatus(player)
	local success, isInGroup = pcall(function()
		return player:IsInGroup(Config.GROUP_ID)
	end)

	if not success then
		warn(`[DataHandler] Gagal memeriksa keanggotaan grup untuk {player.Name}. Anggap tidak di dalam grup.`)
		isInGroup = false
	end

	local questStatus = Config.QUEST_STATUS.NOT_STARTED
	local data = self:GetPlayerData(player)

	if data then
		if #data.collectedPhotos >= Config.TOTAL_PHOTOS_TO_FIND then
			questStatus = Config.QUEST_STATUS.COMPLETED
		else
			questStatus = Config.QUEST_STATUS.IN_PROGRESS
		end
	end

	return { isInGroup = isInGroup, questStatus = questStatus }
end

return PlayerDataHandler
