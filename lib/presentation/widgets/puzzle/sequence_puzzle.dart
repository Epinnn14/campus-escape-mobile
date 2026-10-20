import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/engines/puzzle_engine.dart';

/// State puzzle "susun urutan": slot bernomor + pool chip.
/// Dipisah dari widget supaya room screen bisa cek jawaban & reset.
class SequencePuzzleController extends ChangeNotifier {
  final List<String> answer;
  final List<String> _pool;
  late List<String?> _placed;

  SequencePuzzleController({
    required this.answer,
    List<String> distractors = const [],
    List<String>? initialOrder,
  }) : _pool = List.of(initialOrder ?? _shuffle([...answer, ...distractors])) {
    _placed = List<String?>.filled(answer.length, null);
  }

  static List<String> _shuffle(List<String> items) {
    // Shuffle deterministik ringan: balik lalu selang-seling, supaya urutan
    // awal tidak sama dengan jawaban tapi tetap konsisten antar run.
    final out = <String>[];
    final rev = items.reversed.toList();
    for (var i = 0; i < rev.length; i++) {
      if (i.isEven) {
        out.add(rev[i]);
      } else {
        out.insert(0, rev[i]);
      }
    }
    if (out.length > 1 && out.first == items.first) {
      out.add(out.removeAt(0));
    }
    return out;
  }

  List<String?> get placed => List.unmodifiable(_placed);
  List<String> get pool =>
      _pool.where((c) => !_placed.contains(c)).toList(growable: false);
  bool get isComplete => _placed.every((e) => e != null);

  void placeAt(String chip, int slot) {
    if (slot < 0 || slot >= _placed.length) return;
    // Kalau chip sudah ada di slot lain, pindahkan.
    final from = _placed.indexOf(chip);
    if (from != -1) _placed[from] = null;
    final displaced = _placed[slot];
    _placed[slot] = chip;
    if (displaced != null && from != -1) _placed[from] = displaced;
    notifyListeners();
  }

  /// Tap chip di pool → isi slot kosong pertama.
  void placeNext(String chip) {
    final idx = _placed.indexOf(null);
    if (idx == -1) return;
    placeAt(chip, idx);
  }

  void removeAt(int slot) {
    if (_placed[slot] == null) return;
    _placed[slot] = null;
    notifyListeners();
  }

  void reset() {
    _placed = List<String?>.filled(answer.length, null);
    notifyListeners();
  }

  SequenceCheck check() => SequenceEvaluator.check(
        placed: _placed.map((e) => e ?? '').toList(),
        answer: answer,
      );

  int? firstMismatch() => SequenceEvaluator.firstMismatch(
        placed: _placed.map((e) => e ?? '').toList(),
        answer: answer,
      );
}

/// Widget slot + chip pool. Drag chip ke slot, atau tap chip untuk isi
/// slot kosong berikutnya; tap slot terisi untuk melepas.
class SequencePuzzle extends StatelessWidget {
  final SequencePuzzleController controller;
  final Color accent;
  final bool enabled;
  final String slotsLabel;
  final String poolLabel;
  final bool monospace;

  const SequencePuzzle({
    super.key,
    required this.controller,
    required this.accent,
    this.enabled = true,
    this.slotsLabel = 'Urutan tahapan',
    this.poolLabel = 'Tahapan tersedia',
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final placed = controller.placed;
        final pool = controller.pool;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(slotsLabel.toUpperCase(), style: AppTypography.labelSection),
            const SizedBox(height: AppSpacing.xs),
            for (var i = 0; i < placed.length; i++) ...[
              _Slot(
                index: i,
                value: placed[i],
                accent: accent,
                enabled: enabled,
                monospace: monospace,
                onAccept: (chip) => controller.placeAt(chip, i),
                onRemove: () => controller.removeAt(i),
              ),
              if (i < placed.length - 1) const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(poolLabel.toUpperCase(), style: AppTypography.labelSection),
            const SizedBox(height: AppSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSize.chip),
              child: pool.isEmpty
                  ? Text(
                      'Semua tahapan sudah ditaruh.',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textDisabled),
                    )
                  : Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final chip in pool)
                          _DraggableChip(
                            label: chip,
                            accent: accent,
                            enabled: enabled,
                            monospace: monospace,
                            onTap: () => controller.placeNext(chip),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _Slot extends StatelessWidget {
  final int index;
  final String? value;
  final Color accent;
  final bool enabled;
  final bool monospace;
  final ValueChanged<String> onAccept;
  final VoidCallback onRemove;

  const _Slot({
    required this.index,
    required this.value,
    required this.accent,
    required this.enabled,
    required this.monospace,
    required this.onAccept,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => enabled,
      onAcceptWithDetails: (d) => onAccept(d.data),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        final filled = value != null;
        final borderColor = filled
            ? AppColors.accent
            : hovering
                ? accent
                : AppColors.outline;

        return Material(
          color: filled ? AppColors.surfaceRaised : AppColors.surfaceDim,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: borderColor, width: hovering ? 1.5 : 1),
          ),
          child: InkWell(
            onTap: filled && enabled ? onRemove : null,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              height: AppSize.slot,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: filled ? AppColors.accent : AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: AppTypography.numberSm.copyWith(
                        fontSize: 13,
                        color: filled ? AppColors.onAccent : AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      value ?? 'Taruh tahapan di sini',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: filled
                          ? (monospace ? AppTypography.code : AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600))
                          : AppTypography.bodyMd.copyWith(color: AppColors.textDisabled),
                    ),
                  ),
                  if (filled)
                    const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DraggableChip extends StatelessWidget {
  final String label;
  final Color accent;
  final bool enabled;
  final bool monospace;
  final VoidCallback onTap;

  const _DraggableChip({
    required this.label,
    required this.accent,
    required this.enabled,
    required this.monospace,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chip = DragChip(label: label, monospace: monospace, onTap: enabled ? onTap : null);
    if (!enabled) return chip;
    return LongPressDraggable<String>(
      data: label,
      delay: const Duration(milliseconds: 120),
      feedback: Material(
        color: Colors.transparent,
        child: DragChip(label: label, monospace: monospace, dragging: true, accent: accent),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: chip,
    );
  }
}

/// Chip pill dengan ikon grip (DESIGN.md "Drag Chip").
class DragChip extends StatelessWidget {
  final String label;
  final bool dragging;
  final bool monospace;
  final Color? accent;
  final VoidCallback? onTap;

  const DragChip({
    super.key,
    required this.label,
    this.dragging = false,
    this.monospace = false,
    this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dragging ? AppColors.surfaceRaised : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        side: BorderSide(color: dragging ? (accent ?? AppColors.accent) : AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          height: AppSize.chip,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.drag_indicator_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: monospace
                    ? AppTypography.code
                    : AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
