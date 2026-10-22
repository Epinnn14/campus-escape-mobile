import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/player_session.dart';
import 'local_storage_provider.dart';
import 'player_archive_provider.dart';

class SessionNotifier extends Notifier<PlayerSession> {
  @override
  PlayerSession build() {
    final storage = ref.read(localStorageProvider);
    return storage.loadSession() ?? _fresh();
  }

  static PlayerSession _fresh() => PlayerSession(
        sessionId: DateTime.now().microsecondsSinceEpoch.toString(),
      );

  /// Registrasi dari Landing Page (nama lengkap, sekolah, no HP, robot avatar).
  /// Mode online: [eventCode] + [onlineUid] diisi setelah kode acara
  /// tervalidasi dan login anonim berhasil.
  void register({
    required String teamName,
    required String schoolOrigin,
    required String phone,
    required int avatarIndex,
    String eventCode = '',
    String onlineUid = '',
  }) {
    state = state.copyWith(
      teamName: teamName.trim().replaceAll(RegExp(r'\s+'), ' '),
      schoolOrigin: schoolOrigin.trim(),
      phone: PhoneFormat.normalize(phone),
      avatarIndex: avatarIndex,
      startedAt: state.startedAt ?? DateTime.now(),
      eventCode: eventCode,
      onlineUid: onlineUid,
    );
    _persist();
    ref.read(playerArchiveProvider.notifier).syncCurrent(isNew: true);
  }

  void setAvatar(int index) {
    state = state.copyWith(avatarIndex: index);
    _persist();
  }

  void addScore(int points) {
    state = state.copyWith(totalScore: state.totalScore + points);
    _persist();
  }

  void resetToFresh() {
    state = _fresh();
    _persist();
  }

  void _persist() => ref.read(localStorageProvider).saveSession(state);
}

final sessionProvider = NotifierProvider<SessionNotifier, PlayerSession>(
  SessionNotifier.new,
);

/// Format mm:ss (atau h:mm:ss kalau >= 1 jam).
String formatDuration(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}
