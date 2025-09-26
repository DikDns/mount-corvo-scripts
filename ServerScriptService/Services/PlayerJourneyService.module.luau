local formatTime = require(game.ReplicatedStorage.Modules.FormatTime)
local DataStoreService = game:GetService("DataStoreService")

local PlayerJourneyService = {}
local journeyData = {}
local checkpointStore = DataStoreService:GetDataStore("JourneyCheckpoints_V2")
local SUSPICIOUS_TIME = 180


function PlayerJourneyService.HasCheckpoint(player)
	local userId = player.UserId

	local success, checkpointData = pcall(function()
		return checkpointStore:GetAsync("User-" .. player.UserId)
	end)

	-- Only a summit checkpoint should prevent a new journey completion.
	-- If a checkpoint exists and IsSummit is true, deactivate the current journey and return true.
	if success and checkpointData and checkpointData.IsSummit then
		if journeyData[userId] then
			journeyData[userId].isActive = false
		end
		return true
	end

	return false
end

function PlayerJourneyService.StartJourney(player)
	local userId = player.UserId
	local departureTime = tick() -- Default to a new departure time

	-- Check for an existing checkpoint that is NOT a summit
	local success, checkpointData = pcall(function()
		return checkpointStore:GetAsync("User-" .. userId)
	end)

	if success and checkpointData and not checkpointData.IsSummit and checkpointData.DepartureTime then
		departureTime = checkpointData.DepartureTime -- Load departure time from the checkpoint
		print("🔄 Resuming journey for:", player.Name, "from last checkpoint.")
	end

	journeyData[userId] = {
		departureTime = departureTime,
		arrivalTime = nil,
		isActive = true,
		attempts = (journeyData[userId] and journeyData[userId].attempts or 0)
	}

	print("🚀 Journey Started:", player.Name, "- Attempt #" .. journeyData[userId].attempts)
end

function PlayerJourneyService.SaveCheckpoint(player)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local userId = player.UserId
	local data = journeyData[userId]
	if not data then
		warn("❌ Cannot save checkpoint for", player.Name, "- no active journey.")
		return
	end

	local rootPart = player.Character.HumanoidRootPart
	local positionToSave = {
		X = rootPart.Position.X,
		Y = rootPart.Position.Y + 2,
		Z = rootPart.Position.Z
	}

	local checkpointData = {
		Position = positionToSave,
		IsSummit = false, -- Mark as a non-summit checkpoint
		DepartureTime = data.departureTime
	}

	local success, err = pcall(function()
		checkpointStore:SetAsync("User-" .. userId, checkpointData)
	end)

	if success then
		print("✅ Regular checkpoint saved for", player.Name)
	else
		warn("❌ Failed to save regular checkpoint for", player.Name, ":", err)
	end
end

function PlayerJourneyService.CompleteJourney(player)
	local userId = player.UserId
	local data = journeyData[userId]

	if not data or not data.isActive then
		warn("❌ Invalid journey completion for:", player.Name)
		return false
	end

	local arrivalTime = tick()
	local journeyDuration = arrivalTime - data.departureTime

	-- Update data
	data.arrivalTime = arrivalTime
	data.isActive = false

	-- Anti-cheat validation
	local isValid = PlayerJourneyService.ValidateJourney(journeyDuration)

	if isValid then
		print("✅ Valid Journey:", player.Name, "- Duration:", formatTime(journeyDuration))
		journeyData[userId].attempts = (journeyData[userId] and journeyData[userId].attempts or 0) + 1

		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local rootPart = player.Character.HumanoidRootPart
			local positionToSave = {
				X = rootPart.Position.X,
				Y = rootPart.Position.Y + 2,
				Z = rootPart.Position.Z
			}

			-- Create data structure for the datastore
			local checkpointData = {
				Position = positionToSave,
				IsSummit = true, -- This is a summit checkpoint
				DepartureTime = data.departureTime
			}

			local success, err = pcall(function()
				checkpointStore:SetAsync("User-" .. userId, checkpointData)
			end)
			if success then
				print("✅ Summit checkpoint berhasil disimpan untuk", player.Name)
			else
				warn("❌ Gagal menyimpan summit checkpoint untuk", player.Name, ":", err)
			end
		end


		return true
	else
		warn("🚫 SUSPICIOUS JOURNEY:", player.Name, "- Duration:", formatTime(journeyDuration))
		return false
	end
end

function PlayerJourneyService.ValidateJourney(duration)
	if duration < SUSPICIOUS_TIME then
		return false
	end

	return true
end

function PlayerJourneyService.ResetJourney(player)
	local userId = player.UserId
	if journeyData[userId] then
		journeyData[userId].isActive = false
	end

	local success, err = pcall(function()
		checkpointStore:RemoveAsync("User-" .. userId)
	end)

	if success then
		print("🔄 Journey & Checkpoint Reset:", player.Name)
	else
		warn("❌ Gagal menghapus checkpoint untuk", player.Name, ":", err)
	end
end

function PlayerJourneyService.PrintAll(player: Player)
	if player then
		local data = journeyData[player.UserId]
		if data then
			local currentDuration = tick() - data.departureTime
			print("Journey Status for " .. player.Name .. ":")
			print("Duration so far:", formatTime(currentDuration))
			print("Active:", data.isActive)
			print("Attempts:", data.attempts)
		end
	end
end

function PlayerJourneyService.GetData(player: Player)
	if player then
		return journeyData[player.UserId]
	end
end

function PlayerJourneyService.GetSummitMessage(player: Player)
	if not player then
		return nil
	end

	local userId = player.UserId
	local data = journeyData[userId]

	-- Check if player has valid journey data
	if not data or not data.departureTime or not data.arrivalTime then
		return string.format("🏔️ %s reached the summit!", player.Name)
	end

	-- Calculate journey duration
	local journeyDuration = data.arrivalTime - data.departureTime
	local formattedTime = formatTime(journeyDuration)

	-- Create summit message based on duration
	local message
	local timeEmoji = ""

	-- Add emoji based on performance
	if journeyDuration < 600 then -- Under 10 minutes - Very Fast
		timeEmoji = "🚀⚡"
	elseif journeyDuration < 1800 then -- Under 30 minutes - Fast
		timeEmoji = "🏃‍♂️💨"
	elseif journeyDuration < 3600 then -- Under 1 hour - Good
		timeEmoji = "🥾✨"
	else -- Over 1 hour - Steady climb
		timeEmoji = "🐌💪"
	end

	-- Create the message
	if data.attempts == 1 then
		message = string.format("🏔️ %s %s has conquered the summit in %s on their first attempt this session! 🎉",
			timeEmoji, player.Name, formattedTime)
	else
		message = string.format("🏔️ %s %s has reached the summit in %s (Attempt #%d this session)! 🎊",
			timeEmoji, player.Name, formattedTime, data.attempts)
	end

	return message
end

return PlayerJourneyService
