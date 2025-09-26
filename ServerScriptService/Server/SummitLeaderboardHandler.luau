local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local LEADERBOARD_TAG = "SummitLeaderboardDisplay"

-- DataStore dan MemoryStore
local summitLeaderboardStore = DataStoreService:GetOrderedDataStore("SummitLeaderboardV1")


local function setupLeaderboardDisplay(leaderboardPart)
	local surfaceGui = leaderboardPart:FindFirstChildOfClass("SurfaceGui")
	if not surfaceGui then print("DEBUG: SurfaceGui tidak ditemukan di", leaderboardPart.Name) return end

	local scrollingFrame = surfaceGui:FindFirstChildOfClass("ScrollingFrame")
	if not scrollingFrame then print("DEBUG: ScrollingFrame tidak ditemukan di", surfaceGui.Name) return end

	local template = scrollingFrame:FindFirstChild("Template")
	if not template then print("DEBUG: Frame 'Template' tidak ditemukan di", scrollingFrame.Name) return end

	template.Visible = false

	local MAX_PLAYER_DISPLAYED = 50
	local REFRESH_RATE = 60

	while true do
		-- (PERBAIKAN) Kita cek hasil pcall-nya
		local success, err = pcall(function()
			-- Hapus semua entri lama
			for _, child in ipairs(scrollingFrame:GetChildren()) do
				if child:IsA("Frame") and child.Name ~= "Template" then
					child:Destroy()
				end
			end

			-- Ambil data teratas dari DataStore
			local pages = summitLeaderboardStore:GetSortedAsync(false, MAX_PLAYER_DISPLAYED)
			local topPlayers = pages:GetCurrentPage()

			if #topPlayers == 0 then
				local noPlayerEntry = template:Clone()
				noPlayerEntry.Name = "NoPlayers"
				noPlayerEntry.Visible = true
				noPlayerEntry.RankLabel.Text = ""
				noPlayerEntry.UsernameLabel.Text = "Belum ada data."
				noPlayerEntry.SummitLabel.Text = ""
				local profileImage = noPlayerEntry:FindFirstChild("ProfileImage")
				if profileImage then profileImage.Visible = false end
				noPlayerEntry.Parent = scrollingFrame
			end

			for rank, data in ipairs(topPlayers) do
				local userId = tonumber(data.key)
				local summits = data.value

				local nameSuccess, username = pcall(function()
					return Players:GetNameFromUserIdAsync(userId)
				end)
				if not nameSuccess then username = "???" end

				local newEntry = template:Clone()
				newEntry.Name = username
				newEntry.Visible = true

				newEntry.RankLabel.Text = "#" .. rank
				newEntry.UsernameLabel.Text = username
				newEntry.SummitLabel.Text = summits

				local profileImage = newEntry:FindFirstChild("ProfileImage")
				if profileImage then
					local thumbType = Enum.ThumbnailType.HeadShot
					local thumbSize = Enum.ThumbnailSize.Size150x150

					local thumbSuccess, content = pcall(Players.GetUserThumbnailAsync, Players, userId, thumbType, thumbSize)
					if thumbSuccess and content then
						profileImage.Image = content
					end
				end

				newEntry.Parent = scrollingFrame
			end
		end)

		if not success then
			warn("!! ERROR DALAM LOOP LEADERBOARD: ", err)
		end

		task.wait(REFRESH_RATE)
	end
end


-- (BARU) Bagian ini akan secara otomatis mencari dan mengaktifkan semua papan leaderboard
-- Jalankan 'mesin update' untuk setiap papan yang SUDAH ada saat game dimulai
for _, part in ipairs(CollectionService:GetTagged(LEADERBOARD_TAG)) do
	-- task.spawn digunakan agar setiap papan memiliki loop update-nya sendiri-sendiri
	task.spawn(setupLeaderboardDisplay, part)
end

-- Jalankan 'mesin update' untuk setiap papan yang BARU ditambahkan tag-nya saat game berjalan
CollectionService:GetInstanceAddedSignal(LEADERBOARD_TAG):Connect(function(part)
	task.spawn(setupLeaderboardDisplay, part)
end)
