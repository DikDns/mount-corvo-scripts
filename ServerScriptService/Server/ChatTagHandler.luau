--[[
	ChatTagHandler

	Tugas skrip ini adalah untuk mengecek kepemilikan gamepass VIP
	saat pemain bergabung, lalu mengatur sebuah Attribute pada player object.
	Metode ini direkomendasikan untuk TextChatService.
]]

-- Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local GamepassData = require(ReplicatedStorage.Modules.GamepassData)

-- Helper function to find the VIP Gamepass ID from the module
local function getVipGamepassId()
	for _, data in ipairs(GamepassData) do
		if data.Name == "⭐️ VIP" then
			return data.Id
		end
	end
	return nil -- Return nil if not found to prevent errors
end

local VIP_GAMEPASS_ID = getVipGamepassId()

-- Cek jika VIP_GAMEPASS_ID tidak ditemukan
if not VIP_GAMEPASS_ID then
	warn("[ChatTagHandler] ID untuk gamepass '⭐️ VIP' tidak ditemukan. Fitur chat tag tidak akan aktif.")
	return
end

-- Fungsi yang berjalan saat pemain baru masuk ke game
local function onPlayerAdded(player)
	-- Lakukan pengecekan kepemilikan gamepass dalam pcall
	local success, ownsPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, VIP_GAMEPASS_ID)
	end)

	-- Atur attribute berdasarkan hasil pengecekan.
	-- Jika pengecekan gagal, anggap saja tidak punya.
	if success and ownsPass then
		player:SetAttribute("IsVIP", true)
		print("[ChatTagHandler] Atribut IsVIP = true, ditetapkan untuk:", player.Name)
	else
		player:SetAttribute("IsVIP", false)
	end
end

-- Hubungkan fungsi ke event PlayerAdded
Players.PlayerAdded:Connect(onPlayerAdded)
