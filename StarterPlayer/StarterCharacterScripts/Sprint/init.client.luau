--!nonstrict
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService") -- [+] Tambahin TweenService

-- ===================================================================
-- SETUP AWAL
-- ===================================================================
local Char = script.Parent
local Player = Players:GetPlayerFromCharacter(Char)
if not Player then return end

local Humanoid: Humanoid = Char:WaitForChild("Humanoid")
local playerGui = Player:WaitForChild("PlayerGui")
local Camera = game:GetService("Workspace").CurrentCamera

local function InitializeSprint()
	-- ===================================================================
	-- KONFIGURASI
	-- ===================================================================
	local SprintSpeed = 10
	local NormalSpeed = Humanoid.WalkSpeed
	local Speed = NormalSpeed + SprintSpeed
	local StaminaRate = 10
	local Keybind = Enum.KeyCode.LeftShift
	local ToggleMode = false

	-- [+] Konfigurasi FOV
	local NORMAL_FOV = 70 -- FOV default Roblox
	local SPRINT_FOV = 85  -- FOV pas lagi lari (naik 15)
	local FOV_TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	-- ===================================================================
	-- SETUP
	-- ===================================================================
	local Animator = Humanoid:FindFirstChildOfClass("Animator")
	local SprintAnim = Animator:LoadAnimation(script.Run)
	SprintAnim.Priority = Enum.AnimationPriority.Action
	if UserInputService.GamepadEnabled then Keybind = Enum.KeyCode.ButtonL3 end

	local Sprinting = false
	local Conn: RBXScriptConnection
	local currentFovTween

	-- ===================================================================
	-- FUNGSI INTI
	-- ===================================================================
	local function StopSprint()
		if Sprinting then
			Sprinting = false

			if currentFovTween then currentFovTween:Cancel() end
			currentFovTween = TweenService:Create(Camera, FOV_TWEEN_INFO, { FieldOfView = NORMAL_FOV })
			currentFovTween:Play()

			Char:SetAttribute("AntiRegen", false)
			Humanoid.WalkSpeed = NormalSpeed
			SprintAnim:Stop(0.25)
			if Conn then Conn:Disconnect() end
		end
	end

	local function StartSprint()
		if not Sprinting and Char:GetAttribute("Stamina") > 0 and Humanoid.MoveDirection.Magnitude > 0 then
			Sprinting = true

			if currentFovTween then currentFovTween:Cancel() end
			currentFovTween = TweenService:Create(Camera, FOV_TWEEN_INFO, { FieldOfView = SPRINT_FOV })
			currentFovTween:Play()

			Humanoid.WalkSpeed = Speed
			SprintAnim:Play(0.25)
			Char:SetAttribute("AntiRegen", true)
			Conn = RunService.Heartbeat:Connect(function(deltaTime)
				if Humanoid.MoveDirection.Magnitude <= 0 or Char:GetAttribute("Stamina") <= 0 then
					StopSprint()
					return
				end
				local DrainAmount = StaminaRate * deltaTime
				Char:SetAttribute("Stamina", math.max(0, Char:GetAttribute("Stamina") - DrainAmount))
			end)
		end
	end


	local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Keybind then
			if not Sprinting then StartSprint()
			elseif Sprinting and ToggleMode then StopSprint() end
		end
	end)

	local inputEndedConn = UserInputService.InputEnded:Connect(function(input, gp)
		if input.KeyCode == Keybind and not ToggleMode then
			if Sprinting then StopSprint() end
		end
	end)

	local sprintButton = playerGui:WaitForChild("SprintScreenGUI").SprintButtonFrame.SprintButtonWrapper
	if UserInputService.TouchEnabled then
		sprintButton.Visible = true

		sprintButton.SprintButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				StartSprint()
			end
		end)

		sprintButton.SprintButton.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				StopSprint()
			end
		end)
	else
		sprintButton.Visible = false
	end

	Humanoid.Died:Once(function()
		inputBeganConn:Disconnect()
		inputEndedConn:Disconnect()
		if currentFovTween then currentFovTween:Cancel() end
		Camera.FieldOfView = NORMAL_FOV -- Langsung reset
	end)
end

if Char:GetAttribute("SprintEnabled") == true then
	InitializeSprint()
else
	Char:GetAttributeChangedSignal("SprintEnabled"):Once(function()
		if Char:GetAttribute("SprintEnabled") == true then
			InitializeSprint()
		end
	end)
end
