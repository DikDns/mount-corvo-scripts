-- ===================================================================
-- PlayerReportGenerator.module.luau
-- Membuat laporan detail tentang progres seorang pemain, termasuk
-- lokasi dan waktu setiap foto yang dikoleksi.
-- ===================================================================

local Config = require(script.Parent.EventConfig)
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)

local PlayerReportGenerator = {}

-- Fungsi helper untuk mengubah selisih waktu (detik) menjadi format relatif
local function formatRelativeTime(secondsDifference)
	if secondsDifference < 60 then
		return "beberapa detik yang lalu"
	elseif secondsDifference < 3600 then
		local minutes = math.floor(secondsDifference / 60)
		return string.format("%d menit yang lalu", minutes)
	elseif secondsDifference < 86400 then
		local hours = math.floor(secondsDifference / 3600)
		return string.format("%d jam yang lalu", hours)
	else
		local days = math.floor(secondsDifference / 86400)
		return string.format("%d hari yang lalu", days)
	end
end

-- Fungsi utama untuk menghasilkan laporan
function PlayerReportGenerator:GenerateReportForPlayer(player)
	local data = PlayerDataHandler:GetPlayerData(player)

	if not data then
		return string.format("Laporan tidak tersedia: Pemain '%s' belum memulai event.", player.Name)
	end

	local reportLines = {}
	local collectedCount = #data.collectedPhotos
	local statusText = (collectedCount >= Config.TOTAL_PHOTOS_TO_FIND) and "SELESAI" or "BERLANGSUNG"

	-- Header
	table.insert(reportLines, string.format("=== Laporan Detail untuk %s (ID: %d) ===", player.Name, player.UserId))
	table.insert(reportLines, string.format("Status: %s | Progres: %d/%d", statusText, collectedCount, Config.TOTAL_PHOTOS_TO_FIND))
	table.insert(reportLines, "---------------------------------------------")

	-- Detail Foto yang Dikoleksi
	table.insert(reportLines, "--- Foto yang Dikoleksi ---")
	if collectedCount == 0 then
		table.insert(reportLines, "Belum ada foto yang dikoleksi.")
	else
		for i, photoData in ipairs(data.collectedPhotos) do
			local loc = photoData.location
			local timestamp = photoData.collectedTimestamp
			local collectedTime = DateTime.fromUnixTimestamp(timestamp)
			local timeDifference = DateTime.now().UnixTimestamp - timestamp
			local absoluteTimeString = collectedTime:FormatLocalTime("dddd, D MMMM YYYY, HH:mm", "id-id")
			local relativeTimeString = formatRelativeTime(timeDifference)
			table.insert(reportLines, string.format("  %d. Decal: %s", i, photoData.decalId))
			table.insert(reportLines, string.format("     - Lokasi: (X: %.1f, Y: %.1f, Z: %.1f)", loc.x, loc.y, loc.z))
			table.insert(reportLines, string.format("     - Waktu: %s (%s)", absoluteTimeString, relativeTimeString))
		end
	end

	-- Footer
	table.insert(reportLines, "---------------------------------------------")
	table.insert(reportLines, string.format("Sisa foto untuk ditemukan: %d", #data.pendingPhotos))
	table.insert(reportLines, "=============================================")

	return reportLines
end

return PlayerReportGenerator
