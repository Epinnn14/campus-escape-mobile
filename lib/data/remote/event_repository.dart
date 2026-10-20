import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/event_info.dart';
import '../models/player_record.dart';
import '../models/room_settings.dart';
import 'firebase_service.dart';

/// Struktur Firestore (lihat juga firestore.rules):
///
///   events/{code}                       → EventInfo (publik untuk yang tahu kodenya)
///   events/{code}/players/{uid}         → data pemain TANPA no HP (leaderboard)
///   events/{code}/private/{uid}         → { phone }  (hanya pemilik & admin)
///   admins/{uid}                        → { username } (dibuat manual di Console)
///
/// Satu class untuk sisi peserta (instance Firebase default, login anonim)
/// dan sisi admin (instance 'admin', login username+password). Method admin
/// diberi awalan `admin...` dan memakai [FirebaseService.adminFirestore].
class EventRepository {
  final FirebaseService _fb;
  EventRepository(this._fb);

  /// Leaderboard peserta: hanya TOP-N yang di-stream ke tiap HP (peringkat
  /// diri sendiri dihitung lewat count aggregate) supaya ribuan peserta
  /// bersamaan tidak membuat tiap HP mengunduh ribuan dokumen.
  static const int leaderboardTop = 50;

  /// Daftar live di panel admin (sisanya lewat statistik aggregate & ekspor).
  static const int adminLiveTop = 100;

  /// Ukuran halaman saat ekspor semua peserta.
  static const int exportPage = 500;

  FirebaseFirestore get _db => _fb.firestore;
  FirebaseFirestore get _adminDb => _fb.adminFirestore;

  DocumentReference<Map<String, dynamic>> _eventRef(FirebaseFirestore db, String code) =>
      db.collection('events').doc(code);
  CollectionReference<Map<String, dynamic>> _playersRef(FirebaseFirestore db, String code) =>
      _eventRef(db, code).collection('players');
  CollectionReference<Map<String, dynamic>> _privateRef(FirebaseFirestore db, String code) =>
      _eventRef(db, code).collection('private');

  // ================================================================ peserta

  /// Ambil acara dari server (bukan cache) untuk validasi kode saat daftar.
  /// null = kode tidak ada. Melempar FirebaseException kalau offline.
  Future<EventInfo?> fetchEvent(String code) async {
    final snap = await _eventRef(_db, code)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 15));
    final data = snap.data();
    if (!snap.exists || data == null) return null;
    return EventInfo.fromMap(code, data);
  }

  /// Pantau acara (pengaturan ruangan & pemenang) secara real-time.
  Stream<EventInfo?> watchEvent(String code) => _eventRef(_db, code).snapshots().map((s) {
        final d = s.data();
        return s.exists && d != null ? EventInfo.fromMap(code, d) : null;
      });

  /// Leaderboard real-time satu acara: TOP-[leaderboardTop], skor tertinggi dulu.
  Stream<List<PlayerRecord>> watchPlayers(String code) => _watchPlayers(_db, code, leaderboardTop);

  Stream<List<PlayerRecord>> _watchPlayers(FirebaseFirestore db, String code, int limit) => _playersRef(db, code)
      .orderBy('totalScore', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => [for (final d in s.docs) _recordFromDoc(d.id, d.data())]);

  /// Peringkat pemain = jumlah peserta dengan skor lebih tinggi + 1, dan total
  /// peserta — dua count aggregate (murah, tidak mengunduh dokumen).
  Future<({int rank, int total})> fetchRank(String code, int score) async {
    final col = _playersRef(_db, code);
    final above = await col.where('totalScore', isGreaterThan: score).count().get();
    final total = await col.count().get();
    return (rank: (above.count ?? 0) + 1, total: total.count ?? 0);
  }

  /// Kirim snapshot pemain (publik) + no HP (privat). Dipanggil tiap
  /// registrasi dan tiap ruangan selesai. `set(merge)` supaya field yang
  /// dijaga rules (name, school, createdAt) tidak perlu dikirim ulang.
  Future<void> upsertPlayer({
    required String code,
    required String uid,
    required PlayerRecord record,
    required bool isNew,
  }) async {
    final roomsDone = record.roomScores.values.where((v) => v > 0).length;
    final data = <String, dynamic>{
      'uid': uid,
      'eventCode': code,
      'name': record.name,
      'school': record.school,
      'avatarIndex': record.avatarIndex,
      'totalScore': record.totalScore,
      'roomsCompleted': record.roomsCompleted,
      'roomsTotal': record.roomsTotal,
      'roomsDone': roomsDone,
      'finished': record.finished,
      'roomScores': record.roomScores,
      'startedAt': record.startedAt.toIso8601String(),
      'lastPlayedAt': record.lastPlayedAt.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (isNew) data['createdAt'] = FieldValue.serverTimestamp();
    final batch = _db.batch();
    batch.set(_playersRef(_db, code).doc(uid), data, SetOptions(merge: true));
    if (isNew) {
      batch.set(_privateRef(_db, code).doc(uid), {
        'uid': uid,
        'phone': record.phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    // Tidak di-await sampai server: Firestore mengantre write saat offline
    // dan mengirimnya begitu online. Error (mis. ditolak rules) dicatat saja.
    batch.commit().catchError((Object e) => debugPrint('Sync pemain ditolak: $e'));
  }

  // ================================================================== admin

  Stream<List<EventInfo>> adminWatchEvents() => _adminDb
      .collection('events')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => [for (final d in s.docs) EventInfo.fromMap(d.id, d.data())]);

  Stream<EventInfo?> adminWatchEvent(String code) => _eventRef(_adminDb, code).snapshots().map((s) {
        final d = s.data();
        return s.exists && d != null ? EventInfo.fromMap(code, d) : null;
      });

  Stream<List<PlayerRecord>> adminWatchPlayers(String code) => _watchPlayers(_adminDb, code, adminLiveTop);

  /// Statistik seluruh peserta acara lewat aggregate (count/average) —
  /// tetap akurat walau pesertanya ribuan.
  Future<({int total, int finished, int avgScore})> adminFetchStats(String code) async {
    final col = _playersRef(_adminDb, code);
    final agg = await col.aggregate(count(), average('totalScore')).get();
    final fin = await col.where('finished', isEqualTo: true).count().get();
    return (
      total: agg.count ?? 0,
      finished: fin.count ?? 0,
      avgScore: (agg.getAverage('totalScore') ?? 0).round(),
    );
  }

  /// Cek apakah kode acara sudah dipakai (dibaca dari server).
  Future<bool> adminCodeExists(String code) async {
    final snap = await _eventRef(_adminDb, code).get(const GetOptions(source: Source.server));
    return snap.exists;
  }

  /// Buat acara baru. [code] ditentukan admin (sudah dinormalisasi & valid
  /// menurut [EventCodeFormat]); melempar [StateError] kalau kode sudah ada.
  Future<EventInfo> adminCreateEvent({
    required String code,
    required String name,
    required String createdBy,
  }) async {
    final normalized = EventCodeFormat.normalize(code);
    if (!EventCodeFormat.isValid(normalized)) {
      throw StateError('Format kode acara harus 3 huruf + 3 angka, misal ABC321.');
    }
    if (await adminCodeExists(normalized)) {
      throw StateError('Kode $normalized sudah dipakai acara lain.');
    }
    final info = EventInfo(
      code: normalized,
      name: name.trim(),
      active: true,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );
    await _eventRef(_adminDb, normalized).set({...info.toMap(), 'serverCreatedAt': FieldValue.serverTimestamp()});
    return info;
  }

  Future<void> adminSetActive(String code, bool active) =>
      _eventRef(_adminDb, code).update({'active': active});

  Future<void> adminRename(String code, String name) =>
      _eventRef(_adminDb, code).update({'name': name.trim()});

  Future<void> adminSetRoomSettings(String code, RoomSettings settings) =>
      _eventRef(_adminDb, code).update({'roomSettings': settings.toMap()});

  Future<void> adminSetWinner(String code, EventWinner? winner) =>
      _eventRef(_adminDb, code).update({'winner': winner?.toMap()});

  Future<void> adminDeletePlayer(String code, String uid) async {
    final batch = _adminDb.batch();
    batch.delete(_playersRef(_adminDb, code).doc(uid));
    batch.delete(_privateRef(_adminDb, code).doc(uid));
    await batch.commit();
  }

  /// Hapus SEMUA peserta satu acara (dokumen publik + privat), per batch
  /// 400 supaya aman untuk ribuan peserta. Acara & pengaturannya tetap ada.
  /// Mengembalikan jumlah peserta yang dihapus.
  Future<int> adminDeleteAllPlayers(String code) async {
    var removed = 0;
    removed += await _deleteCollection(_playersRef(_adminDb, code));
    await _deleteCollection(_privateRef(_adminDb, code));
    return removed;
  }

  /// Hapus acara beserta semua pemainnya (untuk acara uji coba).
  Future<void> adminDeleteEvent(String code) async {
    await adminDeleteAllPlayers(code);
    await _eventRef(_adminDb, code).delete();
  }

  Future<int> _deleteCollection(CollectionReference<Map<String, dynamic>> col) async {
    var total = 0;
    while (true) {
      final snap = await col.limit(400).get();
      if (snap.docs.isEmpty) return total;
      final batch = _adminDb.batch();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
      total += snap.docs.length;
      if (snap.docs.length < 400) return total;
    }
  }

  /// Pemain lengkap DENGAN no HP untuk ekspor (hanya admin yang boleh baca
  /// koleksi `private`). Dibaca per halaman [exportPage] supaya aman untuk
  /// ribuan peserta.
  Future<List<PlayerRecord>> adminFetchPlayersForExport(String code) async {
    final phones = <String, String>{};
    await _paginate(_privateRef(_adminDb, code), (d) {
      phones[d.id] = d.data()['phone'] as String? ?? '';
    });
    final out = <PlayerRecord>[];
    await _paginate(
      _playersRef(_adminDb, code).orderBy('totalScore', descending: true),
      (d) => out.add(_recordFromDoc(d.id, d.data(), phone: phones[d.id] ?? '')),
    );
    return out;
  }

  Future<void> _paginate(
    Query<Map<String, dynamic>> query,
    void Function(QueryDocumentSnapshot<Map<String, dynamic>> doc) onDoc,
  ) async {
    DocumentSnapshot? cursor;
    while (true) {
      var q = query.limit(exportPage);
      if (cursor != null) q = q.startAfterDocument(cursor);
      final snap = await q.get();
      for (final d in snap.docs) {
        onDoc(d);
      }
      if (snap.docs.length < exportPage) break;
      cursor = snap.docs.last;
    }
  }

  // ================================================================ mapping

  PlayerRecord _recordFromDoc(String uid, Map<String, dynamic> m, {String phone = ''}) => PlayerRecord(
        sessionId: uid,
        name: m['name'] as String? ?? '',
        school: m['school'] as String? ?? '',
        phone: phone,
        avatarIndex: (m['avatarIndex'] as num?)?.toInt() ?? 0,
        totalScore: (m['totalScore'] as num?)?.toInt() ?? 0,
        roomsCompleted: (m['roomsCompleted'] as num?)?.toInt() ?? 0,
        roomsTotal: (m['roomsTotal'] as num?)?.toInt() ?? 0,
        roomScores: {
          for (final e in (m['roomScores'] as Map? ?? const {}).entries)
            e.key as String: (e.value as num?)?.toInt() ?? 0,
        },
        startedAt: DateTime.tryParse(m['startedAt'] as String? ?? '') ?? DateTime.now(),
        lastPlayedAt: DateTime.tryParse(m['lastPlayedAt'] as String? ?? '') ?? DateTime.now(),
      );
}
