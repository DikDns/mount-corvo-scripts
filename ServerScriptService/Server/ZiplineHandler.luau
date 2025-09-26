--[[
	MULTI-ZIPLINE HANDLER
	Deskripsi: Script ini secara otomatis mendeteksi dan mengelola semua
	zipline yang ada di dalam folder Workspace.Ziplines.
	Setiap zipline beroperasi secara independen.

	Struktur Model Zipline yang Diharapkan:
	- ZiplineModel (Model)
	  - ZiplineStructure (Model)
	    - MainSeat (Model)
	      - ZiplineSeat (Model)
	        - Seat (Seat)
	        - Center (BasePart) -- Harus dijadikan PrimaryPart untuk MainSeat
	    - ProximityPrompt (Model)
	      - ProxPromptPart (BasePart)
	        - ProximityPrompt (ProximityPrompt)
	  - ZiplineCode (Folder)
	    - DestinationNavigation (Folder)
	      - 1 (BasePart)
	      - 2 (BasePart)
	      - ... (dan seterusnya)
]]

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local ZiplinesFolder = Workspace:WaitForChild("Ziplines")

-- Constants
local BASE_SPEED = 16
local GRAVITY_ACCELERATION = 9.8
local MIN_SPEED = 10
local MAX_SPEED = 50
local RESET_DELAY = 1

-- "Class" Zipline
local Zipline = {}
Zipline.__index = Zipline

-- Constructor: Fungsi untuk membuat dan menginisialisasi objek zipline baru
function Zipline.new(ziplineModel)
	local self = setmetatable({}, Zipline)

	-- Validasi struktur model
	if not ziplineModel:IsA("Model") then return nil end

	-- Cache semua part penting dari model
	self.model = ziplineModel
	self.destinationsFolder = ziplineModel:FindFirstChild("ZiplineCode", true) and ziplineModel:FindFirstChild("DestinationNavigation", true)
	self.seatAssembly = ziplineModel:FindFirstChild("ZiplineSeat", true)
	self.seatPart = ziplineModel:FindFirstChild("Seat", true)
	self.promptPart = ziplineModel:FindFirstChild("ProxPromptPart", true)
	self.prompt = self.promptPart and self.promptPart:FindFirstChildOfClass("ProximityPrompt")

	-- Jika ada part yang tidak ditemukan, batalkan inisialisasi
	if not (self.destinationsFolder and self.seatAssembly and self.seatPart and self.prompt) then
		warn("Struktur model tidak lengkap untuk Zipline:", ziplineModel.Name)
		return nil
	end

	-- State variables (setiap zipline punya state-nya sendiri)
	self.currentPoint = 1
	self.isActive = false
	self.weldingComplete = false
	self.currentTween = nil
	self.destinationCache = {}

	-- Inisialisasi awal
	self.seatAssembly.PrimaryPart = self.seatAssembly:FindFirstChild("Center")
	self:cacheDestinations()

	-- Pindahkan zipline ke titik awal jika ada
	if self.destinationCache[1] then
		self.seatAssembly.PrimaryPart.CFrame = self.destinationCache[1].CFrame
	end

	-- Hubungkan event
	self.prompt.Triggered:Connect(function(player)
		self:start()
	end)

	print("🚡 Zipline '" .. ziplineModel.Name .. "' berhasil diinisialisasi.")
	return self
end

-- Method untuk meng-cache titik destinasi
function Zipline:cacheDestinations()
	self.destinationCache = {}
	for _, dest in ipairs(self.destinationsFolder:GetChildren()) do
		local pointNumber = tonumber(dest.Name)
		if pointNumber then
			self.destinationCache[pointNumber] = dest
		end
	end
end

-- Method untuk menyatukan (weld) semua part di seat assembly
function Zipline:weldSeat()
	if self.weldingComplete then return end

	local primaryPart = self.seatAssembly.PrimaryPart
	for _, child in ipairs(self.seatAssembly:GetChildren()) do
		if child ~= primaryPart and child:IsA("BasePart") then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = child
			weld.Part1 = primaryPart
			weld.Parent = primaryPart
			child.Anchored = false
		end
	end
	self.weldingComplete = true
end

-- Method untuk mengeluarkan player dari kursi
function Zipline:ejectPlayer()
	local seatWeld = self.seatPart:FindFirstChild("SeatWeld")
	if not seatWeld then return end

	local character = seatWeld.Part1 and seatWeld.Part1.Parent
	if character and character:FindFirstChild("Humanoid") then
		seatWeld:Destroy()
	end
end

-- Method untuk menghitung kecepatan berdasarkan gravitasi
function Zipline:calculateSpeed(startPos, endPos)
	local heightDifference = startPos.Y - endPos.Y
	local gravityBonus = math.max(0, heightDifference * (GRAVITY_ACCELERATION / 10))
	local finalSpeed = BASE_SPEED + gravityBonus
	return math.clamp(finalSpeed, MIN_SPEED, MAX_SPEED)
end

-- Method untuk menghitung waktu perjalanan
function Zipline:getTime(startPos, endPos)
	local distance = (endPos - startPos).Magnitude
	local speed = self:calculateSpeed(startPos, endPos)
	return distance / speed, speed
end

-- Method utama untuk pergerakan zipline
function Zipline:moveToNextPoint()
	if not self.destinationCache[self.currentPoint + 1] then
		self:ejectPlayer()
		task.wait(RESET_DELAY)

		self.currentPoint = 1
		if self.destinationCache[1] then
			self.seatAssembly.PrimaryPart.CFrame = self.destinationCache[1].CFrame
		end

		task.wait(RESET_DELAY / 2)
		self.isActive = false
		self.prompt.Enabled = true
		return
	end

	self.currentPoint += 1
	local nextPoint = self.destinationCache[self.currentPoint]
	local startPos = self.seatAssembly.PrimaryPart.Position
	local endPos = nextPoint.Position

	local time, actualSpeed = self:getTime(startPos, endPos)

	local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	if self.currentTween then self.currentTween:Cancel() end

	self.currentTween = TweenService:Create(self.seatAssembly.PrimaryPart, tweenInfo, { CFrame = nextPoint.CFrame })

	print(string.format("Zipline '%s': Moving to point %d | Speed: %.1f | Time: %.1fs",
		self.model.Name, self.currentPoint, actualSpeed, time))

	self.currentTween:Play()
	self.currentTween.Completed:Wait()

	-- Panggil diri sendiri untuk lanjut ke titik berikutnya (rekursif)
	self:moveToNextPoint()
end

-- Method untuk memulai zipline
function Zipline:start()
	if self.isActive then return end
	self.isActive = true
	self.prompt.Enabled = false

	self:weldSeat()
	self:cacheDestinations() -- Refresh cache untuk jaga-jaga

	self:moveToNextPoint()
end

-- ====== MAIN SCRIPT EXECUTION ======

-- Fungsi untuk menginisialisasi semua zipline yang ada saat script berjalan
local function initializeAllZiplines()
	for _, ziplineModel in ipairs(ZiplinesFolder:GetChildren()) do
		Zipline.new(ziplineModel)
	end
end

-- Inisialisasi zipline yang baru ditambahkan saat runtime
ZiplinesFolder.ChildAdded:Connect(function(ziplineModel)
	task.wait(1) -- Beri waktu sedikit agar semua part di dalam model ter-load
	Zipline.new(ziplineModel)
end)

-- Jalankan inisialisasi awal
initializeAllZiplines()

print("✅ Multi-Zipline Handler loaded and watching for ziplines.")
