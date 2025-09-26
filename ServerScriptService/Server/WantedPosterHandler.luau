-- Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

-- DataStore
local donationStore = DataStoreService:GetDataStore("Donation Board // V3 - Data")
local DONATION_KEY = "Donations"

-- Configuration
local UPDATE_INTERVAL = 60
local MAX_RETRIES = 3
local RETRY_DELAY = 5

-- Caching
local lastDataHash = ""
local thumbnailCache = {}
local lastUpdate = 0

local function formatBounty(amount)
	local s = tostring(math.floor(amount))
	local result = ""
	for i = 1, #s do
		if i > 1 and (i - 1) % 3 == 0 then
			result = "," .. result
		end
		result = s:sub(#s - i + 1, #s - i + 1) .. result
	end
	return result
end

-- Improved thumbnail fetching with caching and retry logic
local function getThumbnailAsync(userId)
	-- Check cache first
	if thumbnailCache[userId] then
		return true, thumbnailCache[userId]
	end

	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420

	for attempt = 1, MAX_RETRIES do
		local success, imageUrl = pcall(Players.GetUserThumbnailAsync, Players, userId, thumbType, thumbSize)

		if success and imageUrl then
			thumbnailCache[userId] = imageUrl -- Cache the result
			return true, imageUrl
		end

		if attempt < MAX_RETRIES then
			task.wait(RETRY_DELAY)
		end
	end

	warn("Failed to get thumbnail for userId:", userId, "after", MAX_RETRIES, "attempts")
	return false, ""
end

-- Main update function
local function updateWantedPosters()
	-- 1. Fetch data from DataStore
	local success, data = pcall(function()
		return donationStore:GetAsync(DONATION_KEY)
	end)

	if not success then
		warn("Failed to fetch donation data:", data)
		return
	end

	if not data or not data.Users then
		print("No donation data available")
		return
	end

	-- 2. Create hash to check if data changed
	local dataString = game:GetService("HttpService"):JSONEncode(data)
	local currentHash = game:GetService("HttpService"):JSONEncode({dataString, RunService:IsStudio()})

	-- Skip update if data hasn't changed
	if currentHash == lastDataHash then
		print("Donation data unchanged, skipping update")
		return
	end

	lastDataHash = currentHash
	-- 3. Convert data to sortable list
	local donorsList = {}
	for _, userId in ipairs(data.Users) do
		local userData = data[userId]
		if userData then
			table.insert(donorsList, userData)
		end
	end

	-- 4. Sort donors by total donation
	table.sort(donorsList, function(a, b)
		local totalA = (a["Donated - Experience"] or 0) + (RunService:IsStudio() and (a["Donated - Studio"] or 0) or 0)
		local totalB = (b["Donated - Experience"] or 0) + (RunService:IsStudio() and (b["Donated - Studio"] or 0) or 0)
		return totalA > totalB
	end)

	-- 5. Update posters
	for rank = 1, 4 do
		local tagName = "WantedPosterRank" .. tostring(rank)
		local allPostersForThisRank = CollectionService:GetTagged(tagName)
		local donorData = donorsList[rank]

		for _, posterPart in ipairs(allPostersForThisRank) do
			if not posterPart or not posterPart.Parent then
				warn("Invalid poster part found for rank", rank)
				continue
			end

			local gui = posterPart:FindFirstChild("SurfaceGui")
			if not gui then
				warn("SurfaceGui not found on poster:", posterPart.Name)
				continue
			end

			if donorData then
				-- Update with donor data
				local userId = donorData.UserId
				local amount = (donorData["Donated - Experience"] or 0) +
					(RunService:IsStudio() and (donorData["Donated - Studio"] or 0) or 0)
				local username = donorData.Name or "Player"

				-- Safely update GUI elements
				pcall(function()
					if gui:FindFirstChild("PlayerName") then
						gui.PlayerName.Text = string.upper(username)
					end

					if gui:FindFirstChild("PlayerBounty") then
						gui.PlayerBounty.Text = formatBounty(amount)
					end

					if gui:FindFirstChild("PlayerPhoto") then
						-- Get thumbnail asynchronously to avoid blocking
						task.spawn(function()
							local thumbSuccess, imageUrl = getThumbnailAsync(userId)
							if thumbSuccess and gui:FindFirstChild("PlayerPhoto") then
								gui.PlayerPhoto.Image = imageUrl
							end
						end)
					end
				end)
			else
				-- Clear poster if no data
				pcall(function()
					if gui:FindFirstChild("PlayerPhoto") then
						gui.PlayerPhoto.Image = ""
					end
					if gui:FindFirstChild("PlayerName") then
						gui.PlayerName.Text = "???"
					end
					if gui:FindFirstChild("PlayerBounty") then
						gui.PlayerBounty.Text = "0"
					end
				end)
			end
		end
	end

	print("✅ Wanted posters updated successfully")
end

-- Initial update
task.spawn(updateWantedPosters)

-- Set up periodic updates using Heartbeat
RunService.Heartbeat:Connect(function()
	local now = tick()
	if now - lastUpdate >= UPDATE_INTERVAL then
		lastUpdate = now
		task.spawn(updateWantedPosters) -- Use task.spawn to prevent blocking
	end
end)

print("✅ Optimized Wanted Posters Script loaded")
