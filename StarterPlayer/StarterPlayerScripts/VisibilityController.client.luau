--!nonstrict
--[[
	VisibilityController (Client)
	Mendengarkan update dari InvisibilityService dan menyembunyikan/menampilkan karakter.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local stateChangedEvent = ReplicatedStorage.Remotes:WaitForChild("InvisibilityStateChanged")

local localPlayer = Players.LocalPlayer
local invisibleList = {} -- Daftar lokal berisi UserId pemain invisible

-- Fungsi untuk memperbarui visibilitas sebuah karakter
local function updateCharacterVisibility(character)
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	-- [DIUBAH] Gunakan tostring() untuk mencocokkan tipe data string dari daftar
	local isTargetInvisible = invisibleList[tostring(player.UserId)]
	local transparency = isTargetInvisible and 1 or 0

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			descendant.LocalTransparencyModifier = transparency
		elseif descendant:IsA("Trail") then
			descendant.Enabled = not isTargetInvisible
		end
	end

	local tag = character:FindFirstChild("Head") and character.Head:FindFirstChild("Tag")
	if tag then
		tag.Enabled = not isTargetInvisible
	end
end

-- Saat server mengirim daftar baru
stateChangedEvent.OnClientEvent:Connect(function(newList)
	invisibleList = newList
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			updateCharacterVisibility(player.Character)
		end
	end
end)

-- Handle saat karakter baru muncul
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(updateCharacterVisibility)
end)
for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(updateCharacterVisibility)
end
