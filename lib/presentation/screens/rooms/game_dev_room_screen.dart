import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/common.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 4 — Game Development: "Lompat Tepat Waktu".
/// Penanda bergerak bolak-balik; tekan Lompat saat penanda di zona hijau.
/// Inilah game loop: update posisi → gambar ke layar → baca input, berulang.
class GameDevRoomScreen extends StatefulWidget {
  const GameDevRoomScreen({super.key});

  @override
  State<GameDevRoomScreen> createState() => _GameDevRoomScreenState();
}

class _GameDevRoomScreenState extends State<GameDevRoomScreen>
    with SingleTickerProviderStateMixin {
  static const _target = 3;
  static const _zoneStart = 0.40, _zoneEnd = 0.60;

  late final AnimationController _ctrl;
  int _hits = 0;
  int _misses = 0;
  String? _lastFeedback;
  bool _lastHit = false;

  RoomMeta get _meta => RoomCatalog.byId(RoomId.gameDev);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _jump() {
    if (_hits >= _target) return;
    final pos = _ctrl.value;
    final hit = pos >= _zoneStart && pos <= _zoneEnd;
    setState(() {
      _lastHit = hit;
      if (hit) {
        _hits++;
        _lastFeedback = _hits >= _target ? 'Tiga kali tepat! Tekan "Selesai".' : 'Tepat! ${_target - _hits} lagi.';
      } else {
        _misses++;
        _lastFeedback = pos < _zoneStart ? 'Terlalu cepat.' : 'Terlalu lambat.';
      }
    });
  }

  RoomCheck _check() {
    if (_hits < _target) {
      return RoomCheckIncomplete('Butuh $_target lompatan tepat di zona hijau. Sekarang baru $_hits.');
    }
    return const RoomCheckCorrect('Mantap! Timing pas = game terasa responsif.');
  }

  void _reset() => setState(() {
        _hits = 0;
        _misses = 0;
        _lastFeedback = null;
      });

  @override
  Widget build(BuildContext context) {
    return RoomScaffold(
      meta: _meta,
      storyLead: 'Karakter game-nya harus melompati jurang.',
      storyBody:
          'Penanda bergerak bolak-balik. Tekan "Lompat!" tepat saat penanda '
          'berada di zona hijau. Berhasil $_target kali untuk membuka pintu.',
      hints: const [
        'Perhatikan ritmenya dulu beberapa detik tanpa menekan apa-apa. Penanda bergerak dengan kecepatan tetap.',
        'Tekan sedikit lebih awal dari yang kamu kira, karena jari butuh waktu untuk bereaksi.',
        'Zona hijau ada di tengah. Saat penanda bergerak dari kiri, tekan tepat ketika ujung kirinya menyentuh zona.',
      ],
      modeLabel: 'Tap cepat',
      stageCount: _target,
      stagesDone: _hits,
      checkLabel: 'Selesai',
      onCheck: _check,
      onReset: _reset,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HelperPanel(
            label: 'Lintasan · zona hijau = waktu yang pas',
            child: SizedBox(
              height: 72,
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  return AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, _) {
                      final x = _ctrl.value * (w - 28);
                      return Stack(
                        children: [
                          // rail
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 30,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceRaised,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                            ),
                          ),
                          // zona hijau
                          Positioned(
                            left: w * _zoneStart,
                            width: w * (_zoneEnd - _zoneStart),
                            top: 30,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                            ),
                          ),
                          // penanda
                          Positioned(
                            left: x,
                            top: 22,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _meta.accent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.ground, width: 2),
                              ),
                              child: const Icon(Icons.directions_run_rounded, size: 18, color: AppColors.onAccent),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: _hits >= _target ? AppColors.successSurface : _meta.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: InkWell(
                onTap: _hits >= _target ? null : _jump,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: SizedBox(
                  height: 72,
                  child: Center(
                    child: Text(
                      _hits >= _target ? 'Berhasil!' : 'LOMPAT!',
                      style: AppTypography.headlineMd.copyWith(
                        color: _hits >= _target ? AppColors.successText : AppColors.onAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: StatTile(value: '$_hits/$_target', caption: 'Tepat', valueColor: AppColors.success)),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: StatTile(value: '$_misses', caption: 'Meleset', valueColor: AppColors.textSecondary)),
            ],
          ),
          if (_lastFeedback != null) ...[
            const SizedBox(height: AppSpacing.xs),
            StatusBanner(kind: _lastHit ? BannerKind.success : BannerKind.warning, text: _lastFeedback!),
          ],
          const SizedBox(height: AppSpacing.md),
          SurfaceCard(
            color: AppColors.surfaceDim,
            borderColor: AppColors.outlineSubtle,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'Di balik layar, game mengulang tiga hal puluhan kali per detik: '
              'baca input (jarimu), update posisi, lalu gambar ulang. Itu yang disebut game loop.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}
