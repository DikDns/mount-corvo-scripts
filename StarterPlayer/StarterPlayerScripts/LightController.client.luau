--!nonstrict
--[[
	LightController (Client - Final Version)
	Mengoptimisasi semua lampu dengan memanipulasi Brightness & Range.
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local RENDER_DISTANCE = 150

-- [DIUBAH] Tabel ini sekarang nyimpen data lengkap buat tiap lampu
local managedLights = {}

-- [FUNGSI BARU] Fungsi buat nambahin lampu ke manajer
local function addLightToManager(light)
	if light:IsA("Light") and not managedLights[light] then
		-- Simpen data asli lampu dan state awalnya
		managedLights[light] = {
			OriginalBrightness = light.Brightness,
			OriginalRange = light.Range,
			IsVisible = false, -- Status saat ini
			ActiveTween = nil,
		}

		-- Langsung matiin lampu (set Brightness/Range jadi 0) kalo di luar jangkauan
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local distance = (character.HumanoidRootPart.Position - light.Parent.Position).Magnitude
			if distance > RENDER_DISTANCE then
				light.Brightness = 0
				light.Range = 0
			else
				managedLights[light].IsVisible = true -- Kalo deket, langsung set visible
			end
		end

		print("Lampu baru ditambahkan ke manajer:", light:GetFullName())
	end
end

-- ===================================================================
-- INISIALISASI
-- ===================================================================
for _, descendant in ipairs(Workspace:GetDescendants()) do
	addLightToManager(descendant)
end
Workspace.DescendantAdded:Connect(addLightToManager)

-- ===================================================================
-- LOOP UTAMA
-- ===================================================================
RunService.Heartbeat:Connect(function()
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local playerPos = character.HumanoidRootPart.Position

	for light, data in pairs(managedLights) do
		if not light.Parent then
			managedLights[light] = nil
			continue
		end

		local distance = (playerPos - light.Parent.Position).Magnitude
		local shouldBeVisible = (distance <= RENDER_DISTANCE)

		-- Cuma jalanin tween kalo statusnya berubah (misal, dari jauh jadi deket)
		if shouldBeVisible ~= data.IsVisible then
			data.IsVisible = shouldBeVisible

			-- Batalin tween lama kalo ada
			if data.ActiveTween then
				data.ActiveTween:Cancel()
			end

			local targetProperties
			if shouldBeVisible then
				-- Kalo deket, balikin ke nilai asli
				targetProperties = {
					Brightness = data.OriginalBrightness,
					Range = data.OriginalRange,
				}
			else
				-- Kalo jauh, set jadi 0
				targetProperties = {
					Brightness = 0,
					Range = 0,
				}
			end

			-- Buat dan mainkan tween baru
			data.ActiveTween = TweenService:Create(light, TweenInfo.new(0.5), targetProperties)
			data.ActiveTween:Play()
		end
	end
end)
