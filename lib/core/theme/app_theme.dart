import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Dark-only theme. Semua komponen Material yang kepakai (button, input,
/// card, app bar, snackbar) di-style di sini supaya screen tinggal nyusun.
abstract class AppTheme {
  static ThemeData get dark => tinted(null);

  /// Tema dengan background yang ikut warna robot avatar ([tint] = warna
  /// avatar, null = default).
  static ThemeData tinted(Color? tint) {
    final base = ThemeData.dark(useMaterial3: true);
    final ground = AppColors.tintedGround(tint);
    return base.copyWith(
      scaffoldBackgroundColor: ground,
      canvasColor: ground,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        primaryContainer: AppColors.accentPressed,
        onPrimaryContainer: AppColors.onAccent,
        secondary: AppColors.success,
        onSecondary: AppColors.onAccent,
        secondaryContainer: AppColors.successSurface,
        onSecondaryContainer: AppColors.successText,
        tertiary: AppColors.bonusAI,
        onTertiary: AppColors.onAccent,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        surfaceContainerHighest: AppColors.surfaceRaised,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineSubtle,
        error: AppColors.danger,
        onError: AppColors.onAccent,
        errorContainer: AppColors.dangerSurface,
        onErrorContainer: AppColors.danger,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        headlineLarge: AppTypography.headlineLg,
        headlineMedium: AppTypography.headlineMd,
        headlineSmall: AppTypography.headlineSm,
        titleMedium: AppTypography.titleMd,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.bodySm,
        labelLarge: AppTypography.labelButton,
        labelMedium: AppTypography.labelButtonSm,
        labelSmall: AppTypography.labelBadge,
      ).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleMd,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.surfaceRaised;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accentPressed;
            }
            return AppColors.accent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textDisabled;
            }
            return AppColors.onAccent;
          }),
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(AppSize.primaryButton),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          textStyle: WidgetStatePropertyAll(AppTypography.labelButton),
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.outline),
          minimumSize: const Size.fromHeight(AppSize.secondaryButton),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.labelButtonSm,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: AppTypography.labelButtonSm,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 15,
        ),
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textDisabled),
        labelStyle: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        border: _inputBorder(AppColors.outline),
        enabledBorder: _inputBorder(AppColors.outline),
        focusedBorder: _inputBorder(AppColors.accent),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineSubtle,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceRaised,
        contentTextStyle: AppTypography.bodyMd,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.outline, width: 1.5),
        ),
        titleTextStyle: AppTypography.headlineSm,
        contentTextStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.onAccent
              : AppColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.surfaceRaised,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.outline),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.success,
        linearTrackColor: AppColors.surfaceRaised,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color),
      );
}
