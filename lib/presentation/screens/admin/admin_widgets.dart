import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/player_record.dart';
import '../../../data/models/player_session.dart';
import '../../../data/models/room_meta.dart';
import '../../../data/models/room_settings.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

// Widget bersama panel admin lokal (AdminScreen) & online (OnlineAdminScreen).

/// Bottom sheet detail satu pemain (skor per ruangan).
void showAdminPlayerDetail(BuildContext context, PlayerRecord record, {Widget? extraActions}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      side: BorderSide(color: AppColors.outline, width: 1.5),
    ),
    builder: (ctx) => AdminPlayerDetailSheet(record: record, extraActions: extraActions),
  );
}

class AdminPlayerTile extends StatelessWidget {
  final PlayerRecord record;

  /// Tandai dengan pill (mis. 'Aktif' di panel lokal, 'Pemenang' di online).
  final bool isCurrent;
  final String badge;
  final VoidCallback onTap;
  const AdminPlayerTile({
    super.key,
    required this.record,
    required this.isCurrent,
    required this.onTap,
    this.badge = 'Aktif',
  });

  @override
  Widget build(BuildContext context) {
    final variant = RobotAvatars.at(record.avatarIndex);
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      radius: AppRadius.md,
      borderColor: isCurrent ? AppColors.accent : AppColors.outline,
      onTap: onTap,
      child: Row(
        children: [
          RobotAvatar(variant: variant, size: 44),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(record.name, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (isCurrent) AppPill.accent(label: badge),
                  ],
                ),
                Text(
                  record.phone.isEmpty
                      ? (record.school.isEmpty ? '-' : record.school)
                      : '${record.school.isEmpty ? '-' : record.school} · ${PhoneFormat.pretty(record.phone)}',
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${record.totalScore} XP', style: AppTypography.numberSm.copyWith(fontSize: 13, color: AppColors.accent)),
                    const SizedBox(width: AppSpacing.xs),
                    Text('${record.roomsCompleted}/${record.roomsTotal} ruang', style: AppTypography.captionXs),
                    const Spacer(),
                    AppPill(
                      label: record.finished ? 'Selesai' : 'Berjalan',
                      foreground: record.finished ? AppColors.success : AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminPlayerDetailSheet extends StatelessWidget {
  final PlayerRecord record;

  /// Tombol tambahan di bawah (mis. "Tetapkan pemenang" di panel online).
  final Widget? extraActions;
  const AdminPlayerDetailSheet({super.key, required this.record, this.extraActions});

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.xl + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.outline, borderRadius: BorderRadius.circular(AppRadius.pill)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                RobotAvatar(variant: RobotAvatars.at(record.avatarIndex), size: 52),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.name, style: AppTypography.headlineSm),
                      Text(record.school.isEmpty ? '-' : record.school, style: AppTypography.caption),
                      if (record.phone.isNotEmpty) Text(PhoneFormat.pretty(record.phone), style: AppTypography.caption),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: StatTile(value: '${record.totalScore}', caption: 'XP', valueColor: AppColors.accent)),
                const SizedBox(width: 10),
                Expanded(child: StatTile(value: '${record.roomsCompleted}/${record.roomsTotal}', caption: 'Ruang', valueColor: AppColors.success)),
                const SizedBox(width: 10),
                Expanded(child: StatTile(value: record.finished ? 'Selesai' : 'Jalan', caption: 'Status')),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Mulai: ${_fmt(record.startedAt)}  ·  Terakhir: ${_fmt(record.lastPlayedAt)}', style: AppTypography.captionXs),
            const SizedBox(height: AppSpacing.md),
            const SectionLabel('Skor per ruangan'),
            const SizedBox(height: AppSpacing.xs),
            for (final meta in RoomCatalog.all)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(meta.icon, size: 16, color: meta.accent),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(child: Text(meta.title, style: AppTypography.bodySm)),
                    Text(
                      (record.roomScores[meta.id.name] ?? 0) == 0 ? '-' : '${record.roomScores[meta.id.name]} XP',
                      style: AppTypography.numberSm.copyWith(fontSize: 13, color: (record.roomScores[meta.id.name] ?? 0) == 0 ? AppColors.textDisabled : AppColors.success),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            if (extraActions != null) ...[extraActions!, const SizedBox(height: AppSpacing.xs)],
            SecondaryButton(label: 'Tutup', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

class AdminRoomSettingTile extends StatelessWidget {
  final RoomMeta meta;
  final bool enabled;
  final int xp;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onXp;
  const AdminRoomSettingTile({
    super.key,
    required this.meta,
    required this.enabled,
    required this.xp,
    required this.onToggle,
    required this.onXp,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
      radius: AppRadius.md,
      color: enabled ? AppColors.surface : AppColors.surfaceDim,
      child: Row(
        children: [
          Icon(meta.icon, size: 20, color: enabled ? meta.accent : AppColors.textDisabled),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${meta.order}. ${meta.title}',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('${meta.isBonus ? 'Bonus' : 'Core'} · ${meta.mechanic}', style: AppTypography.captionXs, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          _XpStepper(value: xp, enabled: enabled, onChanged: onXp),
          const SizedBox(width: 4),
          Switch(value: enabled, onChanged: onToggle),
        ],
      ),
    );
  }
}

class _XpStepper extends StatelessWidget {
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;
  const _XpStepper({required this.value, required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, bool can, VoidCallback fn) => InkWell(
          onTap: enabled && can ? fn : null,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, size: 16, color: enabled && can ? AppColors.textPrimary : AppColors.textDisabled),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.remove_rounded, value > RoomSettings.minXp, () => onChanged(value - RoomSettings.xpStep)),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppTypography.numberSm.copyWith(fontSize: 13, color: enabled ? AppColors.accent : AppColors.textDisabled),
          ),
        ),
        btn(Icons.add_rounded, value < RoomSettings.maxXp, () => onChanged(value + RoomSettings.xpStep)),
      ],
    );
  }
}

class AdminActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool danger;
  final VoidCallback onTap;
  const AdminActionRow({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: SurfaceCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        radius: AppRadius.md,
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700, color: color)),
                  Text(subtitle, style: AppTypography.captionXs),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
