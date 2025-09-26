--!nonstrict
--[[
	TitleAnimator
	Modul utilitas untuk menerapkan warna dan animasi ke TextLabel.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TitlesData = require(ReplicatedStorage.Modules.TitlesData)

local TitleAnimator = {}

local activeAnimations = setmetatable({}, { __mode = "k" })

local function stopPreviousAnimation(textLabel)
	local animData = activeAnimations[textLabel]
	if animData then
		if animData.tween then animData.tween:Cancel() end
		if animData.coroutine then coroutine.close(animData.coroutine) end
		activeAnimations[textLabel] = nil
	end

	textLabel.TextTransparency = 0
	local stroke = textLabel:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Enabled = false
	end
end

function TitleAnimator.Apply(textLabel, titleId)
	if not textLabel or not titleId then return end

	local data = TitlesData[titleId]
	if not data then return end

	stopPreviousAnimation(textLabel)

	textLabel.Text = data.Name
	textLabel.TextColor3 = data.Color or Color3.fromRGB(200, 200, 200)

	-- [BARU] Terapkan StrokeColor jika ada
	local stroke = textLabel:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = data.StrokeColor or Color3.new(0, 0, 0)
		stroke.Enabled = true -- Pastikan stroke selalu aktif (jika tidak dianimasikan)
	end

	local animationInfo = data.AnimationInfo
	if not animationInfo then return end

	if animationInfo.Type == "Rainbow" then
		local co = coroutine.create(function()
			while true do
				local hue = tick() * animationInfo.Speed % 1
				textLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
				if stroke and data.StrokeColor then -- Buat stroke mengikuti warna pelangi
					stroke.Color = Color3.fromHSV(hue, 1, 0.5) -- Versi lebih gelap
				end
				task.wait()
			end
		end)
		coroutine.resume(co)
		activeAnimations[textLabel] = { coroutine = co }

	elseif animationInfo.Type == "Pulse" then
		local tween = TweenService:Create(textLabel, TweenInfo.new(animationInfo.Speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			TextTransparency = 0.5
		})
		tween:Play()
		activeAnimations[textLabel] = { tween = tween }

	elseif animationInfo.Type == "Glow" then
		if not stroke then return end

		stroke.Color = data.StrokeColor or textLabel.TextColor3
		stroke.Transparency = 1
		stroke.Enabled = true

		local tween = TweenService:Create(stroke, TweenInfo.new(animationInfo.Speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Transparency = 0.2
		})
		tween:Play()
		activeAnimations[textLabel] = { tween = tween }
	end
end

return TitleAnimator
