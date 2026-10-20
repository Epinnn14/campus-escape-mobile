import 'player_session.dart';
import 'room_meta.dart';
import 'room_progress.dart';

/// Arsip satu pemain di perangkat ini (PLAYER_RECORD untuk panel admin &
/// leaderboard). Diperbarui tiap registrasi, tiap ruangan selesai, dan
/// sebelum reset — jadi data semua orang yang pernah main tetap ada
/// walau sesi aktifnya sudah di-reset.
class PlayerRecord {
  final String sessionId;
  final String name;
  final String school;
  final String phone;
  final int avatarIndex;
  final int totalScore;
  final int roomsCompleted;
  final int roomsTotal;

  /// Skor per ruangan (key = RoomId.name). 0 = belum selesai.
  final Map<String, int> roomScores;
  final DateTime startedAt;
  final DateTime lastPlayedAt;

  const PlayerRecord({
    required this.sessionId,
    required this.name,
    required this.school,
    required this.phone,
    required this.avatarIndex,
    required this.totalScore,
    required this.roomsCompleted,
    required this.roomsTotal,
    required this.roomScores,
    required this.startedAt,
    required this.lastPlayedAt,
  });

  bool get finished => roomsTotal > 0 && roomsCompleted >= roomsTotal;

  /// Bangun dari sesi + progres saat ini. [activeRooms] = ruangan aktif
  /// menurut pengaturan admin (supaya total mengikuti konfigurasi).
  factory PlayerRecord.fromCurrent({
    required PlayerSession session,
    required List<RoomProgress> rooms,
    required List<RoomMeta> activeRooms,
  }) {
    final activeIds = {for (final m in activeRooms) m.id};
    final scores = <String, int>{};
    var completed = 0;
    for (final r in rooms) {
      scores[r.roomId.name] = r.isCompleted ? r.score : 0;
      if (r.isCompleted && activeIds.contains(r.roomId)) completed++;
    }
    return PlayerRecord(
      sessionId: session.sessionId,
      name: session.displayName,
      school: session.schoolOrigin,
      phone: session.phone,
      avatarIndex: session.avatarIndex,
      totalScore: session.totalScore,
      roomsCompleted: completed,
      roomsTotal: activeRooms.length,
      roomScores: scores,
      startedAt: session.startedAt ?? session.createdAt,
      lastPlayedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'sessionId': sessionId,
        'name': name,
        'school': school,
        'phone': phone,
        'avatarIndex': avatarIndex,
        'totalScore': totalScore,
        'roomsCompleted': roomsCompleted,
        'roomsTotal': roomsTotal,
        'roomScores': roomScores,
        'startedAt': startedAt.toIso8601String(),
        'lastPlayedAt': lastPlayedAt.toIso8601String(),
      };

  factory PlayerRecord.fromMap(Map<dynamic, dynamic> map) => PlayerRecord(
        sessionId: map['sessionId'] as String,
        name: map['name'] as String? ?? '',
        school: map['school'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        avatarIndex: map['avatarIndex'] as int? ?? 0,
        totalScore: map['totalScore'] as int? ?? 0,
        roomsCompleted: map['roomsCompleted'] as int? ?? 0,
        roomsTotal: map['roomsTotal'] as int? ?? 0,
        roomScores: {
          for (final e in (map['roomScores'] as Map? ?? const {}).entries)
            e.key as String: (e.value as num?)?.toInt() ?? 0,
        },
        startedAt: DateTime.tryParse(map['startedAt'] as String? ?? '') ?? DateTime.now(),
        lastPlayedAt: DateTime.tryParse(map['lastPlayedAt'] as String? ?? '') ?? DateTime.now(),
      );
}
