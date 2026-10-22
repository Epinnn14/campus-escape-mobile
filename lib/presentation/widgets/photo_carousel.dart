import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/socs_fact.dart';

/// Gambar aset dengan fallback kalau file belum diganti / hilang.
class CampusImage extends StatelessWidget {
  final String asset;
  final BoxFit fit;

  /// Lebar decode (px). Default: lebar layar × DPR. Isi kecil (mis. 160)
  /// untuk thumbnail supaya bitmap 1200 px tidak di-decode penuh.
  final int? cacheWidth;
  const CampusImage({super.key, required this.asset, this.fit = BoxFit.cover, this.cacheWidth});

  @override
  Widget build(BuildContext context) {
    final width = cacheWidth ??
        (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round().clamp(360, 1600);
    return Image.asset(
      asset,
      fit: fit,
      cacheWidth: width,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.surfaceRaised,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textDisabled),
      ),
    );
  }
}

/// Carousel foto kampus yang berputar terus (infinite loop) dan bisa
/// auto-play. Dipakai di Home dan Galeri.
class LoopingPhotoCarousel extends StatefulWidget {
  final List<CampusPhoto> photos;
  final double height;
  final double viewportFraction;
  final bool autoPlay;
  final Duration interval;
  final bool showCaption;
  final void Function(int index)? onTap;

  const LoopingPhotoCarousel({
    super.key,
    this.photos = CampusPhotos.all,
    required this.height,
    this.viewportFraction = 0.86,
    this.autoPlay = true,
    this.interval = const Duration(seconds: 4),
    this.showCaption = true,
    this.onTap,
  });

  @override
  State<LoopingPhotoCarousel> createState() => _LoopingPhotoCarouselState();
}

class _LoopingPhotoCarouselState extends State<LoopingPhotoCarousel> {
  // Mulai dari "tengah" supaya bisa digeser ke kiri maupun kanan tanpa mentok.
  static const int _base = 100000;
  late final PageController _ctrl =
      PageController(initialPage: _base, viewportFraction: widget.viewportFraction);
  int _page = _base;
  Timer? _timer;

  int get _index => _page % widget.photos.length;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!widget.autoPlay || widget.photos.length < 2) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted || !_ctrl.hasClients) return;
      _ctrl.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: Listener(
            // Saat pengguna menyentuh, hentikan auto-play sebentar lalu lanjut.
            onPointerDown: (_) => _timer?.cancel(),
            onPointerUp: (_) => _startTimer(),
            onPointerCancel: (_) => _startTimer(),
            child: PageView.builder(
              controller: _ctrl,
              // itemCount null = tak terbatas → berputar terus.
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final p = photos[i % photos.length];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Material(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      side: const BorderSide(color: AppColors.outline),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: widget.onTap == null ? null : () => widget.onTap!(i % photos.length),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CampusImage(asset: p.asset),
                          if (widget.showCaption)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.sm, AppSpacing.lg, AppSpacing.sm, AppSpacing.sm,
                                ),
                                color: AppColors.scrim,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.title, style: AppTypography.titleMd, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(
                                      p.caption,
                                      style: AppTypography.captionXs.copyWith(color: AppColors.textSecondary),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < photos.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == _index ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i == _index ? AppColors.accent : AppColors.outline,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
