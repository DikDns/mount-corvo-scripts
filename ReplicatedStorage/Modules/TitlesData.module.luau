--!nonstrict
--[[
	TitlesData (ModuleScript)
	Defines all titles, their properties, and unlock conditions.
]]

local Titles = {
	-- //////////////////////////////
	-- //      DEFAULT TITLES      //
	-- //////////////////////////////
	["T001"] = {
		Name = "Rookie",
		Description = "This is your default title when you begin your first journey.",
		Color = Color3.fromRGB(200, 200, 200),
		StrokeColor = Color3.fromRGB(36, 36, 36),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = nil, -- No special animation
		UnlockMethod = "Default",
		Secret = false,
	},

	-- //////////////////////////////
	-- //      SUMMIT TITLES       //
	-- //////////////////////////////
	["T002"] = {
		Name = "Pathfinder",
		Description = "Complete 5 summits. The routes are becoming familiar to you.",
		Color = Color3.fromRGB(200, 200, 200),
		StrokeColor = Color3.fromRGB(36, 36, 36),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = nil,
		UnlockMethod = "Stat",
		UnlockRequirement = { StatName = "Summits", Value = 5 },
		Secret = false,
	},
	["T003"] = {
		Name = "Dawn Inheritor",
		Description = "Complete 10 summits. You carry the will of the dawn with every step.",
		Color = Color3.fromRGB(146, 222, 32),
		StrokeColor = Color3.fromRGB(49, 74, 11),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = nil,
		UnlockMethod = "Stat",
		UnlockRequirement = { StatName = "Summits", Value = 10 },
		Secret = false,
	},
	["T004"] = {
		Name = "Keeper of Memories",
		Description = "Complete 25 summits. Every rock and tree on the mountain tells you its story.",
		Color = Color3.fromRGB(118, 188, 255),
		StrokeColor = Color3.fromRGB(40, 64, 86),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = nil,
		UnlockMethod = "Stat",
		UnlockRequirement = { StatName = "Summits", Value = 25 },
		Secret = false,
	},
	["T005"] = {
		Name = "Spirit of the Mountain",
		Description = "Complete 50 summits. You no longer walk the path; you have become a part of it.",
		Color = Color3.fromRGB(158, 122, 255),
		StrokeColor = Color3.fromRGB(52, 40, 84),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = nil,
		UnlockMethod = "Stat",
		UnlockRequirement = { StatName = "Summits", Value = 50 },
		Secret = false,
	},
	["T006"] = {
		Name = "Corvo Legend",
		Description = "Complete 100 summits. Your footsteps are now etched into the history of this mountain.",
		Color = Color3.fromRGB(255, 120, 120),
		StrokeColor = Color3.fromRGB(93, 44, 44),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = { Type = "Pulse", Speed = 1 }, -- Example of a simple animation
		UnlockMethod = "Stat",
		UnlockRequirement = { StatName = "Summits", Value = 100 },
		Secret = false,
	},
	["T007"] = {
		Name = "Eternal Voyager",
		Description = "Complete 250 summits. A journey without end, a memory relived forever.",
		Color = Color3.fromRGB(255, 255, 255), -- Base color is white for rainbow
		StrokeColor = Color3.fromRGB(0, 0, 0),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = { Type = "Rainbow", Speed = 0.25 }, -- Example of a special animation
		UnlockMethod = "Stat",
		UnlockRequirement = { StatName = "Summits", Value = 250 },
		Secret = false,
	},

	-- //////////////////////////////
	-- //    Achievement TITLES      //
	-- //////////////////////////////
	["T008"] = {
		Name = "Wanderer",
		Description = "Find 3 unique achievements.",
		Color = Color3.fromRGB(187, 152, 97),
		StrokeColor = Color3.fromHex("#54200d"),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = nil,
		UnlockMethod = "Achievement",
		UnlockRequirement = { AchievementCount = 3 },
		Secret = false,
	},
	["T009"] = {
		Name = "Curious Soul",
		Description = "Find 7 unique achievements. Your curiosity leads you off the main path.",
		Color = Color3.fromRGB(0, 126, 180),
		StrokeColor = Color3.fromHex("#54200d"),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = nil,
		UnlockMethod = "Achievement",
		UnlockRequirement = { AchievementCount = 7 },
		Secret = false,
	},
	["T010"] = {
		Name = "Secret Hunter",
		Description = "Find 9 unique achievements. Few stones are left unturned for you.",
		Color = Color3.fromRGB(152, 83, 255),
		StrokeColor = Color3.fromRGB(54, 30, 91),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = nil,
		UnlockMethod = "Achievement",
		UnlockRequirement = { AchievementCount = 9 },
		Secret = false,
	},
	["T011"] = {
		Name = "Loremaster",
		Description = "Find all 15 unique achievements. You have witnessed every story the mountain has to tell, from the waterfall to the hidden blossoms.",
		Color = Color3.fromRGB(255, 85, 0),
		StrokeColor = Color3.fromRGB(80, 27, 0),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = nil,
		UnlockMethod = "Achievement",
		UnlockRequirement = { AchievementCount = 15 },
		Secret = false,
	},

	-- //////////////////////////////
	-- //      SPECIAL TITLES      //
	-- //////////////////////////////
	["T012"] = {
		Name = "The Creator's Companion",
		Description = "Awarded to those who have personally been escorted on a journey by the Founder. A symbol of a special and respected bond.",
		Color = Color3.fromRGB(255, 195, 75),
		StrokeColor = Color3.fromRGB(63, 48, 19),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = { Type = "Pulse", Speed = 1 },
		UnlockMethod = "Manual",
		Secret = true,
	},
	["T013"] = {
		Name = "Developer",
		Description = "A title reserved for the development team who brought the world of Mount Corvo to life.",
		Color = Color3.fromRGB(255, 80, 80),
		StrokeColor = Color3.fromRGB(66, 21, 21),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = { Type = "Pulse", Speed = 1 },
		UnlockMethod = "Group",
		UnlockRequirement = { GroupId = 432800971, Rank = 254 },
		Secret = true,
	},
	["T014"] = {
		Name = "Admin",
		Description = "A title for server moderators and administrators who help maintain a safe and peaceful community.",
		Color = Color3.fromRGB(255, 0, 0),
		StrokeColor = Color3.fromRGB(88, 0, 0),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = { Type = "Pulse", Speed = 1 },
		UnlockMethod = "Group",
		UnlockRequirement = { GroupId = 432800971, Rank = 253 },
		Secret = true,
	},
	["T015"] = {
		Name = "VIP",
		Description = "A special title for players who support the game through the VIP gamepass. Thank you for your support!",
		Color = Color3.fromRGB(255, 200, 0),
		StrokeColor = Color3.fromRGB(106, 95, 0),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = { Type = "Pulse", Speed = 1 },
		UnlockMethod = "Gamepass",
		UnlockRequirement = { GamepassId = 1336827563 },
		Secret = false,
	},
	["T016"] = {
		Name = "Founder",
		Description = "The original architect of this world. The visionary who brought this experience to life.",
		Color = Color3.fromRGB(255, 170, 0),
		StrokeColor = Color3.fromRGB(80, 43, 0),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = { Type = "Pulse", Speed = 1 },
		UnlockMethod = "Group",
		UnlockRequirement = { GroupId = 432800971, Rank = 255 },
		Secret = true,
	},
	["T017"] = {
		Name = "Nakama",
		Description = "Welcome to the crew! A title for all members of the Dreamer's Ascent journey.",
		Color = Color3.fromRGB(135, 206, 235),
		StrokeColor = Color3.fromRGB(70, 130, 180),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = nil,
		UnlockMethod = "Group",
		UnlockRequirement = { GroupId = 432800971, Rank = 1 },
	},
	["T018"] = {
		Name = "Pioneer",
		Description = "Forging the path for others. A title for testers who helped shape this world before its official journey began. Thank you!",
		Color = Color3.fromRGB(85, 85, 255),
		StrokeColor = Color3.fromRGB(0, 80, 80),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = { Type = "Pulse", Speed = 1 },
		UnlockMethod = "Group",
		UnlockRequirement = { GroupId = 432800971, Rank = 252 },
		Secret = true,
	},
	["T019"] = {
		Name = "Content Creator",
		Description = "Sharing the tale of Mount Corvo with the world. A title for creators who broadcast this journey to new dreamers.",
		Color = Color3.fromRGB(0, 255, 136),
		StrokeColor = Color3.fromRGB(139, 0, 139),
		PreviewBGColor = Color3.fromHex("#54200d"),
		AnimationInfo = nil,
		UnlockMethod = "Manual",
		Secret = true,
	},
}

return Titles
