local ReplicatedStorage = game:GetService("ReplicatedStorage")
local toolsFolder = ReplicatedStorage:WaitForChild("Tools")

local GiveToolService = {}

function GiveToolService.GiveTool(player: Player, toolName: string)
	local starterGear = player:WaitForChild("StarterGear")

	if starterGear:FindFirstChild(toolName) then
		return
	end

	local toolToGive = toolsFolder:FindFirstChild(toolName)
	if not toolToGive then
		warn("Tidak dapat menemukan tool bernama '" .. toolName .. "' di ReplicatedStorage > Tools")
		return
	end

	print("Memberikan tool '"..toolName.."' kepada " .. player.Name)

	local toolForGear = toolToGive:Clone()
	toolForGear.Parent = starterGear

	if player.Character then
		local toolForBackpack = toolToGive:Clone()
		toolForBackpack.Parent = player.Backpack
	end
end

return GiveToolService
