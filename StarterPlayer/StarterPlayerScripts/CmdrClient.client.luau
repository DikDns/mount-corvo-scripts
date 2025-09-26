--!nonstrict
--[[
	CmdrClientInitializer (Client) - Respawn-proof version
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Muat modul-modul
local CmdrPermissionData = require(ReplicatedStorage.Modules:WaitForChild("CmdrPermissionData"))
local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Lakukan pengecekan izin HANYA SEKALI
local playerRank = player:GetRankInGroup(CmdrPermissionData.GroupId)
local minimumRankRequired = CmdrPermissionData.Ranks.Admin

if playerRank >= minimumRankRequired then
	CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })

	local function makeButtonVisible()
		local topBarGui = playerGui:WaitForChild("TopBarScreenGUI")
		local cmdrButton = topBarGui.Frame.MainButtonsFrame:WaitForChild("CmdrWrapper")
		if cmdrButton then
			cmdrButton.Visible = true
		end
	end

	-- Hubungkan fungsi di atas ke event CharacterAdded untuk respawn di masa depan
	player.CharacterAdded:Connect(makeButtonVisible)

	-- Jalankan sekali sekarang jika karakter sudah ada
	if player.Character then
		makeButtonVisible()
	end
end
