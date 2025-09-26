--!nonstrict
--[[
	SpectateController (Client)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local toggleSpectateEvent = ReplicatedStorage.Remotes:WaitForChild("ToggleSpectate")

local isSpectating = false
local originalCameraSubject = nil
local spectateTarget = nil

-- Fungsi untuk menghentikan mode spectate
local function stopSpectating()
	if not isSpectating then return end

	camera.CameraSubject = originalCameraSubject
	camera.CameraType = Enum.CameraType.Custom
	isSpectating = false
	spectateTarget = nil
end

-- Fungsi untuk memulai mode spectate
local function startSpectating(targetPlayer)
	stopSpectating() -- Hentikan spectate sebelumnya jika ada

	if not targetPlayer.Character or not targetPlayer.Character:FindFirstChildOfClass("Humanoid") then
		print("Target character is not available.")
		return
	end

	originalCameraSubject = camera.CameraSubject -- Simpan subjek kamera asli

	camera.CameraSubject = targetPlayer.Character.Humanoid
	camera.CameraType = Enum.CameraType.Custom -- Atau Enum.CameraType.Follow
	isSpectating = true
	spectateTarget = targetPlayer
end

toggleSpectateEvent.OnClientEvent:Connect(function(targetPlayer)
	if not targetPlayer or (isSpectating and targetPlayer == spectateTarget) then
		stopSpectating()
	else
		startSpectating(targetPlayer)
	end
end)

Players.PlayerRemoving:Connect(function(playerLeft)
	if isSpectating and playerLeft == spectateTarget then
		stopSpectating()
	end
end)
