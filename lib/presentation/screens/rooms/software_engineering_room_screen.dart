import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/common.dart';
import '../../widgets/puzzle/choice_task.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 7 — Software Engineering: "Cari Bug".
/// Program kecil yang salah menentukan siswa lulus. Tap baris yang salah,
/// lalu pilih perbaikannya. Inilah pekerjaan sehari-hari Software Engineer.
class SoftwareEngineeringRoomScreen extends StatefulWidget {
  const SoftwareEngineeringRoomScreen({super.key});

  @override
  State<SoftwareEngineeringRoomScreen> createState() => _SoftwareEngineeringRoomScreenState();
}

class _SoftwareEngineeringRoomScreenState extends State<SoftwareEngineeringRoomScreen> {
  static const _lines = [
    'nilai = 80',
    'batas_lulus = 75',
    'jika nilai < batas_lulus:',
    '    tampilkan "Selamat, kamu lulus!"',
    'selain itu:',
    '    tampilkan "Belum lulus, coba lagi"',
  ];
  static const _bugLine = 2;
  static const _fixes = [
    'jika nilai >= batas_lulus:',
    'jika nilai == batas_lulus:',
    'jika nilai < 100:',
  ];
  static const _fixCorrect = 0;

  int? _selectedLine;
  int? _fix;

  RoomMeta get _meta => RoomCatalog.byId(RoomId.softwareEngineering);

  RoomCheck _check() {
    if (_selectedLine == null) return const RoomCheckIncomplete('Tap dulu baris program yang menurutmu salah.');
    if (_selectedLine != _bugLine) {
      return const RoomCheckWrong('Bukan baris itu. Nilainya 80, batasnya 75 — seharusnya lulus, tapi program bilang belum. Cari baris pembandingnya.');
    }
    if (_fix == null) return const RoomCheckIncomplete('Baris yang salah sudah ketemu! Sekarang pilih perbaikannya.');
    if (_fix != _fixCorrect) {
      return const RoomCheckWrong('Perbaikan itu belum tepat. Siswa lulus kalau nilainya sama atau lebih besar dari batas.');
    }
    return const RoomCheckCorrect('Bug ketemu dan diperbaiki! Program sekarang bilang "Selamat, kamu lulus!".');
  }

  @override
  Widget build(BuildContext context) {
    final bugFound = _selectedLine == _bugLine;
    return RoomScaffold(
      meta: _meta,
      storyLead: 'Program pengumuman kelulusan salah hitung.',
      storyBody:
          'Nilai 80 dengan batas 75 seharusnya lulus, tapi program bilang belum. '
          'Temukan baris yang salah, lalu pilih perbaikannya.',
      hints: const [
        'Baca programnya seperti kalimat biasa dari atas ke bawah. Di baris mana komputer "memutuskan" lulus atau tidak?',
        'Perhatikan tanda pembandingnya. "<" artinya lebih kecil. Apakah 80 lebih kecil dari 75?',
        'Baris ke-3 salah. Tanda "<" harus diganti ">=" (lebih besar atau sama dengan).',
      ],
      modeLabel: 'Tap baris',
      stageCount: 2,
      stagesDone: bugFound ? 1 : 0,
      onCheck: _check,
      onReset: () => setState(() {
        _selectedLine = null;
        _fix = null;
      }),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Tahap 1 · Tap baris yang salah'),
          const SizedBox(height: AppSpacing.xs),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _lines.length; i++)
                  Material(
                    color: _selectedLine == i ? AppColors.surfaceRaised : Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() {
                        _selectedLine = i;
                        if (i != _bugLine) _fix = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: _selectedLine == i ? _meta.accent : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 22,
                              child: Text('${i + 1}', style: AppTypography.code.copyWith(color: AppColors.textDisabled, fontSize: 12)),
                            ),
                            Expanded(
                              child: Text(
                                bugFound && i == _bugLine && _fix != null ? _fixes[_fix!] : _lines[i],
                                style: AppTypography.code.copyWith(
                                  color: _selectedLine == i ? AppColors.textPrimary : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            if (_selectedLine == i)
                              Icon(Icons.bug_report_outlined, size: 18, color: _meta.accent),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Opacity(
            opacity: bugFound ? 1 : 0.5,
            child: IgnorePointer(
              ignoring: !bugFound,
              child: ChoiceTask(
                question: 'Tahap 2 · Ganti baris itu dengan…',
                options: _fixes,
                selected: _fix,
                accent: _meta.accent,
                onSelect: (i) => setState(() => _fix = i),
              ),
            ),
          ),
          if (!bugFound) ...[
            const SizedBox(height: AppSpacing.xs),
            Text('Pilihan perbaikan terbuka setelah baris yang salah ditemukan.', style: AppTypography.captionXs),
          ],
          const SizedBox(height: AppSpacing.md),
          SurfaceCard(
            color: AppColors.surfaceDim,
            borderColor: AppColors.outlineSubtle,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'Software Engineer membangun aplikasi dan menjaga agar tetap benar: '
              'menulis kode, mengujinya, lalu memperbaiki "bug" seperti ini bersama tim.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}
