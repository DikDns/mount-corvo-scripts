--!nonstrict
--[[
	CarryAnimationData
	Menyimpan ID animasi dan CFrame offset untuk setiap tipe carry.
]]

local CarryData = {
	["Bride"] = {
		CarrierAnimId = "rbxassetid://89389994536393",
		TargetAnimId = "rbxassetid://71791769947511",
		AttachmentPoint = CFrame.new(0, -0.5, -1) * CFrame.Angles(0, 0, 0),
	},
	["Piggyback"] = {
		CarrierAnimId = "rbxassetid://113000285372129",
		TargetAnimId = "rbxassetid://102344150911064",
		AttachmentPoint = CFrame.new(0, 0.1, 1.4) * CFrame.Angles(0, 0, 0),
	},
	["Shoulder"] = {
		CarrierAnimId = "rbxassetid://132884153827320",
		TargetAnimId = "rbxassetid://129687783104050",
		AttachmentPoint = CFrame.new(0, 0.1, 0.75) * CFrame.Angles(0, 0, 0),
	},
}

return CarryData
