import 'dart:math';

import 'package:material_ui/material_ui.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/common.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 5 — Mobile App Development: "Rakit Layar Aplikasi".
/// Dua layar dirakit bergantian (pendaftaran, lalu halaman masuk): tap
/// komponen untuk menyusunnya ke dalam layar HP, dari atas ke bawah. Urutan
/// komponen di bawah diacak tiap layar supaya tidak bisa asal tap berurutan.
class MobileDevRoomScreen extends StatefulWidget {
  const MobileDevRoomScreen({super.key});

  @override
  State<MobileDevRoomScreen> createState() => _MobileDevRoomScreenState();
}

enum _Part { judul, gambar, teks, tombol, judulMasuk, kolomNama, kolomSandi, tombolMasuk }

extension on _Part {
  String get label => switch (this) {
        _Part.judul => 'Judul aplikasi',
        _Part.gambar => 'Gambar kampus',
        _Part.teks => 'Keterangan',
        _Part.tombol => 'Tombol "Daftar"',
        _Part.judulMasuk => 'Judul "Masuk"',
        _Part.kolomNama => 'Kolom nama',
        _Part.kolomSandi => 'Kolom kata sandi',
        _Part.tombolMasuk => 'Tombol "Masuk"',
      };
  IconData get icon => switch (this) {
        _Part.judul || _Part.judulMasuk => Icons.title_rounded,
        _Part.gambar => Icons.image_outlined,
        _Part.teks => Icons.notes_rounded,
        _Part.tombol => Icons.smart_button_outlined,
        _Part.kolomNama => Icons.person_outline_rounded,
        _Part.kolomSandi => Icons.lock_outline_rounded,
        _Part.tombolMasuk => Icons.login_rounded,
      };
}

class _MobileDevRoomScreenState extends State<MobileDevRoomScreen> {
  /// Tiap layar: judul, urutan komponen yang benar (atas → bawah), dan pesan
  /// pengarah saat susunannya salah.
  static const _screens = [
    (
      title: 'Layar 1 dari 2 · Halaman pendaftaran',
      answer: [_Part.judul, _Part.gambar, _Part.teks, _Part.tombol],
      wrong: 'Susunannya belum pas. Bayangkan app yang nyaman: judul di atas, tombol aksi di bawah.',
    ),
    (
      title: 'Layar 2 dari 2 · Halaman masuk',
      answer: [_Part.judulMasuk, _Part.kolomNama, _Part.kolomSandi, _Part.tombolMasuk],
      wrong: 'Belum pas. Orang mengisi nama dulu, baru kata sandi, lalu menekan tombol di paling bawah.',
    ),
  ];

  int _screen = 0;
  final List<_Part> _placed = [];

  /// Komponen layar ini dalam urutan acak (yang tampil di bawah).
  late List<_Part> _shuffled;

  RoomMeta get _meta => RoomCatalog.byId(RoomId.mobileDev);
  List<_Part> get _answer => _screens[_screen].answer;
  List<_Part> get _pool => _shuffled.where((p) => !_placed.contains(p)).toList();

  @override
  void initState() {
    super.initState();
    _shufflePool();
  }

  /// Acak komponen; ulangi kalau kebetulan sama persis dengan jawaban.
  void _shufflePool() {
    final rnd = Random();
    List<_Part> list;
    do {
      list = List<_Part>.of(_answer)..shuffle(rnd);
    } while (_sameOrder(list, _answer));
    _shuffled = list;
  }

  bool _sameOrder(List<_Part> a, List<_Part> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  RoomCheck _check() {
    if (_placed.length < _answer.length) {
      return RoomCheckIncomplete('Layar belum lengkap, masih ada ${_answer.length - _placed.length} komponen di bawah.');
    }
    if (!_sameOrder(_placed, _answer)) return RoomCheckWrong(_screens[_screen].wrong);
    if (_screen < _screens.length - 1) {
      // Layar ini beres → lanjut ke layar berikutnya dengan komponen baru.
      setState(() {
        _screen++;
        _placed.clear();
        _shufflePool();
      });
      return const RoomCheckProgress('Layar pertama jadi! Sekarang rakit layar kedua: halaman masuk.');
    }
    return const RoomCheckCorrect('Dua layar jadi! Developer mobile menyusun layar persis seperti ini, komponen demi komponen.');
  }

  /// Reset hanya mengosongkan layar yang sedang dirakit (dan mengacak ulang).
  void _reset() => setState(() {
        _placed.clear();
        _shufflePool();
      });

  @override
  Widget build(BuildContext context) {
    final total = _screens.length * _answer.length;
    return RoomScaffold(
      meta: _meta,
      storyLead: 'Dua layar aplikasi masih kosong.',
      storyBody:
          'Tap komponen di bawah untuk memasangnya ke layar HP, dari paling '
          'atas ke paling bawah. Tap komponen di layar untuk melepasnya. '
          'Ada 2 layar yang harus dirakit.',
      hints: const [
        'Lihat aplikasi di HP-mu: judul hampir selalu paling atas, dan tombol aksi paling bawah. Urutan komponen di bawah diacak, jadi jangan ikuti urutannya.',
        'Layar 1: gambar ditaruh sebelum keterangan, supaya orang tertarik dulu baru membaca. Layar 2: orang mengisi nama dulu, baru kata sandi.',
        'Layar 1: Judul aplikasi → Gambar kampus → Keterangan → Tombol "Daftar". Layar 2: Judul "Masuk" → Kolom nama → Kolom kata sandi → Tombol "Masuk".',
      ],
      modeLabel: 'Tap komponen',
      stageCount: total,
      stagesDone: _screen * _answer.length + _placed.length,
      onCheck: _check,
      onReset: _reset,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(_screens[_screen].title),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: _PhoneFrame(
              accent: _meta.accent,
              placed: _placed,
              slots: _answer.length,
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
  final int slots;
  final ValueChanged<_Part> onRemove;
  const _PhoneFrame({required this.accent, required this.placed, required this.slots, required this.onRemove});

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
            for (var i = 0; i < slots; i++) ...[
              Expanded(
                child: i < placed.length
                    ? _Slot(part: placed[i], accent: accent, onTap: () => onRemove(placed[i]))
                    : _EmptySlot(index: i + 1),
              ),
              if (i < slots - 1) const SizedBox(height: 6),
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

  static const _ink = Color(0xFF111827);
  static const _blue = Color(0xFF2563EB);

  Widget _title(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink)),
      );

  Widget _button(String text) => Center(
        child: Container(
          height: 34,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(9)),
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      );

  /// Tiruan kolom isian (ikon + teks contoh di dalam kotak bergaris).
  Widget _field(IconData icon, String text) => Center(
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final child = switch (part) {
      _Part.judul => _title('Campus Escape'),
      _Part.gambar => Container(
          decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(8)),
          child: const Center(child: Icon(Icons.apartment_rounded, size: 28, color: _blue)),
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
      _Part.tombol => _button('Daftar'),
      _Part.judulMasuk => _title('Masuk'),
      _Part.kolomNama => _field(Icons.person_outline_rounded, 'Nama'),
      _Part.kolomSandi => _field(Icons.lock_outline_rounded, '••••••••'),
      _Part.tombolMasuk => _button('Masuk'),
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
