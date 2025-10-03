local HeeseungPhotoService = require(script.Parent.HeeseungPhotoService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:FindFirstChild("HeeseungEventRemotes") or Instance.new("Folder")
remotesFolder.Name = "HeeseungEventRemotes"
remotesFolder.Parent = ReplicatedStorage

if not remotesFolder:FindFirstChild("GetQuestStatus") then Instance.new("RemoteFunction", remotesFolder).Name = "GetQuestStatus" end
if not remotesFolder:FindFirstChild("RequestStartQuest") then Instance.new("RemoteEvent", remotesFolder).Name = "RequestStartQuest" end
if not remotesFolder:FindFirstChild("AdminRequestReset") then Instance.new("RemoteEvent", remotesFolder).Name = "AdminRequestReset" end
if not remotesFolder:FindFirstChild("SyncPlayerData") then
	Instance.new("RemoteEvent", remotesFolder).Name = "SyncPlayerData"
end

HeeseungPhotoService:Init()
