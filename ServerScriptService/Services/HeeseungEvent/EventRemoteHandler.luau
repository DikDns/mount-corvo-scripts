-- ===================================================================
-- EventRemoteHandler.server.luau (Diperbaiki)
-- Menjembatani komunikasi antara client (LilyPrompt) dan service
-- di server (HeeseungPhotoService).
-- ===================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ShowNotification = ReplicatedStorage.Remotes:WaitForChild("ShowNotification")

print("[EventRemoteHandler] Pertama kali dimuat. Menghubungkan remotes...")

-- Memuat service utama dan konfigurasi
local HeeseungPhotoService = require(ServerScriptService.Services.HeeseungEvent.HeeseungPhotoService)
local Config = require(ServerScriptService.Services.HeeseungEvent.EventConfig)

local Remotes = ReplicatedStorage:WaitForChild("HeeseungEventRemotes")

local GetQuestStatus = Remotes:WaitForChild("GetQuestStatus")
local RequestStartQuest = Remotes:WaitForChild("RequestStartQuest")
local AdminRequestReset = Remotes:WaitForChild("AdminRequestReset")

-- Handle permintaan status dari client
GetQuestStatus.OnServerInvoke = function(player)
	local statusData = HeeseungPhotoService:GetPlayerQuestStatus(player)
	return statusData
end

-- Handle permintaan untuk memulai quest
RequestStartQuest.OnServerEvent:Connect(function(player)
	local statusData = HeeseungPhotoService:GetPlayerQuestStatus(player)

	if statusData.isInGroup and statusData.questStatus == Config.QUEST_STATUS.NOT_STARTED then
		print(`Player {player.Name} memulai Heeseung's Memory Trail.`)
		HeeseungPhotoService:StartHunt(player)
		ShowNotification:FireClient(player, {
			icon = "rbxassetid://99071221774597",
			title = "Quest Started!",
			subtitle = "Heeseung's Memory Trail has begun!"
		})
	else
		warn(`Player {player.Name} mengirim permintaan tidak valid untuk memulai quest.`)
	end
end)
