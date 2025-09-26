--!nonstrict
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local RequestSync = ReplicatedStorage.Remotes:WaitForChild("RequestSync")

success = false

while not success do
	success = pcall(function()
		StarterGui:SetCore("AvatarContextMenuEnabled", true)
	end)
	task.wait(1/30)
end

-- Hapus opsi default yang tidak diinginkan
StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Emote)

local contextMenuEvent = Instance.new("BindableEvent")

local function onCarryActionTriggered(targetPlayer)
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local avatarMenuGui = playerGui:FindFirstChild("AvatarMenuScreenGUI")

	local openMenuEvent = ReplicatedStorage.Remotes:FindFirstChild("OpenCarryMenu")
	if openMenuEvent then
		openMenuEvent:Fire(targetPlayer)
	else
		warn("RemoteEvent 'OpenAvatarMenuFromContext' tidak ditemukan.")
	end
end

contextMenuEvent.Event:Connect(onCarryActionTriggered)

-- Buat opsi menu baru
local options = {"Carry", contextMenuEvent} -- Mengganti "Carry" dengan "Interact" agar lebih umum
StarterGui:SetCore("AddAvatarContextMenuOption", options)

local syncBindableEvent = Instance.new("BindableEvent")
syncBindableEvent.Event:Connect(function(targetPlayer)
	RequestSync:FireServer(targetPlayer)
end)
StarterGui:SetCore("AddAvatarContextMenuOption", {"Sync Dance", syncBindableEvent})

StarterGui:SetCore("AvatarContextMenuTheme", {
	BackgroundImage = "",
	BackgroundTransparency = 0.5,
	BackgroundColor = Color3.fromRGB(220, 212, 174),
	NameTagColor = Color3.fromRGB(84, 33, 13),
	NameUnderlineColor = Color3.fromRGB(157, 104, 78),
	ButtonFrameColor = Color3.fromRGB(187, 152, 97),
	ButtonFrameTransparency = 0.25,
	ButtonUnderlineColor = Color3.fromRGB(187, 152, 97),
	Font = Enum.Font.Merriweather
})
