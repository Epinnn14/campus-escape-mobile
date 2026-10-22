import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Tekstur latar halus untuk seluruh app: grid titik + jalur "sirkuit" bersiku
/// dengan pad di ujungnya, warnanya ikut warna robot avatar. Dipasang di atas
/// konten dengan opasitas sangat rendah dan `IgnorePointer`, jadi tidak
/// mengganggu sentuhan dan tidak perlu mengubah background tiap screen.
///
/// Semua posisi dihitung relatif terhadap ukuran layar (bukan piksel tetap),
/// jadi tampilannya konsisten di iPhone kecil maupun Android lebar.
class AppBackdrop extends StatelessWidget {
  final Color tint;
  const AppBackdrop({super.key, required this.tint});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _BackdropPainter(tint), size: Size.infinite),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  final Color tint;
  _BackdropPainter(this.tint);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final unit = w / 16; // 1 "sel" grid ≈ 27 px di layar 430 px

    // 1. Grid titik — satu drawPoints (bukan ratusan drawCircle) supaya
    //    murah di-rasterisasi tiap frame.
    final dots = <Offset>[];
    for (double y = unit / 2; y < h; y += unit) {
      for (double x = unit / 2; x < w; x += unit) {
        dots.add(Offset(x, y));
      }
    }
    final dot = Paint()
      ..color = tint.withValues(alpha: 0.085)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(ui.PointMode.points, dots, dot);

    // 2. Jalur sirkuit bersiku (deterministik, supaya tidak "lompat" saat rebuild).
    final rnd = math.Random(2026);
    final trace = Paint()
      ..color = tint.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final pad = Paint()..color = tint.withValues(alpha: 0.22);
    final padHole = Paint()
      ..color = tint.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const cols = 16;
    final rows = (h / unit).floor();
    for (var i = 0; i < 14; i++) {
      var cx = rnd.nextInt(cols);
      var cy = rnd.nextInt(math.max(rows, 1));
      final path = Path()..moveTo((cx + 0.5) * unit, (cy + 0.5) * unit);
      final segments = 2 + rnd.nextInt(3);
      var horizontal = rnd.nextBool();
      for (var s = 0; s < segments; s++) {
        final len = 1 + rnd.nextInt(4);
        final dir = rnd.nextBool() ? 1 : -1;
        if (horizontal) {
          cx = (cx + dir * len).clamp(0, cols - 1);
        } else {
          cy = (cy + dir * len).clamp(0, math.max(rows - 1, 0));
        }
        path.lineTo((cx + 0.5) * unit, (cy + 0.5) * unit);
        horizontal = !horizontal;
      }
      canvas.drawPath(path, trace);
      final end = Offset((cx + 0.5) * unit, (cy + 0.5) * unit);
      canvas.drawCircle(end, 3.2, pad);
      canvas.drawCircle(end, 5.5, padHole);
    }

    // 3. Satu bentuk besar samar (cincin ganda) di kanan atas dan heksagon di
    //    kiri bawah — memberi "berat" visual tanpa foto.
    final big = Paint()
      ..color = tint.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final ringC = Offset(w * 0.92, h * 0.16);
    canvas.drawCircle(ringC, w * 0.30, big);
    canvas.drawCircle(ringC, w * 0.22, big);
    final arc = Paint()
      ..color = tint.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(Rect.fromCircle(center: ringC, radius: w * 0.26), -math.pi * 0.2, math.pi * 0.7, false, arc);

    final hexC = Offset(w * 0.08, h * 0.84);
    final hex = Path();
    for (var k = 0; k < 6; k++) {
      final a = math.pi / 3 * k - math.pi / 6;
      final p = Offset(hexC.dx + math.cos(a) * w * 0.26, hexC.dy + math.sin(a) * w * 0.26);
      if (k == 0) {
        hex.moveTo(p.dx, p.dy);
      } else {
        hex.lineTo(p.dx, p.dy);
      }
    }
    hex.close();
    canvas.drawPath(hex, big);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) => old.tint != tint;
}
