# Setup Mode Online (Firebase) — Campus Escape

Mode online membuat satu APK yang dibagikan panitia ke peserta bisa:

- peserta main di HP masing-masing, masuk dengan **kode acara** (1 kode per kunjungan sekolah),
- skor tiap ruangan langsung masuk **leaderboard acara** (real-time),
- panitia memantau dari **panel admin online** (login username + password), menetapkan pemenang
  dari leaderboard, mengatur ruangan per acara, dan mengekspor CSV (lihat di app atau unduh file) lengkap dengan no HP.

Kalau langkah di bawah **belum** dijalankan, app tetap jalan 100% dalam **mode lokal**
(tanpa kode acara; panel admin pakai password lokal `socs2026`). Tidak ada yang rusak.

> Backend: Firebase **Firestore** (database) + **Firebase Auth** (login). Paket Spark (gratis)
> cukup untuk kunjungan sekolah (kuota harian 50k read / 20k write).

---

## 1. Buat project Firebase (sekali)

1. Buka <https://console.firebase.google.com> → **Add project** → nama bebas, mis. `campus-escape`.
   Google Analytics boleh dimatikan.
2. Di menu **Build → Firestore Database** → **Create database** → pilih lokasi
   `asia-southeast2 (Jakarta)` → mode **production** (rules kita deploy sendiri di langkah 4).
3. Di menu **Build → Authentication** → **Get started** → tab **Sign-in method**, aktifkan dua provider:
   - **Anonymous** (untuk peserta — tidak ada data pribadi di Auth),
   - **Email/Password** (untuk admin — username dipetakan ke email sintetis, lihat §3).

## 2. Hubungkan app Flutter (`flutterfire configure`)

Butuh Node.js (untuk Firebase CLI). Jalankan di terminal (Git Bash), dari folder project:

```bash
npm install -g firebase-tools
firebase login                       # buka browser, login akun Google yang punya project
dart pub global activate flutterfire_cli
flutterfire configure                # pilih project → centang android & ios → Enter
flutter pub get
```

`flutterfire configure` **menimpa** `lib/firebase_options.dart` (yang sekarang placeholder) dan
mendaftarkan app Android (`com.campusescape.campus_escape`) + iOS di project. Setelah file itu
berisi `projectId` sungguhan, app otomatis masuk **mode online** — tidak ada flag lain.

> Kalau `flutterfire` tidak dikenali di Git Bash: tambahkan `%LOCALAPPDATA%\Pub\Cache\bin` ke PATH
> (Windows), lalu buka terminal baru.

## 3. Buat akun admin (username + password, tanpa email)

Admin login di app dengan **username + password**. Di balik layar, username dipetakan ke email
sintetis `<username>@admin.campusescape.app` — jadi panitia tidak perlu punya/ingat email, dan
akun tidak bisa dibuat dari dalam app (hanya dari Console ini).

1. **Authentication → Users → Add user**
   - Email: `panitia@admin.campusescape.app`  (= username `panitia`; huruf kecil, 3–24 karakter, boleh `.` dan `_`)
   - Password: **minimal 8 karakter, pakai angka & huruf** — ini satu-satunya kunci panel admin online.
   - Klik **Add user**, lalu **salin UID**-nya (kolom User UID).
2. **Firestore Database → Start collection**
   - Collection ID: `admins`
   - Document ID: *tempel UID tadi*
   - Field: `username` (string) = `panitia`
   - Save.

Tanpa dokumen `admins/{uid}`, login akan ditolak app ("belum terdaftar sebagai admin") dan rules
juga menolak semua aksi admin — jadi akun Email/Password lain tidak otomatis jadi admin.

Ulangi untuk tiap panitia (boleh beberapa admin). Ganti password: Console → Users → ⋮ → Reset password,
atau hapus user dan buat lagi.

## 4. Deploy Firestore Security Rules (WAJIB)

Rules ada di `firestore.rules` (root project) dan `firebase.json` sudah menunjuk ke sana.

```bash
firebase use --add          # pilih project, alias: default
firebase deploy --only firestore:rules
```

Cek di Console → Firestore → **Rules**: isinya harus sama dengan file `firestore.rules`.
Rules bisa diuji di tab **Rules playground** (mis. coba update `events/X/players/Y` dengan uid lain → harus ditolak).

Yang dijaga rules (ringkas; detail ada di komentar file):

| Ancaman | Cegahan |
|---|---|
| Ubah skor orang lain | Dokumen pemain hanya bisa ditulis oleh uid pemiliknya (login anonim). |
| Naikkan skor sendiri lewat script/APK modifikasi | Skor tidak boleh turun; kenaikan hanya kalau ada ruangan baru selesai, maks 500 XP per ruangan; total ≤ ruangan selesai × 500; nama/sekolah dikunci setelah daftar. |
| Spam setelah acara selesai | Write ditolak kalau `events/{code}.active == false` (panitia tutup acara / sudah ada pemenang). |
| Menebak kode acara | Peserta tidak bisa `list` koleksi `events`, hanya `get` per kode (3 huruf + 3 angka ≈ 13,8 juta kombinasi, dan Firebase membatasi laju request). |
| Baca no HP peserta | No HP disimpan di `events/{code}/private/{uid}` — hanya pemilik & admin. Leaderboard tidak pernah memuatnya. |
| Jadi admin tanpa izin | Admin = provider `password` **dan** ada dokumen `admins/{uid}`; dokumen itu tidak bisa ditulis dari app. |
| Brute-force password admin | Firebase Auth otomatis membatasi percobaan (`too-many-requests`). Pakai password panjang. |
| API key Firebase di APK | Normal & memang publik; keamanan Firebase bergantung pada rules + Auth, bukan kerahasiaan key. Hardening tambahan: §8. |

## 5. Build & bagikan APK

```bash
flutter build apk --release
# hasil: build/app/outputs/flutter-apk/app-release.apk
```

Bagikan file APK itu ke peserta (WhatsApp/Drive/QR link). Peserta install → buka → masukkan **kode acara**
+ nama, no HP, sekolah → main. Butuh internet saat daftar (validasi kode) dan saat skor dikirim;
kalau sinyal putus di tengah, skor diantre dan terkirim otomatis begitu online lagi.

## 6. Alur hari-H untuk panitia

1. Buka app di HP panitia → di halaman daftar tekan ikon **kunci** di kanan atas (juga ada di Home) → **Login Admin** (username + password).
2. **Acara baru** → isi nama kunjungan (mis. "Kunjungan SMAN 1 Bekasi") dan **kode acara** 3 huruf + 3 angka (mis. `ABC321`; ada tombol acak untuk saran) → Buat.
   Tulis di layar/papan atau bacakan ke peserta.
3. Pantau **Peserta live** (urut skor, otomatis bergerak). Tap peserta → detail skor per ruangan.
4. (Opsional) **Atur ruangan acara ini** — matikan ruangan / ubah XP; berlaku real-time ke semua HP peserta.
5. Selesai: tekan **Pemenang: juara 1** (atau pilih peserta → *Jadikan pemenang*). Banner pemenang
   muncul di Home & Leaderboard semua peserta.
6. **Tutup acara** supaya tidak ada skor masuk lagi, lalu **Lihat CSV** / **Unduh CSV** untuk arsip.
   Peserta yang masih main setelah acara ditutup tetap bisa main (progres lokal), tapi skornya tidak tersimpan ke leaderboard.
7. Setelah data diunduh: **Hapus semua peserta acara ini** (hanya aktif saat acara sudah ditutup) untuk membersihkan server; acaranya sendiri tetap ada dan bisa dibuka lagi.

Pemain yang HP-nya tidak punya internet sama sekali: tetap bisa main (progres lokal), tapi tidak
masuk leaderboard acara — panitia bisa cek skornya langsung di Profil HP tersebut.

## 7. Skala: ribuan peserta bersamaan

Firestore sendiri tidak punya batas praktis untuk 10.000 dokumen peserta (batas koneksi real-time
1 juta per database). Yang diatur app supaya tetap ringan & murah saat ribuan HP main bersamaan:

- **Leaderboard peserta hanya men-stream TOP-50**; peringkat & total peserta tiap HP dihitung lewat
  *count aggregate* (2 read kecil), bukan mengunduh semua dokumen.
- **Panel admin**: daftar live TOP-100, sedangkan jumlah peserta / selesai / rata-rata XP memakai
  *aggregate* (`count`, `average`) sehingga akurat untuk seluruh peserta.
- **Ekspor** membaca per halaman 500 dokumen sampai habis.
- Tiap peserta hanya menulis dokumennya sendiri (±1 write per ruangan selesai).

Perkiraan beban untuk 10.000 peserta dalam satu acara: ±10.000 write registrasi + ±100.000 write skor
(10 ruangan), dan read untuk leaderboard ±50 dokumen per HP + update saat TOP-50 bergerak. Ini
**melebihi kuota gratis Spark** (20k write & 50k read per hari). Untuk acara sebesar itu, upgrade project
ke paket **Blaze** (bayar sesuai pemakaian; tarif Firestore ±$0,06 per 100k read dan ±$0,18 per 100k
write — cek harga terkini di https://firebase.google.com/pricing). Kunjungan sekolah biasa (ratusan
peserta) masih muat di Spark.

## 8. Hardening tambahan (opsional, kalau nanti dibutuhkan)

- **App Check (Play Integrity)** — menolak request dari selain APK resmi (mis. script di laptop).
  Paket `firebase_app_check`, aktifkan di Console → App Check, dan daftarkan *debug token* untuk emulator.
  Belum dipasang supaya pengujian di emulator tetap gampang.
- **Nonaktifkan Anonymous auth di luar hari acara** (Console → Authentication → Sign-in method) —
  mencegah pendaftaran peserta di luar jam acara.
- **Hapus acara uji coba** dari panel admin supaya kuota & leaderboard bersih.

## 9. Troubleshooting

| Gejala | Penyebab / solusi |
|---|---|
| Landing tidak menampilkan kolom "Kode acara" | `firebase_options.dart` masih placeholder → jalankan §2. |
| "Kode acara tidak ditemukan" padahal benar | Acara dihapus, atau rules belum di-deploy (§4), atau HP offline. |
| Login admin: "belum terdaftar sebagai admin" | Dokumen `admins/{uid}` belum dibuat (§3 langkah 2) — cek UID-nya sama persis. |
| Login admin: "Username atau password salah" | Email di Console harus `<username>@admin.campusescape.app` (huruf kecil). |
| Skor peserta tidak naik di panel admin | Acara sudah **ditutup**, atau update ditolak rules (cek Console → Firestore → Usage/Rules). |
| `PERMISSION_DENIED` di logcat | Rules belum di-deploy / beda dengan `firestore.rules`. |
| Build Android gagal soal `minSdkVersion` | Firebase Auth butuh `minSdk 23`; `android/app/build.gradle.kts` sudah memakai `maxOf(23, flutter.minSdkVersion)`. |
| Build iOS lama sekali | Normal untuk Firestore (pod besar). Pastikan `platform :ios, '15.0'` di `ios/Podfile`. |
