import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/player_record.dart';
import 'local_storage_provider.dart';
import 'online_provider.dart';
import 'room_progress_provider.dart';
import 'room_settings_provider.dart';
import 'session_provider.dart';

/// Arsip semua pemain yang pernah main di perangkat ini. Dipakai panel
/// admin (lihat progres, ekspor) dan leaderboard (data sungguhan, bukan dummy).
class PlayerArchiveNotifier extends Notifier<List<PlayerRecord>> {
  @override
  List<PlayerRecord> build() => ref.read(localStorageProvider).loadPlayers();

  /// Simpan/perbarui snapshot pemain yang sedang aktif. Dipanggil saat
  /// registrasi ([isNew] = true), tiap ruangan selesai, dan sebelum reset.
  /// Mode online: snapshot yang sama dikirim ke Firestore (publik tanpa
  /// no HP + dokumen privat berisi no HP saat registrasi).
  void syncCurrent({bool isNew = false}) {
    final session = ref.read(sessionProvider);
    if (!session.isRegistered) return;
    final record = PlayerRecord.fromCurrent(
      session: session,
      rooms: ref.read(roomProgressProvider),
      activeRooms: ref.read(activeRoomsProvider),
    );
    final others = state.where((p) => p.sessionId != record.sessionId).toList();
    state = [...others, record];
    _persist();

    // Acara yang sudah ditutup admin: pemain tetap boleh main (progres
    // lokal), tapi skor tidak dikirim lagi (server juga menolaknya).
    final event = ref.read(currentEventProvider).valueOrNull;
    final eventOpen = event == null || event.code != session.eventCode || event.active;
    if (session.isOnlinePlayer && eventOpen) {
      ref.read(eventRepositoryProvider)?.upsertPlayer(
            code: session.eventCode,
            uid: session.onlineUid,
            record: record,
            isNew: isNew,
          );
    }
  }

  void clearAll() {
    state = const [];
    ref.read(localStorageProvider).clearPlayers();
  }

  void _persist() => ref.read(localStorageProvider).savePlayers(state);
}

final playerArchiveProvider = NotifierProvider<PlayerArchiveNotifier, List<PlayerRecord>>(
  PlayerArchiveNotifier.new,
);
