local player = game.Players.LocalPlayer
local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")

	local defaultJumpPower = 50

	local function updateJump()
		if humanoid:GetState() == Enum.HumanoidStateType.Seated
			or humanoid:GetState() == Enum.HumanoidStateType.Swimming then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			humanoid.UseJumpPower = true
			humanoid.JumpPower = defaultJumpPower
		else
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			humanoid.UseJumpPower = false
			humanoid.JumpPower = 0
		end
	end

	humanoid.StateChanged:Connect(function(_, newState)
		updateJump()
	end)

	updateJump()
end

player.CharacterAdded:Connect(setupCharacter)
if player.Character then
	setupCharacter(player.Character)
end
