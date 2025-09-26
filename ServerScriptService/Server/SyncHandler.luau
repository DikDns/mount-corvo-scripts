--[[
	SyncHandler - Server-Authoritative Sync System (FIXED)
	- Timing yang lebih akurat dengan milliseconds
	- Support multiple players yang aman
	- Better error handling dan validation
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Setup Remotes Folder & Events
local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = ReplicatedStorage

local RequestSync = Instance.new("RemoteEvent")
RequestSync.Name = "RequestSync"
RequestSync.Parent = Remotes

local RequestUnsync = Instance.new("RemoteEvent")
RequestUnsync.Name = "RequestUnsync"
RequestUnsync.Parent = Remotes

local BroadcastSync = Instance.new("RemoteEvent")
BroadcastSync.Name = "BroadcastSync"
BroadcastSync.Parent = Remotes

local syncGroups = {}
local playerToMaster = {}

-- Fungsi untuk mendapatkan timing yang akurat (dalam milliseconds)
local function getAccurateTime()
	return math.floor(workspace.DistributedGameTime * 1000) / 1000 -- Precision sampai milliseconds
end

-- Fungsi untuk mendapatkan animasi dance yang sedang diputar
local function getCurrentDanceAnimation(player)
	if not player or not player.Character then return nil end

	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return nil end

	local playingTracks = animator:GetPlayingAnimationTracks()

	-- Ambil track pertama yang sedang playing
	for _, track in ipairs(playingTracks) do
		if track.IsPlaying and track.Animation then
			return track
		end
	end

	return nil
end

-- Fungsi untuk broadcast update ke semua anggota grup dengan retry mechanism
local function broadcastToGroup(masterPlayer)
	local group = syncGroups[masterPlayer]
	if not group then return end

	-- Collect valid members dan cleanup yang invalid
	local validMembers = {}
	local membersToCleanup = {}

	-- Check master
	if masterPlayer and masterPlayer.Parent and masterPlayer.Character then
		table.insert(validMembers, masterPlayer)
	else
		table.insert(membersToCleanup, masterPlayer)
	end

	-- Check slaves
	for slave, _ in pairs(group.Slaves) do
		if slave and slave.Parent and slave.Character then
			table.insert(validMembers, slave)
		else
			table.insert(membersToCleanup, slave)
			group.Slaves[slave] = nil
			playerToMaster[slave] = nil
		end
	end

	-- Cleanup invalid members
	if #membersToCleanup > 0 then
		print("Cleaning up", #membersToCleanup, "invalid members")
	end

	-- Jika tidak ada member yang valid, bubarkan grup
	if #validMembers == 0 then
		print("No valid members, dissolving group for", masterPlayer and masterPlayer.Name or "unknown master")
		syncGroups[masterPlayer] = nil
		return
	end

	-- Prepare sync data dengan timing yang akurat
	local currentTime = getAccurateTime()
	local syncData = {
		AnimationId = group.AnimationId,
		StartTime = group.StartTime,
		CurrentTime = currentTime, -- Tambahkan current time untuk validasi
		IsMaster = nil -- Akan di-set per member
	}

	local successCount = 0
	local failCount = 0

	-- Broadcast ke semua member yang valid
	for _, member in ipairs(validMembers) do
		local success = pcall(function()
			syncData.IsMaster = (member == masterPlayer)
			BroadcastSync:FireClient(member, syncData)
		end)

		if success then
			successCount = successCount + 1
		else
			failCount = failCount + 1
			print("Failed to broadcast to", member.Name)
		end
	end

	print(string.format("Broadcast complete for master %s: %d/%d successful",
		masterPlayer.Name, successCount, #validMembers))

	if failCount > 0 then
		warn(string.format("Failed to broadcast to %d members", failCount))
	end
end

-- Fungsi untuk menghentikan sync dengan retry
local function stopSyncForPlayers(playersToStop)
	for _, player in ipairs(playersToStop) do
		if player and player.Parent then
			local success = pcall(function()
				BroadcastSync:FireClient(player, nil)
			end)
			if not success then
				print("Failed to stop sync for", player.Name)
				-- Retry sekali lagi setelah delay kecil
				wait(0.1)
				pcall(function()
					BroadcastSync:FireClient(player, nil)
				end)
			end
		end
		playerToMaster[player] = nil
	end
end

-- Fungsi untuk cleanup player dari semua data
local function cleanupPlayer(player)
	local master = playerToMaster[player]
	if master and syncGroups[master] then
		if player == master then
			-- Jika yang cleanup adalah master, bubarkan grup
			print("Master", player.Name, "is being cleaned up. Dissolving group.")
			local membersToStop = {master}
			for slave, _ in pairs(syncGroups[master].Slaves) do
				table.insert(membersToStop, slave)
				playerToMaster[slave] = nil
			end
			stopSyncForPlayers(membersToStop)
			syncGroups[master] = nil
		else
			-- Jika slave, keluarkan dari grup
			print("Slave", player.Name, "is being cleaned up from", master.Name, "'s group")
			syncGroups[master].Slaves[player] = nil
		end
	end
	playerToMaster[player] = nil
end

-- Handle request untuk sync dengan validation yang lebih ketat
RequestSync.OnServerEvent:Connect(function(requester, targetPlayer)
	-- Validasi input yang lebih lengkap
	if not requester or not requester.Parent then
		print("Invalid requester")
		return
	end

	if not targetPlayer or not targetPlayer.Parent or not targetPlayer.Character then
		print("Invalid target player from", requester.Name)
		return
	end

	if requester == targetPlayer then
		print("Cannot sync with self:", requester.Name)
		return
	end

	print("🔄 Sync request:", requester.Name, "->", targetPlayer.Name)

	-- 1. Cleanup requester dari grup lama
	cleanupPlayer(requester)

	-- 2. Tentukan master
	local master = playerToMaster[targetPlayer] or targetPlayer

	-- 3. Jika master belum punya grup, coba buat grup baru
	if not syncGroups[master] then
		local danceTrack = getCurrentDanceAnimation(targetPlayer)
		if not danceTrack then
			print("Target", targetPlayer.Name, "is not playing any animation.")
			return
		end

		-- Validasi bahwa master masih ada dan valid
		if not master.Parent or not master.Character then
			print("Master", master.Name, "is no longer valid")
			return
		end

		syncGroups[master] = {
			AnimationId = danceTrack.Animation.AnimationId,
			StartTime = getAccurateTime(), -- Gunakan timing yang akurat
			Slaves = {}
		}
		playerToMaster[master] = master
		print("New sync group created by master:", master.Name, "AnimationId:", danceTrack.Animation.AnimationId)
	end

	-- 4. Tambahkan requester ke grup
	local group = syncGroups[master]
	group.Slaves[requester] = true
	playerToMaster[requester] = master

	print("✅ Sync successful:", requester.Name, "joined", master.Name, "'s group")

	-- 5. Reset timing agar semua sinkron dari awal
	group.StartTime = getAccurateTime() -- Reset ke waktu sekarang dengan precision tinggi

	-- 6. Wait sedikit untuk memastikan semua ready, lalu broadcast
	wait(0.05) -- 50ms delay untuk stabilitas
	broadcastToGroup(master)
end)

-- Handle request untuk unsync
RequestUnsync.OnServerEvent:Connect(function(player)
	if not player or not player.Parent then
		print("Invalid unsync request")
		return
	end

	local master = playerToMaster[player]
	if not master or not syncGroups[master] then
		print(player.Name, "tried to unsync but was not in a group.")
		return
	end

	if player == master then
		print("Master", player.Name, "is unsyncing. Dissolving group.")
		local membersToStop = {master}
		for slave, _ in pairs(syncGroups[master].Slaves) do
			table.insert(membersToStop, slave)
		end
		stopSyncForPlayers(membersToStop)
		syncGroups[master] = nil
	else
		print("Slave", player.Name, "is unsyncing from", master.Name)
		syncGroups[master].Slaves[player] = nil
		stopSyncForPlayers({player})
	end
end)

-- Cleanup saat player keluar
Players.PlayerRemoving:Connect(function(player)
	print("Player", player.Name, "is leaving. Cleaning up...")
	cleanupPlayer(player)
end)

-- Monitor master yang berhenti dance dengan interval yang lebih jarang untuk performance
local lastMonitorTime = 0
RunService.Heartbeat:Connect(function()
	local currentTime = getAccurateTime()

	-- Check setiap 0.5 detik saja untuk mengurangi load
	if currentTime - lastMonitorTime < 0.5 then
		return
	end
	lastMonitorTime = currentTime

	for master, group in pairs(syncGroups) do
		if master and master.Parent and master.Character then
			local currentTrack = getCurrentDanceAnimation(master)
			if not currentTrack or not currentTrack.Animation or
				currentTrack.Animation.AnimationId ~= group.AnimationId or
				not currentTrack.IsPlaying then
				-- Master berhenti dance, bubarkan grup
				print("Master", master.Name, "stopped dancing. Dissolving group.")
				local membersToStop = {master}
				for slave, _ in pairs(group.Slaves) do
					table.insert(membersToStop, slave)
				end
				stopSyncForPlayers(membersToStop)
				syncGroups[master] = nil
			end
		else
			-- Master sudah disconnect atau character hilang
			print("Master disconnected or lost character. Dissolving group.")
			local membersToStop = {}
			for slave, _ in pairs(group.Slaves) do
				table.insert(membersToStop, slave)
			end
			stopSyncForPlayers(membersToStop)
			syncGroups[master] = nil
		end
	end
end)

print("✅ Fixed Server-Authoritative SyncHandler ready for multiple players!")
