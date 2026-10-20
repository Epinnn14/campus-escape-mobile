import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/room_meta.dart';
import '../../data/models/room_progress.dart';
import '../../domain/engines/puzzle_engine.dart';
import 'insight_provider.dart';
import 'local_storage_provider.dart';
import 'player_archive_provider.dart';
import 'room_settings_provider.dart';
import 'session_provider.dart';

/// Aturan unlock (hanya ruangan yang AKTIF menurut pengaturan admin):
/// - Core room dibuka berurutan (core aktif N terbuka setelah core aktif
///   sebelumnya selesai).
/// - Bonus room terbuka setelah SEMUA core aktif selesai.
/// - Ruangan nonaktif selalu terkunci dan dilewati.
/// - Skor masuk ke sesi hanya saat ruangan pertama kali selesai; replay
///   boleh memperbaiki bintang tapi tidak menambah skor.
class RoomProgressNotifier extends Notifier<List<RoomProgress>> {
  @override
  List<RoomProgress> build() {
    // Mode online: pengaturan ruangan bisa berubah dari admin kapan saja →
    // hitung ulang status kunci begitu pengaturannya berubah.
    ref.listen(roomSettingsProvider, (prev, next) {
      if (prev != null && prev != next) recomputeUnlocks();
    });
    final storage = ref.read(localStorageProvider);
    List<RoomProgress>? saved;
    try {
      saved = storage.loadRoomProgress();
    } catch (_) {
      saved = null;
    }
    if (saved == null || saved.length != RoomCatalog.all.length) {
      return _applyUnlockRules(defaultRoomProgress());
    }
    return saved;
  }

  RoomProgress of(RoomId id) => state.firstWhere((r) => r.roomId == id);

  /// Tandai ruangan sedang dimainkan (buat badge "Lanjut" di peta).
  void markActive(RoomId id) {
    final room = of(id);
    if (room.status != RoomStatus.unlocked) return;
    _update(id, (r) => r.copyWith(status: RoomStatus.active));
  }

  void addHint(RoomId id) {
    _update(id, (r) => r.copyWith(hintsUsed: r.hintsUsed + 1));
  }

  void completeRoom(RoomId id, PuzzleResult result, Duration timeSpent) {
    final existing = of(id);
    final firstTime = !existing.isCompleted;
    final bestStars = existing.stars > result.stars ? existing.stars : result.stars;

    _update(
      id,
      (r) => r.copyWith(
        status: RoomStatus.completed,
        score: firstTime ? result.score : r.score,
        stars: bestStars,
        timeSpentSeconds: timeSpent.inSeconds,
        completedAt: DateTime.now(),
      ),
    );
    recomputeUnlocks();

    if (firstTime) {
      ref.read(sessionProvider.notifier).addScore(result.score);
      ref.read(insightProvider.notifier).unlock(id);
    }
    ref.read(playerArchiveProvider.notifier).syncCurrent();
  }

  void resetAll() {
    state = _applyUnlockRules(defaultRoomProgress());
    _persist();
  }

  /// Hitung ulang status terkunci/terbuka sesuai pengaturan admin —
  /// dipanggil setelah ruangan selesai dan setelah admin mengubah ruangan.
  void recomputeUnlocks() {
    state = _applyUnlockRules(state);
    _persist();
  }

  List<RoomProgress> _applyUnlockRules(List<RoomProgress> rooms) {
    final settings = ref.read(roomSettingsProvider);
    final core = settings.activeCore;
    RoomProgress byId(RoomId id) => rooms.firstWhere((r) => r.roomId == id);
    final allCoreDone = core.every((m) => byId(m.id).isCompleted);

    return [
      for (final room in rooms) _nextStatusFor(room, core, allCoreDone, settings.isEnabled(room.roomId), byId),
    ];
  }

  RoomProgress _nextStatusFor(
    RoomProgress room,
    List<RoomMeta> core,
    bool allCoreDone,
    bool enabled,
    RoomProgress Function(RoomId) byId,
  ) {
    // Ruangan nonaktif: kunci lagi kalau belum selesai (yang sudah selesai
    // dibiarkan, tapi tidak dihitung di total).
    if (!enabled) {
      return room.isCompleted ? room : room.copyWith(status: RoomStatus.locked);
    }
    if (room.status != RoomStatus.locked) return room;
    final meta = RoomCatalog.byId(room.roomId);
    if (meta.isBonus) {
      return allCoreDone ? room.copyWith(status: RoomStatus.unlocked) : room;
    }
    final idx = core.indexWhere((m) => m.id == meta.id);
    if (idx <= 0) return room.copyWith(status: RoomStatus.unlocked);
    final previousDone = byId(core[idx - 1].id).isCompleted;
    return previousDone ? room.copyWith(status: RoomStatus.unlocked) : room;
  }

  void _update(RoomId id, RoomProgress Function(RoomProgress) fn) {
    state = [for (final r in state) r.roomId == id ? fn(r) : r];
    _persist();
  }

  void _persist() => ref.read(localStorageProvider).saveRoomProgress(state);
}

final roomProgressProvider = NotifierProvider<RoomProgressNotifier, List<RoomProgress>>(
  RoomProgressNotifier.new,
);

/// Ruangan yang paling masuk akal buat "Lanjutkan" di Home:
/// yang sedang aktif, kalau tidak ada → yang terbuka tapi belum selesai.
/// Hanya ruangan aktif menurut admin.
final nextRoomProvider = Provider<RoomProgress?>((ref) {
  final rooms = ref.watch(roomProgressProvider);
  final settings = ref.watch(roomSettingsProvider);
  final enabled = rooms.where((r) => settings.isEnabled(r.roomId));
  final active = enabled.where((r) => r.status == RoomStatus.active);
  if (active.isNotEmpty) return active.first;
  final unlocked = enabled.where((r) => r.status == RoomStatus.unlocked);
  return unlocked.isEmpty ? null : unlocked.first;
});

/// Jumlah ruangan AKTIF yang sudah selesai.
final completedCountProvider = Provider<({int core, int bonus})>((ref) {
  final rooms = ref.watch(roomProgressProvider);
  final settings = ref.watch(roomSettingsProvider);
  var core = 0, bonus = 0;
  for (final r in rooms) {
    if (!r.isCompleted || !settings.isEnabled(r.roomId)) continue;
    if (RoomCatalog.byId(r.roomId).isBonus) {
      bonus++;
    } else {
      core++;
    }
  }
  return (core: core, bonus: bonus);
});
