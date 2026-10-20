import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 3 — Data Science: "Sortir Data".
/// Kartu data pendaftar muncul satu per satu; simpan yang benar, buang yang
/// rusak. Setelah bersih, grafiknya langsung bisa dibaca.
class DataScienceRoomScreen extends StatefulWidget {
  const DataScienceRoomScreen({super.key});

  @override
  State<DataScienceRoomScreen> createState() => _DataScienceRoomScreenState();
}

class _Card {
  final String nama;
  final String umur;
  final String jurusanMinat;
  final bool valid;
  final String alasan;
  const _Card(this.nama, this.umur, this.jurusanMinat, {required this.valid, this.alasan = ''});
}

class _DataScienceRoomScreenState extends State<DataScienceRoomScreen> {
  static const _cards = [
    _Card('Aisyah', '17', 'Software Engineering', valid: true),
    _Card('Bima', '250', 'Game Development', valid: false, alasan: 'umur 250 tahun tidak masuk akal'),
    _Card('Citra', '16', 'Data Science', valid: true),
    _Card('', '17', 'Cyber Security', valid: false, alasan: 'nama kosong'),
    _Card('Dion', '18', 'Software Engineering', valid: true),
    _Card('Eka', '-3', 'UI/UX', valid: false, alasan: 'umur minus'),
  ];

  final List<bool?> _keep = List.filled(_cards.length, null);
  int _index = 0;

  RoomMeta get _meta => RoomCatalog.byId(RoomId.dataScience);
  int get _decided => _keep.where((k) => k != null).length;
  bool get _finished => _decided == _cards.length;

  void _decide(bool keep) {
    setState(() {
      _keep[_index] = keep;
      // Lompat ke kartu berikutnya yang belum diputuskan (kalau ada).
      final nextUndecided = _keep.indexWhere((k) => k == null);
      if (nextUndecided != -1) _index = nextUndecided;
    });
  }

  RoomCheck _check() {
    if (!_finished) {
      return RoomCheckIncomplete('Masih ada ${_cards.length - _decided} kartu yang belum disortir.');
    }
    var wrong = 0;
    for (var i = 0; i < _cards.length; i++) {
      if (_keep[i] != _cards[i].valid) wrong++;
    }
    if (wrong > 0) {
      return RoomCheckWrong('Ada $wrong kartu yang salah sortir. Cek lagi: umur masuk akal? nama terisi? Tekan ulang untuk mencoba lagi.');
    }
    return const RoomCheckCorrect('Data bersih! Sekarang grafiknya bisa dipercaya.');
  }

  void _reset() => setState(() {
        _keep.fillRange(0, _keep.length, null);
        _index = 0;
      });

  Map<String, int> get _distribution {
    final m = <String, int>{};
    for (var i = 0; i < _cards.length; i++) {
      if (_keep[i] == true) {
        m.update(_cards[i].jurusanMinat, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final card = _cards[_index];
    final dist = _distribution;
    final maxV = dist.values.isEmpty ? 1 : dist.values.reduce((a, b) => a > b ? a : b);

    return RoomScaffold(
      meta: _meta,
      storyLead: 'Data pendaftar open house berantakan.',
      storyBody:
          'Ada kartu yang isinya aneh. Simpan kartu yang benar, buang yang '
          'rusak. Data Scientist selalu membersihkan data dulu sebelum membaca grafik.',
      hints: const [
        'Tanya dua hal untuk tiap kartu: apakah umurnya masuk akal untuk siswa SMA, dan apakah namanya terisi?',
        'Umur 250 atau minus jelas salah. Nama kosong juga tidak bisa dipakai.',
        'Yang harus dibuang: kartu Bima (umur 250), kartu tanpa nama, dan kartu Eka (umur -3). Sisanya disimpan.',
      ],
      modeLabel: 'Tap simpan / buang',
      stageCount: _cards.length,
      stagesDone: _decided,
      onCheck: _check,
      onReset: _reset,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kartu aktif
          SurfaceCard(
            color: AppColors.surfaceRaised,
            borderColor: _meta.accent,
            radius: AppRadius.xl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.badge_outlined, size: 20, color: _meta.accent),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Kartu ${_index + 1} dari ${_cards.length}', style: AppTypography.labelSection),
                    const Spacer(),
                    if (_keep[_index] != null)
                      AppPill(
                        label: _keep[_index]! ? 'Disimpan' : 'Dibuang',
                        foreground: _keep[_index]! ? AppColors.success : AppColors.danger,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _Field(label: 'Nama', value: card.nama.isEmpty ? '(kosong)' : card.nama, odd: card.nama.isEmpty),
                _Field(label: 'Umur', value: '${card.umur} tahun', odd: int.tryParse(card.umur) == null || int.parse(card.umur) < 10 || int.parse(card.umur) > 25),
                _Field(label: 'Minat', value: card.jurusanMinat),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _DecideButton(
                  label: 'Buang',
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  onTap: () => _decide(false),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _DecideButton(
                  label: 'Simpan',
                  icon: Icons.check_rounded,
                  color: AppColors.success,
                  onTap: () => _decide(true),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Navigasi kartu (biar bisa koreksi)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _cards.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _index = i),
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == _index ? AppColors.surfaceRaised : AppColors.surfaceDim,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _keep[i] == null
                            ? AppColors.outline
                            : _keep[i]!
                                ? AppColors.success
                                : AppColors.danger,
                      ),
                    ),
                    child: Text('${i + 1}', style: AppTypography.captionXs.copyWith(fontSize: 10)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          HelperPanel(
            label: _finished ? 'Grafik minat jurusan (dari data yang disimpan)' : 'Grafik muncul setelah semua kartu disortir',
            child: SizedBox(
              height: 110,
              child: !_finished
                  ? const Center(child: Icon(Icons.bar_chart_rounded, size: 40, color: AppColors.outline))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final e in dist.entries) ...[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('${e.value}', style: AppTypography.captionXs),
                                const SizedBox(height: 2),
                                Container(
                                  height: 70 * e.value / maxV,
                                  decoration: BoxDecoration(
                                    color: e.value == maxV ? _meta.accent : AppColors.surfaceRaised,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  e.key.split(' ').first,
                                  style: AppTypography.captionXs.copyWith(fontSize: 9),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final bool odd;
  const _Field({required this.label, required this.value, this.odd = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(label, style: AppTypography.caption)),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: odd ? AppColors.warning : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecideButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _DecideButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: onTap == null ? AppColors.outlineSubtle : color),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: onTap == null ? AppColors.textDisabled : color),
              const SizedBox(width: 6),
              Text(label, style: AppTypography.labelButtonSm.copyWith(color: onTap == null ? AppColors.textDisabled : color)),
            ],
          ),
        ),
      ),
    );
  }
}
