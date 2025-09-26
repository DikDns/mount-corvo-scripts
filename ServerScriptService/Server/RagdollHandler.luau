require(game:GetService('ReplicatedStorage').Packages.RagdollService)

local players = game:GetService('Players')

players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild('Humanoid', 10)

		if not humanoid or not humanoid.Parent then
			warn("Humanoid not found for ragdoll setup:", player.Name)
			return
		end

		-- Wait additional frame for character stability
		game:GetService("RunService").Heartbeat:Wait()

		-- Final validation
		if humanoid.Parent and character.Parent then
			humanoid:AddTag('Ragdollable')
			humanoid:AddTag('RagdollOnHumanoidFall')
			humanoid:AddTag('RagdollOnHumanoidDied')
		end
	end)
end)

-- Safer ragdoll toggle
game:GetService('ReplicatedStorage').Remotes.RagdollState.OnServerEvent:Connect(function(player)
	if not player.Character or not player.Character:FindFirstChild('Humanoid') then
		return
	end

	local humanoid = player.Character.Humanoid
	if humanoid:HasTag('Ragdoll') then
		humanoid:RemoveTag('Ragdoll')
	else
		humanoid:AddTag('Ragdoll')
	end
end)
