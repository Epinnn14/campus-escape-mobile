import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/common.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 1 — Algoritma: "Robot Pengantar".
/// Susun perintah panah supaya robot sampai ke tujuan. Algoritma = urutan
/// langkah yang jelas; komputer cuma mengikuti perintah persis seperti ditulis.
class AlgorithmRoomScreen extends StatefulWidget {
  const AlgorithmRoomScreen({super.key});

  @override
  State<AlgorithmRoomScreen> createState() => _AlgorithmRoomScreenState();
}

enum _Dir { up, down, left, right }

class _AlgorithmRoomScreenState extends State<AlgorithmRoomScreen> {
  static const _cols = 4, _rows = 3;
  static const _start = (x: 0, y: 2);
  static const _goal = (x: 3, y: 0);
  static const _walls = [(x: 1, y: 2), (x: 2, y: 1)];
  static const _maxCommands = 8;

  final List<_Dir> _commands = [];
  ({int x, int y}) _robot = _start;
  bool _running = false;
  bool _crashed = false;

  RoomMeta get _meta => RoomCatalog.byId(RoomId.algorithm);

  bool _isWall(int x, int y) => _walls.any((w) => w.x == x && w.y == y);
  bool _inside(int x, int y) => x >= 0 && x < _cols && y >= 0 && y < _rows;

  ({int x, int y})? _step(({int x, int y}) p, _Dir d) {
    final (dx, dy) = switch (d) {
      _Dir.up => (0, -1),
      _Dir.down => (0, 1),
      _Dir.left => (-1, 0),
      _Dir.right => (1, 0),
    };
    final nx = p.x + dx, ny = p.y + dy;
    if (!_inside(nx, ny) || _isWall(nx, ny)) return null;
    return (x: nx, y: ny);
  }

  /// Dipanggil tombol "Cek Jawaban": robot bergerak dulu mengikuti perintah,
  /// baru hasilnya ditentukan dari posisi akhir (atau tabrakan).
  Future<RoomCheck> _check() async {
    if (_commands.isEmpty) {
      return const RoomCheckIncomplete('Belum ada perintah. Tap tombol panah untuk menyusun langkah robot.');
    }
    setState(() {
      _running = true;
      _crashed = false;
      _robot = _start;
    });
    await Future<void>.delayed(const Duration(milliseconds: 250));
    for (final c in _commands) {
      if (!mounted) return const RoomCheckIncomplete('');
      final n = _step(_robot, c);
      if (n == null) {
        setState(() {
          _crashed = true;
          _running = false;
        });
        return const RoomCheckWrong('Robot menabrak tembok atau keluar papan. Cek lagi urutan panahnya.');
      }
      setState(() => _robot = n);
      await Future<void>.delayed(const Duration(milliseconds: 380));
    }
    if (!mounted) return const RoomCheckIncomplete('');
    setState(() => _running = false);
    if (_robot.x == _goal.x && _robot.y == _goal.y) {
      return const RoomCheckCorrect('Robot sampai! Itulah algoritma: langkah jelas, hasil pasti.');
    }
    return const RoomCheckWrong('Robot berhenti sebelum sampai bendera. Tambah atau ubah perintahnya.');
  }

  void _reset() => setState(() {
        _commands.clear();
        _robot = _start;
        _crashed = false;
      });

  @override
  Widget build(BuildContext context) {
    return RoomScaffold(
      meta: _meta,
      storyLead: 'Robot pengantar paket tersesat di lorong kampus.',
      storyBody:
          'Susun perintah panah supaya robot sampai ke bendera tanpa menabrak '
          'tembok. Saat kamu tekan "Jalankan Robot", robot bergerak dulu — '
          'kalau sampai bendera, pintu terbuka.',
      hints: const [
        'Robot mengikuti perintah persis sesuai urutan, satu kotak per panah. Hitung dulu berapa kotak ke atas dan ke kanan.',
        'Kotak gelap adalah tembok. Dari posisi awal, coba naik dulu dua kali, baru belok kanan.',
        'Salah satu jawaban: ↑ ↑ → → →. Tekan Jalankan Robot untuk melihatnya bergerak.',
      ],
      modeLabel: 'Tap panah',
      checkLabel: 'Jalankan Robot',
      onCheck: _check,
      onReset: _reset,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HelperPanel(
            label: 'Papan lorong · robot mulai dari kiri bawah',
            child: AspectRatio(
              aspectRatio: _cols / _rows,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _cols,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: _cols * _rows,
                itemBuilder: (context, i) {
                  final x = i % _cols, y = i ~/ _cols;
                  final isRobot = _robot.x == x && _robot.y == y;
                  final isGoal = _goal.x == x && _goal.y == y;
                  final wall = _isWall(x, y);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: wall
                          ? AppColors.surfaceHighest
                          : isRobot
                              ? AppColors.surfaceRaised
                              : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(
                        color: isRobot
                            ? (_crashed ? AppColors.danger : _meta.accent)
                            : isGoal
                                ? AppColors.success
                                : AppColors.outlineSubtle,
                        width: isRobot || isGoal ? 1.5 : 1,
                      ),
                    ),
                    child: isRobot
                        ? RobotMark(size: 30, color: _crashed ? AppColors.danger : _meta.accent)
                        : isGoal
                            ? const Icon(Icons.flag_rounded, size: 24, color: AppColors.success)
                            : wall
                                ? const Icon(Icons.block_rounded, size: 16, color: AppColors.textDisabled)
                                : null,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          SectionLabel('Urutan perintah (${_commands.length}/$_maxCommands)'),
          const SizedBox(height: AppSpacing.xs),
          Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.outline, style: BorderStyle.solid),
            ),
            child: _commands.isEmpty
                ? Center(
                    child: Text(
                      'Tap panah di bawah untuk menambah perintah',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textDisabled),
                    ),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (var i = 0; i < _commands.length; i++)
                        _CommandChip(
                          index: i + 1,
                          dir: _commands[i],
                          accent: _meta.accent,
                          onRemove: _running ? null : () => setState(() => _commands.removeAt(i)),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (final d in _Dir.values) ...[
                Expanded(
                  child: _ArrowButton(
                    dir: d,
                    onTap: _running || _commands.length >= _maxCommands
                        ? null
                        : () => setState(() => _commands.add(d)),
                  ),
                ),
                if (d != _Dir.values.last) const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(_Dir d) => switch (d) {
      _Dir.up => Icons.arrow_upward_rounded,
      _Dir.down => Icons.arrow_downward_rounded,
      _Dir.left => Icons.arrow_back_rounded,
      _Dir.right => Icons.arrow_forward_rounded,
    };

String _labelFor(_Dir d) => switch (d) {
      _Dir.up => 'Atas',
      _Dir.down => 'Bawah',
      _Dir.left => 'Kiri',
      _Dir.right => 'Kanan',
    };

class _CommandChip extends StatelessWidget {
  final int index;
  final _Dir dir;
  final Color accent;
  final VoidCallback? onRemove;
  const _CommandChip({required this.index, required this.dir, required this.accent, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(color: accent),
      ),
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$index', style: AppTypography.numberSm.copyWith(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(width: 4),
              Icon(_iconFor(dir), size: 18, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final _Dir dir;
  final VoidCallback? onTap;
  const _ArrowButton({required this.dir, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_iconFor(dir), size: 24, color: onTap == null ? AppColors.textDisabled : AppColors.textPrimary),
              const SizedBox(height: 2),
              Text(_labelFor(dir), style: AppTypography.captionXs),
            ],
          ),
        ),
      ),
    );
  }
}
