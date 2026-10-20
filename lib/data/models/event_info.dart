import 'dart:math';

import 'room_settings.dart';

/// Pemenang acara yang ditetapkan admin dari leaderboard. Disimpan di
/// dokumen acara supaya semua peserta langsung melihat banner yang sama.
class EventWinner {
  final String uid;
  final String name;
  final String school;
  final int score;
  final DateTime setAt;

  const EventWinner({
    required this.uid,
    required this.name,
    required this.school,
    required this.score,
    required this.setAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'school': school,
        'score': score,
        'setAt': setAt.toIso8601String(),
      };

  static EventWinner? fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return null;
    final uid = map['uid'] as String?;
    if (uid == null || uid.isEmpty) return null;
    return EventWinner(
      uid: uid,
      name: map['name'] as String? ?? '',
      school: map['school'] as String? ?? '',
      score: (map['score'] as num?)?.toInt() ?? 0,
      setAt: DateTime.tryParse(map['setAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// EVENT di Firestore (`events/{code}`): satu kunjungan sekolah = satu acara
/// dengan kode unik. Peserta masuk dengan kode ini; admin memantau,
/// mengatur ruangan, dan menetapkan pemenang per acara.
class EventInfo {
  final String code;
  final String name;
  final bool active;
  final DateTime createdAt;
  final String createdBy;
  final RoomSettings roomSettings;
  final EventWinner? winner;

  const EventInfo({
    required this.code,
    required this.name,
    required this.active,
    required this.createdAt,
    required this.createdBy,
    this.roomSettings = const RoomSettings(),
    this.winner,
  });

  bool get hasWinner => winner != null;

  EventInfo copyWith({
    String? name,
    bool? active,
    RoomSettings? roomSettings,
    EventWinner? winner,
    bool clearWinner = false,
  }) =>
      EventInfo(
        code: code,
        name: name ?? this.name,
        active: active ?? this.active,
        createdAt: createdAt,
        createdBy: createdBy,
        roomSettings: roomSettings ?? this.roomSettings,
        winner: clearWinner ? null : (winner ?? this.winner),
      );

  Map<String, dynamic> toMap() => {
        'code': code,
        'name': name,
        'active': active,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
        'roomSettings': roomSettings.toMap(),
        'winner': winner?.toMap(),
      };

  factory EventInfo.fromMap(String code, Map<dynamic, dynamic> map) => EventInfo(
        code: code,
        name: map['name'] as String? ?? code,
        active: map['active'] as bool? ?? false,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
        createdBy: map['createdBy'] as String? ?? '',
        roomSettings: RoomSettings.fromMap(Map<dynamic, dynamic>.from(map['roomSettings'] as Map? ?? const {})),
        winner: EventWinner.fromMap(map['winner'] as Map?),
      );
}

/// Format kode acara: **3 huruf + 3 angka**, mis. `ABC321` — gampang
/// dibacakan admin dan diketik peserta. Huruf I dan O tidak dipakai saat
/// generate (mirip 1/0); kalau peserta salah ketik O/0 atau I/1, [normalize]
/// membetulkannya berdasarkan posisi (3 pertama pasti huruf, 3 terakhir
/// pasti angka). Dipisah supaya gampang di-unit-test.
abstract class EventCodeFormat {
  static const int length = 6;
  static const String letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String digits = '0123456789';
  static final _valid = RegExp(r'^[A-Z]{3}[0-9]{3}$');

  static String normalize(String raw) {
    final v = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (v.length != length) return v;
    final head = v.substring(0, 3).replaceAll('0', 'O').replaceAll('1', 'I');
    final tail = v.substring(3).replaceAll('O', '0').replaceAll('I', '1').replaceAll('L', '1');
    return head + tail;
  }

  static bool isValid(String raw) => _valid.hasMatch(normalize(raw));

  static String? validate(String? raw) {
    final v = normalize(raw ?? '');
    if (v.isEmpty) return 'Kode acara wajib diisi';
    if (v.length != length) return 'Kode acara terdiri dari 3 huruf + 3 angka, misal ABC321';
    if (!_valid.hasMatch(v)) return 'Format kode: 3 huruf lalu 3 angka, misal ABC321';
    return null;
  }

  static String generate([Random? rng]) {
    final r = rng ?? Random.secure();
    final a = List.generate(3, (_) => letters[r.nextInt(letters.length)]).join();
    final n = List.generate(3, (_) => digits[r.nextInt(digits.length)]).join();
    return a + n;
  }
}

/// Username admin: 3–24 karakter huruf kecil/angka/titik/garis bawah.
/// Dipetakan ke email sintetis `<username>@admin.campusescape.app` di
/// Firebase Auth (provider Email/Password) — admin tidak perlu punya email.
abstract class AdminUsername {
  static const String emailDomain = 'admin.campusescape.app';
  static final _valid = RegExp(r'^[a-z0-9._]{3,24}$');

  static String normalize(String raw) => raw.trim().toLowerCase();
  static bool isValid(String raw) => _valid.hasMatch(normalize(raw));
  static String toEmail(String username) => '${normalize(username)}@$emailDomain';

  /// Kebalikan dari [toEmail]; null kalau bukan email sintetis admin.
  static String? fromEmail(String? email) {
    if (email == null) return null;
    const suffix = '@$emailDomain';
    if (!email.endsWith(suffix)) return null;
    return email.substring(0, email.length - suffix.length);
  }
}
