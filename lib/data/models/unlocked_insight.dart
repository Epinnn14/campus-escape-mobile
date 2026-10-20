import 'room_meta.dart';

/// UNLOCKED_INSIGHT di ERD — kartu wawasan yang sudah terbuka,
/// ditampilkan di Galeri Koleksi.
class UnlockedInsight {
  final RoomId roomId;
  final DateTime unlockedAt;
  final bool isBookmarked;

  const UnlockedInsight({
    required this.roomId,
    required this.unlockedAt,
    this.isBookmarked = false,
  });

  Map<String, dynamic> toMap() => {
        'roomId': roomId.name,
        'unlockedAt': unlockedAt.toIso8601String(),
        'isBookmarked': isBookmarked,
      };

  factory UnlockedInsight.fromMap(Map<dynamic, dynamic> map) => UnlockedInsight(
        roomId: RoomId.values.byName(map['roomId'] as String),
        unlockedAt:
            DateTime.tryParse(map['unlockedAt'] as String? ?? '') ?? DateTime.now(),
        isBookmarked: map['isBookmarked'] as bool? ?? false,
      );

  UnlockedInsight copyWith({bool? isBookmarked}) => UnlockedInsight(
        roomId: roomId,
        unlockedAt: unlockedAt,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );
}
