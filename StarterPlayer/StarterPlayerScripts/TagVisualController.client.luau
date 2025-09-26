--!nonstrict
--[[
	TagVisualController (Client)
	Mencari SEMUA tag, membaca data dari Value Objects, dan menerapkan visual.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local TitleAnimator = require(ReplicatedStorage.Modules.TitleAnimator)

local TAG_NAME = "PlayerTag"

local function setupTagVisuals(tagGui)
	local player = Players:GetPlayerFromCharacter(tagGui.Parent.Parent)
	if not player then return end

	local nameLabel = tagGui.Frame:WaitForChild("Name")
	local titleLabel = tagGui.Frame:WaitForChild("Title")
	local usernameLabel = tagGui.Frame:WaitForChild("Username")

	local equippedTitleID = tagGui:WaitForChild("EquippedTitleID")
	local namePrefix = tagGui:WaitForChild("NamePrefix")

	local function refreshVisuals()
		usernameLabel.Text = "@" .. player.Name
		nameLabel.Text = (namePrefix.Value ~= "" and namePrefix.Value .. " " or "") .. player.DisplayName
		TitleAnimator.Apply(titleLabel, equippedTitleID.Value)
	end

	refreshVisuals()

	equippedTitleID.Changed:Connect(refreshVisuals)
	namePrefix.Changed:Connect(refreshVisuals)
end

for _, tagGui in ipairs(CollectionService:GetTagged(TAG_NAME)) do
	setupTagVisuals(tagGui)
end

CollectionService:GetInstanceAddedSignal(TAG_NAME):Connect(setupTagVisuals)
