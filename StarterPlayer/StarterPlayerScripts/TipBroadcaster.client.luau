--!nonstrict
--[[
	TipBroadcaster
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local TipBroadcast = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TipBroadcast")
local player = Players.LocalPlayer
local generalChannel: TextChannel = TextChatService:WaitForChild("TextChannels").RBXGeneral

local PREFIX = "💡 [TIP]: "

TipBroadcast.OnClientEvent:Connect(function (tip)
	if generalChannel then
		generalChannel:DisplaySystemMessage(PREFIX .. tip)
	end
end)
