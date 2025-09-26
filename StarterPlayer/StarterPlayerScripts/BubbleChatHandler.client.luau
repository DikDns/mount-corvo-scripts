--[[
	BubbleChatHandler (LocalScript)

	Skrip ini menangani kustomisasi tampilan bubble chat
	untuk pemain berdasarkan atribut tertentu, seperti "IsVIP".
]]

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

-- Event ini berjalan setiap kali bubble chat baru dibuat di layar pemain
TextChatService.OnBubbleAdded = function(message: TextChatMessage, adornee: Instance)
	-- Pastikan bubble chat ini berasal dari seorang pemain
	if message.TextSource then
		-- Buat objek properti baru untuk menampung kustomisasi
		local bubbleProperties = Instance.new("BubbleChatMessageProperties")

		-- Dapatkan objek Player dari pengirim pesan
		local player = Players:GetPlayerByUserId(message.TextSource.UserId)

		-- Jika pemain tidak ditemukan, hentikan
		if not player then return end

		-- Cek apakah pemain memiliki atribut "IsVIP"
		if player:GetAttribute("IsVIP") == true then
			bubbleProperties.TextColor3 = Color3.fromHex("#F5CD30")
			bubbleProperties.BackgroundColor3 = Color3.fromHex("#4A3F35")
			bubbleProperties.FontFace = Font.fromEnum(Enum.Font.Merriweather)

			return bubbleProperties
		end
	end

	-- Jika bukan VIP, jangan lakukan kustomisasi apa pun
	return nil
end

print("✅ BubbleChatHandler (Local) is running.")
