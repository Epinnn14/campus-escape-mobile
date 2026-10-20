import 'package:flutter/material.dart';
import '../../data/models/player_session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Label section uppercase ("CORE ROOM · 8 LEVEL").
class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(text.toUpperCase(), style: AppTypography.labelSection),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Card dasar: surface + border 1px + radius 16.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double radius;
  final VoidCallback? onTap;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color = AppColors.surface,
    this.borderColor = AppColors.outline,
    this.radius = AppRadius.lg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}

/// Stat tile: angka besar + caption.
class StatTile extends StatelessWidget {
  final String value;
  final String caption;
  final Color valueColor;
  final IconData? icon;

  const StatTile({
    super.key,
    required this.value,
    required this.caption,
    this.valueColor = AppColors.textPrimary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: valueColor),
            const SizedBox(height: AppSpacing.xxs),
          ],
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppTypography.numberLg.copyWith(color: valueColor)),
          ),
          const SizedBox(height: 2),
          Text(caption, style: AppTypography.captionXs, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Avatar robot berwarna (12 varian, dipilih saat registrasi).
class RobotAvatar extends StatelessWidget {
  final RobotVariant variant;
  final double size;
  final bool selected;
  const RobotAvatar({
    super.key,
    required this.variant,
    this.size = 48,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: variant.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size / 3),
        border: Border.all(
          color: selected ? AppColors.accent : variant.color.withValues(alpha: 0.5),
          width: selected ? 2 : 1,
        ),
      ),
      child: RobotMark(size: size * 0.66, color: variant.color),
    );
  }
}

/// Maskot robot Campus Escape: siluet robot melambai (kepala kotak membulat
/// dengan antena & kuping, badan, satu tangan terangkat). Digambar dengan
/// CustomPainter supaya warnanya bisa mengikuti avatar / accent ruangan.
class RobotMark extends StatelessWidget {
  final double size;
  final Color color;
  const RobotMark({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _RobotPainter(color)),
    );
  }
}

class _RobotPainter extends CustomPainter {
  final Color color;
  _RobotPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Koordinat dalam kotak 100x100, lalu diskalakan.
    final s = size.width / 100;
    canvas.scale(s, s);
    final fill = Paint()..color = color;
    final hole = Paint()..color = AppColors.ground;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

    // Antena
    canvas.drawLine(const Offset(32, 20), const Offset(28, 8), stroke);
    canvas.drawLine(const Offset(68, 20), const Offset(72, 8), stroke);
    canvas.drawCircle(const Offset(27, 6), 4.5, fill);
    canvas.drawCircle(const Offset(73, 6), 4.5, fill);
    // Kuping
    canvas.drawRRect(rr(14, 30, 9, 16, 4), fill);
    canvas.drawRRect(rr(77, 30, 9, 16, 4), fill);
    // Kepala
    canvas.drawRRect(rr(22, 18, 56, 38, 11), fill);
    // Mata + mulut (lubang)
    canvas.drawCircle(const Offset(38, 35), 5.5, hole);
    canvas.drawCircle(const Offset(62, 35), 5.5, hole);
    canvas.drawRRect(rr(41, 45, 18, 5, 2.5), hole);
    // Leher
    canvas.drawRRect(rr(44, 55, 12, 6, 2), fill);
    // Badan
    canvas.drawRRect(rr(28, 60, 44, 30, 9), fill);
    canvas.drawCircle(const Offset(50, 70), 3, hole);
    // Lengan kiri melambai (terangkat), lengan kanan turun
    canvas.drawLine(const Offset(28, 70), const Offset(14, 54), stroke);
    canvas.drawCircle(const Offset(12, 50), 5.5, fill);
    canvas.drawLine(const Offset(72, 70), const Offset(84, 82), stroke);
    canvas.drawCircle(const Offset(86, 85), 5.5, fill);
    // Kaki
    canvas.drawRRect(rr(33, 88, 12, 10, 4), fill);
    canvas.drawRRect(rr(55, 88, 12, 10, 4), fill);
  }

  @override
  bool shouldRepaint(_RobotPainter old) => old.color != color;
}

/// Progress bar flat: rail surfaceRaised, fill teal.
class ProgressRail extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  const ProgressRail({
    super.key,
    required this.value,
    this.color = AppColors.success,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        color: color,
        backgroundColor: AppColors.surfaceRaised,
      ),
    );
  }
}

/// Progress tersegmentasi (satu segmen per ruangan).
class SegmentedProgress extends StatelessWidget {
  final int total;
  final int completed;
  final int? activeIndex;
  const SegmentedProgress({
    super.key,
    required this.total,
    required this.completed,
    this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: i < completed
                    ? AppColors.success
                    : i == activeIndex
                        ? AppColors.accent
                        : AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          if (i < total - 1) const SizedBox(width: 5),
        ],
      ],
    );
  }
}

/// Avatar inisial regu.
class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final bool ring;
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.ring = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(size / 3),
        border: Border.all(
          color: ring ? AppColors.accent : AppColors.outline,
          width: ring ? 2 : 1,
        ),
      ),
      child: Text(
        initials,
        style: AppTypography.headlineSm.copyWith(
          fontSize: size * 0.36,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

enum BannerKind { success, warning, danger, info }

/// Banner status (benar / salah / belum lengkap / info).
class StatusBanner extends StatelessWidget {
  final String text;
  final BannerKind kind;
  const StatusBanner({super.key, required this.text, required this.kind});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (kind) {
      BannerKind.success => (AppColors.successSurface, AppColors.successText, Icons.check_circle_outline),
      BannerKind.warning => (AppColors.warningSurface, AppColors.warning, Icons.error_outline),
      BannerKind.danger => (AppColors.dangerSurface, AppColors.danger, Icons.cancel_outlined),
      BannerKind.info => (AppColors.surfaceRaised, AppColors.textPrimary, Icons.info_outline),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySm.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel visual bantu di ruangan (array cells, diagram, tabel) — latar
/// surfaceDim + label kecil di atasnya.
class HelperPanel extends StatelessWidget {
  final String label;
  final Widget child;
  const HelperPanel({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTypography.labelSection.copyWith(fontSize: 11)),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

/// Header dua sisi standar: judul kiri, aksi kanan.
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.sm)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headlineMd),
              if (subtitle != null)
                Text(subtitle!, style: AppTypography.bodySm.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
