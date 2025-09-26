--!nonstrict
--[[
    CharacterSetupHandler (IMPROVED)
    Properly waits for full character loading before setup.
]]

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local CollisionService = require(ServerScriptService.Services.CollisionService)

local function onCharacterAdded(character)
	-- Wait for essential components
	local humanoid = character:WaitForChild("Humanoid", 10)
	local rootPart = character:WaitForChild("HumanoidRootPart", 10)

	if not humanoid or not rootPart then
		warn("Character components failed to load for:", character.Name)
		return
	end

	-- Additional safety wait for character to be fully loaded
	if not character.Parent then return end

	-- Wait a frame to ensure all character parts are loaded
	game:GetService("RunService").Heartbeat:Wait()

	-- Final validation before applying collision
	if character.Parent and humanoid.Parent and rootPart.Parent then
		CollisionService.SetCharacterGroup(character, "Player")
	end
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		task.spawn(onCharacterAdded, character)
	end)

	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end
end

-- Apply to existing and new players
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)

print("✅ CharacterSetupHandler is running.")
