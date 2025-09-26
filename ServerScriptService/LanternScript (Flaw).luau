local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local toolToGive = ReplicatedStorage:WaitForChild("Lantern") -- Ganti "NamaToolKamu"

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local clonedTool = toolToGive:Clone()
		clonedTool.Parent = player.Backpack
	end)
end)
