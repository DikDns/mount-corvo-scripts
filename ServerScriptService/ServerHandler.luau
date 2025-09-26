local webhook = "https://webhook.lewisakura.moe/api/webhooks/1416555615165218856/F9f4pDtgATWSYS011SJft5_sKcCxE0I_Gk0lBtvr6M2N8_2DyJW7w9k8mGNzE6Tl4I_m"
local filteringFunction = game.ReplicatedStorage.FilteringFunction
local HTTP = game:GetService("HttpService")

-- Cooldown configuration
local cooldownTime = 600 -- seconds
local playerCooldowns = {} -- stores last submission time per player

function filteringFunction.OnServerInvoke(player, msg)
	local now = tick()
	local lastSubmission = playerCooldowns[player.UserId]

	-- Check if the player is still in cooldown
	if lastSubmission and now - lastSubmission < cooldownTime then
		local timeLeft = math.ceil(cooldownTime - (now - lastSubmission))
		return "Please wait " .. timeLeft .. " seconds before submitting again."
	end

	-- Update the last submission time
	playerCooldowns[player.UserId] = now

	-- Send the feedback
	local payload = HTTP:JSONEncode({
		content = msg,
		username = "Feedback Bot - New Feedback by " .. player.Name
	})

	HTTP:PostAsync(webhook, payload)

	return "Feedback received!"
end
