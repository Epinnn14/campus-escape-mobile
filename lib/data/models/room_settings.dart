import 'room_meta.dart';

/// Pengaturan ruangan yang bisa diubah admin dari dalam app (tanpa rebuild):
/// ruangan mana yang aktif dan berapa XP dasarnya. Disimpan di box admin
/// (tidak ikut terhapus saat pemain reset progres).
class RoomSettings {
  /// Ruangan yang dinonaktifkan admin — tidak muncul di peta, dilewati
  /// dalam urutan unlock, dan tidak dihitung di total.
  final Set<RoomId> disabled;

  /// Override XP dasar per ruangan (null/absen = pakai default katalog).
  final Map<RoomId, int> xpOverride;

  const RoomSettings({this.disabled = const {}, this.xpOverride = const {}});

  static const int minXp = 50;
  static const int maxXp = 500;
  static const int xpStep = 25;

  bool isEnabled(RoomId id) => !disabled.contains(id);

  int xpOf(RoomMeta meta) => xpOverride[meta.id] ?? meta.xpReward;

  /// Ruangan aktif, urut sesuai katalog.
  List<RoomMeta> get active => [for (final m in RoomCatalog.all) if (isEnabled(m.id)) m];
  List<RoomMeta> get activeCore => [for (final m in active) if (!m.isBonus) m];
  List<RoomMeta> get activeBonus => [for (final m in active) if (m.isBonus) m];

  RoomSettings copyWith({Set<RoomId>? disabled, Map<RoomId, int>? xpOverride}) =>
      RoomSettings(disabled: disabled ?? this.disabled, xpOverride: xpOverride ?? this.xpOverride);

  Map<String, dynamic> toMap() => {
        'disabled': [for (final id in disabled) id.name],
        'xpOverride': {for (final e in xpOverride.entries) e.key.name: e.value},
      };

  factory RoomSettings.fromMap(Map<dynamic, dynamic> map) {
    final disabled = <RoomId>{};
    for (final name in (map['disabled'] as List? ?? const [])) {
      final id = _parse(name as String);
      if (id != null) disabled.add(id);
    }
    final xp = <RoomId, int>{};
    for (final e in (map['xpOverride'] as Map? ?? const {}).entries) {
      final id = _parse(e.key as String);
      if (id != null && e.value is int) xp[id] = e.value as int;
    }
    return RoomSettings(disabled: disabled, xpOverride: xp);
  }

  static RoomId? _parse(String name) {
    for (final id in RoomId.values) {
      if (id.name == name) return id;
    }
    return null;
  }
}

/// Konfigurasi panel admin. Password disimpan lokal di perangkat booth
/// (aplikasi offline, tanpa akun) — cukup untuk mencegah siswa iseng masuk.
class AdminConfig {
  static const String defaultPassword = 'socs2026';
  final String password;
  const AdminConfig({this.password = defaultPassword});

  bool check(String input) => input.trim() == password;
}
