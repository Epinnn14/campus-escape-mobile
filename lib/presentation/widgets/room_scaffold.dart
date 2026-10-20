import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/room_progress_provider.dart';
import '../../application/providers/room_settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/room_meta.dart';
import '../../domain/engines/puzzle_engine.dart';
import 'buttons.dart';
import 'common.dart';

/// Hasil evaluasi dari room screen saat tombol utama ditekan.
sealed class RoomCheck {
  const RoomCheck();
}

class RoomCheckIncomplete extends RoomCheck {
  final String message;
  const RoomCheckIncomplete(this.message);
}

class RoomCheckWrong extends RoomCheck {
  final String message;
  const RoomCheckWrong(this.message);
}

class RoomCheckCorrect extends RoomCheck {
  final String message;
  const RoomCheckCorrect(this.message);
}

/// Kerangka semua ruangan: top bar (back, nama ruang), progres tahap, kartu
/// cerita, body puzzle, banner status, dan dock tombol (petunjuk, reset,
/// tombol utama). Skor, hint, dan penyelesaian diurus di sini supaya tiap
/// room screen cuma fokus ke mekanik puzzle-nya.
class RoomScaffold extends ConsumerStatefulWidget {
  final RoomMeta meta;
  final String storyLead;
  final String storyBody;
  final List<String> hints;
  final int stageCount;
  final int stagesDone;
  final String modeLabel;
  final Widget body;
  /// Boleh async: mis. ruang Algoritma menjalankan animasi robot dulu,
  /// baru mengembalikan hasilnya. Selama menunggu, tombol dinonaktifkan.
  final FutureOr<RoomCheck> Function() onCheck;
  final VoidCallback onReset;
  final String checkLabel;

  /// Kalau true, tombol utama dinonaktifkan (mis. saat animasi robot jalan).
  final bool busy;

  const RoomScaffold({
    super.key,
    required this.meta,
    required this.storyLead,
    required this.storyBody,
    required this.hints,
    required this.body,
    required this.onCheck,
    required this.onReset,
    this.stageCount = 1,
    this.stagesDone = 0,
    this.modeLabel = 'Tap & drag',
    this.checkLabel = 'Cek Jawaban',
    this.busy = false,
  });

  @override
  ConsumerState<RoomScaffold> createState() => _RoomScaffoldState();
}

class _RoomScaffoldState extends ConsumerState<RoomScaffold> {
  late final DateTime _enteredAt;
  int _hintsUsed = 0;
  int _hintsRevealed = 0;
  int _wrongAttempts = 0;
  bool _solved = false;
  bool _checking = false;
  (BannerKind, String)? _banner;

  @override
  void initState() {
    super.initState();
    _enteredAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roomProgressProvider.notifier).markActive(widget.meta.id);
    });
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _banner = null;
    });
    final RoomCheck result;
    try {
      result = await widget.onCheck();
    } finally {
      if (mounted) setState(() => _checking = false);
    }
    if (!mounted) return;
    switch (result) {
      case RoomCheckIncomplete(:final message):
        setState(() => _banner = (BannerKind.warning, message));
      case RoomCheckWrong(:final message):
        setState(() {
          _wrongAttempts++;
          _banner = (BannerKind.danger, message);
        });
      case RoomCheckCorrect(:final message):
        final puzzle = ScoreCalculator.success(
          hintsUsed: _hintsUsed,
          wrongAttempts: _wrongAttempts,
          feedback: message,
          base: ref.read(roomSettingsProvider).xpOf(widget.meta),
        );
        ref.read(roomProgressProvider.notifier).completeRoom(
              widget.meta.id,
              puzzle,
              DateTime.now().difference(_enteredAt),
            );
        setState(() {
          _solved = true;
          _banner = (BannerKind.success, '$message  +${puzzle.score} XP');
        });
    }
  }

  /// Petunjuk bertingkat: setiap petunjuk baru yang dibuka kena penalti,
  /// membaca ulang petunjuk yang sudah terbuka gratis.
  void _showHint() {
    if (_hintsRevealed == 0) _revealNextHint();
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final total = widget.hints.length;
          final canReveal = _hintsRevealed < total;
          return AlertDialog(
            title: Text('Petunjuk $_hintsRevealed dari $total'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _hintsRevealed; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppTypography.numberSm.copyWith(fontSize: 12, color: AppColors.accent),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(child: Text(widget.hints[i])),
                    ],
                  ),
                  if (i < _hintsRevealed - 1) const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.md),
                Text(
                  canReveal
                      ? 'Petunjuk berikutnya -${ScoreCalculator.hintPenalty} XP.'
                      : 'Semua petunjuk sudah terbuka.',
                  style: AppTypography.captionXs,
                ),
              ],
            ),
            actions: [
              if (canReveal)
                TextButton(
                  onPressed: () {
                    _revealNextHint();
                    setDialogState(() {});
                  },
                  child: const Text('Buka petunjuk berikutnya'),
                ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Oke, paham'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _revealNextHint() {
    if (_hintsRevealed >= widget.hints.length) return;
    if (!_solved) {
      ref.read(roomProgressProvider.notifier).addHint(widget.meta.id);
    }
    setState(() {
      _hintsRevealed++;
      _hintsUsed++;
    });
  }

  void _reset() {
    if (_checking) return;
    widget.onReset();
    setState(() => _banner = null);
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.meta;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ---- Top bar ----
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, AppSpacing.xs, AppSpacing.screenH, 0,
              ),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticLabel: 'Kembali ke peta',
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          meta.levelLabel.toUpperCase(),
                          style: AppTypography.labelSection.copyWith(fontSize: 11),
                        ),
                        Text(
                          meta.title,
                          style: AppTypography.titleMd,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: AppSize.iconButton,
                    height: AppSize.iconButton,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Icon(meta.icon, size: 20, color: meta.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(height: 3, color: meta.accent),

            // ---- Konten scroll ----
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StageProgress(
                      count: widget.stageCount,
                      done: _solved ? widget.stageCount : widget.stagesDone,
                      modeLabel: widget.modeLabel,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _BriefCard(
                      lead: widget.storyLead,
                      body: widget.storyBody,
                      accent: meta.accent,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    IgnorePointer(ignoring: _solved, child: widget.body),
                  ],
                ),
              ),
            ),

            // ---- Dock bawah ----
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenH, AppSpacing.sm, AppSpacing.screenH, AppSpacing.md + bottomInset,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: const Border(top: BorderSide(color: AppColors.outlineSubtle)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_banner != null) ...[
                    StatusBanner(kind: _banner!.$1, text: _banner!.$2),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  Row(
                    children: [
                      _DockIconButton(
                        icon: Icons.lightbulb_outline_rounded,
                        label: 'Minta petunjuk',
                        onPressed: _solved ? null : _showHint,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _DockIconButton(
                        icon: Icons.restart_alt_rounded,
                        label: 'Ulang dari awal',
                        onPressed: _solved || widget.busy || _checking ? null : _reset,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _solved
                            ? PrimaryButton(
                                label: 'Pintu terbuka — lanjut',
                                icon: Icons.arrow_forward_rounded,
                                success: true,
                                onPressed: () =>
                                    context.pushReplacement('/insight/${meta.id.name}'),
                              )
                            : PrimaryButton(
                                label: widget.checkLabel,
                                icon: Icons.bolt_rounded,
                                onPressed: widget.busy || _checking ? null : _check,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  const _DockIconButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            width: AppSize.primaryButton,
            height: AppSize.primaryButton,
            child: Icon(
              icon,
              size: 22,
              color: onPressed == null ? AppColors.textDisabled : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _StageProgress extends StatelessWidget {
  final int count;
  final int done;
  final String modeLabel;
  const _StageProgress({required this.count, required this.done, required this.modeLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              count == 1 ? 'Satu tantangan' : 'Tahap ${(done + 1).clamp(1, count)} dari $count',
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(modeLabel, style: AppTypography.caption),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        SegmentedProgress(
          total: count,
          completed: done,
          activeIndex: done < count ? done : null,
        ),
      ],
    );
  }
}

class _BriefCard extends StatelessWidget {
  final String lead;
  final String body;
  final Color accent;
  const _BriefCard({required this.lead, required this.body, required this.accent});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: AppRadius.xl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 26, color: accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                children: [
                  TextSpan(
                    text: '$lead ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
