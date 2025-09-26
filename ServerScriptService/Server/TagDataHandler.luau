--!nonstrict
--[[
	TagDataHandler (Server)
	Membuat Tag & mengisi ValueObjects di dalamnya dengan data.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local CountryService = require(ReplicatedStorage.Packages.CountryService)
local tagTemplate = ReplicatedStorage:WaitForChild("Tag")
local platformEvent = ReplicatedStorage.Remotes:WaitForChild("ReportPlatform")

local TAG_NAME = "PlayerTag"

local function updateTagData(player)
	if not player or not player.Character then return end

	local head = player.Character:FindFirstChild("Head")
	local tagGui = head and head:FindFirstChild("Tag")
	local playerData = player:FindFirstChild("PlayerData")
	if not (tagGui and playerData) then return end

	local equippedTitleID_Value = tagGui:FindFirstChild("EquippedTitleID") or Instance.new("StringValue", tagGui)
	equippedTitleID_Value.Name = "EquippedTitleID"

	local namePrefix_Value = tagGui:FindFirstChild("NamePrefix") or Instance.new("StringValue", tagGui)
	namePrefix_Value.Name = "NamePrefix"

	local equippedTitleData = playerData.Titles:WaitForChild("Equipped")
	local isMobileData = playerData:WaitForChild("IsMobile")

	-- Update Title ID
	equippedTitleID_Value.Value = equippedTitleData.Value

	-- Update Name Prefix
	local prefixParts = {}

	-- Add VIP star first if the attribute exists and is true
	if player:GetAttribute("IsVIP") == true then
		table.insert(prefixParts, "⭐")
	end

	-- Add country emoji
	local country = CountryService:GetPlayerCountry(player)
	if country and country.emoji then
		table.insert(prefixParts, country.emoji)
	end

	-- Add mobile icon
	if isMobileData.Value then
		table.insert(prefixParts, "📱")
	end

	-- Combine all parts with a space
	namePrefix_Value.Value = table.concat(prefixParts, " ")
end

local function setupCharacter(character)
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end
	local head = character:WaitForChild("Head")
	if not head or head:FindFirstChild(tagTemplate.Name) then return end

	local newTag = tagTemplate:Clone()
	newTag.Parent = head

	CollectionService:AddTag(newTag, TAG_NAME)

	player:WaitForChild("PlayerData")

	-- Listen for the IsVIP attribute to change
	player:GetAttributeChangedSignal("IsVIP"):Connect(function()
		updateTagData(player)
	end)

	updateTagData(player)
end



local function onPlayerAdded(player)
	local playerData = player:WaitForChild("PlayerData")
	local isMobileValue = Instance.new("BoolValue", playerData)
	isMobileValue.Name = "IsMobile"

	player.CharacterAdded:Connect(setupCharacter)
	if player.Character then setupCharacter(player.Character) end

	playerData.Titles.Equipped.Changed:Connect(function() updateTagData(player) end)
	isMobileValue.Changed:Connect(function() updateTagData(player) end)
end

platformEvent.OnServerEvent:Connect(function(player, isMobile)
	local playerData = player:FindFirstChild("PlayerData")
	if playerData and playerData:FindFirstChild("IsMobile") then
		playerData.IsMobile.Value = isMobile
	end
end)

for _, p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end
Players.PlayerAdded:Connect(onPlayerAdded)
print("✅ TagDataHandler (Server) is running.")
