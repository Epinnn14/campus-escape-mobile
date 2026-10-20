import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/room_meta.dart';
import '../../data/models/unlocked_insight.dart';
import 'local_storage_provider.dart';

/// Kartu wawasan yang sudah terbuka (Galeri Koleksi).
class InsightNotifier extends Notifier<List<UnlockedInsight>> {
  @override
  List<UnlockedInsight> build() =>
      ref.read(localStorageProvider).loadInsights();

  bool isUnlocked(RoomId id) => state.any((i) => i.roomId == id);

  void unlock(RoomId id) {
    if (isUnlocked(id)) return;
    state = [...state, UnlockedInsight(roomId: id, unlockedAt: DateTime.now())];
    _persist();
  }

  void toggleBookmark(RoomId id) {
    state = [
      for (final i in state)
        i.roomId == id ? i.copyWith(isBookmarked: !i.isBookmarked) : i,
    ];
    _persist();
  }

  void resetAll() {
    state = const [];
    _persist();
  }

  void _persist() => ref.read(localStorageProvider).saveInsights(state);
}

final insightProvider =
    NotifierProvider<InsightNotifier, List<UnlockedInsight>>(
  InsightNotifier.new,
);
