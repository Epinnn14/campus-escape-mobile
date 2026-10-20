import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Type scale — Space Grotesk untuk judul & angka, Manrope untuk body.
///
/// Catatan offline-first: google_fonts fetch + cache font saat pertama
/// dipakai. Untuk build final di booth tanpa internet, bundle font ke
/// `assets/fonts/` dan ganti `GoogleFonts.x(` dengan `TextStyle(fontFamily:`.
abstract class AppTypography {
  static TextStyle _grotesk({
    required double size,
    required double height,
    double letterSpacing = 0,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: height / size,
        letterSpacing: letterSpacing,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle _manrope({
    required double size,
    required double height,
    FontWeight weight = FontWeight.w500,
    double letterSpacing = 0,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: letterSpacing,
        color: color,
      );

  // Display / headline (Space Grotesk 700)
  static TextStyle get displayLarge =>
      _grotesk(size: 44, height: 46, letterSpacing: -0.88);
  static TextStyle get displayTimer =>
      _grotesk(size: 40, height: 44, letterSpacing: -0.8);
  static TextStyle get headlineLg =>
      _grotesk(size: 28, height: 34, letterSpacing: -0.28);
  static TextStyle get headlineMd => _grotesk(size: 22, height: 28);
  static TextStyle get headlineSm => _grotesk(size: 18, height: 24);
  static TextStyle get titleMd => _grotesk(size: 16, height: 20);
  static TextStyle get numberLg => _grotesk(size: 24, height: 26);
  static TextStyle get numberSm => _grotesk(size: 14, height: 16);

  // Body (Manrope)
  static TextStyle get bodyLg => _manrope(size: 16, height: 24);
  static TextStyle get bodyMd => _manrope(size: 14, height: 20);
  static TextStyle get bodySm =>
      _manrope(size: 13, height: 18, weight: FontWeight.w400);
  static TextStyle get caption =>
      _manrope(size: 12, height: 16, color: AppColors.textMuted);
  static TextStyle get captionXs =>
      _manrope(size: 11, height: 14, color: AppColors.textMuted);

  // Labels
  static TextStyle get labelSection => _manrope(
        size: 12,
        height: 16,
        weight: FontWeight.w700,
        letterSpacing: 1.44,
        color: AppColors.textMuted,
      );
  static TextStyle get labelButton =>
      _manrope(size: 16, height: 20, weight: FontWeight.w700);
  static TextStyle get labelButtonSm =>
      _manrope(size: 14, height: 18, weight: FontWeight.w600);
  static TextStyle get labelBadge => _manrope(
        size: 11,
        height: 14,
        weight: FontWeight.w700,
        letterSpacing: 0.44,
      );
  static TextStyle get labelNav =>
      _manrope(size: 10, height: 12, weight: FontWeight.w700);

  // Monospace untuk potongan kode (Ruang SE, Database, Cyber)
  static TextStyle get code => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );
}
