import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../models/event_info.dart';

/// Hasil login admin (dipakai UI untuk pesan error yang ramah).
enum AdminLoginError { invalidUsername, wrongCredential, notAdmin, network, unknown }

class AdminLoginException implements Exception {
  final AdminLoginError error;
  final String message;
  const AdminLoginException(this.error, this.message);
  @override
  String toString() => message;
}

/// Pintu masuk ke Firebase. Dibuat SEKALI di main() lalu dibagikan lewat
/// `firebaseServiceProvider`.
///
/// Dua "aplikasi" Firebase di satu perangkat:
/// - app DEFAULT  → peserta (login anonim, tanpa data pribadi di Auth).
/// - app 'admin'  → admin (username + password). Dipisah supaya admin
///   bisa login di HP yang sama tanpa menimpa sesi anonim peserta.
///
/// Kalau `firebase_options.dart` masih placeholder atau init gagal,
/// [isOnline] = false dan seluruh app jalan dalam mode lokal (Hive saja).
class FirebaseService {
  FirebaseService._();

  static const String adminAppName = 'campus-escape-admin';

  FirebaseApp? _app;
  FirebaseApp? _adminApp;
  bool _initialized = false;

  /// true kalau `flutterfire configure` sudah dijalankan (projectId bukan
  /// placeholder). Dicek tanpa menyentuh plugin native.
  static bool get isConfigured {
    try {
      final o = DefaultFirebaseOptions.currentPlatform;
      return o.projectId.isNotEmpty && o.projectId != 'PLACEHOLDER';
    } catch (_) {
      // Platform belum di-generate flutterfire (mis. web) → mode lokal.
      return false;
    }
  }

  bool get isOnline => _initialized && _app != null;

  /// Inisialisasi aman: tidak pernah melempar — app tetap jalan offline.
  static Future<FirebaseService> init() async {
    final svc = FirebaseService._();
    if (!isConfigured) return svc;
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      svc._app = await Firebase.initializeApp(options: options);
      svc._adminApp = await _initNamed(adminAppName, options);
      svc._initialized = true;
      // Cache offline bawaan Firestore: skor tetap terkirim begitu sinyal
      // kembali (antrean write dijaga urutannya oleh SDK).
      svc.firestore.settings = const Settings(persistenceEnabled: true);
    } catch (e, st) {
      debugPrint('Firebase init gagal, lanjut mode lokal: $e\n$st');
      svc._app = null;
      svc._adminApp = null;
      svc._initialized = false;
    }
    return svc;
  }

  static Future<FirebaseApp> _initNamed(String name, FirebaseOptions options) async {
    try {
      return Firebase.app(name);
    } catch (_) {
      return Firebase.initializeApp(name: name, options: options);
    }
  }

  // ---------------------------------------------------------------- peserta

  FirebaseFirestore get firestore => FirebaseFirestore.instanceFor(app: _app!);
  FirebaseAuth get _auth => FirebaseAuth.instanceFor(app: _app!);

  /// UID peserta yang sedang login anonim (null kalau belum/offline).
  String? get participantUid => isOnline ? _auth.currentUser?.uid : null;

  /// Pastikan ada sesi anonim. [fresh] = paksa UID baru (dipakai saat
  /// registrasi pemain baru supaya dokumen pemain lama tidak tertimpa).
  Future<String> ensureParticipant({bool fresh = false}) async {
    if (!isOnline) throw StateError('Firebase belum dikonfigurasi');
    final current = _auth.currentUser;
    if (current != null && !fresh) return current.uid;
    if (current != null) {
      // Kirim dulu write yang masih antre milik UID lama (mis. skor pemain
      // sebelumnya di HP ini) supaya tidak terkirim dengan token UID baru.
      try {
        await firestore.waitForPendingWrites().timeout(const Duration(seconds: 5));
      } catch (_) {
        // Offline / lambat: lanjut saja, write lama akan ditolak rules (aman).
      }
      await _auth.signOut();
    }
    final cred = await _auth.signInAnonymously().timeout(const Duration(seconds: 15));
    return cred.user!.uid;
  }

  // ------------------------------------------------------------------ admin

  FirebaseFirestore get adminFirestore => FirebaseFirestore.instanceFor(app: _adminApp!);
  FirebaseAuth get _adminAuth => FirebaseAuth.instanceFor(app: _adminApp!);

  /// Username admin yang sedang login (null = belum login).
  String? get adminUsername => isOnline ? AdminUsername.fromEmail(_adminAuth.currentUser?.email) : null;
  String? get adminUid => isOnline ? _adminAuth.currentUser?.uid : null;
  bool get isAdminSignedIn => adminUid != null;

  /// Stream perubahan sesi admin (login/logout) untuk UI.
  Stream<bool> get adminSignedInStream =>
      isOnline ? _adminAuth.authStateChanges().map((u) => u != null) : Stream.value(false);

  /// Login admin dengan username + password. Username dipetakan ke email
  /// sintetis (lihat [AdminUsername.toEmail]); akun dibuat sekali oleh
  /// pengelola di Firebase Console (lihat docs/FIREBASE_SETUP.md).
  /// Setelah login, dicek juga dokumen `admins/{uid}` — tanpa dokumen itu
  /// akun dianggap bukan admin dan langsung di-logout.
  Future<String> adminSignIn({required String username, required String password}) async {
    if (!isOnline) {
      throw const AdminLoginException(AdminLoginError.network, 'Mode online belum aktif di build ini.');
    }
    final user = AdminUsername.normalize(username);
    if (!AdminUsername.isValid(user)) {
      throw const AdminLoginException(
        AdminLoginError.invalidUsername,
        'Username 3–24 karakter: huruf kecil, angka, titik, atau garis bawah.',
      );
    }
    try {
      final cred = await _adminAuth
          .signInWithEmailAndPassword(email: AdminUsername.toEmail(user), password: password)
          .timeout(const Duration(seconds: 20));
      final uid = cred.user!.uid;
      final doc = await adminFirestore.collection('admins').doc(uid).get(const GetOptions(source: Source.server));
      if (!doc.exists) {
        await _adminAuth.signOut();
        throw const AdminLoginException(
          AdminLoginError.notAdmin,
          'Akun ini belum terdaftar sebagai admin (dokumen admins/{uid} belum dibuat).',
        );
      }
      return user;
    } on AdminLoginException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
        case 'invalid-email':
        case 'user-disabled':
          throw const AdminLoginException(AdminLoginError.wrongCredential, 'Username atau password salah.');
        case 'too-many-requests':
          throw const AdminLoginException(
            AdminLoginError.wrongCredential,
            'Terlalu banyak percobaan. Tunggu beberapa menit lalu coba lagi.',
          );
        case 'network-request-failed':
          throw const AdminLoginException(AdminLoginError.network, 'Tidak ada koneksi internet.');
        default:
          throw AdminLoginException(AdminLoginError.unknown, 'Gagal login (${e.code}).');
      }
    } on TimeoutException {
      throw const AdminLoginException(AdminLoginError.network, 'Koneksi lambat — coba lagi.');
    } on FirebaseException catch (e) {
      // Biasanya permission-denied saat baca admins/{uid} (rules belum di-deploy).
      await _adminAuth.signOut();
      throw AdminLoginException(AdminLoginError.notAdmin, 'Tidak bisa memverifikasi admin (${e.code}). Cek Firestore Rules.');
    }
  }

  Future<void> adminSignOut() async {
    if (!isOnline) return;
    await _adminAuth.signOut();
  }
}
