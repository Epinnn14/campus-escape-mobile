import 'room_meta.dart';

enum RoomStatus { locked, unlocked, active, completed }

/// Progress per ruangan per sesi (ROOM_PROGRESS di ERD). Disimpan lokal
/// di Hive sebagai Map, tanpa codegen.
class RoomProgress {
  final RoomId roomId;
  final RoomStatus status;
  final int timeSpentSeconds;
  final int score;
  final int stars;
  final int hintsUsed;
  final DateTime? completedAt;

  const RoomProgress({
    required this.roomId,
    this.status = RoomStatus.locked,
    this.timeSpentSeconds = 0,
    this.score = 0,
    this.stars = 0,
    this.hintsUsed = 0,
    this.completedAt,
  });

  bool get isCompleted => status == RoomStatus.completed;
  bool get isPlayable =>
      status == RoomStatus.unlocked ||
      status == RoomStatus.active ||
      status == RoomStatus.completed;

  Map<String, dynamic> toMap() => {
        'roomId': roomId.name,
        'status': status.name,
        'timeSpentSeconds': timeSpentSeconds,
        'score': score,
        'stars': stars,
        'hintsUsed': hintsUsed,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory RoomProgress.fromMap(Map<dynamic, dynamic> map) => RoomProgress(
        roomId: RoomId.values.byName(map['roomId'] as String),
        status: RoomStatus.values.byName(map['status'] as String),
        timeSpentSeconds: map['timeSpentSeconds'] as int? ?? 0,
        score: map['score'] as int? ?? 0,
        stars: map['stars'] as int? ?? 0,
        hintsUsed: map['hintsUsed'] as int? ?? 0,
        completedAt: DateTime.tryParse(map['completedAt'] as String? ?? ''),
      );

  RoomProgress copyWith({
    RoomStatus? status,
    int? timeSpentSeconds,
    int? score,
    int? stars,
    int? hintsUsed,
    DateTime? completedAt,
  }) =>
      RoomProgress(
        roomId: roomId,
        status: status ?? this.status,
        timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
        score: score ?? this.score,
        stars: stars ?? this.stars,
        hintsUsed: hintsUsed ?? this.hintsUsed,
        completedAt: completedAt ?? this.completedAt,
      );
}

/// State awal: core room 1 terbuka, sisanya terkunci.
List<RoomProgress> defaultRoomProgress() => [
      for (final meta in RoomCatalog.all)
        RoomProgress(
          roomId: meta.id,
          status: meta.order == 1 ? RoomStatus.unlocked : RoomStatus.locked,
        ),
    ];
