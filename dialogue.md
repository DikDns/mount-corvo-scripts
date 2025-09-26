Alur Dialog (Struktur Bercabang)
Dialog akan dibagi menjadi beberapa "Layer" atau "Cabang". Pemain bisa bolak-balik antar cabang dari menu utama.

LAYER 1: Sambutan Awal (WelcomeLayer)
(Pemain berinteraksi dengan Lilyyeoui. Lilyyeoui merespons dengan animasi ceria)
LILYYEOUI: "Hai, engene! Kamu juga di sini buat ngerayain?!"
LILYYEOUI: "Ini kan bulan Oktober! Bulan paling spesial buat kita para Engene, karena bias aku, HEESEUNG, lagi ulang tahun! Makanya ada perayaan spesial: 'The 1009th Journey'!"
PILIHAN PEMAIN:
"Ceritain lebih lanjut tentang event-nya!" → (Lanjut ke LAYER 2: EventMenuLayer)
"Sampai nanti!" → (Dialog Selesai)

LAYER 2: Menu Informasi (EventMenuLayer)
LILYYEOUI: "Oke, jadi selama dua minggu ini, Mount Corvo kita dihias dan ada dua challenge seru! (disini pokknya mention dua challenge itu) Mau tahu soal yang mana dulu? "
PILIHAN PEMAIN:
"Apa itu #CorvoDanceChallenge?" → (Lanjut ke LAYER 3: DanceChallengeLayer)
"Heeseung's Memory Trail itu apa?" → [ACTION: Cek apakah quest 'MemoryTrail' sudah aktif untuk pemain]
Jika SUDAH AKTIF → (Lanjut ke LAYER 4B: QuestInProgressLayer)
Jika BELUM AKTIF → (Lanjut ke LAYER 4A: MemoryTrailLayer)
"Ada perubahan apa di Gunung Corvo?" → (Lanjut ke LAYER 5: MapChangesLayer)
"Oke, cukup dulu." → (Dialog Selesai)

LAYER 3: Info Dance Challenge (DanceChallengeLayer)
LILYYEOUI: "Jadi, ada 'Heeseung Walk' yang ditambahin ke game sementara. Kamu tinggal ke puncak The Summit , rekam video TikTok paling sinematik, terus post pake hashtag
#CorvoDanceChallenge!"
LILYYEOUI: "Nanti bakal ada voting buat nentuin pemenangnya, dan hadiahnya Robux, lho! Kalo ada pertanyaan lebih detail, langsung aja cek pengumuman lengkapnya di server Discord Dreamer's Ascent ya! Kita tunggu video kamu!"
PILIHAN PEMAIN:
"Oke, ngerti!" → (Kembali ke LAYER 2: EventMenuLayer)

LAYER 4A: Info Scavenger Hunt (MemoryTrailLayer)
(Hanya diakses jika quest belum aktif)
LILY YEOUI: "Ini favoritku! Aku nyebar 5 foto Heeseung yang gemes-gemes di seluruh gunung. Tiga orang pertama yang berhasil nemuin semuanya dan post kompilasi perjalanannya di TikTok bakal dapet Robux!"
Periode: Mulai 10 Oktober
Ide: Sebuah perburuan (scavenger hunt) untuk menemukan 10 foto Heeseung yang tersebar di seluruh peta.
Mekanisme:
Lokasi Acak: Untuk menjaga keadilan dan mencegah spoiler, lokasi 10 foto akan diacak untuk setiap pemain dari total 50 titik potensial yang telah disiapkan.
Penyebaran Bertahap:
10 - 17 Oktober: 5 foto pertama disebar.
18 - 24 Oktober: 5 foto sisanya disebar.
Penentuan Pemenang: 3 pemain pertama yang berhasil menemukan semua 10 foto dan mengunggah video kompilasi perjalanannya di TikTok (dengan hashtag #HeeseungsMemoryTrail) akan menjadi pemenang.
Desain Foto:
Pake frame foto putih
Foto meme atau foto keren
LILY YEOUI: "TAPI, ada satu syarat penting. Biar adil, quest ini khusus buat member grup Roblox 'Dreamer's Ascent'. Udah join beluum?"
PILIHAN PEMAIN:
"Aku sudah join grup!" → [ACTION: Cek status grup pemain] → (Lanjut ke LAYER 6A atau 6B)
"Belum join, deh..." → (Lanjut ke LAYER 7: NotInGroupLayer)
"Kembali ke menu." → (Kembali ke LAYER 2: EventMenuLayer)

LAYER 4B: Quest Sedang Berlangsung (QuestInProgressLayer)
(Hanya diakses jika quest 'MemoryTrail' sudah aktif untuk pemain)
LILY YEOUI: "Lho, kamu kan lagi di tengah-tengah Heeseung's Memory Trail! Gimana, udah ketemu berapa foto?"
LILY YEOUI: "Semangat terus carinya, ya! Jangan lupa rekam perjalananmu, aku nggak sabar lihat hasilnya!" PILIHAN PEMAIN:
"Oke, semangat!" → (Dialog Selesai)
"Boleh tanya info lain?" → (Kembali ke LAYER 2: EventMenuLayer)

LAYER 5: Info Perubahan Map (MapChangesLayer)
LILYYEOUI: "Selama 'The 1009th Journey' ini, The Summit dapet sentuhan spesial, lho! Ada banner ucapan selamat ulang tahun yang cantik, dan pas malam hari, ada partikel bintang-bintang yang melayang."
LILYYEOUI: "Musiknya juga diganti jadi lebih spesial pake lagu-lagu Heeseung & ENHYPEN versi piano. Pokoknya,
vibe-nya dapet banget buat foto-foto!"
PILIHAN PEMAIN:
"Keren! Makasih infonya." → (Kembali ke LAYER 2: EventMenuLayer)
LAYER 4C: Quest Selesai (QuestCompletedLayer)
(Hanya bisa diakses jika status quest 'MemoryTrail' pemain sudah selesai)
LILY YEOUI: "WAH! Kamu hebat banget, udah berhasil nemuin semua 10 fotonya! Selamat, ya!"
LILY YEOUI: "Jangan lupa langkah terakhir yang paling penting: edit perjalananmu jadi video kompilasi yang keren, terus post di TikTok!"
LILY YEOUI: "Semoga kamu jadi salah satu dari tiga pemenang pertama, ya! Aku dukung kamu!"
PILIHAN PEMAIN:
"Pasti aku post! Makasih!" → (Dialog Selesai)
"Boleh tanya info lain?" → (Kembali ke LAYER 2: EventMenuLayer)

LAYER 6A: Lolos Cek Grup (QuestStartedLayer)
(Hanya bisa diakses jika player:IsInGroup() mengembalikan true)
LILYYEOUI: "YESS! Sistem udah konfirmasi kamu beneran Nakama kita! Quest Heeseung's Memory Trail sudah aktif buat kamu. Semangat ya carinya!"
LILYYEOUI: "Inget, rekam perjalananmu! Good luck!"
PILIHAN PEMAIN:
"Siap!" → [ACTION: Aktifkan quest untuk pemain] → (Dialog Selesai)

LAYER 6B & 7: Gagal Cek Grup (NotInGroupLayer)
(Bisa diakses dari Layer 4 atau jika cek grup di Layer 6A gagal)
LILYYEOUI: "Yah, sayang banget! Sistem ngecek dan kayaknya kamu belum gabung ke grup "Dreamer's Ascent" di Roblox"
LILYYEOUI: "Coba klik 'Dreamer's Ascent' di halaman Roblox Mount Corvo ya terus join. Setelah itu, balik lagi ke aku ya, nanti kita bisa mulai Heeseung's Memory Trail-nya!"
PILIHAN PEMAIN:
"Oke, aku join dulu!" → (Kembali ke LAYER 2: EventMenuLayer)
"Nanti saja, deh." → (Dialog Selesai)
