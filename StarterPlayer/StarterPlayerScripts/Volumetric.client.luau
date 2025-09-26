--!nonstrict
--[[
	VolumetricController (Client)
	- katclap, CLEANED VERSION by DIKDNS
	- Now includes forced ExposureCompensation on render step.
]]

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- Variables
local filter = ReplicatedStorage:WaitForChild("Filter")
local localPlayer = Players.LocalPlayer
local volumetricSetting = ReplicatedStorage:WaitForChild("VolumetricEnabled")
local currentCamera = Workspace.CurrentCamera

local VOLUMETRIC_EXPOSURE = -2
local DEFAULT_EXPOSURE = -0.5

-- Move InteriorChecks to Workspace
ReplicatedStorage:WaitForChild("InteriorChecks").Parent = Workspace

-- Cache script settings
local scriptQuality = script["Graphics Quality"].Value
local isInteriorEnabled = script.interior.Value
local isNightCheckEnabled = script.nightcheck.Value

-- Set filter size
filter.Size = Vector3.new(100, 100, 100)

-- Clock tracking
local clock = Lighting.ClockTime
Lighting.Changed:Connect(function()
	clock = Lighting.ClockTime
end)

-- Functions
local function getCharacter()
	local character = localPlayer.Character
	if not character or not character.Parent then
		character = localPlayer.CharacterAdded:Wait()
	end
	return character
end

local function checkForInterior(character)
	local rootPart = character:WaitForChild("HumanoidRootPart", 5)
	if not rootPart then return false end
	for _, part in pairs(rootPart:GetTouchingParts()) do
		if part.Parent and part.Parent.Name == "InteriorChecks" then
			return true
		end
	end
	return false
end

local function shouldShowVolumetric(character)
	if not volumetricSetting.Value then return false end
	if not character then return false end

	local graphicsQuality = UserSettings().GameSettings.SavedQualityLevel.Value
	if graphicsQuality < scriptQuality then return false end

	local isNight = (clock > 17.75 or clock < 6.15)
	local isPlayerInside = checkForInterior(character)

	if not isNightCheckEnabled and not isInteriorEnabled then return true end
	if isNightCheckEnabled and not isNight then return true end
	if isInteriorEnabled and isPlayerInside then return true end

	return false
end

RunService.RenderStepped:Connect(function()
	local character = getCharacter()
	local shouldShow = shouldShowVolumetric(character)

	if shouldShow then
		filter.Parent = Workspace
		filter.CFrame = currentCamera.CFrame

		Lighting.ExposureCompensation = VOLUMETRIC_EXPOSURE
	else
		filter.Parent = ReplicatedStorage

		if Lighting.ExposureCompensation == VOLUMETRIC_EXPOSURE then
			Lighting.ExposureCompensation = DEFAULT_EXPOSURE
		end
	end
end)
