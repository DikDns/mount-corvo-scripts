-- Script ini akan membuat rig developer di lokasi yang telah ditentukan

local developers = {
	{
		UserId = 108719082,
		Role = "Founder",
		AnimationId = "rbxassetid://88529710841829"
	},
	{
		UserId = 3095416192,
		Role = "Environment Builder",
		AnimationId = "rbxassetid://99926075141080"
	},
	{
		UserId = 3113758260,
		Role = "Environment Builder",
		AnimationId = "rbxassetid://99926075141080"
	},
	{
		UserId = 8560004490,
		Role = "Outfit, 3D Modeller, & Environment Builder",
		AnimationId = "rbxassetid://99926075141080"
	}
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local showcaseFolder = Workspace:WaitForChild("DeveloperShowcase")

-- Fungsi ini tidak lagi meng-clone, tapi membuat rig baru dari scratch.
local function createDevRig(devData, devSpotModel)

	-- Ambil 'SpawnPoint' dari dalem model panggungnya
	local spawnPoint = devSpotModel:FindFirstChild("SpawnPoint")
	if not spawnPoint then
		warn("Model '" .. devSpotModel.Name .. "' tidak punya Part bernama 'SpawnPoint'!")
		return
	end

	-- 1. Buat Rig Avatar baru dari UserId
	local rig = Players:CreateHumanoidModelFromUserId(devData.UserId)

	local success, username = pcall(function()
		return Players:GetNameFromUserIdAsync(devData.UserId)
	end)
	if not success or not username then
		username = devData.Role -- Fallback
		warn("Gagal mendapatkan nama untuk UserId: " .. tostring(devData.UserId))
	end

	rig.Name = username
	-- Parent rig-nya ke dalem model panggung biar rapi
	rig.Parent = devSpotModel

	local humanoid = rig:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")

	rig:WaitForChild("HumanoidRootPart").Anchored = true

	-- 2. Posisikan Rig di atas SpawnPoint
	local rigHalfHeight = rig:GetExtentsSize().Y / 2
	rig:PivotTo(spawnPoint.CFrame * CFrame.new(0, rigHalfHeight, 0))

	-- 3. Mainkan Animasi
	if animator then
		local animation = Instance.new("Animation")
		animation.AnimationId = devData.AnimationId
		local animationTrack = animator:LoadAnimation(animation)
		animationTrack.Looped = true
		animationTrack:Play()
	end

	-- 4. Buat Teks Info (UI)
	local infoGui = Instance.new("BillboardGui")
	infoGui.Name = "InfoGui"
	infoGui.Adornee = rig:WaitForChild("Head")
	infoGui.Size = UDim2.new(6, 0, 2.5, 0)
	infoGui.StudsOffset = Vector3.new(0, 4.5, 0)
	infoGui.AlwaysOnTop = false
	infoGui.Parent = rig:WaitForChild("Head")

	-- (BARU) Bikin Frame sebagai wadah
	local frame = Instance.new("Frame")
	frame.Name = "Container"
	frame.Size = UDim2.new(1, 0, 1, 0) -- Penuhin area BillboardGui
	frame.BackgroundTransparency = 1 -- Bikin transparan, ini cuma buat layout
	frame.Parent = infoGui

	-- Atur roleText
	local roleText = Instance.new("TextLabel")
	roleText.Name = "RoleText"

	-- (GANTI) Ukuran sekarang relatif terhadap Frame
	roleText.Size = UDim2.new(1, 0, 0.5, 0) -- Lebar 100%, tinggi 50% dari Frame

	-- (BARU) Atur jangkar dan posisi biar nempel di bawah
	roleText.AnchorPoint = Vector2.new(0.5, 1) -- Jangkar di tengah-bawah
	roleText.Position = UDim2.new(0.5, 0, 1, 0) -- Posisi di tengah-bawah

	roleText.Text = devData.Role
	roleText.BackgroundTransparency = 1
	roleText.Font = Enum.Font.Merriweather
	roleText.TextScaled = true
	roleText.TextColor3 = Color3.fromRGB(255, 255, 0)

	-- (GANTI) Parent-nya sekarang ke Frame
	roleText.Parent = frame
end

-- Loop untuk setiap developer di dalam tabel
for i, devInfo in ipairs(developers) do
	local spotName = "DevSpot" .. i
	-- Cari Model panggungnya di Workspace
	local devSpotModel = showcaseFolder:FindFirstChild(spotName)

	if devSpotModel then
		-- Kirim seluruh model panggung ke fungsi
		createDevRig(devInfo, devSpotModel)
	else
		warn("Spot Model tidak ditemukan: " .. spotName)
	end
end
