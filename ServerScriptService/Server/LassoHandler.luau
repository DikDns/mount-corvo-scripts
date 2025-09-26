--!nonstrict
--[[
	LassoHandler (Final Version with Physics Fix)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local PermissionData = require(ReplicatedStorage.Modules.CmdrPermissionData)
local AchievementService = require(ServerScriptService.Services.AchievementService)


local requestEvent = ReplicatedStorage.Remotes:WaitForChild("RequestLassoPlayer")
local promptEvent = ReplicatedStorage.Remotes:WaitForChild("PromptLassoConfirm")
local respondEvent = ReplicatedStorage.Remotes:WaitForChild("RespondLassoConfirm")
local requestReleaseEvent = ReplicatedStorage.Remotes:WaitForChild("RequestLassoRelease")
local stateChangedEvent = ReplicatedStorage.Remotes:WaitForChild("LassoStateChanged")
local showNotification = ReplicatedStorage.Remotes:WaitForChild("ShowNotification")
local cancelPromptEvent = ReplicatedStorage.Remotes:WaitForChild("CancelLassoPrompt")
local ragdollState = ReplicatedStorage.Remotes:WaitForChild("RagdollState")

local activeLassoObjects = {}

-- ===================================================================
-- FUNGSI UTAMA UNTUK MELEPAS IKATAN (REUSABLE)
-- ===================================================================
local function release(playerA)
	local lassoObjects = activeLassoObjects[playerA]
	if not lassoObjects then return end

	local playerB = lassoObjects.Target

	-- Hancurkan objek fisik & hentikan animasi
	if lassoObjects.Rope then lassoObjects.Rope:Destroy() end
	for _, item in ipairs(lassoObjects.Attachments) do item:Destroy() end

	for _, connection in ipairs(lassoObjects.Connections) do
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
			if humanoidB:HasTag('Ragdoll') then
				humanoidB:RemoveTag('Ragdoll')
			end
		end
	end

	-- [PENTING] Reset "stiker" status kedua pemain kembali ke "Idle"
	playerA.PlayerData.InteractionState.Value = "Idle"
	if playerB then playerB.PlayerData.InteractionState.Value = "Idle" end

	stateChangedEvent:FireClient(playerA, false)
	activeLassoObjects[playerA] = nil
	print("Lasso berhasil dilepaskan.")
end

-- ===================================================================
-- EVENT LISTENERS
-- ===================================================================

-- Player A meminta untuk mengikat Player B
requestEvent.OnServerEvent:Connect(function(playerA, playerB)
	local stateA = playerA.PlayerData.InteractionState.Value
	local stateB = playerB.PlayerData.InteractionState.Value
	if stateA ~= "Idle" or stateB ~= "Idle" then
		showNotification:FireClient(playerA, { title = "Request Failed", subtitle = "You or the other player is busy." })
		return
	end

	playerA.PlayerData.InteractionState.Value = "RequestingLasso"
	playerB.PlayerData.InteractionState.Value = "PendingConfirmation_" .. playerA.UserId

	showNotification:FireClient(playerA, { title = "Rope Request Sent", subtitle = "Waiting for " .. playerB.Name .. "..." })
	promptEvent:FireClient(playerB, playerA)

	local unequipConnection
	unequipConnection = playerA.Character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") and child.Name == "Lasso" then
			if playerA.PlayerData.InteractionState.Value == "RequestingLasso" then
				playerA.PlayerData.InteractionState.Value = "Idle"
				playerB.PlayerData.InteractionState.Value = "Idle"
				cancelPromptEvent:FireClient(playerB)
				if unequipConnection then unequipConnection:Disconnect() end
			end
		end
	end)
end)

-- Player B merespon permintaan
respondEvent.OnServerEvent:Connect(function(playerB, playerA, accepted)
	local expectedStateB = "PendingConfirmation_" .. playerA.UserId
	if playerA.PlayerData.InteractionState.Value ~= "RequestingLasso" or playerB.PlayerData.InteractionState.Value ~= expectedStateB then
		playerA.PlayerData.InteractionState.Value = "Idle"
		playerB.PlayerData.InteractionState.Value = "Idle"
		return
	end

	if not accepted then
		playerA.PlayerData.InteractionState.Value = "Idle"
		playerB.PlayerData.InteractionState.Value = "Idle"
		showNotification:FireClient(playerA, { title = "Request Declined", subtitle = playerB.Name .. " declined." })
		return
	end

	if not playerA.Character or not playerB.Character then
		playerA.PlayerData.InteractionState.Value = "Idle"
		playerB.PlayerData.InteractionState.Value = "Idle"
		return
	end

	playerA.PlayerData.InteractionState.Value = "Dragging"
	playerB.PlayerData.InteractionState.Value = "Dragged"

	local charA = playerA.Character
	local charB = playerB.Character
	local humanoidB = charB.Humanoid

	-- [+] TERAPKAN SOLUSI FISIKA UNTUK MENCEGAH LAG
	humanoidB.PlatformStand = true
	for _, part in ipairs(charB:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Massless = true
		end
	end

	humanoidB:AddTag('Ragdoll')

	-- Buat ikatan fisik
	local originPartA = charA:FindFirstChild("RightHand") or charA:FindFirstChild("Right Arm") or charA.HumanoidRootPart
	local legB = charB.LeftLowerLeg

	local attachmentA = Instance.new("Attachment", originPartA)
	local attachmentB = Instance.new("Attachment", legB)

	local rope: RopeConstraint = Instance.new("RopeConstraint", originPartA)
	rope.Attachment0 = attachmentA
	rope.Attachment1 = attachmentB
	rope.Length = 10
	rope.Visible = true
	rope.Color = BrickColor.new(18)
	rope.Thickness = 0.15

	activeLassoObjects[playerA] = {
		Target = playerB,
		Rope = rope,
		Attachments = {attachmentA, attachmentB},
		Connections = {
			charA.Humanoid.Died:Connect(function() release(playerA) end),
			charB.Humanoid.Died:Connect(function() release(playerA) end)
		}
	}
	stateChangedEvent:FireClient(playerA, true)

	local targetRank = playerB:GetRankInGroup(PermissionData.GroupId)
	if targetRank >= PermissionData.Ranks.Developer then
		print("Player is dragging a developer. Awarding 'Leading the Architects'.")
		AchievementService.AwardAchievement(playerA, "020")
	end

	local attackerRank = playerA:GetRankInGroup(PermissionData.GroupId)
	if attackerRank >= PermissionData.Ranks.Developer then
		print("Developer is dragging a player. Awarding 'A Guided Tour'.")
		AchievementService.AwardAchievement(playerB, "021")
	end

end)

requestReleaseEvent.OnServerEvent:Connect(function(player)
	local state = player.PlayerData.InteractionState.Value
	if state == "Dragging" then
		release(player)
	elseif state == "Dragged" then
		for attacker, data in pairs(activeLassoObjects) do
			if data.Target == player then
				release(attacker)
				break
			end
		end
	end
end)


Players.PlayerRemoving:Connect(function(player)
	local state = player.PlayerData.InteractionState.Value

	if state == "Dragging" then
		release(player)

	elseif state == "Dragged" then
		for attacker, data in pairs(activeLassoObjects) do
			if data.Target == player then
				release(attacker)
				break
			end
		end

	elseif state == "RequestingLasso" then
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer.PlayerData.InteractionState.Value == "PendingConfirmation_" .. player.UserId then
				otherPlayer.PlayerData.InteractionState.Value = "Idle"
				cancelPromptEvent:FireClient(otherPlayer)
				break
			end
		end

	elseif string.find(state, "PendingConfirmation_") then
		local requesterId = tonumber(state:match("PendingConfirmation_(%d+)"))
		if requesterId then
			local requester = Players:GetPlayerByUserId(requesterId)
			if requester and requester.PlayerData.InteractionState.Value == "RequestingLasso" then
				requester.PlayerData.InteractionState.Value = "Idle"
			end
		end
	end
end)



print("✅ LassoHandler is running.")
