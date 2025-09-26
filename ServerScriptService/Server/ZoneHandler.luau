local Zone = require(game:GetService("ReplicatedStorage").Packages.Zone)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AchievementService = require(game.ServerScriptService.Services.AchievementService)
local TitleService = require(game.ServerScriptService.Services.TitleService)
local PlayerJourneyService = require(game.ServerScriptService.Services.PlayerJourneyService)

local ChangeBackgroundSound = ReplicatedStorage.Remotes.ChangeBackgroundSound
local ShowNotificationEvent = ReplicatedStorage.Remotes.ShowNotification
local SendChatMessage = ReplicatedStorage.Remotes.SendChatMessage

-- Create RemoteEvents for zone lighting
local ZoneLightingFolder = Instance.new("Folder")
ZoneLightingFolder.Name = "ZoneLighting"
ZoneLightingFolder.Parent = ReplicatedStorage.Remotes

local ApplyZoneLighting = Instance.new("RemoteEvent")
ApplyZoneLighting.Name = "ApplyZoneLighting"
ApplyZoneLighting.Parent = ZoneLightingFolder

local RestoreNormalLighting = Instance.new("RemoteEvent")
RestoreNormalLighting.Name = "RestoreNormalLighting"
RestoreNormalLighting.Parent = ZoneLightingFolder

-- Zone variables
local zonesContainer = workspace:WaitForChild("Zones")
local showZoneEntered = ReplicatedStorage.Remotes:WaitForChild("ShowZoneEntered")
local debounce = {}

-- Track players in lighting zones
local playersInLightingZones = {}

local function onPlayerEnteredZone(player, zoneAttributes, zoneId)
	local areaName = zoneAttributes.AreaName
	local achievementId = zoneAttributes.AchievementId
	local soundName = zoneAttributes.Sound

	if soundName and soundName ~= "" then
		ChangeBackgroundSound:FireClient(player, soundName)
	end

	if areaName == "Thank You For Playing!" then
		PlayerJourneyService.ResetJourney(player)
	end

	if zoneAttributes.CustomAtmosphereDensity then
		if not playersInLightingZones[player] then
			playersInLightingZones[player] = {}
		end
		playersInLightingZones[player][zoneId] = true

		ApplyZoneLighting:FireClient(player, {
			atmosphereDensity = zoneAttributes.CustomAtmosphereDensity,
			zoneName = areaName,
			zoneId = zoneId
		})

		print("Player", player.Name, "entered atmosphere density zone:", areaName, "- Density:", zoneAttributes.CustomAtmosphereDensity)
	end

	if debounce[player.UserId] and debounce[player.UserId][areaName] then
		return
	end

	if not debounce[player.UserId] then debounce[player.UserId] = {} end
	debounce[player.UserId][areaName] = true

	-- Handle Summit and Checkpoint logic
	if zoneAttributes.IsSummit then
		if PlayerJourneyService.HasCheckpoint(player) then
			print("Pemain sudah punya checkpoint di puncak, CompleteJourney di-skip.")
		else
			local isValidJourney = PlayerJourneyService.CompleteJourney(player)
			if isValidJourney then
				local summitMsg: string = PlayerJourneyService.GetSummitMessage(player)
				SendChatMessage:FireAllClients(summitMsg)
				AchievementService.CheckSummitAchievements(player)
				TitleService.CheckSummitTitles(player)

				if zoneAttributes.StatName and zoneAttributes.StatName ~= "" then
					local leaderstats = player:WaitForChild("leaderstats")
					if leaderstats and leaderstats:FindFirstChild(zoneAttributes.StatName) then
						leaderstats[zoneAttributes.StatName].Value += 1
						print("DEBUG: Stat '"..zoneAttributes.StatName.."' berhasil ditambah. Nilai baru: "..leaderstats[zoneAttributes.StatName].Value)
					end
				end
			else
				showZoneEntered:FireClient(player, "⚠️ SUSPICIOUS ACTIVITY DETECTED")
				return
			end
		end
	elseif zoneAttributes.Checkpoint then
		PlayerJourneyService.SaveCheckpoint(player)
		ShowNotificationEvent:FireClient(player, {
			title = "Checkpoint Reached! 🎉",
			subtitle = areaName,
		})
	end

	if areaName ~= "Edge of The Grey Terminal" then
		showZoneEntered:FireClient(player, string.upper(areaName))
	end

	if achievementId and achievementId ~= "" then
		AchievementService.AwardAchievement(player, achievementId)
	end

	task.delay(zoneAttributes.Cooldown, function()
		if debounce[player.UserId] then
			debounce[player.UserId][areaName] = nil
		end
	end)
end

local function onPlayerExitedZone(player, zoneAttributes, zoneId)
	local areaName = zoneAttributes.AreaName

	if areaName == "Edge of The Grey Terminal" then
		PlayerJourneyService.StartJourney(player)
		print("Player", player.Name, "started their journey to summit!")
	end

	if zoneAttributes.CustomAtmosphereDensity then
		if playersInLightingZones[player] then
			playersInLightingZones[player][zoneId] = nil

			-- Check if player has any other active lighting zones
			local hasOtherZones = false
			for otherZoneId, isActive in pairs(playersInLightingZones[player]) do
				if isActive then
					hasOtherZones = true
					break
				end
			end

			-- If no other lighting zones, restore normal lighting for this player
			if not hasOtherZones then
				RestoreNormalLighting:FireClient(player)
				playersInLightingZones[player] = nil
			end
		end

		print("Player", player.Name, "exited atmosphere density zone:", zoneAttributes.AreaName)
	end
end

-- Handle player leaving to clean up tracking
Players.PlayerRemoving:Connect(function(player)
	-- Clean up player tracking
	if playersInLightingZones[player] then
		playersInLightingZones[player] = nil
	end

	-- Clean up debounce
	if debounce[player.UserId] then
		debounce[player.UserId] = nil
	end
end)

-- Loop inisialisasi zona
for _, zoneContainer in ipairs(zonesContainer:GetChildren()) do
	local attributes = {
		AreaName = zoneContainer:GetAttribute("AreaName"),
		StatName = zoneContainer:GetAttribute("StatName"),
		Cooldown = zoneContainer:GetAttribute("Cooldown") or 30,
		IsSummit = zoneContainer:GetAttribute("IsSummit"),
		Checkpoint = zoneContainer:GetAttribute("Checkpoint"),
		AchievementId = zoneContainer:GetAttribute("AchievementId"),
		Sound = zoneContainer:GetAttribute("Sound"),
		CustomAtmosphereDensity = zoneContainer:GetAttribute("CustomAtmosphereDensity")
	}

	if not attributes.AreaName then
		warn("Container zona '" .. zoneContainer.Name .. "' tidak memiliki atribut 'AreaName'.")
		continue
	end

	local newZone = Zone.new(zoneContainer)
	local zoneId = zoneContainer.Name

	newZone.playerEntered:Connect(function(player)
		onPlayerEnteredZone(player, attributes, zoneId)
	end)

	newZone.playerExited:Connect(function(player)
		onPlayerExitedZone(player, attributes, zoneId)
	end)
end
