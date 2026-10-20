import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/event_repository.dart';
import 'online_provider.dart';
import 'player_archive_provider.dart';
import 'room_progress_provider.dart';
import 'session_provider.dart';

/// LEADERBOARD_ENTRY di ERD.
/// - Mode online (pemain terdaftar ke acara): semua peserta acara dari
///   Firestore, real-time, HP masing-masing.
/// - Mode lokal: arsip semua pemain yang pernah main di perangkat ini +
///   pemain yang sedang aktif.
class LeaderboardEntry {
  final String sessionId;
  final String teamName;
  final String schoolOrigin;
  final int totalScore;
  final int roomsCompleted;
  final bool isCurrentPlayer;

  /// Peringkat (1-based). Mode online: pemain di luar TOP-50 tetap tahu
  /// peringkatnya dari count aggregate.
  final int rank;

  const LeaderboardEntry({
    required this.sessionId,
    required this.teamName,
    required this.schoolOrigin,
    required this.totalScore,
    required this.roomsCompleted,
    this.isCurrentPlayer = false,
    this.rank = 0,
  });

  LeaderboardEntry withRank(int r) => LeaderboardEntry(
        sessionId: sessionId,
        teamName: teamName,
        schoolOrigin: schoolOrigin,
        totalScore: totalScore,
        roomsCompleted: roomsCompleted,
        isCurrentPlayer: isCurrentPlayer,
        rank: r,
      );
}

/// Daftar peringkat termasuk pemain saat ini, sudah diurutkan.
final leaderboardProvider = Provider<List<LeaderboardEntry>>((ref) {
  final session = ref.watch(sessionProvider);
  final done = ref.watch(completedCountProvider);

  final me = LeaderboardEntry(
    sessionId: session.isOnlinePlayer ? session.onlineUid : session.sessionId,
    teamName: session.displayName,
    schoolOrigin: session.schoolOrigin.isEmpty ? 'Sekolahmu' : session.schoolOrigin,
    totalScore: session.totalScore,
    roomsCompleted: done.core + done.bonus,
    isCurrentPlayer: true,
  );
  // Online: pemain lain dari Firestore (diri sendiri selalu pakai data
  // lokal supaya skor langsung naik tanpa menunggu sinkronisasi).
  final source = session.isOnlinePlayer
      ? (ref.watch(onlinePlayersProvider).valueOrNull ?? const [])
      : ref.watch(playerArchiveProvider);
  final others = [
    for (final p in source)
      if (p.sessionId != me.sessionId)
        LeaderboardEntry(
          sessionId: p.sessionId,
          teamName: p.name,
          schoolOrigin: p.school,
          totalScore: p.totalScore,
          roomsCompleted: p.roomsCompleted,
        ),
  ];
  int cmp(LeaderboardEntry a, LeaderboardEntry b) {
    final byScore = b.totalScore.compareTo(a.totalScore);
    return byScore != 0 ? byScore : b.roomsCompleted.compareTo(a.roomsCompleted);
  }

  if (!session.isOnlinePlayer) {
    final list = [...others, me]..sort(cmp);
    return [for (var i = 0; i < list.length; i++) list[i].withRank(i + 1)];
  }

  // Online: `others` = TOP-50 server. Kalau skor saya masuk jajaran itu,
  // sisipkan di posisinya; kalau tidak, tempel di bawah dengan peringkat
  // dari aggregate (fallback: posisi setelah daftar).
  final top = [...others]..sort(cmp);
  final agg = ref.watch(onlineRankProvider).valueOrNull;
  final insideTop = top.length < EventRepository.leaderboardTop || cmp(me, top.last) <= 0;
  if (insideTop) {
    final list = [...top, me]..sort(cmp);
    return [for (var i = 0; i < list.length; i++) list[i].withRank(i + 1)];
  }
  final ranked = [for (var i = 0; i < top.length; i++) top[i].withRank(i + 1)];
  return [...ranked, me.withRank(agg?.rank ?? top.length + 1)];
});

final myRankProvider = Provider<int>((ref) {
  final list = ref.watch(leaderboardProvider);
  return list.firstWhere((e) => e.isCurrentPlayer).rank;
});

/// Total peserta acara (online) — null di mode lokal.
final onlineTotalPlayersProvider = Provider<int?>((ref) => ref.watch(onlineRankProvider).valueOrNull?.total);
