-- ===================================================================
-- PhotoInstanceManager.module.luau
-- Mengelola pembuatan dan pembersihan instance Model foto di ServerStorage.
-- ===================================================================

local Config = require(script.Parent.EventConfig)
local EventTime = require(game:GetService("ReplicatedStorage").Modules.HeeseungEvent.EventTime)

local PhotoInstanceManager = {}

function PhotoInstanceManager:CreatePhotosForPlayer(player, pendingPhotos, eventPeriod)
	self:CleanupPhotosForPlayer(player)

	local playerPhotoFolder = Instance.new("Folder", Config.PHOTO_STORAGE_CONTAINER)
	playerPhotoFolder.Name = player.Name .. "_Photos"

	local photosToShow = 0
	if eventPeriod == "PHASE_1" then photosToShow = EventTime.PHOTOS_IN_PHASE_1
	elseif eventPeriod == "PHASE_2" then photosToShow = EventTime.PHOTOS_IN_PHASE_2
	else return end

	local photosCreated = 0
	for _, photoData in ipairs(pendingPhotos) do
		if photoData.id <= photosToShow then
			local photoModel = Config.PHOTO_TEMPLATE_PATH:Clone()
			local locationVector = Vector3.new(photoData.location.x, photoData.location.y, photoData.location.z)
			photoModel:PivotTo(CFrame.new(locationVector))
			photoModel:SetAttribute("OwnerUserId", player.UserId)
			photoModel:SetAttribute("PhotoId", photoData.id)

			local decal = photoModel.Part:FindFirstChild("Photo")
			if decal and decal:IsA("Decal") then
				decal.Texture = photoData.decalId
			end

			photoModel.Parent = playerPhotoFolder
			photosCreated = photosCreated + 1
		end
	end

	if Config.DEBUG_MODE then print(`[InstanceManager] Selesai. Total foto dibuat untuk {player.Name}: {photosCreated}`) end
end

function PhotoInstanceManager:CleanupPhotosForPlayer(player)
	local playerFolder = Config.PHOTO_STORAGE_CONTAINER:FindFirstChild(player.Name .. "_Photos")
	if playerFolder then
		playerFolder:Destroy()
	end
end

return PhotoInstanceManager
