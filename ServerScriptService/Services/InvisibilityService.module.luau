--!nonstrict
--[[
	InvisibilityService (with Debug)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService") -- [+] Untuk print tabel
local stateChangedEvent = ReplicatedStorage.Remotes:WaitForChild("InvisibilityStateChanged")

local InvisibilityService = {}
local invisiblePlayers = {}

local function broadcastUpdate()
	-- [DEBUG] Tampilkan daftar yang akan dikirim ke client
	print("[InvisibilityService DEBUG] Broadcasting update to all clients. List:", HttpService:JSONEncode(invisiblePlayers))
	stateChangedEvent:FireAllClients(invisiblePlayers)
end

function InvisibilityService.ToggleInvisibility(player)
	local userId = player.UserId
	local isInvisible = invisiblePlayers[userId]

	-- [DEBUG] Tampilkan status sebelum diubah
	print("[InvisibilityService DEBUG] Toggling state for", player.Name, "| Currently invisible:", isInvisible and true)

	if isInvisible then
		invisiblePlayers[userId] = nil
	else
		invisiblePlayers[userId] = true
	end

	-- [DEBUG] Tampilkan status setelah diubah
	print("[InvisibilityService DEBUG] New state for", player.Name, "| Now invisible:", invisiblePlayers[userId] and true)

	broadcastUpdate()
	return not isInvisible
end

Players.PlayerRemoving:Connect(function(player)
	if invisiblePlayers[player.UserId] then
		invisiblePlayers[player.UserId] = nil
		broadcastUpdate()
	end
end)

return InvisibilityService
