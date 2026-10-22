import 'package:flutter/material.dart';

/// 12 varian warna robot avatar (dipilih saat registrasi).
class RobotVariant {
  final String name;
  final Color color;
  const RobotVariant(this.name, this.color);
}

abstract class RobotAvatars {
  static const List<RobotVariant> all = [
    RobotVariant('Electric Blue', Color(0xFF3B82F6)),
    RobotVariant('Coral Blaze', Color(0xFFF87171)),
    RobotVariant('Cyber Mint', Color(0xFF34D399)),
    RobotVariant('Sunny Yellow', Color(0xFFFBBF24)),
    RobotVariant('Neon Violet', Color(0xFFA78BFA)),
    RobotVariant('Emerald Tech', Color(0xFF14B8A6)),
    RobotVariant('Hot Pink', Color(0xFFF472B6)),
    RobotVariant('Sky Pulse', Color(0xFF38BDF8)),
    RobotVariant('Lime Spark', Color(0xFFA3E635)),
    RobotVariant('Orange Core', Color(0xFFFB923C)),
    RobotVariant('Indigo Byte', Color(0xFF818CF8)),
    RobotVariant('Rose Signal', Color(0xFFFB7185)),
  ];

  static RobotVariant at(int index) => all[index.clamp(0, all.length - 1)];
}

/// PLAYER_SESSION di ERD. Satu sesi = satu regu/pemain di satu kunjungan.
class PlayerSession {
  final String sessionId;
  final String teamName;
  final String schoolOrigin;

  /// Nomor HP (format Indonesia, disimpan apa adanya setelah dinormalisasi
  /// oleh [PhoneFormat.normalize]).
  final String phone;
  final int avatarIndex;
  final DateTime createdAt;
  final DateTime? startedAt;
  final int totalScore;

  /// Mode online: kode acara yang dimasukkan saat daftar ('' = mode lokal).
  final String eventCode;

  /// Mode online: UID login anonim Firebase = id dokumen pemain di Firestore.
  final String onlineUid;

  PlayerSession({
    required this.sessionId,
    this.teamName = '',
    this.schoolOrigin = '',
    this.phone = '',
    this.avatarIndex = 0,
    DateTime? createdAt,
    this.startedAt,
    this.totalScore = 0,
    this.eventCode = '',
    this.onlineUid = '',
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isRegistered => teamName.trim().isNotEmpty;

  /// Terdaftar ke acara online (punya kode acara + UID Firebase).
  bool get isOnlinePlayer => eventCode.isNotEmpty && onlineUid.isNotEmpty;
  String get displayName => isRegistered ? teamName.trim() : 'Explorer';
  RobotVariant get avatar => RobotAvatars.at(avatarIndex);

  /// Kode verifikasi yang dicetak di sertifikat.
  String get verificationCode {
    final tail = sessionId.length >= 5
        ? sessionId.substring(sessionId.length - 5)
        : sessionId.padLeft(5, '0');
    return 'CE-${createdAt.year}-${tail.toUpperCase()}';
  }

  Map<String, dynamic> toMap() => {
        'sessionId': sessionId,
        'teamName': teamName,
        'schoolOrigin': schoolOrigin,
        'phone': phone,
        'avatarIndex': avatarIndex,
        'createdAt': createdAt.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'totalScore': totalScore,
        'eventCode': eventCode,
        'onlineUid': onlineUid,
      };

  factory PlayerSession.fromMap(Map<dynamic, dynamic> map) => PlayerSession(
        sessionId: map['sessionId'] as String,
        teamName: map['teamName'] as String? ?? '',
        schoolOrigin: map['schoolOrigin'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        avatarIndex: map['avatarIndex'] as int? ?? 0,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
        startedAt: DateTime.tryParse(map['startedAt'] as String? ?? ''),
        totalScore: map['totalScore'] as int? ?? 0,
        eventCode: map['eventCode'] as String? ?? '',
        onlineUid: map['onlineUid'] as String? ?? '',
      );

  PlayerSession copyWith({
    String? teamName,
    String? schoolOrigin,
    String? phone,
    int? avatarIndex,
    DateTime? startedAt,
    int? totalScore,
    String? eventCode,
    String? onlineUid,
  }) =>
      PlayerSession(
        sessionId: sessionId,
        teamName: teamName ?? this.teamName,
        schoolOrigin: schoolOrigin ?? this.schoolOrigin,
        phone: phone ?? this.phone,
        avatarIndex: avatarIndex ?? this.avatarIndex,
        createdAt: createdAt,
        startedAt: startedAt ?? this.startedAt,
        totalScore: totalScore ?? this.totalScore,
        eventCode: eventCode ?? this.eventCode,
        onlineUid: onlineUid ?? this.onlineUid,
      );
}

/// Validasi & normalisasi nomor HP Indonesia dan nama lengkap.
/// Dipakai form registrasi; dipisah supaya gampang di-unit-test.
abstract class PhoneFormat {
  static final _digits = RegExp(r'[^0-9+]');

  /// Buang spasi/tanda hubung, ubah +62 / 62 di depan menjadi 0.
  static String normalize(String raw) {
    var v = raw.replaceAll(_digits, '');
    if (v.startsWith('+62')) v = '0${v.substring(3)}';
    if (v.startsWith('62') && v.length > 10) v = '0${v.substring(2)}';
    return v;
  }

  /// Valid kalau setelah dinormalisasi: diawali 08, digit ke-3 1–9,
  /// total 10–13 digit (format operator Indonesia).
  static bool isValid(String raw) {
    final v = normalize(raw);
    return RegExp(r'^08[1-9][0-9]{7,10}$').hasMatch(v);
  }

  /// Tampilan 0812-3456-7890.
  static String pretty(String raw) {
    final v = normalize(raw);
    if (v.length < 8) return v;
    final parts = <String>[v.substring(0, 4)];
    var i = 4;
    while (i < v.length) {
      parts.add(v.substring(i, (i + 4).clamp(0, v.length)));
      i += 4;
    }
    return parts.join('-');
  }
}

abstract class NameFormat {
  static final _allowed = RegExp(r"^[A-Za-zÀ-ÿ' .\-]+$");

  /// Nama lengkap: wajib terisi (minimal 3 huruf), hanya huruf/spasi/'.-
  static String? validateFullName(String? raw) {
    final v = (raw ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
    if (v.isEmpty) return 'Nama lengkap wajib diisi';
    if (v.length < 3) return 'Nama terlalu pendek';
    if (!_allowed.hasMatch(v)) return 'Nama hanya boleh huruf, spasi, titik, atau tanda hubung';
    return null;
  }

  static final _schoolPrefix = RegExp(r'^(SMA|SMK|SMAN|SMKN|MA|MAN|SMAS|SMKS)\b', caseSensitive: false);

  /// Asal sekolah: wajib diawali SMA/SMK (atau SMAN, SMKN, MA, MAN) dan
  /// harus ada nama sekolahnya setelah itu, mis. "SMAN 1 Bekasi".
  static String? validateSchool(String? raw) {
    final v = (raw ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
    if (v.isEmpty) return 'Asal sekolah wajib diisi';
    final m = _schoolPrefix.firstMatch(v);
    if (m == null) return 'Awali dengan SMA/SMK, misal: SMAN 1 Bekasi';
    final rest = v.substring(m.end).trim();
    if (rest.isEmpty) return 'Tulis nama sekolahnya setelah SMA/SMK, misal: SMAN 1 Bekasi';
    return null;
  }
}
