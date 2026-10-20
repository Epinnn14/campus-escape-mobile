// PLACEHOLDER — file ini akan DITIMPA oleh `flutterfire configure`.
//
// Jalankan di folder project (butuh Node.js + Firebase CLI, lihat
// docs/FIREBASE_SETUP.md):
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Selama projectId masih 'PLACEHOLDER', app berjalan dalam MODE LOKAL
// (tanpa kode acara, leaderboard online, dan panel admin online) — semua
// fitur booth tetap jalan seperti biasa. Deteksinya ada di
// FirebaseService.isConfigured (cek projectId), jadi file hasil generate
// flutterfire tidak perlu diubah apa pun.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'PLACEHOLDER',
        appId: 'PLACEHOLDER',
        messagingSenderId: 'PLACEHOLDER',
        projectId: 'PLACEHOLDER',
      );
}
