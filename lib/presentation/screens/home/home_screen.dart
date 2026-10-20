import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/leaderboard_provider.dart';
import '../../../application/providers/room_progress_provider.dart';
import '../../../application/providers/room_settings_provider.dart';
import '../../../application/providers/session_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/common.dart';
import '../../widgets/event_banner.dart';
import '../../widgets/photo_carousel.dart';
import '../admin/admin_screen.dart';

/// Home = dashboard pemain: progres, "Lanjutkan", shortcut, dan galeri
/// foto BINUS @Bekasi untuk promosi kampus.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final done = ref.watch(completedCountProvider);
    final totals = ref.watch(roomTotalsProvider);
    final next = ref.watch(nextRoomProvider);
    final rank = ref.watch(myRankProvider);
    final allDone = totals.total > 0 && done.core + done.bonus == totals.total;
    final activeRooms = ref.watch(activeRoomsProvider);
    final completedCount = done.core + done.bonus;
    final activeIdx = next == null ? -1 : activeRooms.indexWhere((m) => m.id == next.roomId);
    final activeIndex = activeIdx < 0 ? null : activeIdx;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                RobotAvatar(variant: session.avatar, size: 52),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Halo, selamat datang', style: AppTypography.caption),
                      Text(
                        session.displayName,
                        style: AppTypography.headlineMd.copyWith(fontSize: 20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(session.avatar.name, style: AppTypography.captionXs.copyWith(color: session.avatar.color)),
                    ],
                  ),
                ),
                // Ikon kunci = akses admin ke panel admin.
                const AdminKeyButton(),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Mode online: status acara / pengumuman pemenang.
            const EventStatusBanner(),

            // Progress card
            SurfaceCard(
              radius: AppRadius.xl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Progres escape'),
                  const SizedBox(height: AppSpacing.xxs),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.numberLg.copyWith(fontSize: 26),
                      children: [
                        TextSpan(text: '$completedCount '),
                        TextSpan(
                          text: '/ ${totals.total} ruangan',
                          style: AppTypography.bodyLg.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedProgress(
                    total: totals.total,
                    completed: completedCount,
                    activeIndex: activeIndex,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTypography.caption,
                          children: [
                            const TextSpan(text: 'Skor '),
                            TextSpan(
                              text: '${session.totalScore} XP',
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        done.core == totals.core ? 'Ruang bonus terbuka' : 'Ruang bonus terkunci',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            if (allDone)
              _ContinueCard(
                icon: Icons.workspace_premium_outlined,
                label: 'Selesai',
                title: 'Semua ruangan terbuka!',
                subtitle: 'Lihat ringkasan & unduh sertifikatmu',
                onTap: () => context.push('/summary'),
              )
            else if (next != null)
              _ContinueCard(
                icon: RoomCatalog.byId(next.roomId).icon,
                iconColor: RoomCatalog.byId(next.roomId).accent,
                label: 'Lanjutkan',
                title: RoomCatalog.byId(next.roomId).title,
                subtitle: 'Mini-game: ${RoomCatalog.byId(next.roomId).mechanic}',
                onTap: () => context.push(RoomCatalog.byId(next.roomId).route),
              ),
            const SizedBox(height: AppSpacing.md),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.7,
              children: [
                _QuickAction(
                  icon: Icons.map_outlined,
                  color: AppColors.success,
                  title: 'Peta Jalur',
                  subtitle: '${totals.core} ruang · ${totals.bonus} bonus',
                  onTap: () => context.go('/map'),
                ),
                _QuickAction(
                  icon: Icons.school_outlined,
                  color: AppColors.bonusAI,
                  title: 'Kenali Kampus',
                  subtitle: 'Video, fasilitas & info CSSE',
                  onTap: () => context.go('/collection'),
                ),
                _QuickAction(
                  icon: Icons.emoji_events_outlined,
                  color: AppColors.accent,
                  title: 'Leaderboard',
                  subtitle: 'Peringkat #$rank saat ini',
                  onTap: () => context.go('/leaderboard'),
                ),
                _QuickAction(
                  icon: Icons.person_outline_rounded,
                  color: AppColors.bonusCyber,
                  title: 'Profil',
                  subtitle: '${done.core + done.bonus} ruang selesai',
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Galeri foto kampus (promosi)
            SectionLabel(
              'Kenali BINUS @Bekasi',
              trailing: TextButton(
                onPressed: () => context.go('/collection'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Lihat semua'),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            LoopingPhotoCarousel(
              height: ((MediaQuery.sizeOf(context).width - AppSpacing.screenH * 2) * 0.52).clamp(150.0, 230.0),
              onTap: (_) => context.go('/collection'),
            ),
            const SizedBox(height: AppSpacing.md),
            SurfaceCard(
              color: AppColors.surfaceDim,
              borderColor: AppColors.outlineSubtle,
              padding: const EdgeInsets.all(AppSpacing.sm),
              onTap: () => context.go('/collection'),
              child: Row(
                children: [
                  const Icon(Icons.school_outlined, size: 20, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Computer Science – Software Engineering BINUS @Bekasi: 4 tahun, gelar S.Kom., '
                      'belajar membangun software dari desain sampai deployment. Tonton video profilnya di tab Kampus.',
                      style: AppTypography.caption,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContinueCard({
    required this.icon,
    this.iconColor = AppColors.accent,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: AppColors.surfaceRaised,
      borderColor: AppColors.accent,
      radius: AppRadius.xl,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.ground, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: AppTypography.labelSection.copyWith(fontSize: 11, color: AppColors.accent)),
                Text(title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      borderColor: AppColors.outlineSubtle,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 24, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
              Text(subtitle, style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }
}
