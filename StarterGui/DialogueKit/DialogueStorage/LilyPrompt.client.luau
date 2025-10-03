-- LilyPrompt LocalScript
-- This script controls the dialogue flow for the NPC Lilyyeoui based on player status.

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules and Events
local dialogueKitModule = require(script.Parent.Parent.DialogueKit)
local dialoguePrompt = workspace:WaitForChild("DialoguePrompts"):WaitForChild("LilyPrompt").PromptPart.ProximityPrompt
local startQuestEvent = ReplicatedStorage.Remotes:WaitForChild("StartHeeseungQuest") -- Example remote event

-- Local Player
local localPlayer = Players.LocalPlayer

-- Configuration
local GROUP_ID = 432800971 -- Dreamer's Ascent group ID
local QUEST_STATUS = {
	NOT_STARTED = 0,
	IN_PROGRESS = 1,
	COMPLETED = 2
}

-- Event Date Configuration (Year, Month, Day) in UTC
local EVENT_START_DATE = { Year = 2025, Month = 10, Day = 10 }
local PHASE_2_START_DATE = { Year = 2025, Month = 10, Day = 18 }
local EVENT_END_DATE = { Year = 2025, Month = 10, Day = 25 } -- Event ends at the start of the 25th

-- ===================================================================
-- HELPER FUNCTIONS
-- ===================================================================

-- Checks the current period of the event based on real-world time using DateTime.
local function getEventPeriod()
	local now = DateTime.now()
	local eventStart = DateTime.fromUniversalTime(EVENT_START_DATE.Year, EVENT_START_DATE.Month, EVENT_START_DATE.Day)
	local phase2Start = DateTime.fromUniversalTime(PHASE_2_START_DATE.Year, PHASE_2_START_DATE.Month, PHASE_2_START_DATE.Day)
	local eventEnd = DateTime.fromUniversalTime(EVENT_END_DATE.Year, EVENT_END_DATE.Month, EVENT_END_DATE.Day)

	-- [DEBUG] Print current time and event timestamps
	print("--- Debugging getEventPeriod ---")
	print("Current UTC Time:", now:ToIsoDate())
	print("Event Start:", eventStart:ToIsoDate())
	print("Phase 2 Start:", phase2Start:ToIsoDate())
	print("Event End:", eventEnd:ToIsoDate())
	print("Current Timestamp:", now.UnixTimestamp)

	local period
	if now.UnixTimestamp < eventStart.UnixTimestamp then
		period = "BEFORE"
	elseif now.UnixTimestamp >= eventStart.UnixTimestamp and now.UnixTimestamp < phase2Start.UnixTimestamp then
		period = "PHASE_1"
	elseif now.UnixTimestamp >= phase2Start.UnixTimestamp and now.UnixTimestamp < eventEnd.UnixTimestamp then
		period = "PHASE_2"
	else
		period = "ENDED"
	end

	print("Calculated Period:", period)
	print("-----------------------------")
	return period
end

-- Checks if the player is in the specified Roblox group.
local function checkGroupMembership()
	return localPlayer:IsInGroup(GROUP_ID)
end

-- This function should get the player's quest status from the server.
local function getMemoryTrailQuestStatus()
	-- <<!>> DEVELOPER NOTE: Replace this with a RemoteFunction call to the server <<!>>
	if not localPlayer.Character then return QUEST_STATUS.NOT_STARTED end
	local statusAttr = localPlayer.Character:GetAttribute("HeeseungQuestStatus")
	if statusAttr == 1 then
		return QUEST_STATUS.IN_PROGRESS
	elseif statusAttr == 2 then
		return QUEST_STATUS.COMPLETED
	else
		return QUEST_STATUS.NOT_STARTED
	end
end

-- This function should tell the server to start the quest for the player.
local function activateMemoryTrailQuest()
	print("Client requesting to start Heeseung's Memory Trail quest...")
	startQuestEvent:FireServer()
	if localPlayer.Character then
		localPlayer.Character:SetAttribute("HeeseungQuestStatus", 1)
	end
end

-- ===================================================================
-- DIALOGUE TRIGGER
-- ===================================================================

dialoguePrompt.Triggered:Connect(function(player)
	-- Determine player status and event period
	local isInGroup = checkGroupMembership()
	local questStatus = getMemoryTrailQuestStatus()
	local eventPeriod = getEventPeriod()

	-- Prepare dynamic dialogue content BEFORE creating the dialogue UI
	local mustJoinDialogue, nakamaDialogue, nakamaReplies, inProgressDialogue

	if eventPeriod == "PHASE_1" then
		mustJoinDialogue = "Ini favoritku! Lokasi 10 fotonya diacak untuk tiap pemain. Selama minggu pertama (10-17 Oktober), baru 5 foto pertama yang disebar. 3 pemain tercepat yang menemukan semua 10 foto dan posting video di TikTok akan menang!\n\nTAPI, quest ini khusus buat member grup 'Dreamer's Ascent'. Join dulu ya!"
		nakamaDialogue = {
			"Ini favoritku! Lokasi 10 fotonya diacak untuk tiap pemain, jadi adil banget!",
			"Selama minggu pertama ini (10-17 Oktober), baru 5 foto pertama yang disebar. Jadi, fokus cari yang itu dulu ya!",
			"Nanti, 3 pemain tercepat yang menemukan semua 10 foto dan memposting videonya di TikTok akan menang!"
		}
		nakamaReplies = {
			reply1 = { ReplyText = "Mulai Quest!", ReplyLayer = "QuestStartedLayer" },
			reply2 = { ReplyText = "Kembali", ReplyLayer = "EventMenuLayer" }
		}
		inProgressDialogue = { "Kamu lagi cari 5 foto pertama ya? Semangat terus dan jangan lupa rekam perjalananmu!" }

	elseif eventPeriod == "PHASE_2" then
		mustJoinDialogue = "Ini favoritku! Lokasi 10 fotonya diacak untuk tiap pemain. Sekarang semua 10 foto sudah disebar! 3 pemain tercepat yang menemukan semuanya dan posting video di TikTok akan jadi pemenang!\n\nTAPI, quest ini khusus buat member grup 'Dreamer's Ascent'. Join dulu ya!"
		nakamaDialogue = {
			"Ini favoritku! Lokasi 10 fotonya diacak untuk tiap pemain, jadi adil banget!",
			"Sekarang udah masuk minggu kedua (18-24 Oktober), artinya semua 10 foto sudah disebar! Ayo selesaikan!",
			"Ingat, 3 pemain tercepat yang menemukan semuanya dan memposting video di TikTok akan jadi pemenang!"
		}
		nakamaReplies = {
			reply1 = { ReplyText = "Mulai Quest!", ReplyLayer = "QuestStartedLayer" },
			reply2 = { ReplyText = "Kembali", ReplyLayer = "EventMenuLayer" }
		}
		inProgressDialogue = { "Info baru, Nakama! 5 foto terakhir sekarang sudah disebar!", "Ayo selesaikan quest-nya! Total ada 10 foto yang harus kamu cari." }

	else -- BEFORE or ENDED
		mustJoinDialogue = "Quest Heeseung's Memory Trail saat ini sedang tidak berlangsung. Cek lagi nanti ya!"
		nakamaDialogue = {"Quest Heeseung's Memory Trail saat ini sedang tidak berlangsung."}
		nakamaReplies = { reply1 = { ReplyText = "Oke, mengerti.", ReplyLayer = "EventMenuLayer" } }
		inProgressDialogue = { "Eventnya sudah berakhir, tapi terima kasih banyak ya sudah berpartisipasi!" }
	end

	-- Determine initial layer based on player status
	local initialLayerName
	if questStatus == QUEST_STATUS.COMPLETED then
		initialLayerName = "QuestCompletedLayer"
	elseif questStatus == QUEST_STATUS.IN_PROGRESS then
		initialLayerName = "QuestInProgressLayer"
	elseif isInGroup and eventPeriod ~= "BEFORE" and eventPeriod ~= "ENDED" then
		initialLayerName = "WelcomeLayer_Nakama"
	else
		initialLayerName = "WelcomeLayer_NewPlayer"
	end

	-- [BUG FIX] Determine the correct layer for the "Memory Trail?" button based on quest status
	local memoryTrailInfoLayerName
	if not isInGroup then
		memoryTrailInfoLayerName = "MemoryTrailInfo_MustJoinGroup"
	elseif questStatus == QUEST_STATUS.NOT_STARTED then
		memoryTrailInfoLayerName = "MemoryTrailInfo_Nakama"
	else -- Player is IN_PROGRESS or COMPLETED
		memoryTrailInfoLayerName = "MemoryTrailInfo_InProgress"
	end

	-- [DEBUG] Print final determined states
	print("--- Debugging Dialogue Trigger ---")
	print("Is In Group:", isInGroup)
	print("Quest Status:", questStatus, "(0=NS, 1=IP, 2=C)")
	print("Event Period:", eventPeriod)
	print("Initial Layer:", initialLayerName)
	print("Memory Trail Info Layer:", memoryTrailInfoLayerName)
	print("---------------------------------")

	-- Create the dialogue with the determined starting point
	dialogueKitModule.CreateDialogue({
		InitialLayer = initialLayerName,
		SkinName = "DefaultDark",
		Config = script.Config,

		Layers = {
			-- ===================================================================
			-- ALUR 1: Player Belum Join Grup / Event Belum Mulai
			-- ===================================================================
			WelcomeLayer_NewPlayer = {
				Dialogue = {
					"Hai, engene! Kamu juga di sini buat ngerayain?!",
					"Ini kan bulan Oktober! Bulan paling spesial buat kita para Engene, karena bias aku, HEESEUNG, lagi ulang tahun! Makanya ada perayaan spesial: 'The 1009th Journey'!"
				},
				DialogueImage = "rbxassetid://73064027053754",
				Title = "LILYYEOUI",
				Replies = {
					reply1 = { ReplyText = "Info Event!", ReplyLayer = "EventMenuLayer" },
					_goodbye = { ReplyText = "Nanti saja." }
				}
			},

			MemoryTrailInfo_MustJoinGroup = {
				Dialogue = mustJoinDialogue,
				DialogueImage = "rbxassetid://73064027053754",
				Title = "LILYYEOUI",
				Replies = {
					reply1 = { ReplyText = "Oke, aku join!", ReplyLayer = "EventMenuLayer" },
					_goodbye = { ReplyText = "Nanti saja." }
				}
			},

			-- ===================================================================
			-- ALUR 2: Player Sudah Join Grup, Belum Mulai Quest
			-- ===================================================================
			WelcomeLayer_Nakama = {
				Dialogue = {
					"Hai, Nakama! Seneng banget ketemu kamu di sini buat ngerayain ulang tahun Heeseung!",
					"Karena kamu bagian dari kita, kamu bisa langsung mulai tantangan spesial Heeseung's Memory Trail! Atau mau tahu info lain dulu?"
				},
				DialogueImage = "rbxassetid://73064027053754",
				Title = "LILYYEOUI",
				Replies = {
					reply1 = { ReplyText = "Mulai Quest!", ReplyLayer = "QuestStartedLayer" },
					reply2 = { ReplyText = "Info Event Lain", ReplyLayer = "EventMenuLayer" },
					_goodbye = { ReplyText = "Nanti saja." }
				}
			},

			MemoryTrailInfo_Nakama = {
				Dialogue = nakamaDialogue,
				DialogueImage = "rbxassetid://73064027053754",
				Title = "LILYYEOUI",
				Replies = nakamaReplies,
			},

			QuestStartedLayer = {
				Dialogue = {
					"YESS! Sistem udah konfirmasi kamu beneran Nakama kita! Quest Heeseung's Memory Trail sudah aktif buat kamu. Semangat ya carinya!",
					"Inget, rekam perjalananmu! Good luck!"
				},
				DialogueImage = "rbxassetid://73064027053754",
				Title = "LILYYEOUI",
				Replies = {
					_goodbye = { ReplyText = "Siap!" }
				},
				Exec = {
					startQuest = {
						Function = activateMemoryTrailQuest,
						ExecTime = "Before",
						ExecContent = 1
					}
				}
			},

			-- ===================================================================
			-- ALUR 3: Player Sudah Join Grup, Quest Sedang Berlangsung
			-- ===================================================================
			QuestInProgressLayer = {
				Dialogue = inProgressDialogue,
				DialogueImage = "rbxassetid://73064027053754",
				Title = "LILYYEOUI",
				Replies = {
					reply1 = { ReplyText = "Info Event Lain", ReplyLayer = "EventMenuLayer" },
					_goodbye = { ReplyText = "Oke, semangat!" }
				}
			},

			-- [NEW LAYER for bug fix] Shows info to players already on the quest
			MemoryTrailInfo_InProgress = {
				Dialogue = nakamaDialogue, -- Shows the same info
				DialogueImage = "rbxassetid://73064027053754",
				Title = "LILYYEOUI",
				Replies = { -- But without the "Start Quest" button
					reply1 = { ReplyText = "Kembali", ReplyLayer = "EventMenuLayer" }
				},
			},

			-- ===================================================================
			-- ALUR 4: Player Sudah Join Grup, Quest Selesai
			-- ===================================================================
			QuestCompletedLayer = {
				Dialogue = {
					"WAH! Kamu hebat banget, udah berhasil nemuin semua 10 fotonya! Selamat, ya!",
					"Jangan lupa langkah terakhir yang paling penting: edit perjalananmu jadi video kompilasi yang keren, terus post di TikTok dengan hashtag #HeeseungsMemoryTrail!",
					"Semoga kamu jadi salah satu dari tiga pemenang pertama, ya! Aku dukung kamu!"
				},
				DialogueImage = "rbxassetid://73064027053754",
				Title = "LILYYEOUI",
				Replies = {
					reply1 = { ReplyText = "Info Event Lain", ReplyLayer = "EventMenuLayer" },
					_goodbye = { ReplyText = "Pasti, makasih!" }
				}
			},

			-- ===================================================================
			-- LAYER BERSAMA (Shared Layers)
			-- ===================================================================
			EventMenuLayer = {
				Dialogue = { "Mau tahu soal yang mana dulu?" },
				DialogueImage = "rbxassetid://73064027053754",
				Title = "LILYYEOUI",
				Replies = {
					reply1 = { ReplyText = "Corvo Dance Challenge?", ReplyLayer = "DanceChallengeLayer" },
					reply2 = {
						ReplyText = "Memory Trail?",
						ReplyLayer = memoryTrailInfoLayerName -- Use the dynamically determined layer name
					},
					reply3 = { ReplyText = "Perubahan Map?", ReplyLayer = "MapChangesLayer" },
					_goodbye = { ReplyText = "Cukup dulu." }
				}
			},

			DanceChallengeLayer = {
				Dialogue = {
					"Jadi, ada 'Heeseung Walk' yang ditambahin ke game sementara. Kamu tinggal ke puncak The Summit, rekam video TikTok paling sinematik, terus post pake hashtag #CorvoDanceChallenge!",
					"Nanti bakal ada voting buat nentuin pemenangnya, dan hadiahnya Robux, lho! Info lengkapnya ada di server Discord Dreamer's Ascent ya!"
				},
				DialogueImage = "rbxassetid://73064027053754",
				Title = "LILYYEOUI",
				Replies = {
					reply1 = { ReplyText = "Oke, mengerti!", ReplyLayer = "EventMenuLayer" }
				}
			},

			MapChangesLayer = {
				Dialogue = {
					"Selama 'The 1009th Journey' ini, The Summit dapet sentuhan spesial! Ada banner ulang tahun, partikel bintang di malam hari, dan musiknya diganti jadi versi piano lagu-lagu Heeseung & ENHYPEN. Vibe-nya dapet banget buat foto-foto!"
				},
				DialogueImage = "rbxassetid://73064027053754",
				Title = "LILYYEOUI",
				Replies = {
					reply1 = { ReplyText = "Keren, makasih!", ReplyLayer = "EventMenuLayer" }
				}
			}
		}
	})
end)
