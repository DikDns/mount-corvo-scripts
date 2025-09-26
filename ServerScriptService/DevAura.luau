local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local permissionData = require(ReplicatedStorage.Modules:WaitForChild("CmdrPermissionData"))

-- List of body parts you want to attach aura to
local bodyParts = {
	"Head",
	"Torso", -- For R6
	"LeftArm", -- R6
	"RightArm", -- R6
	"LeftLeg", -- R6
	"RightLeg", -- R6
	"UpperTorso",
	"LowerTorso",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
	"LeftHand",
	"RightHand",
}

Players.PlayerAdded:Connect(function(player)
	local rank = player:GetRankInGroup(permissionData.GroupId)

	if rank >= permissionData.Ranks.Admin then
		player.CharacterAdded:Connect(function(character)
			local auraTemplate = ReplicatedStorage:FindFirstChild("Aura")
			if not auraTemplate then
				warn("Aura not found in ReplicatedStorage!")
				return
			end

			for _, partName in ipairs(bodyParts) do
				local part = character:FindFirstChild(partName)
				if part and part:IsA("BasePart") then
					-- Create an attachment for better control
					local attachment = Instance.new("Attachment")
					attachment.Name = "AuraAttachment"
					attachment.Parent = part

					-- Clone the aura and parent to the attachment
					local aura = auraTemplate:Clone()
					aura.Parent = attachment
					aura.Enabled = true
				end
			end
		end)
	end
end)
