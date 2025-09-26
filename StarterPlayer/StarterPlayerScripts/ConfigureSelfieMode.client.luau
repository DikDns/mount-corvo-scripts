local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SelfieMode = require(ReplicatedStorage:WaitForChild("SelfieMode"))

local customDepthOfField = Instance.new("DepthOfFieldEffect")
customDepthOfField.NearIntensity = 0
customDepthOfField.FarIntensity = 0.5
customDepthOfField.FocusDistance = 3.5
customDepthOfField.InFocusRadius = 4

SelfieMode.configure({
	depthOfFieldEffect = customDepthOfField
})

SelfieMode.setHudButtonEnabled(false)
SelfieMode.setTheme({
	textSize = 20,
	font = Enum.Font.Merriweather,
	backgroundColor = Color3.fromHex("#54200d"),
})
