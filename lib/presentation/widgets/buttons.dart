import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Tombol amber 54px — satu-satunya tombol "aksi utama" di tiap layar.
/// [success] = varian teal setelah puzzle terpecahkan.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool success;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.success = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = success
        ? FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.onAccent,
          )
        : null;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: style,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label),
            if (icon != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(icon, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Icon button 44x44 dengan surface + border (DESIGN.md "Icon Button").
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Color? iconColor;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: semanticLabel,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SizedBox(
            width: AppSize.iconButton,
            height: AppSize.iconButton,
            child: Icon(icon, size: 20, color: iconColor ?? AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Pill kecil (badge status, "Lanjut", "BONUS", koleksi).
class AppPill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final Color? border;
  final IconData? icon;
  final Color? iconColor;

  const AppPill({
    super.key,
    required this.label,
    this.background = AppColors.surface,
    this.foreground = AppColors.textSecondary,
    this.border = AppColors.outline,
    this.icon,
    this.iconColor,
  });

  const AppPill.accent({super.key, required this.label})
      : background = AppColors.accent,
        foreground = AppColors.onAccent,
        border = null,
        icon = null,
        iconColor = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: border == null ? null : Border.all(color: border!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: iconColor ?? foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTypography.labelBadge.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
