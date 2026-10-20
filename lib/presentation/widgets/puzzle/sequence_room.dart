import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/room_meta.dart';
import '../../../domain/engines/puzzle_engine.dart';
import '../room_scaffold.dart';
import 'choice_task.dart';
import 'sequence_puzzle.dart';

/// Mini-task pilihan ganda opsional (tahap 2 ruangan).
class ChoiceSpec {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String wrongMessage;
  const ChoiceSpec({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.wrongMessage = 'Pilihan tahap 2 belum tepat. Lihat lagi petunjuk visualnya.',
  });
}

/// Spesifikasi ruangan bertipe "susun urutan (+ mini-task)".
/// Satu room screen = satu spec + helper visual khas ruangan itu.
class SequenceRoomSpec {
  final RoomMeta meta;
  final String storyLead;
  final String storyBody;
  final List<String> hints;
  final List<String> answer;
  final List<String> distractors;
  final String successMessage;
  final String slotsLabel;
  final String poolLabel;
  final bool monospace;
  final ChoiceSpec? choice;

  const SequenceRoomSpec({
    required this.meta,
    required this.storyLead,
    required this.storyBody,
    required this.hints,
    required this.answer,
    this.distractors = const [],
    required this.successMessage,
    this.slotsLabel = 'Urutan tahapan',
    this.poolLabel = 'Tahapan tersedia',
    this.monospace = false,
    this.choice,
  });
}

/// Layar ruangan generik: brief → helper visual → slot & chip → mini-task.
class SequenceRoomScreen extends StatefulWidget {
  final SequenceRoomSpec spec;

  /// Visual khas ruangan (array cells, branch diagram, tabel join, ...).
  /// Dapat [placed] supaya bisa bereaksi ke progres susunan.
  final Widget Function(BuildContext context, List<String?> placed)? helperBuilder;

  const SequenceRoomScreen({super.key, required this.spec, this.helperBuilder});

  @override
  State<SequenceRoomScreen> createState() => _SequenceRoomScreenState();
}

class _SequenceRoomScreenState extends State<SequenceRoomScreen> {
  late final SequencePuzzleController _controller;
  int? _choice;

  @override
  void initState() {
    super.initState();
    _controller = SequencePuzzleController(
      answer: widget.spec.answer,
      distractors: widget.spec.distractors,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  RoomCheck _check() {
    final spec = widget.spec;
    switch (_controller.check()) {
      case SequenceCheck.incomplete:
        return const RoomCheckIncomplete('Masih ada slot kosong. Lengkapi dulu urutannya.');
      case SequenceCheck.wrong:
        final idx = _controller.firstMismatch();
        final after = idx == null || idx == 0 ? null : spec.answer[idx - 1];
        return RoomCheckWrong(
          after == null
              ? 'Belum tepat. Cek lagi tahapan pertamanya.'
              : 'Belum tepat. Coba cek lagi urutan setelah "$after".',
        );
      case SequenceCheck.correct:
        final choice = spec.choice;
        if (choice == null) return RoomCheckCorrect(spec.successMessage);
        if (_choice == null) {
          return const RoomCheckIncomplete('Urutan benar! Sekarang jawab pertanyaan tahap 2.');
        }
        if (_choice != choice.correctIndex) return RoomCheckWrong(choice.wrongMessage);
        return RoomCheckCorrect(spec.successMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final seqDone = _controller.check() == SequenceCheck.correct;
        return RoomScaffold(
          meta: spec.meta,
          storyLead: spec.storyLead,
          storyBody: spec.storyBody,
          hints: spec.hints,
          stageCount: spec.choice == null ? 1 : 2,
          stagesDone: spec.choice != null && seqDone ? 1 : 0,
          onCheck: _check,
          onReset: () {
            _controller.reset();
            setState(() => _choice = null);
          },
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.helperBuilder != null) ...[
                widget.helperBuilder!(context, _controller.placed),
                const SizedBox(height: AppSpacing.lg),
              ],
              SequencePuzzle(
                controller: _controller,
                accent: spec.meta.accent,
                slotsLabel: spec.slotsLabel,
                poolLabel: spec.poolLabel,
                monospace: spec.monospace,
              ),
              if (spec.choice != null) ...[
                const SizedBox(height: AppSpacing.lg),
                ChoiceTask(
                  question: spec.choice!.question,
                  options: spec.choice!.options,
                  selected: _choice,
                  accent: spec.meta.accent,
                  onSelect: (i) => setState(() => _choice = i),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
