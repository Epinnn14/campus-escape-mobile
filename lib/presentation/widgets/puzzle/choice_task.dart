import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Mini-task pilihan ganda: pertanyaan + pill pilihan.
/// Jawaban benar/salah hanya dievaluasi saat "Cek Jawaban", jadi widget ini
/// cuma mengelola pilihan.
class ChoiceTask extends StatelessWidget {
  final String question;
  final List<String> options;
  final int? selected;
  final ValueChanged<int> onSelect;
  final Color accent;
  final bool enabled;
  final Widget? helper;

  const ChoiceTask({
    super.key,
    required this.question,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.accent,
    this.enabled = true,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (helper != null) ...[helper!, const SizedBox(height: AppSpacing.sm)],
          Text(question, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (var i = 0; i < options.length; i++)
                ChoicePill(
                  label: options[i],
                  selected: selected == i,
                  accent: accent,
                  onTap: enabled ? () => onSelect(i) : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback? onTap;

  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceRaised : AppColors.surfaceDim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        side: BorderSide(
          color: selected ? AppColors.accent : AppColors.outline,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded, size: 16, color: AppColors.accent),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
