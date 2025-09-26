--!nonstrict
--[[
	Script ini akan menonaktifkan UI nama dan health bar default
	untuk semua karakter pemain di dalam game.
]]

local Players = game:GetService("Players")

-- Fungsi ini akan dijalankan untuk setiap karakter
local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	if humanoid then
		-- Menonaktifkan UI default
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
end

-- Fungsi ini akan dijalankan untuk setiap pemain
local function onPlayerAdded(player)
	-- Hubungkan ke event saat karakter muncul (atau respawn)
	player.CharacterAdded:Connect(setupCharacter)

	-- Jika karakter sudah ada saat pemain bergabung, langsung jalankan
	if player.Character then
		setupCharacter(player.Character)
	end
end

-- Terapkan fungsi di atas untuk semua pemain yang sudah ada
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Hubungkan fungsi di atas untuk semua pemain yang baru bergabung
Players.PlayerAdded:Connect(onPlayerAdded)

print("✅ HideDefaultTags script is running.")
