-- ===================================================================
-- EventConfig.module.luau
-- Menyimpan semua konstanta dan pengaturan untuk event Heeseung.
-- ===================================================================

local EventConfig = {}

-- Pengaturan Umum
EventConfig.DEBUG_MODE = true
EventConfig.GROUP_ID = 432800971
EventConfig.TOTAL_PHOTOS_TO_FIND = 10
EventConfig.STREAMING_RADIUS = 100

-- Enum Status Quest
EventConfig.QUEST_STATUS = {
	NOT_STARTED = 0,
	IN_PROGRESS = 1,
	COMPLETED = 2
}

-- Aset & Lokasi
EventConfig.DATASTORE_NAME = "HeeseungMemoryTrailV0.0.1"
EventConfig.PHOTO_TEMPLATE_PATH = game:GetService("ServerStorage").HeeseungEvent:WaitForChild("HeeseungMemoryTemplate")
EventConfig.PHOTO_STORAGE_CONTAINER = game:GetService("ServerStorage"):FindFirstChild("HeeseungEventPhotoStorage") or Instance.new("Folder", game:GetService("ServerStorage"))
EventConfig.PHOTO_STORAGE_CONTAINER.Name = "HeeseungEventPhotoStorage"

EventConfig.PHOTO_DECAL_ASSETS = {
	"rbxassetid://84607686570767", "rbxassetid://138990108188283", "rbxassetid://111904602273867",
	"rbxassetid://119581976014206", "rbxassetid://95713145410237", "rbxassetid://102659250472545",
	"rbxassetid://70957932072599", "rbxassetid://128841228744954", "rbxassetid://103104270020256",
	"rbxassetid://119316590847593"
}

EventConfig.PHOTO_ASSETS = {
	['rbxassetid://84607686570767'] = {
		assetId = 'rbxassetid://84607686570767',
		imageUrl = 'https://cdn.jsdelivr.net/gh/DikDns/mount-corvo-assets@main/events/the-1009th-journey/heeseung-photos/heeseung-photo%206.webp',
	},
	['rbxassetid://138990108188283'] = {
		assetId = 'rbxassetid://138990108188283',
		imageUrl = 'https://cdn.jsdelivr.net/gh/DikDns/mount-corvo-assets@main/events/the-1009th-journey/heeseung-photos/heeseung-photo%202.webp',
	},
	['rbxassetid://111904602273867'] = {
		assetId = 'rbxassetid://111904602273867',
		imageUrl = 'https://cdn.jsdelivr.net/gh/DikDns/mount-corvo-assets@main/events/the-1009th-journey/heeseung-photos/heeseung-photo%204.webp',
	},
	['rbxassetid://119581976014206'] = {
		assetId = 'rbxassetid://119581976014206',
		imageUrl = 'https://cdn.jsdelivr.net/gh/DikDns/mount-corvo-assets@main/events/the-1009th-journey/heeseung-photos/heeseung-photo%205.webp',
	},
	['rbxassetid://95713145410237'] = {
		assetId = 'rbxassetid://95713145410237',
		imageUrl = 'https://cdn.jsdelivr.net/gh/DikDns/mount-corvo-assets@main/events/the-1009th-journey/heeseung-photos/heeseung-photo%203.webp',
	},
	['rbxassetid://102659250472545'] = {
		assetId = 'rbxassetid://102659250472545',
		imageUrl = 'https://cdn.jsdelivr.net/gh/DikDns/mount-corvo-assets@main/events/the-1009th-journey/heeseung-photos/heeseung-photo%207.webp',
	},
	['rbxassetid://70957932072599'] = {
		assetId = 'rbxassetid://70957932072599',
		imageUrl = 'https://cdn.jsdelivr.net/gh/DikDns/mount-corvo-assets@main/events/the-1009th-journey/heeseung-photos/heeseung-photo%208.webp',
	},
	['rbxassetid://128841228744954'] = {
		assetId = 'rbxassetid://128841228744954',
		imageUrl = 'https://cdn.jsdelivr.net/gh/DikDns/mount-corvo-assets@main/events/the-1009th-journey/heeseung-photos/heeseung-photo%209.webp',
	},
	['rbxassetid://103104270020256'] = {
		assetId = 'rbxassetid://103104270020256',
		imageUrl = 'https://cdn.jsdelivr.net/gh/DikDns/mount-corvo-assets@main/events/the-1009th-journey/heeseung-photos/heeseung-photo%2010.webp',
	},
	['rbxassetid://119316590847593'] = {
		assetId = 'rbxassetid://119316590847593',
		imageUrl = 'https://cdn.jsdelivr.net/gh/DikDns/mount-corvo-assets@main/events/the-1009th-journey/heeseung-photos/heeseung-photo%201.webp',
	}
}

EventConfig.POTENTIAL_SPAWNS = {
	Vector3.new(3.143, 0.167, -23.058), Vector3.new(3.143, 0.167, -33.058),
	Vector3.new(3.143, 0.167, -44.058), Vector3.new(17.143, 0.167, -44.058),
	Vector3.new(17.143, 0.167, -35.058), Vector3.new(-5.857, 0.167, -35.058),
	Vector3.new(-5.857, 0.167, -17.058), Vector3.new(19.143, 0.167, -17.058),
	Vector3.new(19.143, 0.167, 3.942), Vector3.new(19.143, 0.167, -8.058)
	-- ... (tambahkan 40 posisi lainnya di sini)
}

return EventConfig
