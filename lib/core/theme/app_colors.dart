import 'package:flutter/material.dart';

/// Color tokens — satu-satunya sumber warna di app.
/// Nilai mengikuti `DESIGN.md` (Technical Flat / Terminal Brutalism):
/// dark navy ground, amber untuk aksi, teal untuk progres.
abstract class AppColors {
  // Surfaces
  static const ground = Color(0xFF0B1220);
  static const surface = Color(0xFF131C2E);
  static const surfaceRaised = Color(0xFF1B2740);
  static const surfaceDim = Color(0xFF0F1829);
  static const surfaceHighest = Color(0xFF232E45);

  // Borders
  static const outline = Color(0xFF2A3850);
  static const outlineSubtle = Color(0xFF1B2740);

  // Text
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFFC3CCDB);
  static const textMuted = Color(0xFF9AA8BF);
  static const textDisabled = Color(0xFF6B7A94);

  // Action (amber) — hanya untuk hal yang bisa ditekan / sedang aktif.
  static const accent = Color(0xFFF5A524);
  static const accentPressed = Color(0xFFD98E19);
  static const onAccent = Color(0xFF0B1220);

  // Progress / success (teal)
  static const success = Color(0xFF2DD4BF);
  static const successText = Color(0xFF5EEAD4);
  static const successSurface = Color(0xFF113A36);
  static const successOutline = Color(0xFF1F5F58);

  // Feedback
  static const warning = Color(0xFFFBBF24);
  static const warningSurface = Color(0xFF2A2235);
  static const danger = Color(0xFFFDA4AF);
  static const dangerSurface = Color(0xFF3A1D22);

  // Bonus rooms
  static const bonusAI = Color(0xFFA78BFA);
  static const bonusCyber = Color(0xFFF97316);

  // Warna pembeda untuk data/kabel di mini-game (bukan untuk aksi)
  static const dataSky = Color(0xFF38BDF8);
  static const dataPink = Color(0xFFF472B6);

  /// Background yang "diwarnai" tipis oleh warna robot avatar pemain.
  /// Tetap gelap (kontras teks aman), hanya nuansanya yang ikut avatar.
  static Color tintedGround(Color? tint) =>
      tint == null ? ground : Color.alphaBlend(tint.withValues(alpha: 0.13), ground);

  // Scrim untuk modal
  static const scrim = Color(0xCC0B1220);
}
