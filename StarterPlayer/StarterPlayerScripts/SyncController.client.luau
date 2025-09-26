--[[
	SyncController - Server-Authoritative Sync System (FIXED)
	- Timing yang lebih akurat dan stable
	- Better error handling untuk multiple players
	- Improved UI state management
]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Character references (akan di-update saat character spawn)
local Character = nil
local Humanoid = nil
local Animator = nil

-- RemoteEvents
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BroadcastSync = Remotes:WaitForChild("BroadcastSync")
local RequestUnsync = Remotes:WaitForChild("RequestUnsync")

-- UI References
local screenGui = PlayerGui:WaitForChild("ActiveSyncScreenGUI")
local popUpScreen = screenGui.PopUpScreen
local stopSyncButton = popUpScreen.ButtonFrame.Button

-- State
local currentSyncTrack = nil
local currentAnimationId = nil
local isButtonOnScreen = false
local isCurrentlySyncing = false
local lastSyncData = nil

-- Konfigurasi Animasi UI
local TWEEN_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local POSITION_ONSCREEN = UDim2.new(0.5, 0, 0.9, 0)
local POSITION_OFFSCREEN = UDim2.new(0.5, 0, 1.5, 0)

-- Atur posisi awal UI
popUpScreen.Position = POSITION_OFFSCREEN
screenGui.Enabled = false

-- Fungsi untuk mendapatkan timing yang akurat
local function getAccurateTime()
	return math.floor(workspace.DistributedGameTime * 1000) / 1000
end

-- Fungsi untuk update character references
local function updateCharacterReferences(newCharacter)
	Character = newCharacter
	if Character then
		-- Wait untuk Humanoid dan Animator dengan timeout
		local humanoidFound = false
		local animatorFound = false

		for i = 1, 50 do -- Max 5 detik wait
			Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				humanoidFound = true
				Animator = Humanoid:FindFirstChildOfClass("Animator")
				if Animator then
					animatorFound = true
					break
				end
			end
			wait(0.1)
		end

		if humanoidFound and animatorFound then
			print("Character references updated for", LocalPlayer.Name)
		else
			warn("Failed to get complete character references for", LocalPlayer.Name)
		end
	else
		Humanoid = nil
		Animator = nil
		print("Character references cleared for", LocalPlayer.Name)
	end
end

local function showStopSyncButton()
	if isButtonOnScreen then return end
	isButtonOnScreen = true

	screenGui.Enabled = true
	local openTween = TweenService:Create(popUpScreen, TWEEN_INFO, { Position = POSITION_ONSCREEN })
	openTween:Play()
	print("Stop Sync button shown")
end

local function hideStopSyncButton()
	if not isButtonOnScreen then return end
	isButtonOnScreen = false

	local closeTween = TweenService:Create(popUpScreen, TWEEN_INFO, { Position = POSITION_OFFSCREEN })
	closeTween.Completed:Once(function()
		if not isButtonOnScreen then
			screenGui.Enabled = false
		end
	end)
	closeTween:Play()
	print("Stop Sync button hidden")
end

-- Fungsi untuk cleanup sync state
local function cleanupSyncState()
	if currentSyncTrack then
		local success = pcall(function()
			currentSyncTrack:Stop()
			currentSyncTrack:Destroy()
		end)
		if not success then
			print("Error cleaning up sync track")
		end
		currentSyncTrack = nil
	end
	currentAnimationId = nil
	isCurrentlySyncing = false
	lastSyncData = nil
	hideStopSyncButton()
	print("Sync state cleaned up.")
end

-- Saat tombol di-klik
stopSyncButton.Activated:Connect(function()
	print("Stop Sync button clicked. Requesting unsync.")
	RequestUnsync:FireServer()
	-- Langsung hide button untuk responsiveness
	hideStopSyncButton()
	isCurrentlySyncing = false
end)

-- Handle sync broadcast dari server dengan error handling yang lebih baik
local function handleSyncBroadcast(syncData)
	-- Pastikan character references valid
	if not Character or not Humanoid or not Animator then
		print("Character not ready, ignoring sync broadcast")
		return
	end

	if not syncData or not syncData.AnimationId then
		-- PERINTAH STOP DARI SERVER
		print("Received stop sync command from server")
		cleanupSyncState()
		return
	end

	-- Validasi sync data
	if not syncData.StartTime or not syncData.CurrentTime then
		print("Invalid sync data received")
		return
	end

	-- PERINTAH MULAI/UPDATE SYNC DARI SERVER
	print("Received sync command:", syncData.AnimationId, "IsMaster:", syncData.IsMaster)
	isCurrentlySyncing = true
	lastSyncData = syncData

	-- Hanya tampilkan button untuk slave (bukan master)
	if not syncData.IsMaster then
		showStopSyncButton()
	else
		print("I am the master, no unsync button needed")
		hideStopSyncButton() -- Pastikan master tidak punya button
	end

	-- Cleanup animasi lama
	if currentSyncTrack then
		local success = pcall(function()
			currentSyncTrack:Stop()
			currentSyncTrack:Destroy()
		end)
		if not success then
			print("Error stopping old track")
		end
		currentSyncTrack = nil
	end

	-- Load animasi baru dengan error handling
	local success, errorMsg = pcall(function()
		local animation = Instance.new("Animation")
		animation.AnimationId = syncData.AnimationId
		currentSyncTrack = Animator:LoadAnimation(animation)

		if currentSyncTrack then
			-- Set properties sebelum play untuk konsistensi
			currentSyncTrack.Priority = Enum.AnimationPriority.Action
			currentSyncTrack.Looped = true

			currentSyncTrack:Play(0.1, 1, 1) -- Play dengan weight dan speed 1

			-- Kalkulasi time position yang akurat
			local currentTime = getAccurateTime()
			local timeDiff = currentTime - syncData.StartTime
			local timePosition = math.max(0, timeDiff)

			-- Avoid setting position lebih besar dari animation length
			if currentSyncTrack.Length > 0 and timePosition > currentSyncTrack.Length then
				timePosition = timePosition % currentSyncTrack.Length
			end

			currentSyncTrack.TimePosition = timePosition
			currentAnimationId = syncData.AnimationId

			if syncData.IsMaster then
				print(string.format("Master syncing: Animation restarted at position %.3f", timePosition))
			else
				print(string.format("Slave syncing: Animation started at position %.3f", timePosition))
			end
		else
			error("Failed to load animation track")
		end

		animation:Destroy()
	end)

	if not success then
		print("Error loading sync animation:", errorMsg)
		cleanupSyncState()
	end
end

-- Event connections
BroadcastSync.OnClientEvent:Connect(handleSyncBroadcast)

-- Handle character spawn/respawn
local function onCharacterAdded(newCharacter)
	print("Character added for", LocalPlayer.Name)
	cleanupSyncState() -- Cleanup dulu sebelum update references
	updateCharacterReferences(newCharacter)
end

local function onCharacterRemoving(oldCharacter)
	print("Character removing for", LocalPlayer.Name)
	cleanupSyncState()
	updateCharacterReferences(nil)
end

-- Setup initial character
if LocalPlayer.Character then
	onCharacterAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
LocalPlayer.CharacterRemoving:Connect(onCharacterRemoving)

-- Monitor untuk error handling dan auto-correction
local lastErrorTime = 0
local lastSyncCheck = 0

RunService.Heartbeat:Connect(function()
	local currentTime = getAccurateTime()

	-- Check sync state setiap 0.5 detik
	if currentTime - lastSyncCheck > 0.5 then
		lastSyncCheck = currentTime

		if isCurrentlySyncing and currentSyncTrack then
			-- Cek apakah track masih valid dan playing
			if not currentSyncTrack.IsPlaying and currentSyncTrack.Length > 0 then
				print("Sync track stopped unexpectedly, attempting restart")

				-- Coba restart kalau ada last sync data
				if lastSyncData then
					currentSyncTrack:Play(0.1, 1, 1)
					local timeDiff = currentTime - lastSyncData.StartTime
					local timePosition = math.max(0, timeDiff)
					if currentSyncTrack.Length > 0 and timePosition > currentSyncTrack.Length then
						timePosition = timePosition % currentSyncTrack.Length
					end
					currentSyncTrack.TimePosition = timePosition
				else
					cleanupSyncState()
				end
			end
		end
	end

	-- Auto-hide button jika tidak sedang sync (fallback dengan timeout lebih lama)
	if isButtonOnScreen and not isCurrentlySyncing then
		if currentTime - lastErrorTime > 10 then -- 10 detik timeout
			print("Auto-hiding sync button (timeout)")
			hideStopSyncButton()
			lastErrorTime = currentTime
		end
	end
end)

print("✅ Fixed SyncController with enhanced stability ready!")
