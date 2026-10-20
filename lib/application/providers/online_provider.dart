import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/event_info.dart';
import '../../data/models/player_record.dart';
import '../../data/remote/event_repository.dart';
import '../../data/remote/firebase_service.dart';
import 'session_provider.dart';

/// Di-override di main.dart setelah `FirebaseService.init()`.
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  throw UnimplementedError('firebaseServiceProvider harus di-override di main().');
});

/// true = build ini sudah dikonfigurasi Firebase (mode online aktif).
final isOnlineModeProvider = Provider<bool>((ref) => ref.watch(firebaseServiceProvider).isOnline);

/// null kalau mode lokal — pemakai cukup cek null, tidak perlu try/catch.
final eventRepositoryProvider = Provider<EventRepository?>((ref) {
  final fb = ref.watch(firebaseServiceProvider);
  return fb.isOnline ? EventRepository(fb) : null;
});

/// Acara yang diikuti pemain saat ini (real-time). null = mode lokal /
/// belum daftar / acara dihapus admin.
final currentEventProvider = StreamProvider<EventInfo?>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  final code = ref.watch(sessionProvider.select((s) => s.isOnlinePlayer ? s.eventCode : ''));
  if (repo == null || code.isEmpty) return Stream.value(null);
  return repo.watchEvent(code);
});

/// Leaderboard online acara saat ini: TOP-50 real-time (tanpa no HP).
final onlinePlayersProvider = StreamProvider<List<PlayerRecord>>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  final code = ref.watch(sessionProvider.select((s) => s.isOnlinePlayer ? s.eventCode : ''));
  if (repo == null || code.isEmpty) return Stream.value(const []);
  return repo.watchPlayers(code);
});

/// Peringkat & total peserta lewat count aggregate. Dihitung ulang saat skor
/// sendiri berubah atau TOP-50 bergerak (murah: 2 aggregate read).
final onlineRankProvider = FutureProvider<({int rank, int total})?>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  final session = ref.watch(sessionProvider);
  if (repo == null || !session.isOnlinePlayer) return null;
  ref.watch(onlinePlayersProvider); // pemicu refresh saat papan bergerak
  try {
    return await repo.fetchRank(session.eventCode, session.totalScore);
  } catch (_) {
    return null;
  }
});

// ------------------------------------------------------------------- admin

/// Status login admin online (stream auth instance 'admin').
final adminSignedInProvider = StreamProvider<bool>((ref) {
  final fb = ref.watch(firebaseServiceProvider);
  return fb.adminSignedInStream;
});

final adminEventsProvider = StreamProvider<List<EventInfo>>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  final signedIn = ref.watch(adminSignedInProvider).valueOrNull ?? false;
  if (repo == null || !signedIn) return Stream.value(const []);
  return repo.adminWatchEvents();
});

final adminEventProvider = StreamProvider.family<EventInfo?, String>((ref, code) {
  final repo = ref.watch(eventRepositoryProvider);
  if (repo == null) return Stream.value(null);
  return repo.adminWatchEvent(code);
});

final adminPlayersProvider = StreamProvider.family<List<PlayerRecord>, String>((ref, code) {
  final repo = ref.watch(eventRepositoryProvider);
  if (repo == null) return Stream.value(const []);
  return repo.adminWatchPlayers(code);
});

/// Statistik seluruh peserta (aggregate), di-refresh tiap daftar live berubah.
final adminStatsProvider = FutureProvider.family<({int total, int finished, int avgScore}), String>((ref, code) async {
  final repo = ref.watch(eventRepositoryProvider);
  if (repo == null) return (total: 0, finished: 0, avgScore: 0);
  ref.watch(adminPlayersProvider(code));
  return repo.adminFetchStats(code);
});
