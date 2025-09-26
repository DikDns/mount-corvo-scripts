local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local reportPlatformEvent = ReplicatedStorage.Remotes:WaitForChild("ReportPlatform")

local isMobile = UserInputService.TouchEnabled or UserInputService.GamepadEnabled
reportPlatformEvent:FireServer(isMobile)
