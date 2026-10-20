# Campus Escape Mobile

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%2B%20Auth-FFCA28?logo=firebase&logoColor=black)
![Version](https://img.shields.io/badge/version-0.9.0-F5A524)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-131C2E)

**Escape room di dalam genggaman.** Siswa SMA/SMK yang berkunjung ke School of Computer Science (SoCS) BINUS @Bekasi "terkunci" di kampus dan harus memecahkan **10 ruangan mini-game** — Algoritma, UI/UX, Data Science, Game Dev, Mobile Dev, Jaringan, Software Engineering, Database, lalu dua bonus AI & Cyber Security. Setiap ruangan memperkenalkan satu disiplin IT lewat bermain, bukan presentasi satu arah; selesai satu ruangan, muncul *Insight Card* yang menjelaskan apa yang baru saja mereka lakukan.

**Cara kerjanya di hari kunjungan:** admin membuat **kode acara** (3 huruf + 3 angka, mis. `ABC321`) dari panel admin, peserta memasang satu APK, daftar dengan nama, no HP, asal sekolah, dan robot avatar, lalu bermain di HP masing-masing. Skor tiap ruangan masuk ke Firestore, **leaderboard acara tampil real-time** di semua HP, admin memantau peserta live, mengatur ruangan yang aktif, menetapkan pemenang, dan mengekspor data ke CSV. Tanpa konfigurasi Firebase, app tetap berjalan penuh dalam **mode lokal** (single device, Hive).

| | |
|---|---|
| **Tech stack** | Flutter 3.47 · Dart 3.13 · flutter_riverpod · go_router · Hive · Firebase (Auth anonim + Firestore) · pdf/printing (sertifikat) · video_player · share_plus |
| **Arsitektur** | Feature-first: `data/` (model, local, remote) → `domain/` (services) → `application/` (Riverpod providers) → `presentation/` (screens, widgets); satu `RoomScaffold` untuk 10 room |
| **Keamanan** | Firestore Security Rules: peserta hanya menulis dokumennya sendiri, skor tidak bisa turun/melompat, no HP terpisah & hanya admin, kode acara tidak bisa di-enumerasi, admin = username + password + dokumen `admins/{uid}` |
| **Reward** | XP per ruangan, leaderboard, pencapaian, **sertifikat PDF** otomatis dari dalam app |
| **Konteks** | Proyek departemen SoCS BINUS @Bekasi sekaligus laporan **Internship Enrichment** — Kevin Aprilio, Software Engineering BINUS |

## Unduh & coba

| Platform | File | Cara |
|---|---|---|
| **Android** | `CampusEscape-<versi>-android.apk` | Unduh di HP → buka → izinkan install dari sumber tidak dikenal |
| **Windows** | `CampusEscape-<versi>-windows-x64.zip` | Ekstrak → jalankan `CampusEscape.exe` (SmartScreen: *More info → Run anyway*). Tampil dalam bingkai seukuran HP; video profil tidak diputar di Windows |

Semua file ada di halaman **[Releases](../../releases/latest)**. Build dibuat otomatis oleh GitHub Actions (`.github/workflows/release.yml`) setiap kali tag `v*` di-push.

> Dokumentasi lengkap: [Setup Firebase](docs/FIREBASE_SETUP.md) · [Design system](DESIGN.md) · [Master sheet](docs/Campus_Escape_Master_Sheet.xlsx) · daftar isi di bawah.

**Versi:** 0.9.0 · **Status:** MVP playable — mode lokal (single-device) **atau** mode online (Firebase, multi-HP + panel admin online) · **Platform:** Android, iOS, Web (preview)

> **Apa yang baru di 0.9 — MODE ONLINE:** satu APK dibagikan admin → peserta main di HP masing-masing. Peserta masuk dengan **kode acara** (3 huruf + 3 angka, mis. `ABC321`, ditentukan admin saat membuat acara; 1 kode per kunjungan sekolah); skor tiap ruangan dikirim ke Firestore → **leaderboard acara real-time** di semua HP; **panel admin online** (ikon kunci di Landing/Home → selalu minta **username + password**, tanpa email) berisi **daftar acara** → detail acara: tutup/buka acara, pantau peserta live, atur ruangan per acara (berlaku real-time ke peserta), **tetapkan pemenang** dari leaderboard (banner muncul di semua HP), **Lihat CSV / Unduh CSV** lengkap no HP, hapus semua akun peserta setelah acara ditutup. Acara yang sudah ditutup tetap bisa dimainkan, tapi skor tidak tersimpan. Data per orang (tanpa regu), dirancang untuk ≥10.000 peserta bersamaan (leaderboard top-50 + peringkat via count aggregate). Keamanan di **Firestore Security Rules** (`firestore.rules`): peserta login anonim & hanya bisa tulis dokumennya sendiri, skor tidak bisa turun/melompat, no HP terpisah & hanya admin, kode acara tidak bisa di-enumerasi, admin harus punya dokumen `admins/{uid}`. Aktifkan dengan `flutterfire configure` (panduan lengkap: `docs/FIREBASE_SETUP.md`); tanpa itu app tetap jalan di mode lokal seperti 0.8.
>
> **Apa yang baru di 0.8:** **Panel Admin** (ikon kunci di Home → password saja, default `socs2026`): progres semua pemain yang pernah main di perangkat (arsip tidak terhapus saat reset), detail skor per ruangan, **tarik data** (Salin CSV ke clipboard / Bagikan PDF rekap), **atur ruangan** (aktif/nonaktif + XP dasar, urutan unlock menyesuaikan), ganti password, reset pemain aktif, hapus arsip. **Leaderboard sekarang data sungguhan** dari arsip pemain (pill "Dummy data" dihapus).
>
> **Apa yang baru di 0.7:** registrasi: **nama lengkap**, **nomor HP** (validasi format Indonesia 08xx 10–13 digit / +62, dinormalisasi ke 08…), dan **asal sekolah** semuanya wajib — tidak bisa lanjut sebelum ketiganya benar; **warna background seluruh app mengikuti warna robot avatar** yang dipilih (pratinjau langsung di Landing, lalu tema global via `AppTheme.tinted`); nomor HP tampil di Profil; unit test `registration_format_test.dart`.
>
> **Apa yang baru di 0.6:** sertifikat didesain ulang bergaya sertifikat kursus online (kertas putih berbingkai, logo BINUS besar kiri atas, tanggal, nama, judul program, **chip bidang yang dijelajahi** menggantikan skor per ruang, pita di kanan dengan label predikat + stempel bulat SoCS BINUS @Bekasi; robot dihapus), **foto dosen** resmi dari halaman CSSE, tombol **suara (mute/unmute)** di video profil, dan **maskot robot baru** (siluet robot melambai, `RobotMark` CustomPainter) untuk avatar & ruang Algoritma.
>
> **Apa yang baru di 0.5:** tab Galeri jadi **Kampus — "Kenali BINUS @Bekasi"**: video profil resmi SoCS (dibundel di app, `video_player`) + teks tentang SoCS/CSSE (akreditasi, QS ranking), bagian "Kenapa CSSE?", perjalanan akademik 4 tahun (expandable), 5 foto fasilitas asli (Library, Classroom, Computer Lab, Conference Room, Creative Class) dengan deskripsi dari tim SoCS, daftar dosen program CSSE, HIMTI & kehidupan mahasiswa (dari ofog.himtibinus.or.id), fakta singkat bergulir, dan daftar sumber. Logo BINUS & HIMTI asli dipakai di peta dan sertifikat.
>
> **Apa yang baru di 0.4:** carousel foto berputar tanpa henti (Home & Galeri), Galeri satu halaman dengan info CSSE yang bergulir otomatis (sumber: binus.ac.id/bekasi/csse), peta jalur gaya level-map santai (jalur berkelok, node bernomor, bintang, foto BINUS @Bekasi + logo di sisi jalur), ruang Algoritma: robot jalan dulu saat "Jalankan Robot", Jaringan: panel penjelasan yang ikut langkah, Database: 6 siswa × 5 kelas dengan kabel & posisi acak, AI: 2 tahap (latih 10 → uji 15, 5 hewan), Cyber: jarak geser acak (maks 10 putaran), sertifikat baru bergaya kertas terang khas BINUS (logo kanan atas, watermark BINUS/SoCS, sirkuit, robot), skala font dibatasi + ukuran mengikuti layar.
>
> **Apa yang baru di 0.3:** 10 mini-game berbeda (satu ciri khas per disiplin, lebih sederhana & ramah orang tua/siswa awam), tanpa timer, pilih **robot avatar** (12 warna) saat daftar, peta berbentuk **jalur petualangan**, Galeri Kampus terbuka semua (foto + info SoCS / Software Engineering BINUS @Bekasi), carousel foto kampus di Home, dan **sertifikat PDF dibuat otomatis di dalam app**.

---

## Daftar isi

1. [Konsep & keputusan produk](#1-konsep--keputusan-produk)
2. [Tech stack](#2-tech-stack)
3. [Menjalankan project](#3-menjalankan-project)
4. [Struktur folder](#4-struktur-folder)
5. [Arsitektur & state management](#5-arsitektur--state-management)
6. [Data model](#6-data-model)
7. [Alur aplikasi & daftar screen](#7-alur-aplikasi--daftar-screen)
8. [Aturan game: unlock, skor, petunjuk](#8-aturan-game-unlock-skor-petunjuk)
9. [10 ruangan — mekanik per ruangan](#9-10-ruangan--mekanik-per-ruangan)
10. [Design system](#10-design-system)
11. [Cara menambah / mengubah ruangan](#11-cara-menambah--mengubah-ruangan)
12. [Testing](#12-testing)
13. [Yang belum dikerjakan & roadmap](#13-yang-belum-dikerjakan--roadmap)
14. [Dokumen terkait](#14-dokumen-terkait)

---

## 1. Konsep & keputusan produk

| Keputusan | Nilai |
|---|---|
| Target pengguna | Siswa SMA/SMK kelas 11–12 yang berkunjung ke kampus (open house), dimainkan per orang di HP masing-masing |
| Format | Escape room **penuh di dalam app** — tidak ada scan QR / checkpoint fisik |
| Jumlah ruangan | **8 core room** (dibuka berurutan) + **2 bonus room** (terbuka setelah 8 core selesai) |
| Durasi sesi | **Tanpa timer.** Tidak ada countdown; waktu bermain per ruangan hanya dicatat untuk statistik |
| Onboarding | Tanpa password: **nama lengkap**, **nomor HP** (format Indonesia), dan **asal sekolah** — ketiganya wajib — lalu pilih **robot avatar** dari 12 warna dasar; background app ikut warna robot |
| Penyimpanan | Offline-first, semua progres di perangkat (Hive) |
| Reward | Insight Card per ruangan, skor XP, leaderboard (arsip pemain di perangkat), **sertifikat PDF otomatis** (unduh/bagikan langsung dari app, tanpa panitia) |
| Panel admin | Ikon kunci di Home (dan di Landing pada mode online). Lokal: password saja; online: username + password setiap kali dibuka. Lihat & ekspor data semua pemain (CSV: lihat tabel di app / unduh file), atur ruangan aktif & XP, ganti password, reset. Data admin di Hive box terpisah `campus_escape_admin_v1` |
| Kampus (ex-Galeri) | **Terbuka sejak awal.** Halaman profil: video SoCS, tentang CSSE, kenapa CSSE, perjalanan akademik, foto fasilitas (carousel looping), dosen, HIMTI, 15 fakta singkat bergulir, sumber resmi |
| Peta | **Level map santai**: jalur berkelok (sungai + garis), node bulat bernomor, bintang di atas node selesai, garis putus-putus untuk yang terkunci, pill "KAMU DI SINI", foto BINUS @Bekasi dan logo BINUS/SoCS/HIMTI di sisi jalur |
| Gaya visual | "Technical Flat / Terminal Brutalism" — dark navy, amber untuk aksi, teal untuk progres (lihat `DESIGN.md`) |

Pola desain puzzle: setiap ruangan adalah **mini-game yang berbeda** dan menjadi ciri khas disiplinnya (memprogram robot, memilih desain, menyortir data, menekan tombol tepat waktu, merakit layar, mengantar paket, mencari bug, mencocokkan data, melatih AI, memecahkan sandi). Soalnya sengaja sederhana supaya siswa SMA atau orang tua yang belum tahu SoCS tetap bisa menyelesaikan — pelajarannya ada di *Insight Card* setelah ruangan selesai, bukan di tingkat kesulitan.

---

## 2. Tech stack

| Layer | Teknologi | Versi | Alasan |
|---|---|---|---|
| Framework | **Flutter** (Dart 3) | Flutter ≥ 3.27, Dart ≥ 3.3 | Satu codebase Android/iOS/web; pakai `CardThemeData`/`DialogThemeData` (3.27+) |
| State management | **flutter_riverpod** (`Notifier` / `NotifierProvider`) | ^2.5.1 | Provider per domain (session, progress, insight, leaderboard), mudah di-test, tanpa codegen |
| Navigasi | **go_router** | ^14.2.0 | `ShellRoute` untuk 5 tab + route param `/room/:id`, deep-link friendly |
| Local storage | **hive** + **hive_flutter** | ^2.2.3 / ^1.1.0 | Offline-first, cepat, disimpan sebagai `Map` biasa — tanpa TypeAdapter / build_runner |
| Font | **google_fonts** | ^6.2.1 | Space Grotesk (judul/angka) + Manrope (body) + JetBrains Mono (kode). Di-cache setelah fetch pertama |
| Ikon | Material Icons (bawaan Flutter) | — | DESIGN.md menyebut Lucide; dipakai Material outlined yang paling dekat supaya tanpa dependency tambahan |
| PDF | **pdf** + **printing** | ^3.11.1 / ^5.13.4 | Sertifikat A4 landscape dibuat di perangkat; `printing` menyediakan share sheet / preview tanpa plugin tambahan |
| Video | **video_player** | ^2.9.2 | Memutar video profil SoCS dari asset (ExoPlayer di Android, AVFoundation di iOS), tanpa internet |
| Backend (opsional) | **firebase_core** + **firebase_auth** + **cloud_firestore** | ^4.15 / ^6.7 / ^6.10 | Mode online: login anonim peserta, login username+password admin (email sintetis), Firestore real-time + cache offline. Tidak aktif sebelum `flutterfire configure` |
| Lint | flutter_lints | ^4.0.0 | Standar |
| Test | flutter_test | — | Unit test untuk engine puzzle |

Backend bersifat opsional: tanpa konfigurasi Firebase, app berjalan lokal penuh (Hive). Dengan Firebase (`docs/FIREBASE_SETUP.md`), leaderboard & panel admin jadi online lintas HP.

**Tools pengembangan:** VS Code / Android Studio di Windows, Figma (desain hi-fi 27 screen) untuk desain, Claude untuk pair-programming.

---

## 3. Menjalankan project

```bash
# 1. Pastikan Flutter terpasang
flutter --version          # butuh ≥ 3.27

# 2. Install dependency
flutter pub get

# 3. Cek kode
flutter analyze
flutter test

# 4. Jalankan
flutter run                # pilih device Android/iOS/emulator
flutter run -d chrome      # preview web (lebar dikunci 430px supaya seperti HP)
```

Build rilis:

```bash
flutter build apk --release        # Android
flutter build ios --release        # iOS (butuh macOS + Xcode)
```

**Build Windows (.exe):** butuh Visual Studio 2022 Community dengan workload **"Desktop development with C++"** (cek `flutter doctor` → Visual Studio ✔). Lalu:

```bash
flutter config --enable-windows-desktop
flutter build windows --release
# hasil: build\windows\x64\runner\Release\  → zip seluruh folder itu (CampusEscape.exe + DLL + data/)
```

**Rilis otomatis (APK + .exe) ke GitHub Releases:**

```bash
git tag v0.9.0
git push origin v0.9.0        # Actions build keduanya, lalu lampirkan ke Releases
```

Tanpa secrets, build CI memakai `lib/firebase_options.example.dart` (mode lokal). Supaya build CI online, tambahkan secrets `FIREBASE_OPTIONS_DART_B64` dan `GOOGLE_SERVICES_JSON_B64` (isi: `base64 -w0 <file>`) di Settings → Secrets → Actions.

**Mode online (opsional):** ikuti `docs/FIREBASE_SETUP.md` — buat project Firebase, `flutterfire configure` (menimpa `lib/firebase_options.dart`), buat akun admin (`<username>@admin.campusescape.app` + dokumen `admins/{uid}`), lalu `firebase deploy --only firestore:rules`. Build yang belum dikonfigurasi otomatis jalan di mode lokal.

**Catatan offline (booth tanpa internet):** `google_fonts` butuh internet sekali untuk mengunduh font. Untuk build booth, unduh font Space Grotesk, Manrope, dan JetBrains Mono, taruh di `assets/fonts/`, daftarkan di `pubspec.yaml`, lalu ganti `GoogleFonts.spaceGrotesk(...)` → `TextStyle(fontFamily: 'SpaceGrotesk', ...)` di `lib/core/theme/app_typography.dart`.

**Logo & foto (sudah asli):** `assets/images/logos/binus.png` (dari PDF logo resmi, crop mark dibuang) dan `himti.png` dipakai di peta dan sertifikat. Foto fasilitas `assets/images/gallery/campus_01..05.jpg` dari tim SoCS (diperkecil ke lebar maks 1200 px). Untuk menambah foto: taruh file di folder itu dan tambah entri di `CampusPhotos.all` (`socs_fact.dart`).

**Video profil:** `assets/video/socs_profile.mp4` adalah versi terkompresi (640×360, ±7 MB) dari video 720p resmi supaya APK tidak membengkak; poster `socs_profile_poster.jpg`. Kalau mau kualitas lebih tinggi, ganti file dengan nama sama (ukuran APK ikut naik).

**Foto kampus lama:** `campus_01.png` … `campus_06.png` (gambar bertulisan "PLACEHOLDER"). Ganti dengan foto asli BINUS @Bekasi / SoCS dengan **nama file yang sama** (disarankan 900×600 px, landscape, PNG/JPG — kalau JPG, ubah ekstensi di `lib/data/models/socs_fact.dart` → `CampusPhotos.all`). Caption & deskripsi tiap foto juga diatur di file itu.

**Reset data saat development:** Profil → Pengaturan → "Reset progres sesi", atau uninstall app. Hive box bernama `campus_escape_v2`; kalau struktur model berubah lagi, ganti nama box di `local_storage_service.dart` supaya data lama otomatis diabaikan.

---

## 4. Struktur folder

```
campus_escape/
├── DESIGN.md                      # design system (acuan warna, tipografi, komponen)
├── README.md
├── pubspec.yaml
├── lib/
│   ├── main.dart                  # init Hive + Firebase (fallback lokal), ProviderScope, system UI style
│   ├── firebase_options.dart      # PLACEHOLDER — ditimpa `flutterfire configure`
│   ├── app.dart                   # MaterialApp.router + theme + pembatas lebar di web
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart        # semua token warna (satu-satunya sumber warna)
│   │   │   ├── app_typography.dart    # type scale Space Grotesk / Manrope / JetBrains Mono
│   │   │   ├── app_spacing.dart       # AppSpacing, AppRadius, AppSize
│   │   │   └── app_theme.dart         # ThemeData dark: button, input, card, dialog, switch
│   │   └── router/
│   │       └── app_router.dart        # GoRouter + mapping RoomId → screen
│   ├── data/
│   │   ├── models/
│   │   │   ├── room_meta.dart         # katalog statis 10 ruangan (RoomId, RoomMeta incl. nama mini-game, RoomCatalog)
│   │   │   ├── socs_fact.dart         # CampusPhotos (5 foto fasilitas) + BrandLogos + SocsFactCatalog (15 fakta singkat)
│   │   │   ├── socs_profile.dart      # SocsProfile: video, tentang, kenapa CSSE, academic journey, dosen, HIMTI, sumber
│   │   │   ├── room_progress.dart     # progres per ruangan (status, skor, bintang, waktu)
│   │   │   ├── player_session.dart    # sesi pemain (nama, sekolah, phone, avatarIndex, anggota, skor) + RobotAvatars + PhoneFormat/NameFormat
│   │   │   ├── player_record.dart     # arsip pemain untuk admin & leaderboard (skor per ruangan, waktu)
│   │   │   ├── room_settings.dart     # RoomSettings (ruangan nonaktif, override XP) + AdminConfig (password lokal)
│   │   │   ├── event_info.dart        # EventInfo/EventWinner (acara online) + EventCodeFormat + AdminUsername
│   │   │   └── unlocked_insight.dart  # kartu wawasan yang sudah terbuka
│   │   ├── local/
│   │   │   └── local_storage_service.dart  # wrapper Hive (save/load Map)
│   │   └── remote/
│   │       ├── firebase_service.dart  # init Firebase (aman gagal), auth anonim peserta, auth admin (app 'admin' terpisah)
│   │       └── event_repository.dart  # CRUD events/players/private di Firestore (sisi peserta & admin)
│   ├── domain/
│   │   ├── engines/
│   │   │   └── puzzle_engine.dart     # ScoreCalculator, CipherEngine, SequenceEvaluator (pure Dart)
│   │   └── services/
│   │       ├── certificate_service.dart # CertificateData + CertificateService.build() → PDF bytes
│   │       └── admin_export_service.dart # CSV pemain: header/rows/csv(), unduh via share sheet (share_plus)
│   ├── application/
│   │   └── providers/
│   │       ├── local_storage_provider.dart
│   │       ├── session_provider.dart      # SessionNotifier (register, setAvatar, setMembers, addScore, reset)
│   │       ├── room_progress_provider.dart# aturan unlock (hanya ruangan aktif), completeRoom, recomputeUnlocks, nextRoomProvider
│       ├── room_settings_provider.dart# roomSettingsProvider, activeRoomsProvider, roomTotalsProvider, adminConfigProvider
│       ├── player_archive_provider.dart# arsip semua pemain (syncCurrent saat daftar/selesai ruangan/reset)
│   │       ├── insight_provider.dart      # koleksi kartu wawasan
│   │       ├── online_provider.dart       # firebaseServiceProvider, eventRepositoryProvider, currentEventProvider, onlinePlayersProvider, admin*Provider
│   │       └── leaderboard_provider.dart  # online: peserta acara (stream) / lokal: arsip pemain; + pemain saat ini
│   └── presentation/
│       ├── shell/main_shell.dart          # bottom nav 5 tab
│       ├── widgets/
│       │   ├── buttons.dart               # PrimaryButton, SecondaryButton, AppIconButton, AppPill
│       │   ├── photo_carousel.dart        # CampusImage + LoopingPhotoCarousel (infinite, auto-play)
│       │   ├── common.dart                # SectionLabel, SurfaceCard, StatTile, RobotAvatar + RobotMark (maskot), ProgressRail,
│       │   │                              # SegmentedProgress, StatusBanner, HelperPanel, ScreenHeader
│       │   ├── event_banner.dart          # EventStatusBanner: status acara + pengumuman pemenang (mode online)
│       │   ├── room_scaffold.dart         # kerangka semua ruangan (top bar, brief, hint bertingkat, dock tombol, skor)
│       │   └── puzzle/
│       │       └── choice_task.dart       # ChoiceTask / ChoicePill (pilihan ganda, dipakai SE & Cyber)
│       └── screens/
│           ├── splash/      splash_screen.dart
│           ├── landing/     landing_screen.dart       # pembuka + registrasi (nama, sekolah, pilih robot)
│           ├── home/        home_screen.dart          # dashboard + carousel foto kampus + promo SoCS
│           ├── map/         campus_map_screen.dart    # level map berkelok + dekorasi foto/logo (CustomPainter)
│           ├── collection/  collection_screen.dart    # Kampus: video + profil CSSE, journey, fasilitas, dosen, HIMTI, fakta rolling
│           ├── leaderboard/ leaderboard_screen.dart
│           ├── profile/     profile_screen.dart       # akun, ganti robot avatar, stats, anggota, reset
│           ├── insight/     insight_card_screen.dart  # kartu wawasan setelah ruangan selesai
│           ├── summary/     summary_screen.dart       # ringkasan akhir + unduh/preview sertifikat PDF
│           ├── admin/       admin_screen.dart         # openAdminPanel() + AdminPanelRoute + AdminScreen (panel LOKAL, password)
│           │                admin_login_screen.dart   # login admin online: username + password
│           │                online_admin_screen.dart  # panel ONLINE: daftar acara → detail (peserta live, pemenang, CSV, ruangan per acara)
│           │                admin_widgets.dart        # AdminPlayerTile, AdminPlayerDetailSheet, AdminRoomSettingTile, AdminActionRow
│           └── rooms/                                 # 10 file, satu mini-game per ruangan
│               ├── algorithm_room_screen.dart
│               ├── uiux_room_screen.dart
│               ├── data_science_room_screen.dart
│               ├── game_dev_room_screen.dart
│               ├── mobile_dev_room_screen.dart
│               ├── networking_room_screen.dart
│               ├── software_engineering_room_screen.dart
│               ├── database_room_screen.dart
│               ├── ai_lab_room_screen.dart
│               └── cyber_security_room_screen.dart
├── assets/images/gallery/         # campus_hero(.jpg/_wide.jpg) gedung BINUS @Bekasi + campus_01..05.jpg fasilitas
├── assets/images/logos/           # binus.png, himti.png (logo resmi)
├── assets/images/lecturers/       # dosen_01..05.jpg (foto resmi dari binus.ac.id/bekasi/csse)
├── assets/video/                  # socs_profile.mp4 (+ poster) — video profil SoCS
├── firestore.rules                # Security Rules Firestore (anti-cheat, privasi no HP, admin)
├── firebase.json                  # menunjuk ke firestore.rules untuk `firebase deploy`
├── docs/Campus_Escape_Master_Sheet.xlsx
├── docs/FIREBASE_SETUP.md         # panduan mode online langkah demi langkah
└── test/
    ├── puzzle_engine_test.dart
    ├── registration_format_test.dart
    └── event_code_test.dart
```

Pembagian layer: `data` (model + storage) → `domain` (logic murni, tanpa Flutter) → `application` (state/Riverpod) → `presentation` (UI). Arah dependency selalu ke bawah; `presentation` tidak pernah menyentuh Hive langsung.

---

## 5. Arsitektur & state management

```
UI (ConsumerWidget) ──ref.watch──▶ Provider (Notifier) ──write-through──▶ LocalStorageService (Hive)
                     ◀──state───┘                       ◀──load saat build──┘
```

| Provider | Tipe | Isi |
|---|---|---|
| `localStorageProvider` | `Provider<LocalStorageService>` | Di-override di `main()` setelah Hive siap |
| `sessionProvider` | `Notifier<PlayerSession>` | Registrasi (`register(teamName, schoolOrigin, avatarIndex)`), `setAvatar`, `setMembers`, `addScore`, `resetToFresh` |
| `roomProgressProvider` | `Notifier<List<RoomProgress>>` | Status 10 ruangan, `markActive`, `addHint`, `completeRoom`, aturan unlock |
| `nextRoomProvider` | `Provider<RoomProgress?>` | Ruangan untuk kartu "Lanjutkan" di Home |
| `completedCountProvider` | `Provider<({int core, int bonus})>` | Hitungan ruangan selesai |
| `insightProvider` | `Notifier<List<UnlockedInsight>>` | Kartu wawasan terbuka + bookmark |
| `leaderboardProvider` / `myRankProvider` | `Provider` | Arsip pemain perangkat ini + pemain saat ini, diurutkan skor |
| `roomSettingsProvider` | `Notifier<RoomSettings>` | Ruangan nonaktif + override XP (admin); turunan `activeRoomsProvider`, `roomTotalsProvider` |
| `adminConfigProvider` | `Notifier<AdminConfig>` | Password panel admin (default `socs2026`, disimpan di box admin) |
| `playerArchiveProvider` | `Notifier<List<PlayerRecord>>` | Arsip semua pemain; `syncCurrent()` dipanggil saat daftar, ruangan selesai, dan sebelum reset — di mode online snapshot yang sama di-upsert ke Firestore |
| `firebaseServiceProvider` / `isOnlineModeProvider` | `Provider` | Di-override di `main()`; `isOnline` = `firebase_options.dart` sudah di-generate & init sukses |
| `eventRepositoryProvider` | `Provider<EventRepository?>` | null di mode lokal — pemakai cukup cek null |
| `currentEventProvider` | `StreamProvider<EventInfo?>` | Acara yang diikuti pemain (pengaturan ruangan + pemenang, real-time). `roomSettingsProvider` otomatis memakai `event.roomSettings` kalau ada |
| `onlinePlayersProvider` | `StreamProvider<List<PlayerRecord>>` | Peserta acara untuk leaderboard online |
| `adminSignedInProvider`, `adminEventsProvider`, `adminEventProvider(code)`, `adminPlayersProvider(code)` | `StreamProvider` | Sisi admin online (instance Firebase 'admin' terpisah) |

Kenapa Riverpod `Notifier` (bukan Bloc/Provider klasik): state per domain kecil dan jelas, tidak butuh codegen, dan provider bisa saling `ref.read` (mis. `completeRoom` → tambah skor sesi + unlock insight) tanpa boilerplate event/state class.

Setiap mutasi memanggil `_persist()` → write-through ke Hive, jadi progres tidak hilang walau app ditutup paksa.

---

## 6. Data model

```
PlayerSession 1 ──── n RoomProgress      (per RoomId)
PlayerSession 1 ──── n UnlockedInsight   (per RoomId yang selesai)
RoomMeta (statis, 10 entri) ── mendefinisikan ── RoomProgress & UnlockedInsight
LeaderboardEntry (snapshot, dummy di v0.2)
```

**RoomMeta** (`room_meta.dart`, statis): `id` (enum `RoomId`), `order` 1–10, `title`, `shortTitle`, `discipline`, `mechanic` (nama mini-game), `accent` (warna ikon/stripe), `icon`, `isBonus`, `xpReward`, `insightTitle`, `insightBody`. Akses lewat `RoomCatalog.all / core / bonus / byId()`.

**RoomProgress**: `roomId`, `status` (`locked | unlocked | active | completed`), `timeSpentSeconds`, `score`, `stars` (1–3), `hintsUsed`, `completedAt`.

**PlayerSession**: `sessionId`, `teamName` (nama lengkap pemain), `schoolOrigin`, `phone` (nomor HP ternormalisasi 08…), `avatarIndex` (0–11 → `RobotAvatars.all`), `members[]` (legacy, selalu kosong sejak 0.9), `createdAt`, `startedAt`, `totalScore`. Turunan: `displayName`, `avatar` (`RobotVariant{name, color}`), `verificationCode` (`CE-<tahun>-<5 char>`, dicetak di sertifikat).

**RobotAvatars** (12 warna dasar): Electric Blue, Coral Blaze, Cyber Mint, Sunny Yellow, Neon Violet, Emerald Tech, Hot Pink, Sky Pulse, Lime Spark, Orange Core, Indigo Byte, Rose Signal. Avatar digambar sebagai ikon robot di kotak berwarna (`RobotAvatar` widget), tanpa aset gambar.

**CampusPhoto / SocsFact** (`socs_fact.dart`, statis): 6 foto (`asset`, `caption`, `description`) dan 10 info SoCS (`title`, `body`, `category` kampus/program/komunitas/prestasi, `sourceUrl`).

**UnlockedInsight**: `roomId`, `unlockedAt`, `isBookmarked`.

Semua model punya `toMap()/fromMap()` dan disimpan di satu Hive box `campus_escape_v2` dengan key `session`, `rooms`, `insights`.

---

## 7. Alur aplikasi & daftar screen

```
Splash ─▶ Landing (nama + sekolah + pilih robot) ─▶ Home ⇄ Peta ⇄ Kampus ⇄ Peringkat ⇄ Profil   ← 5 tab bottom nav
                                          │
                                          ▼
                                   Room screen (×10, tanpa bottom nav)
                                          │ puzzle selesai
                                          ▼
                                   Insight Card ─▶ kembali ke Peta
                                          │ semua ruangan selesai
                                          ▼
                     Ringkasan Akhir ─▶ unduh / preview sertifikat PDF
```

| Route | Screen | Isi |
|---|---|---|
| `/` | Splash | Logo; redirect ke `/home` kalau regu sudah terdaftar, kalau belum ke `/landing` |
| `/landing` | Landing | Headline, 3 stat, "Cara main", foto gedung BINUS @Bekasi (`campus_hero_wide.jpg`) di bagian atas yang memudar ke warna latar (+ logo), form **nama lengkap** (wajib, huruf saja) + **nomor HP** (wajib, keyboard angka, validasi 08xx/+62, contoh 08123456789) + **asal sekolah (SMA/SMK)** (wajib diawali SMA/SMK/SMAN/SMKN/MA/MAN dan ada nama sekolahnya, mis. SMAN 1 Bekasi); judul & tile robot terpilih ikut warna robot, grid **12 robot avatar** — background langsung berubah ikut robot yang dipilih — tombol **Mulai Petualangan** (ditolak + snackbar kalau form belum valid) |
| `/home` | Home | Robot avatar + nama, kartu progres (N/10 + bar 10 segmen + skor), kartu **Lanjutkan** (menampilkan nama mini-game berikutnya), 4 shortcut, **carousel foto kampus berputar tanpa henti** + kartu promo CSSE di bagian bawah |
| `/map` | Peta Jalur | Level map berkelok dari bawah (Ruang 1) ke atas (Bonus 2): node bulat bernomor (selesai teal + bintang, aktif amber + "KAMU DI SINI", terkunci redup + gembok), jalur solid/putus-putus, foto kampus & logo di sisi jalur (tap foto → Galeri); auto-scroll ke node aktif. Semua posisi dihitung dari lebar layar |
| `/collection` | Kampus — Kenali BINUS @Bekasi | Halaman scroll: (1) video profil SoCS — poster + play, kontrol tap & progress bar; teks tentang SoCS/CSSE (akreditasi A BAN-PT, AUN-QA, ASIIN, QS 2024 351–400), (2) Kenapa CSSE: 3 kartu, (3) perjalanan akademik 4 tahun — timeline expandable, (4) foto fasilitas carousel looping (tap → viewer), (5) dosen CSSE (5 orang, foto resmi), (6) HIMTI & kehidupan mahasiswa (logo HIMTI, 4 komisi, agenda 2026, sejarah), (7) 15 fakta singkat bergulir (tap → bottom sheet + salin sumber), (8) daftar sumber |
| `/leaderboard` | Leaderboard | Kartu posisi kamu + selisih XP ke peringkat di atas, daftar regu (dummy) |
| `/profile` | Profil | Robot avatar besar + nama, 4 stat, badge pencapaian, pengaturan (**ganti robot avatar**, ringkasan, reset) |
| `/room/:id` | Room screen | `id` = `RoomId.name`, mis. `/room/algorithm`. Lihat §9 |
| `/insight/:id` | Insight Card | Judul + penjelasan disiplin, XP/bintang/waktu; `?from=gallery` untuk mode baca ulang |
| `/admin` | Panel Admin | Dibuka dari ikon kunci di Home setelah password benar. Ringkasan (pemain, selesai, rata-rata XP), tombol Lihat CSV / Unduh CSV, daftar pemain (tap → detail skor per ruangan), pengaturan ruangan (switch aktif + stepper XP 50–500 step 25, "Kembalikan default"), keamanan (ganti password, reset pemain aktif, hapus arsip) |
| `/admin/login` | Login Admin (online) | Mode online: username + password (Firebase Auth, email sintetis `<username>@admin.campusescape.app`). Sukses → `/admin` menampilkan **daftar acara** (aktif / sudah ditutup: kode, nama, tanggal, jumlah peserta, pemenang; tombol Acara baru = nama kunjungan + kode 3 huruf 3 angka). Tap acara → **detail acara**: kode besar (tap untuk salin), tutup/buka, tetapkan pemenang juara 1 / batalkan, statistik, Lihat CSV / Unduh CSV (dengan no HP), peserta live top-100 (tap → detail + Jadikan pemenang / Hapus), atur ruangan acara ini (real-time ke peserta), hapus semua peserta (hanya saat ditutup), hapus acara |
| `/summary` | Ringkasan Akhir | Predikat (Distinction / Escaped / Explorer / Pemula), skor · ruang · total waktu bermain, kartu sertifikat + ID verifikasi, skor per ruang, tombol **Unduh sertifikat** (share sheet → simpan PDF) dan **Lihat dulu** (preview). PDF: A4 landscape gaya sertifikat kursus — bingkai ganda + ornamen sudut, logo BINUS kiri atas, tanggal, nama, "telah berhasil menyelesaikan N dari 10 ruangan dengan predikat …", judul program, chip bidang yang dijelajahi, penerbit SoCS BINUS @Bekasi + skor, pita kanan (label predikat emas + stempel bulat bertuliskan SCHOOL OF COMPUTER SCIENCE · BINUS @BEKASI dengan logo), ID verifikasi kanan bawah |

Bottom nav hanya muncul di 5 hub screen; room screen, insight, dan summary di-`push` full-screen.

---

## 8. Aturan game: unlock, skor, petunjuk

**Unlock** (`room_progress_provider.dart`) — hanya ruangan **aktif** menurut panel admin:
- Core aktif pertama terbuka sejak awal; core aktif berikutnya terbuka setelah core aktif sebelumnya selesai.
- Bonus room aktif terbuka bersamaan setelah **semua core aktif** selesai.
- Ruangan yang dinonaktifkan admin selalu terkunci, tidak tampil di peta, dan tidak dihitung di total/sertifikat.
- Masuk ruangan → status `active` (badge "Lanjut" di peta). Selesai → `completed`.

**Skor** (`ScoreCalculator` di `puzzle_engine.dart`):

```
skor    = base − (hint × 25) − (salah × 10)
base    = RoomMeta.xpReward (200 core, 150 AI, 200 Cyber), bisa diubah admin per ruangan (50-500)
clamp   = [base/2, base]          ← tidak ada bonus waktu
bintang = 3 (tanpa hint, ≤1 salah) · 2 (≤1 hint, ≤3 salah) · 1 (sisanya)
```

Skor masuk ke `PlayerSession.totalScore` hanya saat ruangan **pertama kali** selesai; main ulang hanya bisa memperbaiki bintang, tidak menambah XP.

**Waktu:** tidak ada countdown / batas waktu. `RoomScaffold` hanya mencatat lama bermain per ruangan (`timeSpentSeconds`) untuk statistik di Insight Card dan Ringkasan Akhir.

**Petunjuk bertingkat:** tiap ruangan punya 3 hint, dari umum ke hampir-jawaban. Setiap hint *baru* yang dibuka = penalti 25 XP; membaca ulang hint yang sudah terbuka gratis. Tombol reset mengulang puzzle tanpa menghapus hitungan hint/salah.

---

## 9. 10 ruangan — mekanik per ruangan

Semua ruangan memakai kerangka yang sama (`RoomScaffold`): top bar (back, nama ruang, label mini-game) → stripe accent → progress tahap → kartu brief cerita → **area mini-game** → banner status → dock tombol (Petunjuk · Reset · **Cek Jawaban**). Setelah benar, tombol berubah teal "Pintu terbuka — lanjut" → Insight Card.

Tiap ruangan adalah mini-game yang berbeda; tidak ada lagi tipe "susun urutan" generik. Jawaban lengkap + 3 hint per ruangan ada di `docs/Campus_Escape_Master_Sheet.xlsx`. `RoomScaffold.onCheck` boleh `async` (`FutureOr<RoomCheck>`), dipakai ruang Algoritma untuk menganimasikan robot sebelum menilai.

| # | Ruangan | Tipe | Accent | Mini-game | Cara main | Jawaban | Pelajaran (ramah awam) | XP |
|---|---|---|---|---|---|---|---|---|
| 1 | **Algoritma & Logika** | Core | `#60A5FA` | **Robot Pengantar** | Susun perintah panah (maks. 8) supaya robot sampai ke tujuan di grid 4×3 tanpa menabrak tembok. Tombol utama **Jalankan Robot**: robot bergerak dulu, baru hasil (sampai / menabrak / berhenti) muncul | ↑ ↑ → → → | Algoritma = urutan perintah yang jelas untuk komputer | 200 |
| 2 | **UI/UX Design** | Core | `#F472B6` | **Mana yang lebih enak dipakai?** | 3 ronde A/B: pilih mockup (tombol, teks, menu) yang lebih mudah dipakai | A, B, A | UI/UX = merancang supaya orang tidak bingung | 200 |
| 3 | **Data Science** | Core | `#38BDF8` | **Sortir Data** | 6 kartu pendaftar muncul; **Simpan** yang valid, **Buang** yang rusak (umur 250, nama kosong, umur −3). Grafik muncul setelah data bersih | Simpan: Aisyah, Citra, Dion · Buang: Bima, (kosong), Eka | Data harus dibersihkan dulu sebelum dibaca | 200 |
| 4 | **Game Development** | Core | `#E879F9` | **Lompat Tepat Waktu** | Penanda bergerak bolak-balik; tekan **Lompat** saat berada di zona hijau, 3× berhasil | 3 kali tepat (zona 40–60%) | Game = loop input → update → render, timing itu kuncinya | 200 |
| 5 | **Mobile App Development** | Core | `#A3E635` | **Rakit Layar Aplikasi** | Tap 4 bagian (judul, gambar, teks, tombol) ke dalam bingkai HP sesuai urutan dari atas | Judul → Gambar → Teks → Tombol | Layar app disusun dari widget yang ditumpuk | 200 |
| 6 | **Jaringan Komputer** | Core | `#FB7185` | **Antar Paket** | Tap node topologi berurutan untuk mengantar paket dari Lab ke Server; Router B mati (jebakan). Panel penjelasan di bawah berubah tiap langkah dan jadi petunjuk halus ("Router B sedang mati") | Lab → Router A → Switch → Server | Data lewat beberapa perangkat sebelum sampai | 200 |
| 7 | **Software Engineering** | Core | `#818CF8` | **Cari Bug** | 6 baris pseudo-code kelulusan; tap baris yang salah lalu pilih perbaikannya | Baris 3 `jika nilai < batas_lulus` → ganti `>=` | Software engineer membaca kode & memperbaiki bug | 200 |
| 8 | **Database Systems** | Core | `#FACC15` | **Cocokkan Data** | Sambungkan kabel dari 6 siswa ke 5 kelas lewat nomor `kelas_id` ↔ `id`; kabel melengkung digambar antar kartu; posisi kartu **diacak** tiap buka/reset | Aisyah & Dion→X IPA 1 (10), Bima→X IPA 2 (11), Citra→X IPS 1 (12), Eka→XI IPA 1 (13), Fajar→XI IPS 2 (14) | Database menyimpan data di tabel yang saling terhubung | 200 |
| 9 | **AI & Machine Learning** | Bonus | `#A78BFA` | **Latih AI-mu** | 2 tahap: **Latih** 10 contoh acak (jawaban langsung dikoreksi) → **Uji** 15 contoh baru tanpa koreksi; 5 hewan (Kucing, Anjing, Burung, Ikan, Kelinci), 30 ciri di pool | Lulus jika ≥ 11/15 benar; kunci per ciri ada di master sheet | AI dilatih dengan data berlabel lalu diuji dengan data baru | 150 |
| 10 | **Cyber Security** (Final Vault) | Bonus | `#F97316` | **Pecahkan Sandi** | Jarak geser **diacak 1–10** tiap buka/reset; geser (maks 10 putaran) sampai terbaca, lalu pilih password paling kuat | Kata rahasia selalu `BINUS` (mis. shift 3 → `ELQXV`, shift 7 → `IPUBZ`); password `Kampus@Bekasi#2026` | Sandi & password kuat melindungi data | 200 |

Pesan salah bersifat mengarahkan, bukan memberi jawaban (mis. "Robotmu menabrak tembok di langkah ke-3").

---

## 10. Design system

Acuan lengkap ada di **`DESIGN.md`**. Ringkasan yang dipakai di kode (`lib/core/theme/`):

| Token | Nilai | Pemakaian |
|---|---|---|
| `ground` | `#0B1220` | Background semua screen |
| `surface` / `surfaceRaised` / `surfaceDim` | `#131C2E` / `#1B2740` / `#0F1829` | Card / card aktif / bottom nav |
| `outline` | `#2A3850` | Border 1px |
| `accent` + `onAccent` | `#F5A524` + `#0B1220` | **Hanya** tombol utama, state aktif, badge "Lanjut", nav aktif |
| `success` | `#2DD4BF` | Progress, jalur & node selesai di peta, puzzle benar |
| `warning` / `danger` | `#FBBF24` / `#FDA4AF` | Banner belum lengkap / salah |
| Accent ruangan | lihat tabel §9 | **Hanya** stripe 3px di card + ikon + outline drag |
| Font | Space Grotesk 700 (judul, angka) · Manrope (body, label, tombol) · JetBrains Mono (kode) | |
| Background dinamis | `AppColors.tintedGround(avatarColor)` = `ground` dicampur 13% warna robot | `AppTheme.tinted(tint)` dipilih di `app.dart` dari `sessionProvider`; komponen yang perlu warna latar memakai `Theme.of(context).scaffoldBackgroundColor` |
| Spacing / radius | skala 4px; padding screen 24px; card 14–16; tombol 54px r16; pill 999 | `AppSpacing`, `AppRadius`, `AppSize` |

Aturan keras: tidak ada gradient, shadow, glow, atau emoji; foto **hanya** dipakai sebagai konten (Galeri, carousel Home), bukan dekorasi. Angka literal warna/spacing di widget dilarang — pakai token.

---

## 11. Cara menambah / mengubah ruangan

**Mengubah isi ruangan yang ada** (cerita, jawaban, hint): semuanya ada di file ruangan itu di `lib/presentation/screens/rooms/` — konstanta di bagian atas file (mis. `_goal`, `_walls`, `_answer`, `_hints`, `_goodSide`). Nama mini-game & teks insight ada di `room_meta.dart`. Setelah mengubah jawaban, perbarui juga `docs/Campus_Escape_Master_Sheet.xlsx`.

**Menambah ruangan baru:**
1. Tambah nilai di enum `RoomId` dan entri `RoomMeta` di `RoomCatalog.all` (`room_meta.dart`) — `order`, `mechanic`, warna accent, ikon, teks insight.
2. Buat `xxx_room_screen.dart` (`StatefulWidget`) yang membungkus mini-game-nya dengan `RoomScaffold`: isi `meta`, `storyLead`, `storyBody`, `hints` (3 string), `body`, dan `onCheck()` yang mengembalikan `RoomCheckIncomplete | RoomCheckWrong(message) | RoomCheckCorrect(feedback)`. Skor, hint bertingkat, waktu, dan penyelesaian diurus scaffold.
3. Daftarkan di `roomScreenFor()` di `app_router.dart` (switch exhaustive, analyzer akan mengingatkan).
4. Tambah satu baris di `_xs` (posisi horizontal node) di `campus_map_screen.dart` kalau jumlah ruangan berubah.
5. Ganti nama Hive box di `local_storage_service.dart` (mis. `campus_escape_v3`) supaya data progres lama tidak bentrok.

Home, Kampus, Summary, sertifikat, dan aturan unlock otomatis mengikuti `RoomCatalog`.

**Mengubah isi tab Kampus:** foto fasilitas dan 15 fakta singkat di `socs_fact.dart` (`CampusPhotos.all`, `SocsFactCatalog.all`); teks tentang SoCS, Kenapa CSSE, perjalanan akademik, dosen, HIMTI, dan daftar sumber di `socs_profile.dart`. Setiap klaim wajib punya sumber resmi yang bisa diverifikasi.

---

## 11b. Responsif & platform

- Semua layout dihitung dari lebar layar (`MediaQuery.sizeOf` / `LayoutBuilder`), bukan angka tetap: peta, carousel, bingkai HP di ruang Mobile Dev, topologi jaringan, tombol hewan di ruang AI, kolom kabel di ruang Database. Skala font sistem dibatasi 0,85–1,15 di `app.dart` supaya mini-game tetap muat di HP kecil maupun saat pengguna memperbesar font.
- Di web (`flutter run -d chrome`) lebar dikunci 430 px dan `MediaQuery.size` ikut dikunci, jadi tampilannya sama seperti di HP.
- **Android:** `minSdk` mengikuti default Flutter (21+). Tidak ada permission tambahan — sertifikat dibagikan lewat share sheet (`printing`), tidak menulis ke storage langsung.
- **Windows (.exe):** app dibingkai 430 px di tengah window (`_isWideScreenPlatform` di `app.dart`), window default 470×900. `video_player` belum mendukung Windows → kartu video menampilkan pesan, sisanya (Firebase, CSV, sertifikat) berjalan normal. Nama binary `CampusEscape.exe` (`windows/CMakeLists.txt`).
- **iOS:** folder `ios/` sudah ada; `Podfile` dibuat otomatis saat `flutter build ios` / `flutter run` pertama di macOS (butuh Xcode + CocoaPods). Paket `printing` memerlukan iOS 11+, sudah dipenuhi default Flutter. Preview & share PDF memakai share sheet bawaan iOS. Build iOS hanya bisa dilakukan di macOS; kode Dart-nya sama persis.

---

## 12. Testing

```bash
flutter test
```

`test/registration_format_test.dart` menguji `PhoneFormat` (08/+62/62, panjang 10–13, normalisasi, tampilan), `NameFormat.validateFullName`, dan `NameFormat.validateSchool`. `test/puzzle_engine_test.dart` menguji logic murni: `ScoreCalculator` (penalti hint/salah, clamp, bintang), `CipherEngine` (shift & wrap-around), `SequenceEvaluator` (utilitas urutan). Engine sengaja dibuat tanpa dependency Flutter supaya bisa diuji tanpa widget.

Checklist manual sebelum demo:
- [ ] Landing: nama kosong / HP salah format / sekolah kosong → pesan error, tidak bisa lanjut; pilih robot → background Landing berubah; setelah Mulai, background Home/Peta/Kampus ikut warna robot; ganti robot di Profil → background ikut berubah
- [ ] Peta: hanya Ruang 1 terbuka + pill "KAMU DI SINI"; selesaikan → garis hijau, Ruang 2 terbuka, Insight Card muncul
- [ ] Setiap ruangan: jawaban salah → banner merah, hint 1→2→3 → skor turun 25 tiap hint baru, reset → mini-game kosong
- [ ] Kampus: video bisa diputar/pause, di-seek, dan suaranya bisa di-mute/unmute (ikon speaker); foto dosen tampil; carousel fasilitas berputar sendiri; timeline tahun bisa dibuka-tutup; fakta bergulir, berhenti saat disentuh; tombol salin sumber bekerja
- [ ] Peta: node bernomor + jalur berkelok, foto/logo di sisi jalur tidak menutupi label node (cek di HP kecil 360 px dan besar)
- [ ] Ruang 1: tekan "Jalankan Robot" → robot bergerak dulu, hasil muncul setelah animasi
- [ ] Ruang 8: posisi kartu beda tiap reset; kabel muncul saat pasangan dibuat
- [ ] Ruang 9: setelah 10 latihan tombol jadi "Uji AI"; uji 15 soal; < 11 benar → bisa perbaiki lalu uji ulang
- [ ] Ruang 10: angka geser mentok di 10; sandi berbeda tiap reset
- [ ] Home: carousel foto berputar sendiri, bisa digeser terus (loop), dot indikator ikut
- [ ] Tutup paksa app → progres tetap
- [ ] Selesaikan 8 core → bonus terbuka; selesaikan semua → Home menampilkan kartu "Semua ruangan terbuka" → Summary
- [ ] Summary: "Lihat dulu" membuka preview PDF (logo BINUS kiri atas, pita + stempel di kanan, chip bidang sesuai ruangan yang selesai); "Unduh sertifikat" membuka share sheet dan file PDF tersimpan/terkirim
- [ ] Profil → Ganti robot avatar → berubah di Home; Reset progres → kembali ke Landing
- [ ] Online (setelah `flutterfire configure` + deploy rules): Landing menampilkan "Kode acara"; kode salah ditolak; kode benar → Home menampilkan banner acara; selesai 1 ruangan → muncul di Peserta live admin & leaderboard HP lain; admin matikan ruangan → peta peserta berubah tanpa restart; "Pemenang: juara 1" → banner di semua HP; "Tutup acara" → skor baru tidak masuk; Unduh CSV berisi no HP
- [ ] Admin lokal (build tanpa Firebase): ikon kunci di Home → password salah ditolak, `socs2026` masuk; daftar pemain berisi pemain aktif; Lihat CSV membuka tabel; Unduh CSV membuka share sheet dengan file .csv; matikan Ruang 2 → peta tinggal 9 node dan Ruang 3 terbuka setelah Ruang 1; ubah XP Ruang 1 → skor saat selesai ikut; ganti password → password lama ditolak; setelah Reset pemain aktif, pemain lama masih ada di daftar admin & leaderboard

---

## 13. Yang belum dikerjakan & roadmap

| Item | Status | Catatan |
|---|---|---|
| Logo SoCS | Belum | Hanya BINUS & HIMTI yang ada; logo SoCS bisa ditambah di `BrandLogos` kalau tersedia |
| Leaderboard lintas perangkat | **Selesai (0.9)** | Mode online via Firestore per acara; butuh `flutterfire configure` + deploy rules |
| Password admin lokal | Plain di Hive | Hanya untuk mode lokal/booth; mode online memakai Firebase Auth (username+password) + rules |
| App Check (Play Integrity) | Belum | Hardening opsional: tolak request dari luar APK resmi. Lihat `docs/FIREBASE_SETUP.md` §8 |
| Skala ribuan peserta | Siap (0.9) | Leaderboard top-50 + peringkat via count aggregate; admin top-100 + aggregate; ekspor per 500. Untuk >ribuan peserta per hari perlu paket Blaze — `docs/FIREBASE_SETUP.md` §7 |
| Admin Dashboard lanjutan | Sebagian | Panel admin online sudah ada (acara, peserta live, pemenang, ekspor, ruangan per acara). Belum: heatmap ruangan tersulit, dashboard web |
| Sertifikat: logo resmi | Selesai | Logo BINUS resmi dicetak di kanan atas; kalau file tidak ada, otomatis diganti badge teks |
| Font offline | Belum | Lihat §3 |
| Animasi transisi "pintu terbuka" | Belum | Sesuai design system: tanpa glow/blur, boleh motion sederhana |
| Light mode | Tidak direncanakan | Design system dark-only |

Fase: **1** 10 mini-game + progres lokal + sertifikat PDF ✔ → **2** leaderboard online per acara + panel admin online ✔ (0.9) → **3** dashboard web / analitik.

---

## 14. Dokumen terkait

| Dokumen | Isi |
|---|---|
| `DESIGN.md` | Design system final (token warna, tipografi, komponen, aturan) — juga bisa dipakai sebagai DESIGN.md di Google Stitch |
| `Campus Escape - Master Documentation.md` | Dokumen produk versi awal (6 ruangan, visual lama). Referensi sejarah; kalau bertentangan dengan README ini, README/DESIGN.md yang berlaku |
| Project Claude "Internship" → `claude/catatan-keputusan.md` | Log keputusan produk & teknis |
| Project Claude "Internship" → canvas "Campus Escape UI v0.9" | Desain hi-fi 27 screen (artboard HTML) — diimpor ke Figma via plugin html.to.design |
| `docs/FIREBASE_SETUP.md` | Panduan mode online: project Firebase, `flutterfire configure`, akun admin username+password, deploy rules, alur hari-H, troubleshooting |
| `firestore.rules` | Security Rules (sumber kebenaran untuk keamanan mode online) |
| `docs/Campus_Escape_Master_Sheet.xlsx` | Master sheet panitia: info 10 ruangan + mini-game, kunci jawaban (termasuk kunci per ciri hewan & aturan acak), petunjuk, pesan feedback, aturan skor (dengan simulasi), 15 info Galeri, alur & unlock, **Panel Admin** (password & cara pakai) |

---

Dibuat oleh Kevin Aprilio — Software Engineering, BINUS University · Internship Enrichment 2026.
