import 'dart:math';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/common.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 8 — Database: "Cocokkan Data".
/// Data siswa dan data kelas disimpan terpisah, dihubungkan lewat nomor
/// kelas. Tap siswa, lalu tap kelasnya — kabel akan tersambung. Posisi kartu
/// diacak tiap kali ruangan dibuka supaya tidak bisa dihafal.
class DatabaseRoomScreen extends StatefulWidget {
  const DatabaseRoomScreen({super.key});

  @override
  State<DatabaseRoomScreen> createState() => _DatabaseRoomScreenState();
}

class _DatabaseRoomScreenState extends State<DatabaseRoomScreen> {
  static const _students = [
    (nama: 'Aisyah', kelasId: 10),
    (nama: 'Bima', kelasId: 11),
    (nama: 'Citra', kelasId: 12),
    (nama: 'Dion', kelasId: 10),
    (nama: 'Eka', kelasId: 13),
    (nama: 'Fajar', kelasId: 14),
  ];
  static const _classes = [
    (id: 10, nama: 'X IPA 1'),
    (id: 11, nama: 'X IPA 2'),
    (id: 12, nama: 'X IPS 1'),
    (id: 13, nama: 'XI IPA 1'),
    (id: 14, nama: 'XI IPS 2'),
  ];
  static const _cardH = 62.0;
  static const _gap = AppSpacing.xs;

  // Urutan tampil (indeks ke _students / _classes), diacak.
  late List<int> _studentOrder;
  late List<int> _classOrder;
  int? _selectedStudent;
  final Map<int, int> _pairs = {}; // indeks siswa → id kelas

  RoomMeta get _meta => RoomCatalog.byId(RoomId.database);

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    final rnd = Random();
    _studentOrder = List.generate(_students.length, (i) => i)..shuffle(rnd);
    _classOrder = List.generate(_classes.length, (i) => i)..shuffle(rnd);
  }

  Color _classColor(int id) => switch (id) {
        10 => AppColors.success,
        11 => AppColors.bonusAI,
        12 => AppColors.bonusCyber,
        13 => AppColors.dataSky,
        _ => AppColors.dataPink,
      };

  void _tapStudent(int i) => setState(() {
        if (_pairs.containsKey(i)) {
          _pairs.remove(i);
          _selectedStudent = i;
        } else {
          _selectedStudent = _selectedStudent == i ? null : i;
        }
      });

  void _tapClass(int id) {
    if (_selectedStudent == null) return;
    setState(() {
      _pairs[_selectedStudent!] = id;
      _selectedStudent = null;
    });
  }

  RoomCheck _check() {
    if (_pairs.length < _students.length) {
      return RoomCheckIncomplete('Masih ada ${_students.length - _pairs.length} siswa yang belum tersambung ke kelas.');
    }
    var wrong = 0;
    for (var i = 0; i < _students.length; i++) {
      if (_pairs[i] != _students[i].kelasId) wrong++;
    }
    if (wrong > 0) {
      return RoomCheckWrong('Ada $wrong kabel yang salah sambung. Cocokkan angka "kelas_id" di kartu siswa dengan "id" di kartu kelas.');
    }
    return const RoomCheckCorrect('Semua kabel tersambung benar! Begitulah database menggabungkan dua tabel lewat satu nomor kunci.');
  }

  void _reset() => setState(() {
        _pairs.clear();
        _selectedStudent = null;
        _shuffle();
      });

  @override
  Widget build(BuildContext context) {
    final rows = max(_students.length, _classes.length);
    final boardH = rows * _cardH + (rows - 1) * _gap;

    return RoomScaffold(
      meta: _meta,
      storyLead: 'Daftar siswa dan daftar kelas tersimpan terpisah.',
      storyBody:
          'Sambungkan kabel dari tiap siswa ke kelasnya: tap nama siswa, lalu tap '
          'kelas yang nomornya sama. Tap siswa lagi untuk mencabut kabelnya.',
      hints: const [
        'Tiap kartu siswa punya angka "kelas_id". Tiap kartu kelas punya angka "id". Angka yang sama = pasangan. Posisi kartu diacak, jadi lihat angkanya, bukan urutannya.',
        'Dua siswa boleh masuk kelas yang sama — satu kelas bisa menerima lebih dari satu kabel.',
        'Jawaban: Aisyah & Dion → X IPA 1 (10), Bima → X IPA 2 (11), Citra → X IPS 1 (12), Eka → XI IPA 1 (13), Fajar → XI IPS 2 (14).',
      ],
      modeLabel: 'Tap pasangan',
      stageCount: _students.length,
      stagesDone: _pairs.length,
      onCheck: _check,
      onReset: _reset,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(flex: 11, child: SectionLabel('Tabel siswa')),
              SizedBox(width: AppSpacing.lg),
              Expanded(flex: 9, child: SectionLabel('Tabel kelas')),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          LayoutBuilder(builder: (context, c) {
            const gapW = AppSpacing.lg;
            final leftW = (c.maxWidth - gapW) * 11 / 20;
            final rightX = leftW + gapW;
            return SizedBox(
              height: boardH,
              child: Stack(
                children: [
                  // Kolom siswa
                  Positioned(
                    left: 0,
                    top: 0,
                    width: leftW,
                    child: Column(
                      children: [
                        for (var r = 0; r < _studentOrder.length; r++) ...[
                          SizedBox(
                            height: _cardH,
                            child: _StudentCard(
                              nama: _students[_studentOrder[r]].nama,
                              kelasId: _students[_studentOrder[r]].kelasId,
                              selected: _selectedStudent == _studentOrder[r],
                              pairedColor: _pairs.containsKey(_studentOrder[r]) ? _classColor(_pairs[_studentOrder[r]]!) : null,
                              accent: _meta.accent,
                              onTap: () => _tapStudent(_studentOrder[r]),
                            ),
                          ),
                          if (r < _studentOrder.length - 1) const SizedBox(height: _gap),
                        ],
                      ],
                    ),
                  ),
                  // Kolom kelas
                  Positioned(
                    left: rightX,
                    top: 0,
                    right: 0,
                    child: Column(
                      children: [
                        for (var r = 0; r < _classOrder.length; r++) ...[
                          SizedBox(
                            height: _cardH,
                            child: _ClassCard(
                              id: _classes[_classOrder[r]].id,
                              nama: _classes[_classOrder[r]].nama,
                              color: _classColor(_classes[_classOrder[r]].id),
                              enabled: _selectedStudent != null,
                              connected: _pairs.containsValue(_classes[_classOrder[r]].id),
                              onTap: () => _tapClass(_classes[_classOrder[r]].id),
                            ),
                          ),
                          if (r < _classOrder.length - 1) const SizedBox(height: _gap),
                        ],
                      ],
                    ),
                  ),
                  // Kabel
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _CablePainter(
                          cables: [
                            for (final e in _pairs.entries)
                              (
                                from: _studentOrder.indexOf(e.key),
                                to: _classOrder.indexOf(_classes.indexWhere((k) => k.id == e.value)),
                                color: _classColor(e.value),
                              ),
                          ],
                          pending: _selectedStudent == null ? null : _studentOrder.indexOf(_selectedStudent!),
                          pendingColor: _meta.accent,
                          leftX: leftW,
                          rightX: rightX,
                          rowH: _cardH,
                          gap: _gap,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _selectedStudent == null
                ? 'Tap siswa dulu, lalu tap kelas yang id-nya sama.'
                : 'Pilih kelas untuk ${_students[_selectedStudent!].nama} (kelas_id ${_students[_selectedStudent!].kelasId}).',
            style: AppTypography.captionXs,
          ),
          const SizedBox(height: AppSpacing.md),
          SurfaceCard(
            color: AppColors.surfaceDim,
            borderColor: AppColors.outlineSubtle,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'Database menyimpan data dalam tabel-tabel terpisah supaya rapi, lalu '
              'menghubungkannya lewat nomor kunci (foreign key). Database Engineer menjaga data ini tetap benar dan cepat diakses.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

/// Menggambar kabel melengkung dari sisi kanan kartu siswa ke sisi kiri
/// kartu kelas, plus kabel "menggantung" dari siswa yang sedang dipilih.
class _CablePainter extends CustomPainter {
  final List<({int from, int to, Color color})> cables;
  final int? pending;
  final Color pendingColor;
  final double leftX, rightX, rowH, gap;
  _CablePainter({
    required this.cables,
    required this.pending,
    required this.pendingColor,
    required this.leftX,
    required this.rightX,
    required this.rowH,
    required this.gap,
  });

  double _y(int row) => row * (rowH + gap) + rowH / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final plug = Paint()..style = PaintingStyle.fill;
    for (final c in cables) {
      final a = Offset(leftX, _y(c.from));
      final b = Offset(rightX, _y(c.to));
      final mid = (a.dx + b.dx) / 2;
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(mid, a.dy, mid, b.dy, b.dx, b.dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = c.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
      plug.color = c.color;
      canvas.drawCircle(a, 4.5, plug);
      canvas.drawCircle(b, 4.5, plug);
    }
    if (pending != null) {
      final a = Offset(leftX, _y(pending!));
      final paint = Paint()
        ..color = pendingColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      // Kabel pendek putus-putus yang menunggu disambung.
      for (var x = 0.0; x < (rightX - leftX) * 0.45; x += 10) {
        canvas.drawLine(Offset(a.dx + x, a.dy), Offset(a.dx + x + 5, a.dy), paint);
      }
      plug.color = pendingColor;
      canvas.drawCircle(a, 4.5, plug);
    }
  }

  @override
  bool shouldRepaint(_CablePainter old) =>
      old.cables.length != cables.length ||
      old.pending != pending ||
      old.leftX != leftX ||
      old.rightX != rightX ||
      !_sameCables(old.cables);

  bool _sameCables(List<({int from, int to, Color color})> other) {
    for (var i = 0; i < cables.length; i++) {
      if (cables[i].from != other[i].from || cables[i].to != other[i].to) return false;
    }
    return true;
  }
}

class _StudentCard extends StatelessWidget {
  final String nama;
  final int kelasId;
  final bool selected;
  final Color? pairedColor;
  final Color accent;
  final VoidCallback onTap;
  const _StudentCard({
    required this.nama,
    required this.kelasId,
    required this.selected,
    required this.pairedColor,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceRaised : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(
          color: selected ? accent : (pairedColor ?? AppColors.outline),
          width: selected || pairedColor != null ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('kelas_id: $kelasId', style: AppTypography.code.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(
                pairedColor != null ? Icons.power_rounded : Icons.power_off_rounded,
                size: 16,
                color: pairedColor ?? (selected ? accent : AppColors.textDisabled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final int id;
  final String nama;
  final Color color;
  final bool enabled;
  final bool connected;
  final VoidCallback onTap;
  const _ClassCard({
    required this.id,
    required this.nama,
    required this.color,
    required this.enabled,
    required this.connected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled || connected ? 1 : 0.65,
      child: Material(
        color: connected ? AppColors.surfaceRaised : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: color, width: connected ? 1.5 : 1),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('id: $id', style: AppTypography.code.copyWith(fontSize: 11, color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
