import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/common.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 5 — Mobile App Development: "Rakit Layar Aplikasi".
/// Tap komponen untuk menyusunnya ke dalam layar HP, dari atas ke bawah.
/// Pratinjau HP langsung berubah — itulah cara developer menyusun widget.
class MobileDevRoomScreen extends StatefulWidget {
  const MobileDevRoomScreen({super.key});

  @override
  State<MobileDevRoomScreen> createState() => _MobileDevRoomScreenState();
}

enum _Part { judul, gambar, teks, tombol }

extension on _Part {
  String get label => switch (this) {
        _Part.judul => 'Judul aplikasi',
        _Part.gambar => 'Gambar kampus',
        _Part.teks => 'Keterangan',
        _Part.tombol => 'Tombol "Daftar"',
      };
  IconData get icon => switch (this) {
        _Part.judul => Icons.title_rounded,
        _Part.gambar => Icons.image_outlined,
        _Part.teks => Icons.notes_rounded,
        _Part.tombol => Icons.smart_button_outlined,
      };
}

class _MobileDevRoomScreenState extends State<MobileDevRoomScreen> {
  static const _answer = [_Part.judul, _Part.gambar, _Part.teks, _Part.tombol];
  final List<_Part> _placed = [];

  RoomMeta get _meta => RoomCatalog.byId(RoomId.mobileDev);

  List<_Part> get _pool => _Part.values.where((p) => !_placed.contains(p)).toList();

  RoomCheck _check() {
    if (_placed.length < _answer.length) {
      return RoomCheckIncomplete('Layar belum lengkap, masih ada ${_answer.length - _placed.length} komponen di bawah.');
    }
    for (var i = 0; i < _answer.length; i++) {
      if (_placed[i] != _answer[i]) {
        return const RoomCheckWrong('Susunannya belum pas. Bayangkan app yang nyaman: judul di atas, tombol aksi di bawah.');
      }
    }
    return const RoomCheckCorrect('Layar jadi! Developer mobile menyusun layar persis seperti ini, komponen demi komponen.');
  }

  @override
  Widget build(BuildContext context) {
    return RoomScaffold(
      meta: _meta,
      storyLead: 'Layar aplikasi pendaftaran masih kosong.',
      storyBody:
          'Tap komponen di bawah untuk memasangnya ke layar HP, dari paling '
          'atas ke paling bawah. Tap komponen di layar untuk melepasnya.',
      hints: const [
        'Lihat aplikasi di HP-mu: biasanya yang paling atas adalah judul, dan tombol aksi ada di paling bawah.',
        'Gambar biasanya ditaruh sebelum keterangan, supaya orang tertarik dulu baru membaca.',
        'Urutan dari atas: Judul aplikasi → Gambar kampus → Keterangan → Tombol "Daftar".',
      ],
      modeLabel: 'Tap komponen',
      stageCount: _answer.length,
      stagesDone: _placed.length,
      onCheck: _check,
      onReset: () => setState(_placed.clear),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _PhoneFrame(
              accent: _meta.accent,
              placed: _placed,
              onRemove: (p) => setState(() => _placed.remove(p)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('Komponen tersedia'),
          const SizedBox(height: AppSpacing.xs),
          if (_pool.isEmpty)
            Text('Semua komponen sudah terpasang.', style: AppTypography.bodySm.copyWith(color: AppColors.textDisabled))
          else
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final p in _pool)
                  Material(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      side: const BorderSide(color: AppColors.outline),
                    ),
                    child: InkWell(
                      onTap: () => setState(() => _placed.add(p)),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(p.icon, size: 18, color: _meta.accent),
                            const SizedBox(width: 8),
                            Text(p.label, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            const Icon(Icons.add_rounded, size: 16, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  final Color accent;
  final List<_Part> placed;
  final ValueChanged<_Part> onRemove;
  const _PhoneFrame({required this.accent, required this.placed, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    // Lebar bingkai mengikuti layar (maks 220), tinggi proporsional 3:2.
    final screenW = MediaQuery.sizeOf(context).width;
    final w = (screenW * 0.56).clamp(170.0, 220.0);
    return Container(
      width: w,
      height: w * 1.5,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.outline, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < 4; i++) ...[
              Expanded(
                child: i < placed.length
                    ? _Slot(part: placed[i], accent: accent, onTap: () => onRemove(placed[i]))
                    : _EmptySlot(index: i + 1),
              ),
              if (i < 3) const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  final _Part part;
  final Color accent;
  final VoidCallback onTap;
  const _Slot({required this.part, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = switch (part) {
      _Part.judul => const Align(
          alignment: Alignment.centerLeft,
          child: Text('Campus Escape', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        ),
      _Part.gambar => Container(
          decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(8)),
          child: const Center(child: Icon(Icons.apartment_rounded, size: 28, color: Color(0xFF2563EB))),
        ),
      _Part.teks => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 6, width: 120, decoration: BoxDecoration(color: const Color(0xFF9CA3AF), borderRadius: BorderRadius.circular(3))),
            const SizedBox(height: 4),
            Container(height: 6, width: 90, decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(3))),
          ],
        ),
      _Part.tombol => Center(
          child: Container(
            height: 34,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(9)),
            child: const Text('Daftar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ),
    };
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: accent),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(padding: const EdgeInsets.all(8), child: child),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final int index;
  const _EmptySlot({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text('Slot $index', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
    );
  }
}
