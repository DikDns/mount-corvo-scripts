--!nonstrict
--[[
	TipBroadcaster
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local SendChatMessage = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SendChatMessage")
local player = Players.LocalPlayer
local generalChannel: TextChannel = TextChatService:WaitForChild("TextChannels").RBXGeneral

local PREFIX = "[SERVER]: "

SendChatMessage.OnClientEvent:Connect(function (msg)
	if generalChannel then
		generalChannel:DisplaySystemMessage(PREFIX .. msg)
	end
end)
