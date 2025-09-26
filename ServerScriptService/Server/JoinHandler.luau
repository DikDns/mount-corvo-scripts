--!nonstrict
--[[
	JoinHandler
]]

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local BanService = require(ServerScriptService.Services.BanService)

Players.PlayerAdded:Connect(function(player)
	local isBanned, banInfo = BanService.IsBanned(player)

	if isBanned then
		local reason = banInfo.Reason
		local kickMessage

		if banInfo.UnbanTime == -1 then
			kickMessage = "You are permanently banned.\nReason: " .. reason
		else
			local timeLeft = banInfo.UnbanTime - os.time()
			local hours = math.floor(timeLeft / 3600)
			local minutes = math.floor((timeLeft % 3600) / 60)
			kickMessage = ("You are still banned for %d hours and %d minutes.\nReason: %s"):format(hours, minutes, reason)
		end

		player:Kick(kickMessage)
	end
end)
