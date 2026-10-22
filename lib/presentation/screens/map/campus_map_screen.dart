import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/room_progress_provider.dart';
import '../../../application/providers/room_settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../../data/models/room_progress.dart';
import '../../../data/models/socs_fact.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/photo_carousel.dart';

/// Peta Jalur bergaya "level map" santai: jalur berkelok dari bawah (ruang 1)
/// ke atas (bonus 2), node bulat bernomor, bintang untuk ruang selesai, dan
/// di sisi jalur ada foto BINUS @Bekasi + logo BINUS / HIMTI.
/// Semua posisi dihitung dari lebar layar supaya pas di HP apa pun.
class CampusMapScreen extends ConsumerStatefulWidget {
  const CampusMapScreen({super.key});

  @override
  ConsumerState<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends ConsumerState<CampusMapScreen> {
  final _scroll = ScrollController();
  bool _jumped = false;

  static const _rowHeight = 132.0;
  static const _nodeSize = 64.0;
  static const _headerHeight = 150.0;
  static const _labelWidth = 124.0;
  // Posisi horizontal relatif (0..1) tiap node, dari ruang 1 sampai 10 —
  // sengaja berkelok kiri-kanan supaya ada ruang untuk dekorasi di sisinya.
  static const _xs = [0.16, 0.64, 0.20, 0.72, 0.24, 0.76, 0.18, 0.74, 0.26, 0.68];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Offset _center(int index, int total, double width) {
    final usable = width - AppSpacing.screenH * 2 - _nodeSize;
    final x = AppSpacing.screenH + _xs[index % _xs.length] * usable + _nodeSize / 2;
    final y = _headerHeight + (total - 1 - index) * _rowHeight + _nodeSize / 2 + 16;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(roomProgressProvider);
    final progressOf = {for (final r in rooms) r.roomId: r};
    final done = ref.watch(completedCountProvider);
    final next = ref.watch(nextRoomProvider);
    final metas = ref.watch(activeRoomsProvider);
    final totals = ref.watch(roomTotalsProvider);
    final total = metas.length;
    final completed = done.core + done.bonus;
    final width = MediaQuery.sizeOf(context).width;
    final canvasHeight = _headerHeight + total * _rowHeight + AppSpacing.xxl + 24;

    if (!_jumped) {
      _jumped = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scroll.hasClients) return;
        var idx = next == null ? -1 : metas.indexWhere((m) => m.id == next.roomId);
        if (idx < 0) idx = total - 1;
        final target = (_center(idx, total, width).dy - 280).clamp(0.0, _scroll.position.maxScrollExtent);
        _scroll.jumpTo(target);
      });
    }

    final centers = [for (var i = 0; i < total; i++) _center(i, total, width)];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        controller: _scroll,
        child: SizedBox(
          height: canvasHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ---- Jalur (sungai + garis + gelembung) ----
              Positioned.fill(
                child: CustomPaint(
                  painter: _TrailPainter(
                    centers: centers,
                    rooms: [for (final m in metas) progressOf[m.id]!],
                  ),
                ),
              ),

              // ---- Dekorasi: foto kampus & logo di sisi jalur ----
              ..._decorations(context, centers, width),

              // ---- Header ----
              Positioned(
                left: AppSpacing.screenH,
                right: AppSpacing.screenH,
                top: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScreenHeader(
                      title: 'Peta Jalur',
                      subtitle: '$completed dari $total ruangan selesai',
                      trailing: AppPill(
                        label: '${total == 0 ? 0 : (completed * 100 / total).round()}%',
                        foreground: AppColors.success,
                        icon: Icons.flag_outlined,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ProgressRail(value: total == 0 ? 0 : completed / total),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      totals.bonus > 0 && done.core == totals.core
                          ? 'Ruang bonus terbuka! Tinggal ${totals.bonus} pintu lagi.'
                          : 'Mulai dari bawah. Ruang berikutnya terbuka setelah ruang sebelumnya selesai.',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),

              // ---- Node ----
              for (var i = 0; i < total; i++)
                _buildNode(
                  context,
                  meta: metas[i],
                  progress: progressOf[metas[i].id]!,
                  center: centers[i],
                  isHere: next?.roomId == metas[i].id,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Foto kampus di sisi yang berlawanan dengan node (tiap 2 node), dan logo
  /// di antaranya. Ukuran mengikuti lebar layar.
  List<Widget> _decorations(BuildContext context, List<Offset> centers, double width) {
    final out = <Widget>[];
    const photos = CampusPhotos.all;
    const logos = [BrandLogos.binus, BrandLogos.himti];
    var photoIdx = 0;
    var logoIdx = 0;

    for (var i = 0; i < centers.length; i++) {
      final c = centers[i];
      final nodeOnLeft = c.dx < width / 2;
      // Area kosong di sisi berlawanan node, dijaga tidak menabrak label node.
      final left = nodeOnLeft
          ? math.max(c.dx + _labelWidth / 2 + 6, width * 0.52)
          : AppSpacing.screenH.toDouble();
      final right = nodeOnLeft
          ? width - AppSpacing.screenH
          : math.min(c.dx - _labelWidth / 2 - 6, width * 0.48);
      final slotW = right - left;
      if (slotW < 90) continue;

      if (i.isEven) {
        final photo = photos[photoIdx++ % photos.length];
        final w = math.min(slotW, 168.0);
        final h = w * 0.62;
        out.add(Positioned(
          left: nodeOnLeft ? right - w : left,
          top: c.dy - h / 2 - 6,
          width: w,
          height: h,
          child: Transform.rotate(
            angle: (i % 4 == 0 ? -1 : 1) * 0.05,
            child: _PhotoDeco(photo: photo, onTap: () => context.go('/collection')),
          ),
        ));
      } else if (i % 4 == 1 || i == centers.length - 1) {
        final logo = logos[logoIdx++ % logos.length];
        out.add(Positioned(
          left: nodeOnLeft ? right - 60 : left + 8,
          top: c.dy - 30,
          child: _LogoDeco(asset: logo),
        ));
      }
    }
    return out;
  }

  Widget _buildNode(
    BuildContext context, {
    required RoomMeta meta,
    required RoomProgress progress,
    required Offset center,
    required bool isHere,
  }) {
    final locked = progress.status == RoomStatus.locked;
    final doneRoom = progress.isCompleted;

    final Color fill;
    final Color border;
    final Color numberColor;
    if (doneRoom) {
      fill = AppColors.success;
      border = AppColors.successText;
      numberColor = AppColors.ground;
    } else if (isHere) {
      fill = AppColors.accent;
      border = AppColors.accentPressed;
      numberColor = AppColors.onAccent;
    } else if (locked) {
      fill = AppColors.surfaceDim;
      border = AppColors.outlineSubtle;
      numberColor = AppColors.textDisabled;
    } else {
      fill = AppColors.surfaceRaised;
      border = meta.accent;
      numberColor = AppColors.textPrimary;
    }

    return Positioned(
      left: center.dx - _labelWidth / 2,
      top: center.dy - _nodeSize / 2 - 30,
      width: _labelWidth,
      child: Column(
        children: [
          SizedBox(
            height: 24,
            child: isHere
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.place_rounded, size: 12, color: AppColors.onAccent),
                        const SizedBox(width: 4),
                        Text('KAMU DI SINI', style: AppTypography.labelBadge.copyWith(fontSize: 9, color: AppColors.onAccent)),
                      ],
                    ),
                  )
                : doneRoom
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var s = 0; s < 3; s++)
                            Icon(
                              s < progress.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 18,
                              color: s < progress.stars ? AppColors.accent : AppColors.outline,
                            ),
                        ],
                      )
                    : meta.isBonus
                        ? AppPill(label: 'BONUS', foreground: locked ? AppColors.textDisabled : meta.accent)
                        : const SizedBox.shrink(),
          ),
          const SizedBox(height: 6),
          Semantics(
            button: !locked,
            label: '${meta.title}, ${locked ? 'terkunci' : doneRoom ? 'selesai' : 'terbuka'}',
            child: Material(
              color: fill,
              shape: CircleBorder(side: BorderSide(color: border, width: 3)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: locked ? null : () => context.push(meta.route),
                child: SizedBox(
                  width: _nodeSize,
                  height: _nodeSize,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        meta.order.toString().padLeft(2, '0'),
                        style: AppTypography.headlineMd.copyWith(fontSize: 22, color: numberColor),
                      ),
                      if (locked)
                        const Positioned(
                          bottom: -2,
                          right: -2,
                          child: Icon(Icons.lock_rounded, size: 16, color: AppColors.textMuted),
                        ),
                      if (doneRoom)
                        const Positioned(
                          bottom: -4,
                          right: -4,
                          child: Icon(Icons.check_circle_rounded, size: 20, color: AppColors.ground),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              meta.shortTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w700,
                color: locked ? AppColors.textDisabled : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoDeco extends StatelessWidget {
  final CampusPhoto photo;
  final VoidCallback onTap;
  const _PhotoDeco({required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.outline, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CampusImage(asset: photo.asset),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: AppColors.scrim,
                child: Text(
                  photo.title,
                  style: AppTypography.captionXs.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoDeco extends StatelessWidget {
  final String asset;
  const _LogoDeco({required this.asset});

  @override
  Widget build(BuildContext context) {
    // Latar terang supaya logo resmi (teks hitam/biru) tetap terbaca di tema gelap.
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline, width: 2),
      ),
      child: CampusImage(asset: asset, fit: BoxFit.contain, cacheWidth: 120),
    );
  }
}

/// Menggambar "sungai" lebar di bawah jalur, jalur utama (solid untuk yang
/// sudah dilewati, putus-putus untuk yang terkunci), dan gelembung kecil
/// di sepanjang jalur seperti level map game.
class _TrailPainter extends CustomPainter {
  final List<Offset> centers;
  final List<RoomProgress> rooms;
  _TrailPainter({required this.centers, required this.rooms});

  Path _segment(Offset a, Offset b) {
    // Kurva S: kontrol vertikal supaya jalur melengkung halus antar node.
    final k = (a.dy - b.dy).abs() * 0.55;
    return Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(a.dx, a.dy - k, b.dx, b.dy + k, b.dx, b.dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;

    // 1) Sungai: satu path menerus, stroke lebar & lembut.
    final river = Path()..moveTo(centers.first.dx, centers.first.dy + 40);
    river.lineTo(centers.first.dx, centers.first.dy);
    for (var i = 0; i < centers.length - 1; i++) {
      final a = centers[i], b = centers[i + 1];
      final k = (a.dy - b.dy).abs() * 0.55;
      river.cubicTo(a.dx, a.dy - k, b.dx, b.dy + k, b.dx, b.dy);
    }
    river.lineTo(centers.last.dx, centers.last.dy - 48);
    canvas.drawPath(
      river,
      Paint()
        ..color = AppColors.surfaceRaised
        ..style = PaintingStyle.stroke
        ..strokeWidth = 34
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      river,
      Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round,
    );

    // 2) Jalur per segmen + gelembung.
    final bubble = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < centers.length - 1; i++) {
      final seg = _segment(centers[i], centers[i + 1]);
      final fromDone = rooms[i].isCompleted;
      final toLocked = rooms[i + 1].status == RoomStatus.locked;
      final color = fromDone && !toLocked
          ? AppColors.success
          : fromDone
              ? AppColors.success.withValues(alpha: 0.55)
              : AppColors.outline;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      for (final metric in seg.computeMetrics()) {
        if (toLocked) {
          const dash = 9.0, gap = 8.0;
          var t = 0.0;
          while (t < metric.length) {
            canvas.drawPath(metric.extractPath(t, math.min(t + dash, metric.length)), paint);
            t += dash + gap;
          }
        } else {
          canvas.drawPath(seg, paint);
        }
        // Gelembung kecil di sepanjang jalur.
        bubble.color = (fromDone ? AppColors.success : AppColors.outline).withValues(alpha: 0.5);
        for (var t = 22.0; t < metric.length - 22; t += 26) {
          final tangent = metric.getTangentForOffset(t);
          if (tangent == null) continue;
          final r = 2.0 + (t ~/ 26) % 3;
          canvas.drawCircle(tangent.position + Offset(-tangent.vector.dy, tangent.vector.dx) * 11, r, bubble);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) => old.rooms != rooms || old.centers != centers;
}
