-- ===================================================================
-- PhotoStreamer.module.luau
-- Mengelola streaming foto antara server dan client secara efisien.
-- ===================================================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Config = require(script.Parent.EventConfig)

local PhotoStreamer = {}
local streamedPhotos = {} -- State internal

function PhotoStreamer:Init()
	Players.PlayerAdded:Connect(function(player)
		streamedPhotos[player] = {}
	end)

	Players.PlayerRemoving:Connect(function(player)
		streamedPhotos[player] = nil
	end)

	RunService.Heartbeat:Connect(function()
		self:_updateStreaming()
	end)
end

function PhotoStreamer:_updateStreaming()
	for player, clientStreamed in pairs(streamedPhotos) do
		local character = player.Character
		if not character or not character.PrimaryPart then continue end

		local playerPos = character.PrimaryPart.Position
		local playerGui = player:FindFirstChildOfClass("PlayerGui")
		if not playerGui then continue end

		local clientContainer = playerGui:FindFirstChild("HeeseungPhotoContainer")
		if not clientContainer then
			clientContainer = Instance.new("Folder", playerGui)
			clientContainer.Name = "HeeseungPhotoContainer"
		end

		local serverStorage = Config.PHOTO_STORAGE_CONTAINER:FindFirstChild(player.Name .. "_Photos")

		-- Stream IN
		if serverStorage then
			for _, photoModel in ipairs(serverStorage:GetChildren()) do
				if photoModel:IsA("Model") and not clientStreamed[photoModel] then
					if (photoModel:GetPivot().Position - playerPos).Magnitude <= Config.STREAMING_RADIUS then
						photoModel.Parent = clientContainer
						clientStreamed[photoModel] = true
					end
				end
			end
		end

		-- Stream OUT
		for photoModel, isStreamed in pairs(clientStreamed) do
			if isStreamed then
				if photoModel.Parent == nil then
					clientStreamed[photoModel] = nil
				elseif (photoModel:GetPivot().Position - playerPos).Magnitude > Config.STREAMING_RADIUS + 10 then
					if serverStorage and serverStorage.Parent then
						photoModel.Parent = serverStorage
						clientStreamed[photoModel] = nil
					else
						photoModel:Destroy()
						clientStreamed[photoModel] = nil
					end
				end
			end
		end
	end
end

function PhotoStreamer:CleanupStreamedPhotosForPlayer(player)
	if Config.DEBUG_MODE then print(`[Streamer] Membersihkan semua foto yang di-stream untuk {player.Name}`) end

	if streamedPhotos[player] then
		for photoModel, _ in pairs(streamedPhotos[player]) do
			if photoModel and photoModel.Parent then
				photoModel:Destroy()
			end
		end
		streamedPhotos[player] = {}
	end

	local localRenderFolder = workspace:FindFirstChild("LocalEventPhotos_" .. player.Name)
	if localRenderFolder then
		localRenderFolder:Destroy()
	end
end


return PhotoStreamer
