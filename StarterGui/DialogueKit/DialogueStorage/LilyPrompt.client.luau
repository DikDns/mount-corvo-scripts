-- LilyPrompt LocalScript

local dialogueKitModule = require(script.Parent.Parent.DialogueKit)
local dialoguePrompt = workspace:WaitForChild("DialoguePrompts"):WaitForChild("LilyPrompt").PromptPart.ProximityPrompt
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Configuration
local GROUP_ID = 8983141 -- Dreamer's Ascent group ID
local QUEST_STATUS = {
	NOT_STARTED = 0,
	IN_PROGRESS = 1,
	COMPLETED = 2
}

-- Helper functions
local function checkGroupMembership()
	return localPlayer:IsInGroup(GROUP_ID)
end

local function getMemoryTrailQuestStatus()
	-- This should be replaced with actual quest system integration
	-- For now, return NOT_STARTED as default
	-- You would typically check a player data service or remote function here
	return QUEST_STATUS.NOT_STARTED
end

local function activateMemoryTrailQuest()
	-- This function should activate the Memory Trail quest for the player
	-- Implementation depends on your quest system
	print("Memory Trail quest activated for player:", localPlayer.Name)
end

dialoguePrompt.Triggered:Connect(function(player)
	dialogueKitModule.CreateDialogue(
		{
			InitialLayer = "WelcomeLayer",
			SkinName = "DefaultDark",
			Config = script.Config,

			Layers = {
				-- LAYER 1: Sambutan Awal (WelcomeLayer)
				WelcomeLayer = {
					Dialogue = {
						"Hai, engene! Kamu juga di sini buat ngerayain?!",
						"Ini kan bulan Oktober! Bulan paling spesial buat kita para Engene, karena bias aku, HEESEUNG, lagi ulang tahun! Makanya ada perayaan spesial: 'The 1009th Journey'!"
					},
					DialogueSounds = {nil, nil},
					DialogueImage = "rbxassetid://73064027053754", -- Replace with Lilyyeoui image
					Title = "LILYYEOUI",

					Replies = {
						tellMore = {
							ReplyText = "Ceritain lebih lanjut tentang event-nya!",
							ReplyLayer = "EventMenuLayer"
						},
						_goodbye = {
							ReplyText = "Sampai nanti!",
						}
					},

					Exec = {}
				},

				-- LAYER 2: Menu Informasi (EventMenuLayer)
				EventMenuLayer = {
					Dialogue = {
						"Oke, jadi selama dua minggu ini, Mount Corvo kita dihias dan ada dua challenge seru! Mau tahu soal yang mana dulu?"
					},
					DialogueSounds = {nil},
					DialogueImage = "rbxassetid://73064027053754",
					Title = "LILYYEOUI",

					Replies = {
						danceChallenge = {
							ReplyText = "Apa itu #CorvoDanceChallenge?",
							ReplyLayer = "DanceChallengeLayer"
						},
						memoryTrail = {
							ReplyText = "Heeseung's Memory Trail itu apa?",
							ReplyLayer = "MemoryTrailStatusCheck"
						},
						mapChanges = {
							ReplyText = "Ada perubahan apa di Gunung Corvo?",
							ReplyLayer = "MapChangesLayer"
						},
						_goodbye = {
							ReplyText = "Oke, cukup dulu.",
						}
					},

					Exec = {}
				},

				-- Dynamic layer to check quest status and redirect accordingly
				MemoryTrailStatusCheck = {
					Dialogue = {},
					DialogueSounds = {},
					DialogueImage = "rbxassetid://73064027053754",
					Title = "LILYYEOUI",

					Replies = {},

					Exec = {
						redirectBasedOnStatus = {
							Function = function()
								local questStatus = getMemoryTrailQuestStatus()
								if questStatus == QUEST_STATUS.IN_PROGRESS then
									-- Player should go to QuestInProgressLayer
									print("Redirecting to QuestInProgressLayer")
								elseif questStatus == QUEST_STATUS.COMPLETED then
									-- Player should go to QuestCompletedLayer
									print("Redirecting to QuestCompletedLayer")
								else
									-- Player should go to MemoryTrailLayer (not started)
									print("Redirecting to MemoryTrailLayer")
								end
								-- Note: Due to dialogue system limitations, you might need to handle this redirect differently
								-- This function will run but won't actually redirect - you may need to modify the dialogue system
							end,
							ExecTime = "Before",
							ExecContent = 1
						}
					}
				},

				-- LAYER 3: Info Dance Challenge (DanceChallengeLayer)
				DanceChallengeLayer = {
					Dialogue = {
						"Jadi, ada 'Heeseung Walk' yang ditambahin ke game sementara. Kamu tinggal ke puncak The Summit, rekam video TikTok paling sinematik, terus post pake hashtag #CorvoDanceChallenge!",
						"Nanti bakal ada voting buat nentuin pemenangnya, dan hadiahnya Robux, lho! Kalo ada pertanyaan lebih detail, langsung aja cek pengumuman lengkapnya di server Discord Dreamer's Ascent ya! Kita tunggu video kamu!"
					},
					DialogueSounds = {nil, nil},
					DialogueImage = "rbxassetid://73064027053754",
					Title = "LILYYEOUI",

					Replies = {
						understand = {
							ReplyText = "Oke, ngerti!",
							ReplyLayer = "EventMenuLayer"
						}
					},

					Exec = {}
				},

				-- LAYER 4A: Info Scavenger Hunt (MemoryTrailLayer) - Quest belum aktif
				MemoryTrailLayer = {
					Dialogue = {
						"Ini favoritku! Aku nyebar 5 foto Heeseung yang gemes-gemes di seluruh gunung. Tiga orang pertama yang berhasil nemuin semuanya dan post kompilasi perjalanannya di TikTok bakal dapet Robux!",
						"TAPI, ada satu syarat penting. Biar adil, quest ini khusus buat member grup Roblox 'Dreamer's Ascent'. Udah join beluum?"
					},
					DialogueSounds = {nil, nil},
					DialogueImage = "rbxassetid://73064027053754",
					Title = "LILYYEOUI",

					Replies = {
						alreadyJoined = {
							ReplyText = "Aku sudah join grup!",
							ReplyLayer = "GroupCheckLayer"
						},
						notJoined = {
							ReplyText = "Belum join, deh...",
							ReplyLayer = "NotInGroupLayer"
						},
						backToMenu = {
							ReplyText = "Kembali ke menu.",
							ReplyLayer = "EventMenuLayer"
						}
					},

					Exec = {}
				},

				-- LAYER 4B: Quest Sedang Berlangsung (QuestInProgressLayer)
				QuestInProgressLayer = {
					Dialogue = {
						"Lho, kamu kan lagi di tengah-tengah Heeseung's Memory Trail! Gimana, udah ketemu berapa foto?",
						"Semangat terus carinya, ya! Jangan lupa rekam perjalananmu, aku nggak sabar lihat hasilnya!"
					},
					DialogueSounds = {nil, nil},
					DialogueImage = "rbxassetid://73064027053754",
					Title = "LILYYEOUI",

					Replies = {
						_goodbye = {
							ReplyText = "Oke, semangat!",
						},
						askOther = {
							ReplyText = "Boleh tanya info lain?",
							ReplyLayer = "EventMenuLayer"
						}
					},

					Exec = {}
				},

				-- LAYER 4C: Quest Selesai (QuestCompletedLayer)
				QuestCompletedLayer = {
					Dialogue = {
						"WAH! Kamu hebat banget, udah berhasil nemuin semua 10 fotonya! Selamat, ya!",
						"Jangan lupa langkah terakhir yang paling penting: edit perjalananmu jadi video kompilasi yang keren, terus post di TikTok!",
						"Semoga kamu jadi salah satu dari tiga pemenang pertama, ya! Aku dukung kamu!"
					},
					DialogueSounds = {nil, nil, nil},
					DialogueImage = "rbxassetid://73064027053754",
					Title = "LILYYEOUI",

					Replies = {
						_goodbye = {
							ReplyText = "Pasti aku post! Makasih!",
						},
						askOther = {
							ReplyText = "Boleh tanya info lain?",
							ReplyLayer = "EventMenuLayer"
						}
					},

					Exec = {}
				},

				-- LAYER 5: Info Perubahan Map (MapChangesLayer)
				MapChangesLayer = {
					Dialogue = {
						"Selama 'The 1009th Journey' ini, The Summit dapet sentuhan spesial, lho! Ada banner ucapan selamat ulang tahun yang cantik, dan pas malam hari, ada partikel bintang-bintang yang melayang.",
						"Musiknya juga diganti jadi lebih spesial pake lagu-lagu Heeseung & ENHYPEN versi piano. Pokoknya, vibe-nya dapet banget buat foto-foto!"
					},
					DialogueSounds = {nil, nil},
					DialogueImage = "rbxassetid://73064027053754",
					Title = "LILYYEOUI",

					Replies = {
						thanks = {
							ReplyText = "Keren! Makasih infonya.",
							ReplyLayer = "EventMenuLayer"
						}
					},

					Exec = {}
				},

				-- LAYER 6A: Group Check Layer (shows both success and failure options)
				GroupCheckLayer = {
					Dialogue = {},
					DialogueSounds = {},
					DialogueImage = "rbxassetid://73064027053754",
					Title = "LILYYEOUI",

					Replies = {
						inGroup = {
							ReplyText = "Aku memang sudah join!",
							ReplyLayer = "QuestStartedLayer"
						},
						notInGroup = {
							ReplyText = "Sepertinya aku belum join...",
							ReplyLayer = "NotInGroupLayer"
						}
					},

					Exec = {
						checkGroup = {
							Function = function()
								local isInGroup = checkGroupMembership()
								if isInGroup then
									-- Player is in group, automatically show success message
									print("Player confirmed in group")
								else
									-- Player is not in group, they should select the "not in group" option
									print("Player not in group, they should select appropriate option")
								end
							end,
							ExecTime = "Before",
							ExecContent = 1
						}
					}
				},

				-- Success case when player is in group
				QuestStartedLayer = {
					Dialogue = {
						"YESS! Sistem udah konfirmasi kamu beneran Nakama kita! Quest Heeseung's Memory Trail sudah aktif buat kamu. Semangat ya carinya!",
						"Inget, rekam perjalananmu! Good luck!"
					},
					DialogueSounds = {nil, nil},
					DialogueImage = "rbxassetid://73064027053754",
					Title = "LILYYEOUI",

					Replies = {
						_goodbye = {
							ReplyText = "Siap!",
						}
					},

					Exec = {
						activateQuest = {
							Function = activateMemoryTrailQuest,
							ExecTime = "Before",
							ExecContent = 1
						}
					}
				},

				-- LAYER 6B & 7: Gagal Cek Grup (NotInGroupLayer)
				NotInGroupLayer = {
					Dialogue = {
						"Yah, sayang banget! Sistem ngecek dan kayaknya kamu belum gabung ke grup \"Dreamer's Ascent\" di Roblox",
						"Coba klik 'Dreamer's Ascent' di halaman Roblox Mount Corvo ya terus join. Setelah itu, balik lagi ke aku ya, nanti kita bisa mulai Heeseung's Memory Trail-nya!"
					},
					DialogueSounds = {nil, nil},
					DialogueImage = "rbxassetid://73064027053754",
					Title = "LILYYEOUI",

					Replies = {
						willJoin = {
							ReplyText = "Oke, aku join dulu!",
							ReplyLayer = "EventMenuLayer"
						},
						_goodbye = {
							ReplyText = "Nanti saja, deh.",
						}
					},

					Exec = {}
				}
			}
		}
	)
end)
