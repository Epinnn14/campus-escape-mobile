import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/online_provider.dart';
import '../../application/providers/session_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'buttons.dart';
import 'common.dart';

/// Banner status acara untuk peserta mode online: nama acara + kode,
/// dan pengumuman pemenang kalau sudah ditetapkan admin. Tidak merender
/// apa pun di mode lokal, jadi aman dipasang di Home & Leaderboard.
class EventStatusBanner extends ConsumerWidget {
  /// true = hanya tampilkan kalau ada pemenang (status acara disembunyikan).
  final bool winnerOnly;
  const EventStatusBanner({super.key, this.winnerOnly = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (!session.isOnlinePlayer) return const SizedBox.shrink();
    final event = ref.watch(currentEventProvider).valueOrNull;
    if (event == null) return const SizedBox.shrink();

    final winner = event.winner;
    if (winner != null) {
      final isMe = winner.uid == session.onlineUid;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: SurfaceCard(
          radius: AppRadius.xl,
          color: isMe ? AppColors.accent.withValues(alpha: 0.16) : AppColors.surfaceRaised,
          borderColor: AppColors.accent,
          child: Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: 30),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? 'SELAMAT, KAMU PEMENANGNYA!' : 'PEMENANG ${event.name.toUpperCase()}',
                      style: AppTypography.labelSection.copyWith(fontSize: 11, color: AppColors.accent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      winner.name,
                      style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${winner.school.isEmpty ? '-' : winner.school} · ${winner.score} XP',
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (winnerOnly) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
        radius: AppRadius.md,
        color: AppColors.surfaceDim,
        borderColor: event.active ? AppColors.success : AppColors.outline,
        child: Row(
          children: [
            Icon(
              event.active ? Icons.wifi_tethering_rounded : Icons.lock_clock_rounded,
              size: 18,
              color: event.active ? AppColors.success : AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                event.active
                    ? '${event.name} · live, skor masuk leaderboard acara'
                    : '${event.name} · ditutup admin, skor tidak tersimpan',
                style: AppTypography.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppPill(label: event.code, foreground: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
