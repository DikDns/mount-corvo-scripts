--!nonstrict
--[[
	VipTrailService (Revised)
	Modul ini bertanggung jawab untuk memasang efek trail VIP ke HumanoidRootPart pemain.
]]

local ServerStorage = game:GetService("ServerStorage")

local VipTrailService = {}

-- Path ke template trail
local trailTemplate = ServerStorage:WaitForChild("VipTrail")

-- Fungsi untuk memasang trail ke HumanoidRootPart karakter
local function applyTrailToRoot(character: Model)
	-- Pastikan HumanoidRootPart ada
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Cek jika trail sudah ada untuk mencegah duplikasi
	if character:FindFirstChild("VipTrail_Root") then return end

	-- Clone template trail
	local trailPart = trailTemplate:Clone()
	trailPart.Name = "VipTrail_Root"
	trailPart.Parent = character
	trailPart.CFrame = rootPart.CFrame

	-- Weld trail part ke HumanoidRootPart agar mengikuti gerakan
	-- Tidak perlu membuat attachment lagi, karena diasumsikan sudah ada di dalam 'trailPart'
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = rootPart
	weld.Part1 = trailPart
	weld.Parent = trailPart
end

-- Fungsi utama untuk dipanggil oleh handler lain
function VipTrailService.applyTrail(player)
	-- Fungsi untuk memasang trail ke karakter saat ini dan masa depan (setelah respawn)
	local function onCharacterAdded(character)
		-- Tunggu hingga HumanoidRootPart dimuat
		character:WaitForChild("HumanoidRootPart")

		applyTrailToRoot(character)
	end

	-- Jika karakter sudah ada saat fungsi ini dipanggil
	if player.Character then
		onCharacterAdded(player.Character)
	end

	-- Hubungkan ke event CharacterAdded untuk menangani respawn
	player.CharacterAdded:Connect(onCharacterAdded)
	print("VIP Trail Service diaktifkan untuk:", player.Name)
end

return VipTrailService
