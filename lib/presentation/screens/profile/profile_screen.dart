import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/insight_provider.dart';
import '../../../application/providers/leaderboard_provider.dart';
import '../../../application/providers/local_storage_provider.dart';
import '../../../application/providers/player_archive_provider.dart';
import '../../../application/providers/room_settings_provider.dart';
import '../../../application/providers/room_progress_provider.dart';
import '../../../application/providers/session_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/player_session.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

/// Profil pemain: identitas, stats, pencapaian, pengaturan.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset progres sesi?'),
        content: const Text(
          'Semua progres ruangan, skor, dan kartu wawasan di perangkat ini akan dihapus. '
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    // Simpan snapshot ke arsip admin dulu supaya datanya tidak hilang.
    ref.read(playerArchiveProvider.notifier).syncCurrent();
    await ref.read(localStorageProvider).clearAll();
    ref.read(roomProgressProvider.notifier).resetAll();
    ref.read(insightProvider.notifier).resetAll();
    ref.read(sessionProvider.notifier).resetToFresh();
    if (context.mounted) context.go('/landing');
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final current = ref.read(sessionProvider).avatarIndex;
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        side: BorderSide(color: AppColors.outline, width: 1.5),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih robot temanmu', style: AppTypography.headlineSm),
            const SizedBox(height: AppSpacing.sm),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppSpacing.xs,
                crossAxisSpacing: AppSpacing.xs,
                mainAxisExtent: 76,
              ),
              itemCount: RobotAvatars.all.length,
              itemBuilder: (_, i) => InkWell(
                onTap: () => Navigator.of(ctx).pop(i),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Column(
                  children: [
                    RobotAvatar(variant: RobotAvatars.all[i], size: 48, selected: i == current),
                    const SizedBox(height: 4),
                    Text(
                      RobotAvatars.all[i].name,
                      style: AppTypography.captionXs.copyWith(fontSize: 9),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) ref.read(sessionProvider.notifier).setAvatar(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final rooms = ref.watch(roomProgressProvider);
    final done = ref.watch(completedCountProvider);
    final totals = ref.watch(roomTotalsProvider);
    final rank = ref.watch(myRankProvider);
    final completed = rooms.where((r) => r.isCompleted).toList();
    final avgSeconds = completed.isEmpty
        ? 0
        : completed.map((r) => r.timeSpentSeconds).reduce((a, b) => a + b) ~/ completed.length;
    final totalStars = completed.fold<int>(0, (s, r) => s + r.stars);

    final achievements = <(String, IconData, bool)>[
      ('Pemula', Icons.flag_outlined, completed.isNotEmpty),
      ('3 Bintang', Icons.star_outline_rounded, completed.any((r) => r.stars == 3)),
      ('Setengah jalan', Icons.route_outlined, done.core >= totals.core ~/ 2),
      ('Semua core', Icons.verified_outlined, totals.core > 0 && done.core == totals.core),
      ('Bonus hunter', Icons.auto_awesome_outlined, totals.bonus > 0 && done.bonus == totals.bonus),
    ];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: 'Profil', subtitle: 'Akun pemain di sesi ini'),
            const SizedBox(height: AppSpacing.md),

            // Identity
            SurfaceCard(
              radius: AppRadius.xl,
              child: Row(
                children: [
                  RobotAvatar(variant: session.avatar, size: 64, selected: true),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session.displayName, style: AppTypography.headlineMd),
                        Text(
                          session.schoolOrigin.isEmpty
                              ? 'Asal sekolah belum diisi'
                              : session.schoolOrigin,
                          style: AppTypography.caption,
                        ),
                        if (session.phone.isNotEmpty)
                          Text(PhoneFormat.pretty(session.phone), style: AppTypography.caption),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            AppPill(
                              label: session.avatar.name,
                              foreground: AppColors.successText,
                              background: AppColors.successSurface,
                              border: AppColors.successOutline,
                            ),
                            AppPill(label: 'ID ${session.verificationCode}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Stats
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                StatTile(
                  value: '${done.core + done.bonus}/${totals.total}',
                  caption: 'Ruang selesai',
                  valueColor: AppColors.success,
                ),
                StatTile(value: '${session.totalScore}', caption: 'Skor XP', valueColor: AppColors.accent),
                StatTile(value: formatDuration(Duration(seconds: avgSeconds)), caption: 'Rata-rata waktu/ruang'),
                StatTile(value: '#$rank · $totalStars★', caption: 'Peringkat · bintang'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Achievements
            const SectionLabel('Pencapaian'),
            const SizedBox(height: AppSpacing.xs),
            // Rata kanan-kiri: tiap badge dapat lebar yang sama.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (label, icon, unlocked) in achievements)
                  Expanded(child: _Badge(label: label, icon: icon, unlocked: unlocked)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Settings
            const SectionLabel('Pengaturan'),
            const SizedBox(height: AppSpacing.xs),
            _SettingRow(
              icon: Icons.smart_toy_outlined,
              label: 'Ganti robot avatar',
              onTap: () => _pickAvatar(context, ref),
            ),
            _SettingRow(
              icon: Icons.workspace_premium_outlined,
              label: 'Ringkasan akhir & sertifikat',
              onTap: () => context.push('/summary'),
            ),
            _SettingRow(
              icon: Icons.restart_alt_rounded,
              label: 'Reset progres sesi',
              danger: true,
              onTap: () => _confirmReset(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool unlocked;
  const _Badge({required this.label, required this.icon, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: unlocked ? AppColors.successSurface : AppColors.surfaceDim,
            shape: BoxShape.circle,
            border: Border.all(color: unlocked ? AppColors.successOutline : AppColors.outline),
          ),
          child: Icon(icon, size: 22, color: unlocked ? AppColors.success : AppColors.textDisabled),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTypography.captionXs.copyWith(
            color: unlocked ? AppColors.textSecondary : AppColors.textDisabled,
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _SettingRow({required this.icon, required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 12),
        radius: AppRadius.md,
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(label, style: AppTypography.bodyMd.copyWith(color: color))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
