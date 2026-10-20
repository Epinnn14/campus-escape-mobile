import 'dart:math';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../../domain/engines/puzzle_engine.dart';
import '../../widgets/common.dart';
import '../../widgets/puzzle/choice_task.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 10 (bonus, pintu terakhir) — Cyber Security: "Pecahkan Sandi".
/// Tahap 1: geser huruf sampai sandi rahasia terbaca (Caesar cipher).
/// Jarak gesernya diacak tiap kali ruangan dibuka (1–10), jadi pemain harus
/// benar-benar mencoba, bukan menghafal angka. Maksimal 10 putaran.
/// Tahap 2: pilih password yang paling aman.
class CyberSecurityRoomScreen extends StatefulWidget {
  const CyberSecurityRoomScreen({super.key});

  @override
  State<CyberSecurityRoomScreen> createState() => _CyberSecurityRoomScreenState();
}

class _CyberSecurityRoomScreenState extends State<CyberSecurityRoomScreen> {
  static const _plainText = 'BINUS';
  static const _maxShift = 10;
  static const _passwords = ['binus123', 'Kampus@Bekasi#2026', 'password'];
  static const _passwordCorrect = 1;

  late int _secretShift;
  late String _cipherText;
  int _shift = 0;
  int? _password;

  RoomMeta get _meta => RoomCatalog.byId(RoomId.bonusCyber);
  String get _decoded => CipherEngine.decode(_cipherText, _shift);
  bool get _cipherSolved => _decoded == _plainText;

  @override
  void initState() {
    super.initState();
    _newSecret();
  }

  /// Pilih jarak geser acak 1..10 dan sandikan kata rahasianya.
  void _newSecret() {
    _secretShift = 1 + Random().nextInt(_maxShift);
    _cipherText = CipherEngine.shift(_plainText, _secretShift);
    _shift = 0;
    _password = null;
  }

  RoomCheck _check() {
    if (!_cipherSolved) {
      return const RoomCheckWrong('Sandi belum terbaca. Geser angkanya pelan-pelan sampai jadi kata yang kamu kenal.');
    }
    if (_password == null) return const RoomCheckIncomplete('Sandi terpecahkan! Sekarang pilih password yang paling aman.');
    if (_password != _passwordCorrect) {
      return const RoomCheckWrong('Password itu gampang ditebak. Yang aman: panjang, campur huruf besar-kecil, angka, dan simbol.');
    }
    return const RoomCheckCorrect('Brankas terbuka! Kampus aman di tanganmu.');
  }

  @override
  Widget build(BuildContext context) {
    return RoomScaffold(
      meta: _meta,
      storyLead: 'Ini pintu terakhir.',
      storyBody:
          'Pesan rahasia dari panitia tersandi. Geser hurufnya sampai terbaca, '
          'lalu pilih password yang paling aman untuk mengunci brankas.',
      hints: const [
        'Sandi Caesar menggeser setiap huruf dengan jarak yang sama. Coba naikkan angkanya satu per satu (maksimal 10) dan lihat kotak hasilnya.',
        'Kata rahasianya adalah nama kampus tempat kamu berada sekarang, 5 huruf. Jarak gesernya berbeda tiap kali ruangan dibuka.',
        'Perhatikan huruf pertama: geser sampai huruf pertamanya jadi "B", sisanya otomatis terbaca. Password paling aman adalah yang panjang dan ada simbolnya.',
      ],
      modeLabel: 'Tap − / +',
      stageCount: 2,
      stagesDone: _cipherSolved ? 1 : 0,
      checkLabel: 'Buka Brankas',
      onCheck: _check,
      onReset: () => setState(_newSecret),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Tahap 1 · Pecahkan sandi'),
          const SizedBox(height: AppSpacing.xs),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pesan tersandi', style: AppTypography.caption),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _cipherText.split('').join(' '),
                  style: AppTypography.code.copyWith(fontSize: 24, color: _meta.accent),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Text('Geser huruf', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    _StepButton(icon: Icons.remove_rounded, label: 'Kurangi', onTap: _shift == 0 ? null : () => setState(() => _shift = (_shift - 1).clamp(0, _maxShift))),
                    SizedBox(
                      width: 48,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$_shift', textAlign: TextAlign.center, style: AppTypography.numberLg.copyWith(fontSize: 22)),
                          Text('dari $_maxShift', style: AppTypography.captionXs.copyWith(fontSize: 9)),
                        ],
                      ),
                    ),
                    _StepButton(icon: Icons.add_rounded, label: 'Tambah', onTap: _shift == _maxShift ? null : () => setState(() => _shift = (_shift + 1).clamp(0, _maxShift))),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Hasil', style: AppTypography.caption),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    for (var i = 0; i < _decoded.length; i++) ...[
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _cipherSolved ? AppColors.successSurface : AppColors.surfaceDim,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _cipherSolved ? AppColors.successOutline : AppColors.outline, width: 1.5),
                          ),
                          child: Text(
                            _decoded[i],
                            style: AppTypography.code.copyWith(fontSize: 20, color: _cipherSolved ? AppColors.successText : AppColors.textPrimary),
                          ),
                        ),
                      ),
                      if (i < _decoded.length - 1) const SizedBox(width: 6),
                    ],
                  ],
                ),
                if (_cipherSolved) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const StatusBanner(kind: BannerKind.success, text: 'Terbaca! Lanjut ke tahap 2.'),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Opacity(
            opacity: _cipherSolved ? 1 : 0.5,
            child: IgnorePointer(
              ignoring: !_cipherSolved,
              child: ChoiceTask(
                question: 'Tahap 2 · Password mana yang paling aman?',
                options: _passwords,
                selected: _password,
                accent: _meta.accent,
                onSelect: (i) => setState(() => _password = i),
              ),
            ),
          ),
          if (!_cipherSolved) ...[
            const SizedBox(height: AppSpacing.xs),
            Text('Tahap 2 terbuka setelah sandi terpecahkan.', style: AppTypography.captionXs),
          ],
          const SizedBox(height: AppSpacing.md),
          SurfaceCard(
            color: AppColors.surfaceDim,
            borderColor: AppColors.outlineSubtle,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'Enkripsi (menyandikan pesan) dan password kuat adalah dua lapis pertahanan paling dasar. '
              'Cyber Security Engineer berpikir seperti penyerang untuk menutup celah lebih dulu.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _StepButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: const BorderSide(color: AppColors.outline),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 20, color: onTap == null ? AppColors.textDisabled : AppColors.textPrimary)),
        ),
      ),
    );
  }
}
