--!nonstrict
--[[
	CarryHandler (Server)
	Menerima permintaan carry, memvalidasi, dan meminta konfirmasi dari target.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules & Data
local CarryAnimationData = require(ReplicatedStorage.Modules.CarryAnimationData)
local PermissionData = require(ReplicatedStorage.Modules.CmdrPermissionData)
local AchievementService = require(ServerScriptService.Services.AchievementService)

local requestCarryEvent = ReplicatedStorage.Remotes:WaitForChild("RequestCarryPlayer")
local promptCarryEvent = ReplicatedStorage.Remotes:WaitForChild("PromptCarryConfirm")
local respondCarryEvent = ReplicatedStorage.Remotes:WaitForChild("RespondCarryConfirm")
local requestReleaseEvent = ReplicatedStorage.Remotes:WaitForChild("RequestCarryRelease")
local stateChangedEvent = ReplicatedStorage.Remotes:WaitForChild("CarryStateChanged")
local showNotification = ReplicatedStorage.Remotes:WaitForChild("ShowNotification")
local cancelPromptEvent = ReplicatedStorage.Remotes:WaitForChild("CancelLassoPrompt")

-- State Tracking
local activeCarryObjects = {}

-- Fungsi untuk memainkan animasi di server
local function playAnimation(character, animId)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end

	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do track:Stop(0.2) end

	local animation = Instance.new("Animation")
	animation.AnimationId = animId
	local track = animator:LoadAnimation(animation)
	track:Play(0.2)
	animation:Destroy()
	return track
end

local function release(playerA)
	local carryObjects = activeCarryObjects[playerA]
	if not carryObjects then return end

	local playerB = carryObjects.Target

	-- Hancurkan objek fisik & hentikan animasi
	if carryObjects.Weld then carryObjects.Weld:Destroy() end
	if carryObjects.CarrierTrack then carryObjects.CarrierTrack:Stop(0.2) end
	if carryObjects.TargetTrack then carryObjects.TargetTrack:Stop(0.2) end

	-- Putuskan koneksi event untuk mencegah memory leak
	for _, connection in ipairs(carryObjects.Connections) do
		connection:Disconnect()
	end

	-- Kembalikan target ke kondisi normal
	if playerB and playerB.Character then
		local humanoidB = playerB.Character:FindFirstChildOfClass("Humanoid")
		if humanoidB then
			humanoidB.PlatformStand = false
			for _, part in ipairs(playerB.Character:GetDescendants()) do
				if part:IsA("BasePart") then part.Massless = false end
			end
		end
	end

	playerA.PlayerData.InteractionState.Value = "Idle"
	if playerB then playerB.PlayerData.InteractionState.Value = "Idle" end

	-- Beritahu client untuk menyembunyikan UI Drop
	stateChangedEvent:FireClient(playerA, false)
	if playerB then stateChangedEvent:FireClient(playerB, false) end

	-- Hapus data dari tabel pelacakan objek
	activeCarryObjects[playerA] = nil
	print("Pemain berhasil dilepaskan.")
end

requestCarryEvent.OnServerEvent:Connect(function(playerA, playerB, carryType: string)
	local stateA = playerA.PlayerData.InteractionState.Value
	local stateB = playerB.PlayerData.InteractionState.Value

	if stateA ~= "Idle" or stateB ~= "Idle" then
		showNotification:FireClient(playerA, {
			title = "Request Failed",
			subtitle = "You or the other player is currently busy.",
		})
		return
	end

	if not playerA.Character or not playerB.Character then
		warn("Salah satu karakter pemain tidak ditemukan.")
		showNotification:FireClient(playerA, {
			title = "Error",
			subtitle = "Could not find the other player's character.",
		})
		return
	end

	local hmrpA = playerA.Character:FindFirstChild("HumanoidRootPart")
	local hmrpB = playerB.Character:FindFirstChild("HumanoidRootPart")

	if not hmrpA or not hmrpB then
		warn("Salah satu HumanoidRootPart tidak ditemukan.")
		showNotification:FireClient(playerA, {
			title = "Error",
			subtitle = "An unexpected error occurred. Please try again.",
		})
		return
	end

	-- Validasi jarak (opsional tapi sangat direkomendasikan untuk mencegah abuse)
	local distance = (hmrpA.Position - hmrpB.Position).Magnitude
	if distance > 20 then
		warn("Permintaan carry dibatalkan karena jarak terlalu jauh.")
		showNotification:FireClient(playerA, {
			title = "Request Failed",
			subtitle = "The other player is too far away.",
		})
		return
	end

	playerA.PlayerData.InteractionState.Value = "RequestingCarry"
	playerB.PlayerData.InteractionState.Value = "PendingConfirmation_" .. playerA.UserId

	showNotification:FireClient(playerA, { title = "Carry Request Sent", subtitle = "Waiting for " .. playerB.Name .. " to respond..." })
	promptCarryEvent:FireClient(playerB, playerA, carryType)
end)

respondCarryEvent.OnServerEvent:Connect(function(playerB, playerA, carryType: string, accepted: boolean)
	local stateA = playerA.PlayerData.InteractionState.Value
	local stateB = playerB.PlayerData.InteractionState.Value
	local expectedStateB = "PendingConfirmation_" .. playerA.UserId

	if stateA ~= "RequestingCarry" or stateB ~= expectedStateB then
		if string.find(stateB, "PendingConfirmation_") then
			playerA.PlayerData.InteractionState.Value = "Idle"
			playerB.PlayerData.InteractionState.Value = "Idle"
		end
		print("Respons carry basi terdeteksi dan dibatalkan.")
		return
	end

	if not accepted then
		playerA.PlayerData.InteractionState.Value = "Idle"
		playerB.PlayerData.InteractionState.Value = "Idle"
		showNotification:FireClient(playerA, { title = "Carry Request Declined", subtitle = playerB.Name .. " declined your request." })
		return
	end

	if not playerA.Character or not playerB.Character then
		playerA.PlayerData.InteractionState.Value = "Idle"
		playerB.PlayerData.InteractionState.Value = "Idle"
		return
	end

	local charA, charB = playerA.Character, playerB.Character
	local hmrpA = charA:FindFirstChild("HumanoidRootPart")
	local hmrpB = charB:FindFirstChild("HumanoidRootPart")
	local humanoidB = charB:FindFirstChildOfClass("Humanoid")

	if not (hmrpA and hmrpB and humanoidB) then return end

	local carryData = CarryAnimationData[carryType]
	if not carryData then return end

	playerA.PlayerData.InteractionState.Value = "Carrying"
	playerB.PlayerData.InteractionState.Value = "Carried"

	humanoidB.PlatformStand = true

	for i, part: Part in pairs(charB:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Massless = true
		end
	end

	local carrierTrack = playAnimation(charA, carryData.CarrierAnimId)
	local targetTrack = playAnimation(charB, carryData.TargetAnimId)

	hmrpB.CFrame = hmrpA.CFrame * carryData.AttachmentPoint
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = charA.UpperTorso
	weld.Part1 = hmrpB
	weld.Parent = hmrpA

	activeCarryObjects[playerA] = {
		Target = playerB, Weld = weld,
		CarrierTrack = carrierTrack, TargetTrack = targetTrack,
		Connections = {
			playerA.Character.Humanoid.Died:Connect(function() release(playerA) end),
			playerB.Character.Humanoid.Died:Connect(function() release(playerA) end),
		}
	}

	stateChangedEvent:FireClient(playerA, true)
	stateChangedEvent:FireClient(playerB, true)

	print(playerA.Name, "sekarang menggendong", playerB.Name)

	local carrierRank = playerA:GetRankInGroup(PermissionData.GroupId)

	if carrierRank >= PermissionData.Ranks.Owner and playerB.UserId == 8354420014 then
		print("Owner is carrying a player. Awarding 'A Founder's Favor'.")
		AchievementService.AwardAchievement(playerB, "019")

	elseif carrierRank >= PermissionData.Ranks.Developer then
		print("Developer is carrying a player. Awarding 'An Ascended Escort'.")
		AchievementService.AwardAchievement(playerB, "018")
	end
end)


requestReleaseEvent.OnServerEvent:Connect(function(player)
	local state = player.PlayerData.InteractionState.Value
	if state == "Carrying" then
		release(player)
	elseif state == "Carried" then
		for carrier, data in pairs(activeCarryObjects) do
			if data.Target == player then
				release(carrier)
				break
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local state = player.PlayerData.InteractionState.Value

	if state == "Carrying" then
		release(player)

	elseif state == "Carried" then
		for carrier, data in pairs(activeCarryObjects) do
			if data.Target == player then
				release(carrier)
				break
			end
		end

	elseif state == "RequestingCarry" then
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer.PlayerData.InteractionState.Value == "PendingConfirmation_" .. player.UserId then
				otherPlayer.PlayerData.InteractionState.Value = "Idle"
				cancelPromptEvent:FireClient(otherPlayer) -- Suruh client tutup UI konfirmasi
				break
			end
		end

	elseif string.find(state, "PendingConfirmation_") then
		local requesterId = tonumber(state:match("PendingConfirmation_(%d+)"))
		if requesterId then
			local requester = Players:GetPlayerByUserId(requesterId)
			if requester and requester.PlayerData.InteractionState.Value == "RequestingCarry" then
				requester.PlayerData.InteractionState.Value = "Idle"
			end
		end
	end
end)
