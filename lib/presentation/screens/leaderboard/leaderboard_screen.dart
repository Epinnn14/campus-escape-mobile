import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/leaderboard_provider.dart';
import '../../../application/providers/online_provider.dart';
import '../../../application/providers/room_settings_provider.dart';
import '../../../application/providers/session_provider.dart';
import '../../../data/remote/event_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common.dart';
import '../../widgets/event_banner.dart';

/// Leaderboard — mode online: semua peserta acara real-time; mode lokal:
/// semua pemain yang pernah main di perangkat ini.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(leaderboardProvider);
    final myRank = ref.watch(myRankProvider);
    final totals = ref.watch(roomTotalsProvider);
    final me = entries.firstWhere((e) => e.isCurrentPlayer);
    // Pemain tepat di atas saya (kalau ada di daftar yang ditampilkan).
    final aboveIdx = entries.indexWhere((e) => e.rank == myRank - 1);
    final above = aboveIdx < 0 ? null : entries[aboveIdx];
    final gap = above == null ? 0 : above.totalScore - me.totalScore;
    final online = ref.watch(sessionProvider.select((s) => s.isOnlinePlayer));
    final event = online ? ref.watch(currentEventProvider).valueOrNull : null;
    final totalOnline = ref.watch(onlineTotalPlayersProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'Leaderboard',
              subtitle: online
                  ? '${totalOnline ?? entries.length} peserta ${event?.name ?? 'acara'} · top ${EventRepository.leaderboardTop} live'
                  : '${entries.length} pemain di perangkat ini',
            ),
            const SizedBox(height: AppSpacing.md),
            const EventStatusBanner(),

            // Kartu posisi kamu
            SurfaceCard(
              color: AppColors.surfaceRaised,
              borderColor: AppColors.accent,
              radius: AppRadius.xl,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('POSISI KAMU', style: AppTypography.labelSection.copyWith(fontSize: 11)),
                      Text('#$myRank', style: AppTypography.displayTimer.copyWith(color: AppColors.accent)),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(me.teamName, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                        Text('${me.totalScore} XP · ${me.roomsCompleted}/${totals.total} ruang',
                            style: AppTypography.caption),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          myRank == 1
                              ? 'Kamu di puncak. Pertahankan!'
                              : above == null
                                  ? 'Selesaikan ruangan lagi untuk naik ke top ${EventRepository.leaderboardTop}.'
                                  : 'Butuh $gap XP lagi untuk menyalip ${above.teamName}.',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionLabel('Peringkat pemain'),
            const SizedBox(height: AppSpacing.xs),
            for (final e in entries) ...[
              _RankRow(rank: e.rank, entry: e),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  const _RankRow({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
    final top3 = rank <= 3;
    final me = entry.isCurrentPlayer;
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
      radius: AppRadius.md,
      color: me ? AppColors.surfaceRaised : AppColors.surface,
      borderColor: me ? AppColors.accent : AppColors.outline,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: top3 ? AppColors.successSurface : AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              '$rank',
              style: AppTypography.numberSm.copyWith(
                color: top3 ? AppColors.successText : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.teamName,
                  style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(entry.schoolOrigin, style: AppTypography.captionXs),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.totalScore} XP', style: AppTypography.numberSm.copyWith(color: AppColors.accent)),
              Text('${entry.roomsCompleted} ruang', style: AppTypography.captionXs),
            ],
          ),
        ],
      ),
    );
  }
}
