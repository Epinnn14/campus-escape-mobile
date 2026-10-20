import 'package:hive_flutter/hive_flutter.dart';
import '../models/player_record.dart';
import '../models/player_session.dart';
import '../models/room_progress.dart';
import '../models/room_settings.dart';
import '../models/unlocked_insight.dart';

/// Wrapper tipis di atas Hive — persistence offline-first, write-through
/// setiap progress berubah. Semua disimpan sebagai Map/List biasa
/// (tanpa TypeAdapter / codegen).
class LocalStorageService {
  static const _boxName = 'campus_escape_v2';
  static const _sessionKey = 'session';
  static const _roomsKey = 'rooms';
  static const _insightsKey = 'insights';

  /// Box terpisah untuk data admin (arsip pemain, pengaturan ruangan,
  /// password) — TIDAK ikut terhapus saat pemain reset progres.
  static const _adminBoxName = 'campus_escape_admin_v1';
  static const _playersKey = 'players';
  static const _roomSettingsKey = 'roomSettings';
  static const _adminPasswordKey = 'adminPassword';

  late final Box _box;
  late final Box _adminBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _adminBox = await Hive.openBox(_adminBoxName);
  }

  // ---- Session ----
  Future<void> saveSession(PlayerSession session) =>
      _box.put(_sessionKey, session.toMap());

  PlayerSession? loadSession() {
    final raw = _box.get(_sessionKey);
    if (raw == null) return null;
    return PlayerSession.fromMap(Map<dynamic, dynamic>.from(raw as Map));
  }

  // ---- Room progress ----
  Future<void> saveRoomProgress(List<RoomProgress> rooms) =>
      _box.put(_roomsKey, rooms.map((r) => r.toMap()).toList());

  List<RoomProgress>? loadRoomProgress() {
    final raw = _box.get(_roomsKey);
    if (raw == null) return null;
    return (raw as List)
        .map((e) => RoomProgress.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
  }

  // ---- Insights ----
  Future<void> saveInsights(List<UnlockedInsight> insights) =>
      _box.put(_insightsKey, insights.map((i) => i.toMap()).toList());

  List<UnlockedInsight> loadInsights() {
    final raw = _box.get(_insightsKey);
    if (raw == null) return const [];
    return (raw as List)
        .map((e) =>
            UnlockedInsight.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
  }

  /// Reset sesi pemain — dipakai tombol "Reset progres sesi" di Profil.
  /// Box admin (arsip pemain, pengaturan) tidak disentuh.
  Future<void> clearAll() => _box.clear();

  // ---- Admin: arsip pemain ----
  Future<void> savePlayers(List<PlayerRecord> players) =>
      _adminBox.put(_playersKey, players.map((p) => p.toMap()).toList());

  List<PlayerRecord> loadPlayers() {
    final raw = _adminBox.get(_playersKey);
    if (raw == null) return const [];
    final out = <PlayerRecord>[];
    for (final e in raw as List) {
      try {
        out.add(PlayerRecord.fromMap(Map<dynamic, dynamic>.from(e as Map)));
      } catch (_) {
        // Entri rusak dilewati supaya satu data buruk tidak merusak semuanya.
      }
    }
    return out;
  }

  Future<void> clearPlayers() => _adminBox.delete(_playersKey);

  // ---- Admin: pengaturan ruangan ----
  Future<void> saveRoomSettings(RoomSettings settings) =>
      _adminBox.put(_roomSettingsKey, settings.toMap());

  RoomSettings loadRoomSettings() {
    final raw = _adminBox.get(_roomSettingsKey);
    if (raw == null) return const RoomSettings();
    try {
      return RoomSettings.fromMap(Map<dynamic, dynamic>.from(raw as Map));
    } catch (_) {
      return const RoomSettings();
    }
  }

  // ---- Admin: password ----
  Future<void> saveAdminPassword(String password) => _adminBox.put(_adminPasswordKey, password);

  AdminConfig loadAdminConfig() {
    final raw = _adminBox.get(_adminPasswordKey);
    return AdminConfig(password: (raw as String?) ?? AdminConfig.defaultPassword);
  }
}
