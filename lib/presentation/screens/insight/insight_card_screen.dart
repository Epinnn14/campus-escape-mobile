import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/room_progress_provider.dart';
import '../../../application/providers/room_settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

/// Insight Card: muncul setelah puzzle selesai, bisa dibuka ulang dari Galeri.
class InsightCardScreen extends ConsumerWidget {
  final RoomId roomId;
  final bool fromGallery;
  const InsightCardScreen({super.key, required this.roomId, this.fromGallery = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = RoomCatalog.byId(roomId);
    final progress = ref.watch(roomProgressProvider.notifier).of(roomId);
    ref.watch(roomProgressProvider);
    final allDone = ref.watch(completedCountProvider);
    final totals = ref.watch(roomTotalsProvider);
    final everything = totals.total > 0 && allDone.core + allDone.bonus == totals.total;

    return Scaffold(
      backgroundColor: AppColors.scrim,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenH),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.outline, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppPill(
                          label: fromGallery ? 'Kartu wawasan' : 'Insight terbuka',
                          background: AppColors.successSurface,
                          foreground: AppColors.successText,
                          border: AppColors.successOutline,
                          icon: Icons.lock_open_rounded,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border(top: BorderSide(color: meta.accent, width: 3)),
                        ),
                        child: Icon(meta.icon, size: 22, color: meta.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(meta.levelLabel.toUpperCase(), style: AppTypography.labelSection),
                  Text(meta.title, style: AppTypography.headlineMd),
                  const SizedBox(height: AppSpacing.md),
                  Text(meta.insightTitle, style: AppTypography.headlineSm),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    meta.insightBody,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                  ),
                  if (progress.isCompleted) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            value: '+${progress.score}',
                            caption: 'XP',
                            valueColor: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: StatTile(
                            value: '★' * progress.stars,
                            caption: 'Bintang',
                            valueColor: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: StatTile(
                            value: _mmss(progress.timeSpentSeconds),
                            caption: 'Waktu',
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  if (fromGallery)
                    PrimaryButton(label: 'Tutup', onPressed: () => context.pop())
                  else ...[
                    PrimaryButton(
                      label: everything ? 'Lihat ringkasan akhir' : 'Kembali ke peta',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => everything ? context.go('/summary') : context.go('/map'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SecondaryButton(
                      label: 'Lihat galeri koleksi',
                      onPressed: () => context.go('/collection'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _mmss(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
