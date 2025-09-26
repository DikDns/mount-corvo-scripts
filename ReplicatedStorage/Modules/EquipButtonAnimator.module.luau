--!nonstrict
--[[
	EquipButtonAnimator
	Modul terpusat untuk menganimasikan tombol Equip.
]]

local TweenService = game:GetService("TweenService")

-- [FIX] Tabel STATES harus didefinisikan secara lengkap di sini
local STATES = {
	Equipped = {
		Text = "EQUIPPED",
		TextColor = Color3.fromRGB(107, 41, 16),
		BackgroundColor = Color3.fromRGB(135, 100, 88), -- Warna hijau 'aktif'
		StrokeColor = Color3.fromRGB(95, 70, 62),
		Locked = false,
	},
	Equippable = { -- State default
		Text = "EQUIP",
		TextColor = Color3.fromRGB(84, 32, 13),
		BackgroundColor = Color3.fromRGB(212, 157, 138), -- Warna default Anda
		StrokeColor = Color3.fromRGB(212, 144, 121),
		Locked = false,
	},
	Locked = {
		Text = "LOCKED",
		TextColor = Color3.fromRGB(212, 157, 138),
		BackgroundColor = Color3.fromRGB(84, 32, 13), -- Warna gelap 'nonaktif'
		StrokeColor = Color3.fromRGB(108, 41, 17),
		Locked = true,
	}
}

local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local EquipButtonAnimator = {}

local function playTween(target, properties)
	local tween = TweenService:Create(target, TWEEN_INFO, properties)
	tween:Play()
end

local function applyBaseStyle(button, style)
	local stroke = button:FindFirstChild("UIStroke")
	button.Text = style.Text
	playTween(button, { BackgroundColor3 = style.BackgroundColor, TextColor3 = style.TextColor })
	if stroke then
		playTween(stroke, { Color = style.StrokeColor })
	end
end

function EquipButtonAnimator.Setup(button)
	local state = "Equippable"
	local isMouseHovering = false

	button.MouseEnter:Connect(function()
		local currentStyle = STATES[state]
		if not currentStyle or currentStyle.Locked then return end
		isMouseHovering = true
	end)

	button.MouseLeave:Connect(function()
		local currentStyle = STATES[state]
		if not currentStyle or currentStyle.Locked then return end
		isMouseHovering = false
	end)

	button.MouseButton1Down:Connect(function()
		local currentStyle = STATES[state]
		if not currentStyle or currentStyle.Locked then return end
	end)

	button.MouseButton1Up:Connect(function()
		local currentStyle = STATES[state]
		if not currentStyle or currentStyle.Locked then return end
	end)

	return function(newState)
		newState = newState or "Equippable"
		local style = STATES[newState]
		if not style then
			warn("Invalid state provided to EquipButtonAnimator:", newState)
			return
		end

		state = newState
		button.Active = not style.Locked
		button.Selectable = not style.Locked
		applyBaseStyle(button, style)
	end
end

return EquipButtonAnimator
