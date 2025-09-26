local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer
local Character = Player.Character

local RegenDelay = 1
local RegenRate = 50
local MaxStamina = 250


Character:SetAttribute("Stamina", MaxStamina)
Character:SetAttribute("MaxStamina", MaxStamina)

local TimeSinceLastDrain = 0
local IsRegenning = false

RunService.Heartbeat:Connect(function(deltaTime: number)
	local Stamina = Character:GetAttribute("Stamina")
	local AntiRegen = Character:GetAttribute("AntiRegen")

	if AntiRegen then
		TimeSinceLastDrain = 0
		IsRegenning = false
	else
		TimeSinceLastDrain += deltaTime
		if TimeSinceLastDrain >= RegenDelay then
			IsRegenning = true
		end
	end

	if IsRegenning and Stamina < MaxStamina then
		local RegenAmount = RegenRate * deltaTime
		Stamina = math.min(Stamina + RegenAmount, MaxStamina)
		Character:SetAttribute("Stamina", Stamina)
	end
end)
