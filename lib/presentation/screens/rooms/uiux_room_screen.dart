import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/common.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 2 — UI/UX: "Mana yang lebih enak dipakai?"
/// Tiga ronde membandingkan dua tampilan. Tidak ada jargon: cukup rasakan
/// mana yang lebih mudah dibaca dan ditekan.
class UiuxRoomScreen extends StatefulWidget {
  const UiuxRoomScreen({super.key});

  @override
  State<UiuxRoomScreen> createState() => _UiuxRoomScreenState();
}

class _Round {
  final String question;
  final String why;
  final int goodSide; // 0 = kiri (A), 1 = kanan (B)
  final Widget Function(bool good) builder;
  const _Round({required this.question, required this.why, required this.goodSide, required this.builder});
}

class _UiuxRoomScreenState extends State<UiuxRoomScreen> {
  static final _rounds = <_Round>[
    _Round(
      question: 'Tombol mana yang lebih gampang ditekan?',
      why: 'Tombol besar dengan tulisan jelas lebih mudah dijangkau jari dan dibaca.',
      goodSide: 0,
      builder: (good) => _MockButton(big: good),
    ),
    _Round(
      question: 'Tulisan mana yang lebih enak dibaca?',
      why: 'Kontras tinggi (tulisan terang di latar gelap) nyaman dibaca, termasuk oleh orang tua.',
      goodSide: 1,
      builder: (good) => _MockText(contrast: good),
    ),
    _Round(
      question: 'Menu mana yang lebih jelas maksudnya?',
      why: 'Ikon yang diberi label tidak bikin orang menebak-nebak.',
      goodSide: 0,
      builder: (good) => _MockMenu(labeled: good),
    ),
  ];

  final List<int?> _picks = List.filled(3, null);

  RoomMeta get _meta => RoomCatalog.byId(RoomId.uiUx);

  int get _answered => _picks.where((p) => p != null).length;

  RoomCheck _check() {
    if (_answered < _rounds.length) {
      return RoomCheckIncomplete('Masih ada ${_rounds.length - _answered} perbandingan yang belum dipilih.');
    }
    for (var i = 0; i < _rounds.length; i++) {
      if (_picks[i] != _rounds[i].goodSide) {
        return RoomCheckWrong('Perbandingan ${i + 1} belum tepat. Bayangkan dipakai orang yang terburu-buru atau matanya kurang awas.');
      }
    }
    return const RoomCheckCorrect('Tepat semua! Desain yang baik terasa "gampang" tanpa perlu dijelaskan.');
  }

  @override
  Widget build(BuildContext context) {
    return RoomScaffold(
      meta: _meta,
      storyLead: 'Pintu ini punya sensor empati.',
      storyBody:
          'Ia hanya terbuka kalau kamu bisa memilih tampilan yang paling ramah '
          'untuk pengguna. Pilih satu dari tiap pasangan.',
      hints: const [
        'Bayangkan aplikasinya dipakai kakek atau nenekmu. Mana yang tidak bikin mereka bingung?',
        'Tombol: lebih besar lebih aman. Tulisan: kontras tinggi lebih terbaca. Menu: ada label lebih jelas.',
        'Jawaban: pasangan 1 pilih yang kiri, pasangan 2 pilih yang kanan, pasangan 3 pilih yang kiri.',
      ],
      modeLabel: 'Tap pilihan',
      stageCount: _rounds.length,
      stagesDone: _answered,
      onCheck: _check,
      onReset: () => setState(() => _picks.fillRange(0, _picks.length, null)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _rounds.length; i++) ...[
            Text('${i + 1}. ${_rounds[i].question}', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                for (var side = 0; side < 2; side++) ...[
                  Expanded(
                    child: _OptionFrame(
                      label: side == 0 ? 'A' : 'B',
                      selected: _picks[i] == side,
                      accent: _meta.accent,
                      onTap: () => setState(() => _picks[i] = side),
                      child: _rounds[i].builder(side == _rounds[i].goodSide),
                    ),
                  ),
                  if (side == 0) const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
            if (i < _rounds.length - 1) const SizedBox(height: AppSpacing.lg),
          ],
          const SizedBox(height: AppSpacing.md),
          SurfaceCard(
            color: AppColors.surfaceDim,
            borderColor: AppColors.outlineSubtle,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'UI/UX Designer memastikan aplikasi mudah dipakai semua orang: '
              'tombol gampang ditekan, tulisan gampang dibaca, menu gampang dimengerti.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionFrame extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  final Widget child;
  const _OptionFrame({required this.label, required this.selected, required this.accent, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceRaised : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: selected ? AppColors.accent : AppColors.outline, width: selected ? 2 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label, style: AppTypography.labelBadge.copyWith(color: selected ? AppColors.accent : AppColors.textMuted)),
                  const Spacer(),
                  if (selected) const Icon(Icons.check_circle, size: 16, color: AppColors.accent),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 96,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Mockup mini (latar terang supaya terasa seperti app "beneran") ----

class _MockButton extends StatelessWidget {
  final bool big;
  const _MockButton({required this.big});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: big ? double.infinity : 48,
        height: big ? 40 : 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: big ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(big ? 10 : 4),
        ),
        child: Text(
          big ? 'Daftar Sekarang' : 'ok',
          style: TextStyle(
            fontSize: big ? 14 : 8,
            fontWeight: FontWeight.w700,
            color: big ? Colors.white : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}

class _MockText extends StatelessWidget {
  final bool contrast;
  const _MockText({required this.contrast});

  @override
  Widget build(BuildContext context) {
    final color = contrast ? const Color(0xFF111827) : const Color(0xFFD1D5DB);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jadwal Kunjungan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(
          'Sesi 1 mulai pukul 09.00 di Lab Komputer lantai 3.',
          style: TextStyle(fontSize: 10, height: 1.4, color: color),
        ),
      ],
    );
  }
}

class _MockMenu extends StatelessWidget {
  final bool labeled;
  const _MockMenu({required this.labeled});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Beranda'),
      (Icons.search_rounded, 'Cari'),
      (Icons.person_rounded, 'Profil'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        for (final (icon, label) in items)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: const Color(0xFF374151)),
              if (labeled) ...[
                const SizedBox(height: 3),
                Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF374151))),
              ],
            ],
          ),
      ],
    );
  }
}
