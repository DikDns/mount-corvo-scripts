-- ===================================================================
-- HeeseungPhotoService - VERSI DEBUG (FIXED)
-- Memperbaiki error DataStore 104 & menggunakan PivotTo modern.
-- Loop Heartbeat yang diperkuat dengan STATE TRACKING untuk streaming.
-- ===================================================================

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local BadgeService = game:GetService("BadgeService")
local GroupService = game:GetService("GroupService")
local RunService = game:GetService("RunService")

-- =================[ PENGATURAN DEBUG ]=================
local DEBUG_MODE = true
-- ======================================================

local photoDataStore = DataStoreService:GetDataStore("HeeseungMemoryTrailV0.0.2_Fixed")
local HeeseungPhotoService = {}

-- DIRUBAH: Tabel untuk melacak status streaming setiap foto per pemain
local streamedOutPhotos = {}

local photoStorageContainer = ServerStorage:FindFirstChild("HeeseungEventPhotoStorage") or Instance.new("Folder", ServerStorage)
photoStorageContainer.Name = "HeeseungEventPhotoStorage"

local PHOTO_TEMPLATE = ServerStorage.HeeseungEvent:WaitForChild("HeeseungMemoryTemplate")
local TOTAL_PHOTOS_TO_FIND = 10
local BADGE_ID = 2129938281
local GROUP_ID = 32936758
local STREAMING_RADIUS = 100

local PHOTO_DECAL_ASSETS = {
	"rbxassetid://84607686570767", "rbxassetid://138990108188283", "rbxassetid://111904602273867",
	"rbxassetid://119581976014206", "rbxassetid://95713145410237", "rbxassetid://102659250472545",
	"rbxassetid://70957932072599", "rbxassetid://128841228744954", "rbxassetid://103104270020256",
	"rbxassetid://119316590847593"
}

local potentialSpaws = {
	Vector3.new(3.143, 0.167, -23.058),
	Vector3.new(3.143, 0.167, -33.058),
	Vector3.new(3.143, 0.167, -44.058),
	Vector3.new(17.143, 0.167, -44.058),
	Vector3.new(17.143, 0.167, -35.058),
	Vector3.new(-5.857, 0.167, -35.058),
	Vector3.new(-5.857, 0.167, -17.058),
	Vector3.new(19.143, 0.167, -17.058),
	Vector3.new(19.143, 0.167, 3.942),
	Vector3.new(19.143, 0.167, -8.058),
}

local function generateInitialHuntData()
	if DEBUG_MODE then print("[DEBUG] generateInitialHuntData: Memulai pembuatan data baru.") end
	local spawnsCopy = table.clone(potentialSpaws)
	local decalsCopy = table.clone(PHOTO_DECAL_ASSETS)
	local pendingPhotos = {}
	for i = 1, TOTAL_PHOTOS_TO_FIND do
		if #spawnsCopy == 0 or #decalsCopy == 0 then break end
		local randomSpawnIndex = math.random(#spawnsCopy)
		local randomDecalIndex = math.random(#decalsCopy)

		local vec3 = spawnsCopy[randomSpawnIndex]
		local serializableLocation = { x = vec3.X, y = vec3.Y, z = vec3.Z }

		table.insert(pendingPhotos, {
			location = serializableLocation,
			decalId = decalsCopy[randomDecalIndex]
		})
		table.remove(spawnsCopy, randomSpawnIndex)
		table.remove(decalsCopy, randomDecalIndex)
	end
	if DEBUG_MODE then print("[DEBUG] generateInitialHuntData: Selesai. Total foto dibuat:", #pendingPhotos) end
	return { pendingPhotos = pendingPhotos, collectedPhotos = {} }
end

local function createPlayerPhotosInStorage(player, pendingPhotos)
	if DEBUG_MODE then print(`[DEBUG] createPlayerPhotosInStorage: Membuat instance foto untuk {player.Name}. Total: {#pendingPhotos}`) end
	local playerPhotoFolder = photoStorageContainer:FindFirstChild(player.Name .. "_Photos")
	if playerPhotoFolder then playerPhotoFolder:Destroy() end

	playerPhotoFolder = Instance.new("Folder", photoStorageContainer)
	playerPhotoFolder.Name = player.Name .. "_Photos"

	for i, photoData in ipairs(pendingPhotos) do
		local photoModel = PHOTO_TEMPLATE:Clone()
		local locationVector = Vector3.new(photoData.location.x, photoData.location.y, photoData.location.z)

		photoModel:PivotTo(CFrame.new(locationVector))
		photoModel:SetAttribute("OwnerUserId", player.UserId)
		photoModel:SetAttribute("LocationString", tostring(locationVector))

		local decal = photoModel.Part:FindFirstChild("Photo")
		if decal and decal:IsA("Decal") then
			decal.Texture = photoData.decalId
		else
			warn("Decal 'Photo' tidak ditemukan di dalam 'Part' pada template!")
		end

		photoModel.Parent = playerPhotoFolder
		if DEBUG_MODE then print(`  [DEBUG] Foto #{i} dibuat di posisi {tostring(locationVector)}`) end
	end
end

function HeeseungPhotoService:CheckPrerequisites(player)
	if DEBUG_MODE then print(`[DEBUG] CheckPrerequisites: Memeriksa status untuk {player.Name}`) end
	local results = { isInGroup = false, hasStartedEvent = false }
	local success, inGroup = pcall(function() return GroupService:GetPlayerInfoAsync(player.UserId).Groups end)
	if success and inGroup then
		for _, groupInfo in ipairs(inGroup) do
			if groupInfo.Id == GROUP_ID then results.isInGroup = true; break end
		end
	end
	if DEBUG_MODE then print(`  [DEBUG] Status grup: {results.isInGroup}`) end
	local key = "Player_" .. player.UserId
	local dataSuccess, data = pcall(function() return photoDataStore:GetAsync(key) end)
	if dataSuccess and data then results.hasStartedEvent = true end
	if DEBUG_MODE then print(`  [DEBUG] Status event dimulai: {results.hasStartedEvent}`) end
	return results
end


function HeeseungPhotoService:StartHunt(player)
	if DEBUG_MODE then print(`[DEBUG] StartHunt: Memulai perburuan untuk {player.Name}`) end
	local key = "Player_" .. player.UserId
	local newData = generateInitialHuntData()
	if DEBUG_MODE then print(`  [DEBUG] DataStore: Mencoba menyimpan data baru untuk key: {key}`) end
	local setSuccess, err = pcall(function() photoDataStore:SetAsync(key, newData) end)
	if setSuccess then
		if DEBUG_MODE then print("  [DEBUG] DataStore: Berhasil menyimpan data baru.") end
		createPlayerPhotosInStorage(player, newData.pendingPhotos)
	else
		warn(`[DEBUG] DataStore GAGAL menyimpan data awal untuk {player.Name}: {err}`)
	end
end

function HeeseungPhotoService:OnPhotoCollected(player, photoModel)
	if DEBUG_MODE then print(`[DEBUG] OnPhotoCollected: {player.Name} berinteraksi dengan sebuah foto.`) end
	if not photoModel or not photoModel:IsA("Model") or photoModel:GetAttribute("OwnerUserId") ~= player.UserId then
		warn(player.Name .. " mencoba mengoleksi model foto yang tidak valid.")
		return
	end

	local key = "Player_" .. player.UserId
	if DEBUG_MODE then print(`  [DEBUG] DataStore: Mengambil data untuk key: {key}`) end
	local success, data = pcall(function() return photoDataStore:GetAsync(key) end)

	if success and data then
		if DEBUG_MODE then print("  [DEBUG] DataStore: Berhasil mengambil data.") end
		local collectedPosition = photoModel:GetPivot().Position
		local foundPhotoData

		for i, photoData in ipairs(data.pendingPhotos) do
			local storedVector = Vector3.new(photoData.location.x, photoData.location.y, photoData.location.z)
			if (storedVector - collectedPosition).Magnitude < 0.1 then
				foundPhotoData = table.remove(data.pendingPhotos, i)
				break
			end
		end

		if foundPhotoData then
			if DEBUG_MODE then print("  [DEBUG] Foto valid ditemukan dalam data pemain. Memproses koleksi...") end
			foundPhotoData.collectedTimestamp = os.time()
			table.insert(data.collectedPhotos, foundPhotoData)

			-- Hapus dari state tracking jika ada
			if streamedOutPhotos[player] then
				streamedOutPhotos[player][photoModel] = nil
			end
			photoModel:Destroy()

			print(player.Name .. " mengoleksi sebuah foto! (" .. #data.collectedPhotos .. "/" .. TOTAL_PHOTOS_TO_FIND .. ")")
			pcall(function() photoDataStore:SetAsync(key, data) end)
			if DEBUG_MODE then print("  [DEBUG] DataStore: Progres pemain telah diperbarui.") end
		else
			if DEBUG_MODE then warn("  [DEBUG] Peringatan: Interaksi valid, namun foto tidak ditemukan di data 'pendingPhotos'. Mungkin sudah dikoleksi sebelumnya.") end
		end
	else
		warn(`[DEBUG] DataStore GAGAL mengambil data untuk {player.Name} saat koleksi.`)
	end
end

function HeeseungPhotoService:CheckAndResumeHunt(player)
	if DEBUG_MODE then print(`[DEBUG] CheckAndResumeHunt: Memeriksa data untuk {player.Name}`) end
	local key = "Player_" .. player.UserId
	local success, data = pcall(function() return photoDataStore:GetAsync(key) end)
	if success and data and data.pendingPhotos then
		if DEBUG_MODE then print(`  [DEBUG] Data ditemukan. Melanjutkan perburuan. Sisa foto: {#data.pendingPhotos}`) end
		createPlayerPhotosInStorage(player, data.pendingPhotos)
	else
		if DEBUG_MODE and not data then print("  [DEBUG] Tidak ada data event yang ditemukan untuk pemain ini.") end
	end
end

function HeeseungPhotoService:CleanupPlayerPhotos(player)
	if DEBUG_MODE then print(`[DEBUG] CleanupPlayerPhotos: Membersihkan foto dari ServerStorage untuk {player.Name}`) end
	local playerFolder = photoStorageContainer:FindFirstChild(player.Name .. "_Photos")
	if playerFolder then playerFolder:Destroy() end
end

function HeeseungPhotoService:GetPlayerDataLog(player)
	if DEBUG_MODE then print(`[DEBUG] GetPlayerDataLog: Mengambil log data untuk {player.Name}`) end
	local key = "Player_" .. player.UserId
	local success, data = pcall(function() return photoDataStore:GetAsync(key) end)
	return success and data or nil
end

function HeeseungPhotoService:DEBUG_ResetPlayerData(player)
	if not DEBUG_MODE then
		warn("Mode DEBUG tidak aktif. Fungsi reset dibatalkan.")
		return
	end

	local key = "Player_" .. player.UserId
	print(`[DEBUG] DEBUG_ResetPlayerData: Menghapus data untuk {player.Name} (Key: {key})`)
	local success, err = pcall(function()
		photoDataStore:RemoveAsync(key)
	end)

	if success then
		print(`[DEBUG] Data untuk {player.Name} berhasil direset.`)
		self:CleanupPlayerPhotos(player)
	else
		warn(`[DEBUG] GAGAL mereset data untuk {player.Name}: {err}`)
	end
end

-- DIRUBAH: Mengelola tabel state tracking saat pemain masuk/keluar
Players.PlayerAdded:Connect(function(player)
	streamedOutPhotos[player] = {}
end)

Players.PlayerRemoving:Connect(function(player)
	streamedOutPhotos[player] = nil
end)


-- =================================================================
--                        HEARTBEAT LOOP (DIREVISI TOTAL)
-- =================================================================
RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if not streamedOutPhotos[player] then streamedOutPhotos[player] = {} end -- Safety check

		local character = player.Character
		if not character or not character.PrimaryPart then continue end

		local playerPos = character.PrimaryPart.Position
		local playerGui = player:FindFirstChildOfClass("PlayerGui")
		if not playerGui then continue end

		local clientPhotoContainer = playerGui:FindFirstChild("HeeseungPhotoContainer")
		if not clientPhotoContainer then
			clientPhotoContainer = Instance.new("Folder", playerGui)
			clientPhotoContainer.Name = "HeeseungPhotoContainer"
		end

		local playerStorageFolder = photoStorageContainer:FindFirstChild(player.Name .. "_Photos")

		-- >> STREAMING IN (ServerStorage -> PlayerGui)
		if playerStorageFolder then
			for _, photoModel in ipairs(playerStorageFolder:GetChildren()) do
				if photoModel:IsA("Model") then
					-- Cek jika foto BELUM di-stream
					if not streamedOutPhotos[player][photoModel] then
						local photoPos = photoModel:GetPivot().Position
						local distance = (photoPos - playerPos).Magnitude

						if distance <= STREAMING_RADIUS then
							if DEBUG_MODE then print(`[STREAMING] -> Mengirim foto ke client {player.Name}. Jarak: {string.format("%.1f", distance)}`) end
							photoModel.Parent = clientPhotoContainer
							streamedOutPhotos[player][photoModel] = true -- Tandai sebagai di-stream
						end
					end
				end
			end
		end

		-- << STREAMING OUT (PlayerGui/Workspace -> ServerStorage)
		for photoModel, isStreamed in pairs(streamedOutPhotos[player]) do
			if isStreamed then
				if photoModel.Parent == nil then
					streamedOutPhotos[player][photoModel] = nil -- Hapus jika sudah hancur (misal, dikoleksi)
				else
					local photoPos = photoModel:GetPivot().Position
					local distance = (photoPos - playerPos).Magnitude

					if distance > STREAMING_RADIUS + 10 then
						if DEBUG_MODE then print(`[STREAMING] <- Mengambil kembali foto dari client {player.Name}. Jarak: {string.format("%.1f", distance)}`) end
						if playerStorageFolder then
							photoModel.Parent = playerStorageFolder
							streamedOutPhotos[player][photoModel] = nil -- Tandai sudah tidak di-stream
						else
							photoModel:Destroy()
							streamedOutPhotos[player][photoModel] = nil
						end
					end
				end
			end
		end
	end
end)

return HeeseungPhotoService
