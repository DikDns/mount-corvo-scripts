--!nonstrict
--[[
	PurchaseHandler (Using PromptGamePassPurchaseFinished)
]]

-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load services and data
local TitleService = require(ServerScriptService.Services.TitleService)
local GiveToolService = require(ServerScriptService.Services.GiveToolService)
local GamepassData = require(ReplicatedStorage.Modules.GamepassData)
local VipTrailService = require(ServerScriptService.Services.VipTrailService)

-- References to events
local purchaseSuccessEvent = ReplicatedStorage.Remotes:WaitForChild("PurchaseSuccessEvent")
local showNotificationEvent = ReplicatedStorage.Remotes:WaitForChild("ShowNotification")

-- Product mapping table
local PRODUCT_FUNCTIONS = {
	[1336827563] = function(player) TitleService.GrantTitle(player, "T015") VipTrailService.applyTrail(player) end,
	[1334560168] = function(player) GiveToolService.GiveTool(player, "Lasso") end,
	[1332730049] = function(player) GiveToolService.GiveTool(player, "Vintage Lantern") end,
	[1422645215] = function(player)
		GiveToolService.GiveTool(player, "Selfie Cam")
		GiveToolService.GiveTool(player, "Selfie Stick")
	end,
	[1435963207] = function(player)
		game:GetService("Workspace"):FindFirstChild(player.Name):SetAttribute("SprintEnabled", true)
	end,
}

-- Function to be connected to the event
local function onPromptPurchaseFinished(player, purchasedPassID, purchaseSuccess)
	if not purchaseSuccess then
		return
	end

	local rewardFunction = PRODUCT_FUNCTIONS[purchasedPassID]
	if not rewardFunction then
		warn("Reward function not found for ID:", purchasedPassID)
		return
	end

	local success, err = pcall(rewardFunction, player)
	if success then
		print("Reward granted (via PromptGamePassPurchaseFinished) for:", player.Name)

		local productInfo
		for _, gp in ipairs(GamepassData) do
			if gp.Id == purchasedPassID then
				productInfo = gp
				break
			end
		end

		-- Fallback jika info tidak ditemukan
		if not productInfo then
			productInfo = { Name = "Purchased Item", Icon = "" }
		end

		purchaseSuccessEvent:FireClient(player, purchasedPassID)
		showNotificationEvent:FireClient(player, {
			title = "Purchase Successful!",
			subtitle = "You have acquired: " .. productInfo.Name,
			icon = productInfo.Icon
		})
	else
		warn("Failed to grant reward:", err)
	end
end

-- Connect to the event
MarketplaceService.PromptGamePassPurchaseFinished:Connect(onPromptPurchaseFinished)

print("PurchaseHandler is running.")
