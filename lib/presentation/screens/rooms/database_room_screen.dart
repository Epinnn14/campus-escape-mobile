import 'dart:math';

import 'package:material_ui/material_ui.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/common.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 8 — Database: "Cocokkan Data".
/// Data siswa dan data kelas disimpan terpisah, dihubungkan lewat nomor
/// kelas. 12 siswa (6 di kiri, 6 di kanan) mengapit 5 kelas di tengah: tap
/// siswa, lalu tap kelasnya — kabel akan tersambung. Posisi kartu diacak tiap
/// kali ruangan dibuka supaya tidak bisa dihafal.
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
    (nama: 'Gita', kelasId: 12),
    (nama: 'Hadi', kelasId: 14),
    (nama: 'Indah', kelasId: 11),
    (nama: 'Joko', kelasId: 13),
    (nama: 'Kirana', kelasId: 10),
    (nama: 'Lutfi', kelasId: 12),
  ];
  static const _classes = [
    (id: 10, nama: 'X IPA 1'),
    (id: 11, nama: 'X IPA 2'),
    (id: 12, nama: 'X IPS 1'),
    (id: 13, nama: 'XI IPA 1'),
    (id: 14, nama: 'XI IPS 2'),
  ];

  /// Jumlah siswa per sisi (kiri / kanan).
  static const _perSide = 6;
  static const _cardH = 56.0;
  static const _gap = AppSpacing.xs;

  /// Urutan tampil siswa (indeks ke [_students]), diacak: 6 pertama di kolom
  /// kiri, 6 berikutnya di kolom kanan.
  late List<int> _order;
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
    _order = List.generate(_students.length, (i) => i)..shuffle(rnd);
    _classOrder = List.generate(_classes.length, (i) => i)..shuffle(rnd);
  }

  Color _classColor(int id) => switch (id) {
        10 => AppColors.success,
        11 => AppColors.bonusAI,
        12 => AppColors.bonusCyber,
        13 => AppColors.dataSky,
        _ => AppColors.dataPink,
      };

  bool _isLeft(int student) => _order.indexOf(student) < _perSide;
  int _rowOf(int student) => _order.indexOf(student) % _perSide;
  int _classRow(int classId) => _classOrder.indexOf(_classes.indexWhere((k) => k.id == classId));

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

  /// Kabel yang masuk ke sisi kelas yang sama disebar sedikit ke atas-bawah
  /// (slot) supaya tidak menumpuk di satu titik.
  List<_Cable> _buildCables() {
    final groups = <(int, bool), List<int>>{}; // (baris kelas, dari kiri?) → baris siswa
    _pairs.forEach((student, classId) {
      groups.putIfAbsent((_classRow(classId), _isLeft(student)), () => []).add(_rowOf(student));
    });
    final cables = <_Cable>[];
    groups.forEach((key, rows) {
      rows.sort();
      for (var k = 0; k < rows.length; k++) {
        cables.add(_Cable(
          left: key.$2,
          studentRow: rows[k],
          classRow: key.$1,
          slot: k,
          slots: rows.length,
          color: _classColor(_classes[_classOrder[key.$1]].id),
        ));
      }
    });
    return cables;
  }

  Widget _studentColumn(int from) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 0; r < _perSide; r++) ...[
          SizedBox(
            height: _cardH,
            child: _StudentCard(
              nama: _students[_order[from + r]].nama,
              kelasId: _students[_order[from + r]].kelasId,
              selected: _selectedStudent == _order[from + r],
              pairedColor: _pairs.containsKey(_order[from + r]) ? _classColor(_pairs[_order[from + r]]!) : null,
              accent: _meta.accent,
              onTap: () => _tapStudent(_order[from + r]),
            ),
          ),
          if (r < _perSide - 1) const SizedBox(height: _gap),
        ],
      ],
    );
  }

  Widget _columnLabel(String text, double width) => SizedBox(
        width: width,
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: AppTypography.labelSection.copyWith(fontSize: 11),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const boardH = _perSide * _cardH + (_perSide - 1) * _gap;
    // 5 kelas dipusatkan terhadap 6 baris siswa.
    const classTop = (_perSide - 5) * (_cardH + _gap) / 2;

    return RoomScaffold(
      meta: _meta,
      storyLead: 'Daftar siswa dan daftar kelas tersimpan terpisah.',
      storyBody:
          'Sambungkan kabel dari tiap siswa ke kelasnya: tap nama siswa, lalu tap '
          'kelas di tengah yang nomornya sama. Tap siswa lagi untuk mencabut kabelnya.',
      hints: const [
        'Tiap kartu siswa punya angka "kelas_id". Tiap kartu kelas punya angka "id". Angka yang sama = pasangan. Posisi kartu diacak, jadi lihat angkanya, bukan urutannya.',
        'Beberapa siswa boleh masuk kelas yang sama — satu kelas bisa menerima banyak kabel, dari kiri maupun kanan.',
        'Jawaban: 10 → Aisyah, Dion, Kirana · 11 → Bima, Indah · 12 → Citra, Gita, Lutfi · 13 → Eka, Joko · 14 → Fajar, Hadi.',
      ],
      modeLabel: 'Tap pasangan',
      stageCount: _students.length,
      stagesDone: _pairs.length,
      onCheck: _check,
      onReset: _reset,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (context, c) {
            // Tiga kolom: siswa | kelas | siswa, dengan ruang kabel di antaranya.
            // Semua lebar dihitung dari lebar layar supaya muat di HP kecil.
            final classW = (c.maxWidth * 0.23).clamp(70.0, 92.0);
            final gapW = (c.maxWidth * 0.075).clamp(20.0, 32.0);
            final sideW = (c.maxWidth - classW - gapW * 2) / 2;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _columnLabel('Siswa', sideW),
                    SizedBox(width: gapW),
                    _columnLabel('Kelas', classW),
                    SizedBox(width: gapW),
                    _columnLabel('Siswa', sideW),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: boardH,
                  child: Stack(
                    children: [
                      Positioned(left: 0, top: 0, width: sideW, child: _studentColumn(0)),
                      Positioned(right: 0, top: 0, width: sideW, child: _studentColumn(_perSide)),
                      // Kolom kelas di tengah
                      Positioned(
                        left: sideW + gapW,
                        top: classTop,
                        width: classW,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              cables: _buildCables(),
                              pending: _selectedStudent == null
                                  ? null
                                  : (left: _isLeft(_selectedStudent!), row: _rowOf(_selectedStudent!)),
                              pendingColor: _meta.accent,
                              sideW: sideW,
                              gapW: gapW,
                              classW: classW,
                              classTop: classTop,
                              rowH: _cardH,
                              gap: _gap,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _selectedStudent == null
                ? 'Tap siswa dulu, lalu tap kelas di tengah yang id-nya sama.'
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

/// Satu kabel dari kartu siswa (kolom kiri/kanan) ke kartu kelas di tengah.
class _Cable {
  final bool left;
  final int studentRow;
  final int classRow;

  /// Urutan kabel ini di antara [slots] kabel yang masuk ke sisi kelas yang sama.
  final int slot;
  final int slots;
  final Color color;
  const _Cable({
    required this.left,
    required this.studentRow,
    required this.classRow,
    required this.slot,
    required this.slots,
    required this.color,
  });
}

/// Menggambar kabel melengkung dari tepi dalam kartu siswa ke tepi kartu
/// kelas terdekat, plus kabel putus-putus dari siswa yang sedang dipilih.
class _CablePainter extends CustomPainter {
  final List<_Cable> cables;
  final ({bool left, int row})? pending;
  final Color pendingColor;
  final double sideW, gapW, classW, classTop, rowH, gap;
  _CablePainter({
    required this.cables,
    required this.pending,
    required this.pendingColor,
    required this.sideW,
    required this.gapW,
    required this.classW,
    required this.classTop,
    required this.rowH,
    required this.gap,
  });

  double _y(int row) => row * (rowH + gap) + rowH / 2;

  /// Tepi dalam kolom siswa (titik awal kabel).
  double _studentX(bool left) => left ? sideW : sideW + gapW * 2 + classW;

  /// Tepi kartu kelas yang menghadap kolom siswa itu.
  double _classX(bool left) => left ? sideW + gapW : sideW + gapW + classW;

  @override
  void paint(Canvas canvas, Size size) {
    final plug = Paint()..style = PaintingStyle.fill;
    for (final c in cables) {
      final spread = (c.slot - (c.slots - 1) / 2) * 9;
      final a = Offset(_studentX(c.left), _y(c.studentRow));
      final b = Offset(_classX(c.left), classTop + _y(c.classRow) + spread);
      final mid = (a.dx + b.dx) / 2;
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(mid, a.dy, mid, b.dy, b.dx, b.dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = c.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      plug.color = c.color;
      canvas.drawCircle(a, 4, plug);
      canvas.drawCircle(b, 4, plug);
    }
    final p = pending;
    if (p != null) {
      final a = Offset(_studentX(p.left), _y(p.row));
      final dir = p.left ? 1.0 : -1.0;
      final paint = Paint()
        ..color = pendingColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      // Kabel pendek putus-putus yang menunggu disambung.
      for (var x = 0.0; x < gapW * 0.7; x += 8) {
        canvas.drawLine(Offset(a.dx + dir * x, a.dy), Offset(a.dx + dir * (x + 4), a.dy), paint);
      }
      plug.color = pendingColor;
      canvas.drawCircle(a, 4, plug);
    }
  }

  // Dibuat ulang hanya saat state ruangan berubah, dan menggambarnya murah.
  @override
  bool shouldRepaint(_CablePainter old) => true;
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nama, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              // Diperkecil otomatis di HP sempit supaya tidak terpotong.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'kelas_id: $kelasId',
                  style: AppTypography.code.copyWith(fontSize: 11, color: pairedColor ?? AppColors.textSecondary),
                ),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(nama, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700), maxLines: 1),
                ),
                Text('id: $id', style: AppTypography.code.copyWith(fontSize: 11, color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
