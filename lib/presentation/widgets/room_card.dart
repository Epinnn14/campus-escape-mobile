import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/room_meta.dart';
import '../../data/models/room_progress.dart';
import 'buttons.dart';

/// Card ruangan di grid peta (DESIGN.md "Room Card").
/// Accent ruangan HANYA di stripe 3px + ikon; state pakai amber/teal/abu.
class RoomCard extends StatelessWidget {
  final RoomMeta meta;
  final RoomProgress progress;
  final VoidCallback? onTap;

  const RoomCard({
    super.key,
    required this.meta,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = progress.status;
    final locked = status == RoomStatus.locked;
    final active = status == RoomStatus.active;
    final done = status == RoomStatus.completed;

    final border = done
        ? AppColors.successOutline
        : active
            ? AppColors.accent
            : locked
                ? AppColors.outlineSubtle
                : AppColors.outline;
    final bg = active ? AppColors.surfaceRaised : AppColors.surface;
    final titleColor = locked ? AppColors.textMuted : AppColors.textPrimary;
    final iconColor = locked ? AppColors.textDisabled : meta.accent;

    final meta_ = switch (status) {
      RoomStatus.completed =>
        'Selesai · ${_mmss(progress.timeSpentSeconds)}',
      RoomStatus.active => 'Sedang dimainkan',
      RoomStatus.unlocked => 'Terbuka',
      RoomStatus.locked => meta.isBonus ? 'Bonus · terkunci' : 'Terkunci',
    };

    Widget indicator = switch (status) {
      RoomStatus.completed => const Icon(
          Icons.check_circle,
          size: 18,
          color: AppColors.success,
          semanticLabel: 'Selesai',
        ),
      RoomStatus.active => const AppPill.accent(label: 'Lanjut'),
      RoomStatus.unlocked => const Icon(
          Icons.lock_open_rounded,
          size: 16,
          color: AppColors.textSecondary,
          semanticLabel: 'Terbuka',
        ),
      RoomStatus.locked => const Icon(
          Icons.lock_outline_rounded,
          size: 16,
          color: AppColors.textDisabled,
          semanticLabel: 'Terkunci',
        ),
    };

    return Opacity(
      opacity: locked ? 0.6 : 1,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: locked ? null : onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stripe accent 3px
              Container(height: 3, color: locked ? AppColors.outlineSubtle : meta.accent),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(meta.icon, size: 22, color: iconColor),
                        indicator,
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${meta.order} · ${meta.shortTitle}',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta_,
                      style: AppTypography.captionXs.copyWith(
                        color: done
                            ? AppColors.textMuted
                            : active
                                ? AppColors.textSecondary
                                : AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

/// Card horizontal untuk bonus room (dashed kalau terkunci).
class BonusRoomCard extends StatelessWidget {
  final RoomMeta meta;
  final RoomProgress progress;
  final VoidCallback? onTap;

  const BonusRoomCard({
    super.key,
    required this.meta,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = progress.status == RoomStatus.locked;
    final done = progress.isCompleted;
    final sub = done
        ? 'Selesai · +${progress.score} XP'
        : locked
            ? 'Buka setelah ${RoomCatalog.coreCount} core'
            : 'Terbuka · +${meta.xpReward} XP';

    return Material(
      color: locked ? AppColors.surfaceDim : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: done ? AppColors.successOutline : AppColors.outline,
        ),
      ),
      child: InkWell(
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Icon(meta.icon, size: 22, color: locked ? AppColors.textDisabled : meta.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${meta.order} · ${meta.shortTitle}',
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: locked ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(sub, style: AppTypography.captionXs.copyWith(color: AppColors.textDisabled)),
                  ],
                ),
              ),
              if (locked)
                const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.textDisabled)
              else if (done)
                const Icon(Icons.check_circle, size: 18, color: AppColors.success),
            ],
          ),
        ),
      ),
    );
  }
}
