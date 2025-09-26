local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Wait for lighting system and remotes
local LightingSystem = ReplicatedStorage:WaitForChild("Lighting System")
local Functions = require(LightingSystem.Functions)
local LightingModules = LightingSystem:WaitForChild("Lighting Presets")

local ZoneLightingFolder = ReplicatedStorage.Remotes:WaitForChild("ZoneLighting")
local ApplyZoneLighting = ZoneLightingFolder:WaitForChild("ApplyZoneLighting")
local RestoreNormalLighting = ZoneLightingFolder:WaitForChild("RestoreNormalLighting")

-- Client-side zone tracking
local activeZones = {} -- {[zoneId] = {atmosphereDensity = 0.55, zoneName = "..."}}
local isInLightingZone = false

-- Function to get current lighting preset based on time
local function getCurrentLightingPreset()
	local clockTime = Lighting.ClockTime

	if clockTime >= 6 and clockTime <= 8 then
		return require(LightingModules.Sunrise)
	elseif clockTime > 8 and clockTime <= 17 then
		return require(LightingModules.Day)
	elseif clockTime > 17 and clockTime <= 18.5 then
		return require(LightingModules.AfternoonGoldenHour)
	elseif clockTime > 18.5 and clockTime <= 20 then
		return require(LightingModules.Sunset)
	elseif clockTime > 20 and clockTime <= 23 then
		return require(LightingModules.Twilight)
	elseif clockTime > 23 or clockTime <= 6 then
		return require(LightingModules.Night)
	else
		return require(LightingModules.Day) -- Default
	end
end

-- Function to apply zone atmosphere density while keeping other properties
local function applyZoneAtmosphere(atmosphereDensity)
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then return end

	-- Only tween the density, keep other properties from current lighting
	local tween = TweenService:Create(atmosphere, TweenInfo.new(0.5), {
		Density = atmosphereDensity
	})
	tween:Play()
end

-- Function to restore normal atmosphere density based on current time
local function restoreNormalAtmosphere()
	local currentPreset = getCurrentLightingPreset()
	if currentPreset and currentPreset.Atmosphere and currentPreset.Atmosphere.Density then
		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
		if atmosphere then
			local tween = TweenService:Create(atmosphere, TweenInfo.new(0.5), {
				Density = currentPreset.Atmosphere.Density
			})
			tween:Play()
		end
	end
end

-- Handle zone lighting application
ApplyZoneLighting.OnClientEvent:Connect(function(zoneData)
	local zoneId = zoneData.zoneId
	local atmosphereDensity = zoneData.atmosphereDensity
	local zoneName = zoneData.zoneName

	-- Add zone to active zones
	activeZones[zoneId] = {
		atmosphereDensity = atmosphereDensity,
		zoneName = zoneName
	}

	isInLightingZone = true

	-- Apply the zone atmosphere density
	applyZoneAtmosphere(atmosphereDensity)
end)

-- Handle lighting restoration
RestoreNormalLighting.OnClientEvent:Connect(function()
	-- Clear all active zones
	activeZones = {}
	isInLightingZone = false

	-- Restore normal atmosphere
	restoreNormalAtmosphere()
end)

---- Monitor lighting changes to maintain zone density when time changes
task.spawn(function()
	local lastClockTime = Lighting.ClockTime

	Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
		-- Only act if we're in a lighting zone and time actually changed
		if isInLightingZone and Lighting.ClockTime ~= lastClockTime then
			lastClockTime = Lighting.ClockTime

			task.wait(0.1)

			local activeZoneDensity = nil
			for zoneId, zoneData in pairs(activeZones) do
				activeZoneDensity = zoneData.atmosphereDensity
				break -- Use first active zone
			end

			if activeZoneDensity then
				local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
				if atmosphere and atmosphere.Density ~= activeZoneDensity then
					local tween = TweenService:Create(atmosphere, TweenInfo.new(0.2), {
						Density = activeZoneDensity
					})
					tween:Play()
				end
			end
		end
	end)
end)

-- Optional: Handle player respawn to maintain zone state
game.Players.LocalPlayer.CharacterAdded:Connect(function()
	-- Reset zone state on respawn
	activeZones = {}
	isInLightingZone = false
end)
