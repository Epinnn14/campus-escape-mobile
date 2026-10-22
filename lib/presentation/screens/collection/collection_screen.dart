import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/socs_fact.dart';
import '../../../data/models/socs_profile.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/photo_carousel.dart';

/// "Kenali BINUS @Bekasi" — halaman profil kampus & program CSSE.
/// Semua terbuka sejak awal. Urutan: video profil SoCS + tentang → kenapa
/// CSSE → perjalanan akademik 4 tahun → fasilitas (foto berputar) → dosen →
/// HIMTI & komunitas → fakta singkat (bergulir) → sumber.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final photoHeight = ((width - AppSpacing.screenH * 2) * 0.58).clamp(180.0, 270.0);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(
              title: 'Kenali BINUS @Bekasi',
              subtitle: 'School of Computer Science · Computer Science – Software Engineering',
            ),
            const SizedBox(height: AppSpacing.md),

            // ---- 1. Video + tentang SoCS ----
            const _VideoCard(),
            const SizedBox(height: AppSpacing.sm),
            for (final p in SocsProfile.about) ...[
              Text(p, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary, height: 1.5)),
              const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.lg),

            // ---- 2. Kenapa CSSE ----
            const SectionLabel('Kenapa Computer Science – Software Engineering?'),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Tempat Computer Science bertemu Software Engineering: membangun software dengan '
              'fondasi ilmiah yang kuat dan praktik rekayasa yang sistematis.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final h in SocsProfile.whyCsse) ...[
              _HighlightCard(item: h, color: AppColors.bonusAI),
              const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.lg),

            // ---- 3. Academic journey ----
            const SectionLabel('Perjalanan akademik 4 tahun'),
            const SizedBox(height: AppSpacing.xxs),
            Text('Dari fondasi yang kuat sampai solusi software siap industri. Tap tiap tahun untuk detailnya.',
                style: AppTypography.caption),
            const SizedBox(height: AppSpacing.sm),
            const _JourneyTimeline(),
            const SizedBox(height: AppSpacing.lg),

            // ---- 4. Fasilitas ----
            const SectionLabel('Fasilitas kampus'),
            const SizedBox(height: AppSpacing.xxs),
            Text('Geser atau biarkan berputar. Tap foto untuk melihat lebih besar.', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.sm),
            LoopingPhotoCarousel(
              height: photoHeight,
              viewportFraction: 0.92,
              interval: const Duration(seconds: 5),
              onTap: (i) => _openPhoto(context, i),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ---- 5. Dosen ----
            const SectionLabel('Dosen program CSSE'),
            const SizedBox(height: AppSpacing.xxs),
            Text(SocsProfile.lecturersIntro, style: AppTypography.caption),
            const SizedBox(height: AppSpacing.sm),
            for (final l in SocsProfile.lecturers) ...[
              _LecturerTile(lecturer: l, onTap: () => _openLecturer(context, l)),
              const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.lg),

            // ---- 6. HIMTI ----
            const Row(
              children: [
                _LogoChip(asset: BrandLogos.himti),
                SizedBox(width: AppSpacing.xs),
                Expanded(child: SectionLabel('HIMTI & kehidupan mahasiswa')),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(SocsProfile.himtiIntro, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: AppSpacing.sm),
            for (final h in SocsProfile.himti) ...[
              _HighlightCard(item: h, color: AppColors.success),
              const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.lg),

            // ---- 7. Fakta singkat (rolling) ----
            Row(
              children: [
                const SectionLabel('Fakta singkat'),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text('Bergulir otomatis · tap untuk baca', style: AppTypography.captionXs,
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              height: 290,
              child: _RollingFacts(onTap: (f) => _openFact(context, f)),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ---- 8. Sumber ----
            const SectionLabel('Sumber'),
            const SizedBox(height: AppSpacing.xs),
            for (final s in SocsProfile.sources) _SourceRow(link: s),
            const SizedBox(height: AppSpacing.xs),
            Text('Diakses 14 Oktober 2026. Video & teks profil: materi resmi SoCS BINUS.', style: AppTypography.captionXs),
          ],
        ),
      ),
    );
  }

  void _openPhoto(BuildContext context, int index) {
    showDialog<void>(context: context, builder: (ctx) => _PhotoViewer(initialIndex: index));
  }

  void _openLecturer(BuildContext context, Lecturer lecturer) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        side: BorderSide(color: AppColors.outline, width: 1.5),
      ),
      builder: (ctx) => _LecturerSheet(lecturer: lecturer),
    );
  }

  void _openFact(BuildContext context, SocsFact fact) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        side: BorderSide(color: AppColors.outline, width: 1.5),
      ),
      builder: (ctx) => _FactSheet(fact: fact),
    );
  }
}

Color categoryColor(FactCategory c) => switch (c) {
      FactCategory.kampus => AppColors.bonusCyber,
      FactCategory.program => AppColors.bonusAI,
      FactCategory.komunitas => AppColors.success,
      FactCategory.kompetisi => AppColors.accent,
    };

// ---------------------------------------------------------------- Video

/// Video profil SoCS dari asset. Poster dulu (hemat memori), video baru
/// dimuat saat tombol play ditekan. Tap area video untuk play/pause.
class _VideoCard extends StatefulWidget {
  const _VideoCard();

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  VideoPlayerController? _ctrl;
  bool _loading = false;
  bool _muted = false;
  double _speed = 1.0;
  String? _error;

  static const _speeds = [1.0, 1.5, 2.0];

  Future<void> _start() async {
    if (_ctrl != null || _loading) return;
    setState(() => _loading = true);
    final c = VideoPlayerController.asset(SocsProfile.videoAsset);
    try {
      await c.initialize();
      await c.setVolume(1.0);
      c.addListener(_onTick);
      await c.play();
      if (!mounted) {
        c.dispose();
        return;
      }
      setState(() {
        _ctrl = c;
        _loading = false;
      });
    } catch (e) {
      c.dispose();
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Video belum bisa diputar di perangkat ini.';
        });
      }
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _toggle() {
    final c = _ctrl;
    if (c == null) return;
    c.value.isPlaying ? c.pause() : c.play();
  }

  void _toggleMute() {
    final c = _ctrl;
    if (c == null) return;
    setState(() => _muted = !_muted);
    c.setVolume(_muted ? 0 : 1);
  }

  /// Lompat ±detik; dibatasi 0..durasi.
  Future<void> _skip(int seconds) async {
    final c = _ctrl;
    if (c == null || !c.value.isInitialized) return;
    final target = c.value.position + Duration(seconds: seconds);
    final max = c.value.duration;
    await c.seekTo(target < Duration.zero ? Duration.zero : (target > max ? max : target));
  }

  /// Kecepatan 1x → 1.5x → 2x → 1x.
  Future<void> _cycleSpeed() async {
    final c = _ctrl;
    if (c == null) return;
    final next = _speeds[(_speeds.indexOf(_speed) + 1) % _speeds.length];
    setState(() => _speed = next);
    await c.setPlaybackSpeed(next);
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onTick);
    _ctrl?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = _ctrl;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: c != null && c.value.isInitialized ? c.value.aspectRatio : 16 / 9,
            child: c == null
                ? InkWell(
                    onTap: _loading ? null : _start,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const CampusImage(asset: SocsProfile.videoPoster),
                        Container(color: AppColors.ground.withValues(alpha: 0.35)),
                        Center(
                          child: _loading
                              ? const SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.accent))
                              : Container(
                                  width: 64,
                                  height: 64,
                                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                                  child: const Icon(Icons.play_arrow_rounded, size: 40, color: AppColors.onAccent),
                                ),
                        ),
                        if (_error != null)
                          Positioned(
                            left: AppSpacing.sm,
                            right: AppSpacing.sm,
                            bottom: AppSpacing.sm,
                            child: StatusBanner(kind: BannerKind.warning, text: _error!),
                          ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: _toggle,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        VideoPlayer(c),
                        if (!c.value.isPlaying)
                          Container(
                            color: AppColors.ground.withValues(alpha: 0.35),
                            alignment: Alignment.center,
                            child: const Icon(Icons.play_arrow_rounded, size: 56, color: AppColors.textPrimary),
                          ),
                      ],
                    ),
                  ),
          ),
          if (c != null) ...[
            // Progress bar: area sentuh diperbesar (padding vertikal) supaya
            // gampang digeser di HP; allowScrubbing = tap/geser untuk seek.
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 2, AppSpacing.sm, 0),
              child: Row(
                children: [
                  Text(_fmt(c.value.position), style: AppTypography.captionXs),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: VideoProgressIndicator(
                      c,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      colors: const VideoProgressColors(
                        playedColor: AppColors.accent,
                        bufferedColor: AppColors.surfaceHighest,
                        backgroundColor: AppColors.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(_fmt(c.value.duration), style: AppTypography.captionXs),
                ],
              ),
            ),
            // Tombol kontrol eksplisit — tap di atas video tidak selalu sampai
            // ke Flutter di web (elemen <video> menelan sentuhan), jadi
            // pause/lompat/kecepatan disediakan sebagai tombol sungguhan.
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _VideoButton(
                    icon: Icons.replay_10_rounded,
                    label: '-10 dtk',
                    onTap: () => _skip(-10),
                  ),
                  _VideoButton(
                    icon: c.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    label: c.value.isPlaying ? 'Pause' : 'Putar',
                    onTap: _toggle,
                    primary: true,
                  ),
                  _VideoButton(
                    icon: Icons.forward_10_rounded,
                    label: '+10 dtk',
                    onTap: () => _skip(10),
                  ),
                  _VideoButton(
                    icon: Icons.speed_rounded,
                    label: '${_speed == 1.0 ? '1' : _speed.toString()}x',
                    onTap: _cycleSpeed,
                    active: _speed != 1.0,
                  ),
                  _VideoButton(
                    icon: _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    label: _muted ? 'Bisu' : 'Suara',
                    onTap: _toggleMute,
                    active: _muted,
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(SocsProfile.videoTitle, style: AppTypography.titleMd),
                const SizedBox(height: 2),
                Text(SocsProfile.videoCaption, style: AppTypography.captionXs),
                if (c != null && _muted) ...[
                  const SizedBox(height: 4),
                  Text('Suara dimatikan — tap ikon speaker untuk menyalakan.', style: AppTypography.captionXs.copyWith(color: AppColors.warning)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol kontrol video: ikon + label kecil, area sentuh ≥ 44 px.
class _VideoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool active;
  const _VideoButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = primary ? AppColors.onAccent : (active ? AppColors.accent : AppColors.textPrimary);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: primary ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: primary ? 26 : 22, color: fg),
            Text(label, style: AppTypography.captionXs.copyWith(color: fg, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Sections

class _HighlightCard extends StatelessWidget {
  final HighlightItem item;
  final Color color;
  const _HighlightCard({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border(left: BorderSide(color: color, width: 3)),
            ),
            child: Icon(item.icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(item.body, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyTimeline extends StatefulWidget {
  const _JourneyTimeline();

  @override
  State<_JourneyTimeline> createState() => _JourneyTimelineState();
}

class _JourneyTimelineState extends State<_JourneyTimeline> {
  int _open = 0;

  @override
  Widget build(BuildContext context) {
    const paths = SocsProfile.journey;
    return Column(
      children: [
        for (var i = 0; i < paths.length; i++)
          _JourneyStep(
            path: paths[i],
            isLast: i == paths.length - 1,
            expanded: _open == i,
            onTap: () => setState(() => _open = _open == i ? -1 : i),
          ),
      ],
    );
  }
}

class _JourneyStep extends StatelessWidget {
  final AcademicPath path;
  final bool isLast;
  final bool expanded;
  final VoidCallback onTap;
  const _JourneyStep({required this.path, required this.isLast, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.success;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Garis waktu + nomor tahun
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: expanded ? color : AppColors.surfaceRaised,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Text(
                    '${path.year}',
                    style: AppTypography.numberSm.copyWith(fontSize: 13, color: expanded ? AppColors.ground : color),
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: AppColors.outline)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.xs),
              child: SurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                onTap: onTap,
                borderColor: expanded ? color : AppColors.outline,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TAHUN KE-${path.year}', style: AppTypography.labelSection.copyWith(fontSize: 10)),
                              Text(path.title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        Icon(expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.textMuted),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(path.summary, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                    if (expanded) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Container(height: 1, color: AppColors.outlineSubtle),
                      const SizedBox(height: AppSpacing.xs),
                      Text(path.detail, style: AppTypography.bodySm.copyWith(height: 1.45)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LecturerTile extends StatelessWidget {
  final Lecturer lecturer;
  final VoidCallback? onTap;
  const _LecturerTile({required this.lecturer, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: onTap,
      child: Row(
        children: [
          lecturer.photo == null
              ? InitialsAvatar(initials: lecturer.initials, size: 52)
              : Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.outline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CampusImage(asset: lecturer.photo!, fit: BoxFit.cover),
                ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lecturer.name, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                Text(lecturer.role, style: AppTypography.caption),
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

/// Pop-up dosen (bottom sheet, gaya sama dengan fakta & ruangan): foto besar,
/// nama, jabatan, program, dan link profil resmi. Tidak ada biodata karangan —
/// hanya data dari halaman People CSSE.
class _LecturerSheet extends StatelessWidget {
  final Lecturer lecturer;
  const _LecturerSheet({required this.lecturer});

  static const _sourceUrl = 'https://binus.ac.id/bekasi/csse/';

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final width = MediaQuery.sizeOf(context).width;
    final photoSize = (width * 0.42).clamp(120.0, 180.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.xl + bottom),
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
          Center(
            child: Container(
              width: photoSize,
              height: photoSize,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.outline),
              ),
              clipBehavior: Clip.antiAlias,
              child: lecturer.photo == null
                  ? Center(child: InitialsAvatar(initials: lecturer.initials, size: photoSize * 0.6))
                  : CampusImage(asset: lecturer.photo!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const AppPill(label: 'DOSEN CSSE', foreground: AppColors.bonusAI),
          const SizedBox(height: AppSpacing.xs),
          Text(lecturer.name, style: AppTypography.headlineMd),
          const SizedBox(height: AppSpacing.xxs),
          Text(lecturer.role, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Program Computer Science – Software Engineering, School of Computer Science BINUS @Bekasi. '
            'Kalau ketemu saat kunjungan, tanya langsung soal mata kuliah, proyek, dan karier di bidangnya.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          SurfaceCard(
            color: AppColors.surfaceDim,
            borderColor: AppColors.outlineSubtle,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
            onTap: () {
              Clipboard.setData(const ClipboardData(text: _sourceUrl));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link profil dosen disalin.')));
            },
            child: Row(
              children: [
                const Icon(Icons.link_rounded, size: 16, color: AppColors.textMuted),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text('$_sourceUrl (People)', style: AppTypography.captionXs, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text('Salin', style: AppTypography.captionXs.copyWith(color: AppColors.accent)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(label: 'Tutup', onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

class _LogoChip extends StatelessWidget {
  final String asset;
  const _LogoChip({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.outline),
      ),
      child: CampusImage(asset: asset, fit: BoxFit.contain),
    );
  }
}

class _SourceRow extends StatelessWidget {
  final SourceLink link;
  const _SourceRow({required this.link});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: link.url));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link sumber disalin.')));
        },
        borderRadius: BorderRadius.circular(AppRadius.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.link_rounded, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(link.label, style: AppTypography.captionXs.copyWith(color: AppColors.textSecondary)),
                  Text(link.url, style: AppTypography.captionXs, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Text('Salin', style: AppTypography.captionXs.copyWith(color: AppColors.accent)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Fakta bergulir

/// Daftar info yang bergulir ke atas otomatis (loop tanpa henti). Pengguna
/// tetap bisa menggeser manual; auto-roll berhenti sementara saat disentuh.
class _RollingFacts extends StatefulWidget {
  final void Function(SocsFact) onTap;
  const _RollingFacts({required this.onTap});

  @override
  State<_RollingFacts> createState() => _RollingFactsState();
}

class _RollingFactsState extends State<_RollingFacts> {
  static const int _base = 100000;
  static const _facts = SocsFactCatalog.all;
  PageController? _ctrl;
  double _fraction = 0.34;
  Timer? _timer;

  PageController _controllerFor(double height) {
    final fraction = (92 / height).clamp(0.25, 0.5);
    if (_ctrl == null || (fraction - _fraction).abs() > 0.01) {
      final old = _ctrl;
      if (old != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
      _fraction = fraction;
      _ctrl = PageController(initialPage: _base, viewportFraction: fraction);
    }
    return _ctrl!;
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 3200), (_) {
      final ctrl = _ctrl;
      if (!mounted || ctrl == null || !ctrl.hasClients) return;
      ctrl.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final ctrl = _controllerFor(c.maxHeight.isFinite && c.maxHeight > 0 ? c.maxHeight : 300);
      return Listener(
        onPointerDown: (_) => _timer?.cancel(),
        onPointerUp: (_) => _start(),
        onPointerCancel: (_) => _start(),
        child: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
            stops: [0.0, 0.08, 0.92, 1.0],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: PageView.builder(
            controller: ctrl,
            scrollDirection: Axis.vertical,
            padEnds: false,
            itemBuilder: (context, i) {
              final fact = _facts[i % _facts.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _FactTile(fact: fact, onTap: () => widget.onTap(fact)),
              );
            },
          ),
        ),
      );
    });
  }
}

class _FactTile extends StatelessWidget {
  final SocsFact fact;
  final VoidCallback onTap;
  const _FactTile({required this.fact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(fact.category);
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      radius: AppRadius.md,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border(left: BorderSide(color: color, width: 3)),
            ),
            child: Icon(fact.icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fact.title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(fact.category.label, style: AppTypography.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _FactSheet extends StatelessWidget {
  final SocsFact fact;
  const _FactSheet({required this.fact});

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(fact.category);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.xl + bottom),
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
              Icon(fact.icon, size: 26, color: color),
              const SizedBox(width: AppSpacing.xs),
              AppPill(label: fact.category.label, foreground: color),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(fact.title, style: AppTypography.headlineMd),
          const SizedBox(height: AppSpacing.xs),
          Text(fact.body, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          SurfaceCard(
            color: AppColors.surfaceDim,
            borderColor: AppColors.outlineSubtle,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
            onTap: () {
              Clipboard.setData(ClipboardData(text: fact.sourceUrl));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link sumber disalin.')));
            },
            child: Row(
              children: [
                const Icon(Icons.link_rounded, size: 16, color: AppColors.textMuted),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(fact.sourceUrl, style: AppTypography.captionXs, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text('Salin', style: AppTypography.captionXs.copyWith(color: AppColors.accent)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(label: 'Tutup', onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Foto

class _PhotoViewer extends StatefulWidget {
  final int initialIndex;
  const _PhotoViewer({required this.initialIndex});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final PageController _ctrl = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const photos = CampusPhotos.all;
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
              child: PageView.builder(
                controller: _ctrl,
                itemCount: photos.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => CampusImage(asset: photos[i].asset),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(photos[_index].title, style: AppTypography.headlineSm)),
                    Text('${_index + 1}/${photos.length}', style: AppTypography.captionXs),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(photos[_index].caption, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    AppIconButton(
                      icon: Icons.chevron_left_rounded,
                      semanticLabel: 'Foto sebelumnya',
                      onPressed: _index == 0
                          ? null
                          : () => _ctrl.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AppIconButton(
                      icon: Icons.chevron_right_rounded,
                      semanticLabel: 'Foto berikutnya',
                      onPressed: _index == photos.length - 1
                          ? null
                          : () => _ctrl.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                    ),
                    const Spacer(),
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Tutup')),
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
