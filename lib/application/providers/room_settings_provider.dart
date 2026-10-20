import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/room_meta.dart';
import '../../data/models/room_settings.dart';
import 'local_storage_provider.dart';
import 'online_provider.dart';

/// Pengaturan ruangan dari panel admin (aktif/nonaktif, XP dasar).
/// Semua layar yang butuh "berapa ruangan" membaca dari sini, bukan dari
/// `RoomCatalog.all.length` langsung, supaya konfigurasi admin langsung
/// berlaku tanpa rebuild.
///
/// Mode online: kalau pemain terdaftar ke acara, pengaturan dari dokumen
/// acara (diatur admin online) MENGGANTIKAN pengaturan lokal secara
/// real-time; perubahan lokal (setEnabled/setXp) diabaikan selama itu.
class RoomSettingsNotifier extends Notifier<RoomSettings> {
  @override
  RoomSettings build() {
    final event = ref.watch(currentEventProvider).valueOrNull;
    if (event != null) return event.roomSettings;
    return ref.read(localStorageProvider).loadRoomSettings();
  }

  bool get _lockedByEvent => ref.read(currentEventProvider).valueOrNull != null;

  void setEnabled(RoomId id, bool enabled) {
    if (_lockedByEvent) return;
    final next = {...state.disabled};
    if (enabled) {
      next.remove(id);
    } else {
      // Minimal satu core room harus tetap aktif supaya permainan bisa mulai.
      final remainingCore = RoomCatalog.core.where((m) => m.id != id && !next.contains(m.id));
      if (remainingCore.isEmpty && !RoomCatalog.byId(id).isBonus) return;
      next.add(id);
    }
    state = state.copyWith(disabled: next);
    _persist();
  }

  void setXp(RoomId id, int xp) {
    if (_lockedByEvent) return;
    final clamped = xp.clamp(RoomSettings.minXp, RoomSettings.maxXp);
    final next = {...state.xpOverride};
    if (clamped == RoomCatalog.byId(id).xpReward) {
      next.remove(id);
    } else {
      next[id] = clamped;
    }
    state = state.copyWith(xpOverride: next);
    _persist();
  }

  void resetToDefault() {
    if (_lockedByEvent) return;
    state = const RoomSettings();
    _persist();
  }

  void _persist() => ref.read(localStorageProvider).saveRoomSettings(state);
}

final roomSettingsProvider = NotifierProvider<RoomSettingsNotifier, RoomSettings>(
  RoomSettingsNotifier.new,
);

/// Ruangan aktif urut katalog.
final activeRoomsProvider = Provider<List<RoomMeta>>((ref) => ref.watch(roomSettingsProvider).active);

/// Jumlah ruangan aktif: core, bonus, total.
final roomTotalsProvider = Provider<({int core, int bonus, int total})>((ref) {
  final s = ref.watch(roomSettingsProvider);
  final core = s.activeCore.length;
  final bonus = s.activeBonus.length;
  return (core: core, bonus: bonus, total: core + bonus);
});

/// Konfigurasi admin (password).
class AdminConfigNotifier extends Notifier<AdminConfig> {
  @override
  AdminConfig build() => ref.read(localStorageProvider).loadAdminConfig();

  void setPassword(String password) {
    state = AdminConfig(password: password.trim());
    ref.read(localStorageProvider).saveAdminPassword(state.password);
  }
}

final adminConfigProvider = NotifierProvider<AdminConfigNotifier, AdminConfig>(
  AdminConfigNotifier.new,
);
