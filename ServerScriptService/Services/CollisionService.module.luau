--!nonstrict
--[[
	CollisionService
	Modul terpusat untuk mengelola Collision Groups karakter.
]]

-- [DIHAPUS] PhysicsService tidak lagi diperlukan untuk operasi ini
-- local PhysicsService = game:GetService("PhysicsService")

local CollisionService = {}

function CollisionService.SetCharacterGroup(character, groupName)
	if not character or not character:FindFirstChild("Humanoid") then
		warn("CollisionService: Karakter tidak valid atau tidak memiliki Humanoid.")
		return
	end

	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = groupName
		end
	end

	print(("Collision group untuk %s diatur ke '%s'"):format(character.Name, groupName))
end

return CollisionService
