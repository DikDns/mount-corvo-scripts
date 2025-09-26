--[[
	ChatTagLocal
]]

-- Services
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

-- Konfigurasi Tag
local VIP_TAG_TEXT = "[VIP] ⭐"
local VIP_TAG_COLOR = Color3.fromRGB(255, 200, 0) -- Warna emas
local HEX_COLOR = string.format("#%02x%02x%02x", VIP_TAG_COLOR.R * 255, VIP_TAG_COLOR.G * 255, VIP_TAG_COLOR.B * 255)

-- Fungsi yang berjalan setiap kali ada pesan masuk
TextChatService.OnIncomingMessage = function(message: TextChatMessage)

	-- Pastikan pesan datang dari seorang pemain
	local textSource = message.TextSource
	if not textSource then return end

	local player = Players:GetPlayerByUserId(textSource.UserId)
	if not player then return end

	-- Cek attribute "IsVIP" pada pemain
	if player:GetAttribute("IsVIP") == true then
		-- Jika true, buat properti baru untuk memodifikasi pesan
		local properties = Instance.new("TextChatMessageProperties")

		-- Buat tag dengan format RichText untuk pewarnaan
		local prefixText = string.format('<font color="%s">%s</font> %s', HEX_COLOR, VIP_TAG_TEXT, message.PrefixText)

		properties.PrefixText = prefixText

		-- Kembalikan properti yang sudah diubah
		return properties
	end

	-- Jika pemain bukan VIP, jangan lakukan apa-apa
	return nil
end
