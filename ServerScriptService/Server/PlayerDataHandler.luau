--!nonstrict
--[[
	PlayerDataHandler
]]

-- Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules & Data
local TitleService = require(ServerScriptService.Services.TitleService)
local GiveToolService = require(ServerScriptService.Services.GiveToolService)
local GamepassData = require(ReplicatedStorage.Modules.GamepassData)
local VipTrailService = require(ServerScriptService.Services.VipTrailService)

-- DataStore & Folders
local playerDataStore = DataStoreService:GetDataStore("PlayerData_V2")
local checkpointStore = DataStoreService:GetDataStore("JourneyCheckpoints_V2")
local summitLeaderboardStore = DataStoreService:GetOrderedDataStore("SummitLeaderboardV1")

-- ===================================================================
-- HELPER FUNCTIONS
-- ===================================================================
local function teleportToCheckpoint(player, character)
	local userId = player.UserId

	task.spawn(function()
		local success, checkpointData = pcall(function()
			return checkpointStore:GetAsync("User-" .. userId)
		end)

		-- Check if data exists, is a table, and has a Position field
		if success and type(checkpointData) == "table" and checkpointData.Position then
			local rootPart = character:WaitForChild("HumanoidRootPart")
			if rootPart then
				local savedPosition = checkpointData.Position
				-- Construct the Vector3 from the Position table within the checkpoint data
				local positionVector = Vector3.new(savedPosition.X, savedPosition.Y, savedPosition.Z)

				print("Checkpoint ditemukan. Teleportasi", player.Name, "ke posisi tersimpan.")
				rootPart.CFrame = CFrame.new(positionVector) + Vector3.new(0, 3, 0)
			end
		else
			-- This branch will run if there's no data, an error occurred, or the data format is old/invalid
			print("Tidak ada checkpoint untuk", player.Name, ". Memulai dari spawn point.")
		end
	end)
end


local function giveOneTimeItems(player)
	for _, gamepassInfo in ipairs(GamepassData) do
		local success, ownsPass = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassInfo.Id)
		end)
		if success and ownsPass then
			if gamepassInfo.Name == "Lasso" then
				GiveToolService.GiveTool(player, "Lasso")
			elseif gamepassInfo.Name == "Selfie Pack" then
				GiveToolService.GiveTool(player, "Selfie Cam")
				GiveToolService.GiveTool(player, "Selfie Stick")
			elseif gamepassInfo.Name == "Vintage Lantern" then
				GiveToolService.GiveTool(player, "Vintage Lantern")
			end
		end
	end
end

local function applyCharacterAttributes(player, character)
	for _, gamepassInfo in ipairs(GamepassData) do
		local success, ownsPass = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassInfo.Id)
		end)
		if success and ownsPass then
			if gamepassInfo.Name == "Sprint" then
				character:SetAttribute("SprintEnabled", true)
			elseif gamepassInfo.Name == "⭐️ VIP" then
				VipTrailService.applyTrail(player)
			end
		end
	end
end


local function checkAndGivePurchasedItems(player)
	for _, gamepassInfo in ipairs(GamepassData) do
		local success, ownsPass = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassInfo.Id)
		end)

		if success and ownsPass then
			if gamepassInfo.Name == "Lasso" then
				GiveToolService.GiveTool(player, "Lasso")
			elseif gamepassInfo.Name == "Selfie Pack" then
				GiveToolService.GiveTool(player, "Selfie Cam")
				GiveToolService.GiveTool(player, "Selfie Stick")
			elseif gamepassInfo.Name == "Vintage Lantern" then
				GiveToolService.GiveTool(player, "Vintage Lantern")
			elseif gamepassInfo.Name == "Sprint" then
				game:GetService("Workspace"):FindFirstChild(player.Name):SetAttribute("SprintEnabled", true)
			elseif gamepassInfo.Name == "⭐️ VIP" then
				VipTrailService.applyTrail(player)
			end
		end
	end
end



-- ===================================================================
-- MAIN PLAYER SETUP & SAVE FUNCTIONS
-- ===================================================================

-- Fungsi untuk menyiapkan data pemain saat bergabung
local function setupPlayerData(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local summits = Instance.new("IntValue")
	summits.Name = "Summits"
	summits.Parent = leaderstats

	local success_summits, savedSummits = pcall(function()
		return summitLeaderboardStore:GetAsync(tostring(player.UserId))
	end)

	if success_summits and savedSummits then
		summits.Value = savedSummits
	else
		summits.Value = 0
	end

	local playerDataFolder = Instance.new("Folder")
	playerDataFolder.Name = "PlayerData"
	playerDataFolder.Parent = player

	local interactionState = Instance.new("StringValue")
	interactionState.Name = "InteractionState"
	interactionState.Value = "Idle"
	interactionState.Parent = playerDataFolder

	local achievementsFolder = Instance.new("Folder")
	achievementsFolder.Name = "Achievements"
	achievementsFolder.Parent = playerDataFolder

	local titlesFolder = Instance.new("Folder")
	titlesFolder.Name = "Titles"
	titlesFolder.Parent = playerDataFolder

	local unlockedTitlesFolder = Instance.new("Folder")
	unlockedTitlesFolder.Name = "Unlocked"
	unlockedTitlesFolder.Parent = titlesFolder

	local equippedTitleValue = Instance.new("StringValue")
	equippedTitleValue.Name = "Equipped"
	equippedTitleValue.Parent = titlesFolder

	local success_main, data = pcall(function()
		return playerDataStore:GetAsync("User-" .. player.UserId)
	end)
	if success_main and data then
		if data.Achievements then
			for id, _ in pairs(data.Achievements) do Instance.new("BoolValue", achievementsFolder).Name = id end
		end
		if data.Titles and data.Titles.Unlocked then
			for id, _ in pairs(data.Titles.Unlocked) do Instance.new("BoolValue", unlockedTitlesFolder).Name = id end
		end
		equippedTitleValue.Value = data.Titles and data.Titles.Equipped or ""
	else
		print("[PlayerDataHandler] Creating new main data for: " .. player.Name)
	end

	-- Jalankan pengecekan title untuk SEMUA pemain
	TitleService.CheckAllUnlocks(player)

	-- Jika tidak ada title yang terpasang (terutama untuk pemain baru), pasang title default
	if equippedTitleValue.Value == "" then
		TitleService.EquipTitle(player, "T001")
	end

	-- Berikan item game pass yang sudah dimiliki
	giveOneTimeItems(player)

	local function onCharacterAdded(character)
		print("Karakter baru terdeteksi untuk", player.Name, ". Menerapkan data...")
		applyCharacterAttributes(player, character)
		teleportToCheckpoint(player, character)
	end

	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then onCharacterAdded(player.Character) end

	print("[PlayerDataHandler] Player setup complete for: " .. player.Name)
end

-- Fungsi untuk menyimpan data saat pemain keluar
local function savePlayerData(player)
	local playerData = player:FindFirstChild("PlayerData")
	local leaderstats = player:FindFirstChild("leaderstats")
	if not playerData or not leaderstats then return end

	local dataToSave = {
		Achievements = {},
		Titles = { Equipped = playerData.Titles.Equipped.Value, Unlocked = {} }
	}
	for _, a in ipairs(playerData.Achievements:GetChildren()) do dataToSave.Achievements[a.Name] = true end
	for _, t in ipairs(playerData.Titles.Unlocked:GetChildren()) do dataToSave.Titles.Unlocked[t.Name] = true end

	pcall(function()
		playerDataStore:SetAsync("User-" .. player.UserId, dataToSave)
	end)

	local summitsValue = leaderstats.Summits.Value
	if summitsValue > 0 then
		pcall(function()
			summitLeaderboardStore:SetAsync(tostring(player.UserId), summitsValue)
		end)
	end

	print("Player data successfully saved for:", player.Name)
end

Players.PlayerAdded:Connect(setupPlayerData)
Players.PlayerRemoving:Connect(savePlayerData)
