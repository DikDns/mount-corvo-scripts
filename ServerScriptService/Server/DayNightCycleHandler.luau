--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local DayNightChangedEvent = ReplicatedStorage.Remotes:WaitForChild("DayNightChanged")

-- ===================================================================
-- KONFIGURASI
-- ===================================================================
local CYCLE_DURATION_SECONDS = 12 * 60 -- 12 menit
local DAY_PROPORTION = 3/4 -- 9 menit
local NIGHT_PROPORTION = 1/4 -- 3 menit
local DAY_SPEED_START = 6 * 60    -- 06:00 (Patokan kecepatan)
local NIGHT_SPEED_START = 18 * 60   -- 18:00 (Patokan kecepatan)
local TOTAL_GAME_MINUTES = 24 * 60
local DAY_STATE_START = 5 * 60 + 30  -- 05:30 (Patokan state)
local NIGHT_STATE_START = 18 * 60 + 30 -- 18:30 (Patokan state)

-- ===================================================================
-- KALKULASI KECEPATAN (Jangan diubah)
-- ===================================================================
local DAY_DURATION_GAME = NIGHT_SPEED_START - DAY_SPEED_START
local NIGHT_DURATION_GAME = TOTAL_GAME_MINUTES - DAY_DURATION_GAME
local DAY_DURATION_REAL = CYCLE_DURATION_SECONDS * DAY_PROPORTION
local NIGHT_DURATION_REAL = CYCLE_DURATION_SECONDS * NIGHT_PROPORTION
local VIRTUAL_DAY_SPEED = DAY_DURATION_GAME / DAY_DURATION_REAL
local VIRTUAL_NIGHT_SPEED = NIGHT_DURATION_GAME / NIGHT_DURATION_REAL

-- ===================================================================
-- LOOP UTAMA
-- ===================================================================
local currentState = ""
local virtualMinutes = 420 -- Mulai jam 07:00
local lastVisualMinutes = 0

task.spawn(function()
	while true do
		local deltaTime = task.wait()

		-- 1. DETEKSI & SINKRONISASI JIKA ADA PERUBAHAN DARI LUAR
		local currentRobloxTime = Lighting:GetMinutesAfterMidnight()
		local timeDifference = math.abs(currentRobloxTime - lastVisualMinutes)
		if timeDifference > 5 and timeDifference < (TOTAL_GAME_MINUTES - 5) then
			virtualMinutes = currentRobloxTime
		end

		-- 2. TENTUKAN STATE "day" atau "night" DULUAN
		local isCurrentlyDay = (virtualMinutes >= DAY_STATE_START and virtualMinutes < NIGHT_STATE_START)

		-- 3. UPDATE JAM VIRTUAL BERDASARKAN KECEPATAN YANG SESUAI
		if virtualMinutes >= DAY_SPEED_START and virtualMinutes < NIGHT_SPEED_START then
			virtualMinutes = virtualMinutes + (VIRTUAL_DAY_SPEED * deltaTime)
		else
			virtualMinutes = virtualMinutes + (VIRTUAL_NIGHT_SPEED * deltaTime)
		end
		virtualMinutes = virtualMinutes % TOTAL_GAME_MINUTES

		-- 4. KONVERSI JAM VIRTUAL KE JAM VISUAL
		local phaseProgress
		if isCurrentlyDay then
			-- Progres visual saat SIANG (0.0 -> 1.0 dari jam 06:00 ke 18:00)
			phaseProgress = (virtualMinutes - DAY_SPEED_START) / DAY_DURATION_GAME
		else
			-- Progres visual saat MALAM (0.0 -> 1.0 dari jam 18:00 ke 06:00)
			local minutesIntoNight = (virtualMinutes - NIGHT_SPEED_START + TOTAL_GAME_MINUTES) % TOTAL_GAME_MINUTES
			phaseProgress = minutesIntoNight / NIGHT_DURATION_GAME
		end

		local visualMinutes = DAY_SPEED_START + (phaseProgress * DAY_DURATION_GAME)
		Lighting:SetMinutesAfterMidnight(visualMinutes)
		lastVisualMinutes = visualMinutes

		-- 5. KIRIM EVENT HANYA JIKA STATE BERUBAH
		local newState = isCurrentlyDay and "day" or "night"
		if newState ~= currentState then
			currentState = newState
			DayNightChangedEvent:Fire(currentState)
		end
	end
end)
