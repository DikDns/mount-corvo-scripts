local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)

	if hours > 0 then
		return string.format("%d Hours %d Minutes %d Seconds", hours, minutes, secs)
	elseif minutes > 0 then
		return string.format("%d Minutes %d Seconds", minutes, secs)
	else
		return string.format("%d Seconds", secs)
	end
end

return formatTime
