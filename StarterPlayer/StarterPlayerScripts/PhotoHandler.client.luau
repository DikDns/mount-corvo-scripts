local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")


local sourceContainer = playerGui:WaitForChild("HeeseungPhotoContainer")
local renderContainer = Instance.new("Folder")
renderContainer.Name = "LocalEventPhotos_" .. localPlayer.Name
renderContainer.Parent = Workspace

local function renderAndSetupPhoto(photoModel)
	photoModel.Parent = renderContainer

	local prompt = photoModel.Part:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then return end

	prompt.Enabled = (photoModel:GetAttribute("OwnerUserId") == localPlayer.UserId)
end

sourceContainer.ChildAdded:Connect(renderAndSetupPhoto)

for _, child in ipairs(sourceContainer:GetChildren()) do
	renderAndSetupPhoto(child)
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	if player == localPlayer and renderContainer and renderContainer.Parent then
		renderContainer:Destroy()
	end
end)
