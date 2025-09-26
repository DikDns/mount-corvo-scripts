--!nonstrict
--[[
	TitleRemoteHandler
	Mendengarkan event dari client yang berhubungan dengan sistem Title.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Memuat service yang akan melakukan pekerjaan sebenarnya
local TitleService = require(ServerScriptService.Services.TitleService)

-- Referensi ke RemoteEvent yang akan kita dengarkan
local EquipTitleEvent = ReplicatedStorage.Remotes:WaitForChild("EquipTitleEvent")

-- Fungsi yang akan berjalan setiap kali seorang pemain memanggil FireServer
local function onEquipTitleRequested(player, titleId)
	-- Validasi dasar untuk keamanan: pastikan data yang dikirim adalah string
	if type(titleId) ~= "string" then
		-- Menendang pemain jika mereka mengirim data yang tidak valid adalah opsi keamanan
		player:Kick("Invalid data type sent to server.")
		return
	end

	-- Panggil fungsi yang aman di TitleService untuk memproses permintaan.
	-- TitleService akan melakukan verifikasi akhir (apakah pemain benar-benar memiliki title tsb).
	TitleService.EquipTitle(player, titleId)
end

-- Hubungkan fungsi di atas ke event dari client
EquipTitleEvent.OnServerEvent:Connect(onEquipTitleRequested)

print("✅ TitleRemoteHandler is running and listening for EquipTitleEvent.")
