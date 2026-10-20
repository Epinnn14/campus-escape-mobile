import 'dart:math';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 9 (bonus) — AI & Machine Learning: "Latih AI-mu".
/// Dua tahap seperti machine learning sungguhan:
/// 1. **Latih** — 10 contoh acak, setiap jawaban langsung dikoreksi
///    (data berlabel = supervised learning).
/// 2. **Uji** — 15 contoh baru yang acak, tanpa koreksi; AI lulus kalau
///    akurasinya cukup. Lima jenis hewan supaya tidak bisa ditebak-tebak.
class AiLabRoomScreen extends StatefulWidget {
  const AiLabRoomScreen({super.key});

  @override
  State<AiLabRoomScreen> createState() => _AiLabRoomScreenState();
}

enum _Animal { kucing, anjing, burung, ikan, kelinci }

extension on _Animal {
  String get label => switch (this) {
        _Animal.kucing => 'Kucing',
        _Animal.anjing => 'Anjing',
        _Animal.burung => 'Burung',
        _Animal.ikan => 'Ikan',
        _Animal.kelinci => 'Kelinci',
      };
  IconData get icon => switch (this) {
        _Animal.kucing => Icons.pets_rounded,
        _Animal.anjing => Icons.pets_outlined,
        _Animal.burung => Icons.flight_rounded,
        _Animal.ikan => Icons.water_rounded,
        _Animal.kelinci => Icons.cruelty_free_rounded,
      };
}

class _Clue {
  final String text;
  final _Animal animal;
  const _Clue(this.text, this.animal);
}

enum _Phase { train, test }

class _AiLabRoomScreenState extends State<AiLabRoomScreen> {
  static const _pool = [
    _Clue('Suaranya "meong", suka menjilat bulunya sendiri', _Animal.kucing),
    _Clue('Telinga runcing, kumis panjang, hobi tidur di kardus', _Animal.kucing),
    _Clue('Mendengkur pelan saat dielus, bisa melompat ke atas lemari', _Animal.kucing),
    _Clue('Matanya bersinar di tempat gelap, suka mengejar titik laser', _Animal.kucing),
    _Clue('Mengubur kotorannya di pasir, jalannya nyaris tanpa suara', _Animal.kucing),
    _Clue('Cakarnya bisa disembunyikan, suka menggaruk sofa', _Animal.kucing),
    _Clue('Suaranya "guk guk", senang diajak lari pagi', _Animal.anjing),
    _Clue('Suka mengejar bola dan mengibaskan ekor saat senang', _Animal.anjing),
    _Clue('Menjulurkan lidah saat kepanasan, setia menunggu di depan pintu', _Animal.anjing),
    _Clue('Bisa dilatih duduk dan salaman, hidungnya sangat tajam', _Animal.anjing),
    _Clue('Menggonggong kalau ada tamu, suka digaruk perutnya', _Animal.anjing),
    _Clue('Dibawa jalan pakai tali, senang bermain lempar-tangkap', _Animal.anjing),
    _Clue('Punya paruh dan sayap, bisa terbang tinggi', _Animal.burung),
    _Clue('Berkicau di pagi hari, bertelur di sarang di pohon', _Animal.burung),
    _Clue('Tubuhnya ditutupi bulu halus, bertengger di dahan', _Animal.burung),
    _Clue('Makan biji-bijian, ada yang bisa menirukan suara orang', _Animal.burung),
    _Clue('Dua kaki bercakar, bisa bermigrasi ribuan kilometer', _Animal.burung),
    _Clue('Mengepakkan sayap untuk terbang, tubuhnya sangat ringan', _Animal.burung),
    _Clue('Hidup di air, bernapas dengan insang', _Animal.ikan),
    _Clue('Tubuhnya bersisik dan licin, berenang pakai sirip', _Animal.ikan),
    _Clue('Tidak punya kaki, bertelur di dalam air', _Animal.ikan),
    _Clue('Tinggal di akuarium, makan pelet yang ditabur', _Animal.ikan),
    _Clue('Tidak bisa berkedip, tidur dengan mata terbuka', _Animal.ikan),
    _Clue('Berenang bergerombol, sisiknya bisa berkilau', _Animal.ikan),
    _Clue('Telinganya panjang, suka makan wortel dan sayur', _Animal.kelinci),
    _Clue('Melompat-lompat, giginya terus tumbuh seumur hidup', _Animal.kelinci),
    _Clue('Bulunya lembut, hidungnya terus bergerak-gerak', _Animal.kelinci),
    _Clue('Tinggal di liang, ekornya pendek seperti bola kapas', _Animal.kelinci),
    _Clue('Kaki belakangnya kuat untuk melompat jauh', _Animal.kelinci),
    _Clue('Mengunyah terus, suka bersembunyi di bawah semak', _Animal.kelinci),
  ];
  static const _trainCount = 10;
  static const _testCount = 15;
  static const _passCount = 11;

  late List<_Clue> _train;
  late List<_Clue> _test;
  late List<_Animal?> _trainAnswers;
  late List<_Animal?> _testAnswers;
  _Phase _phase = _Phase.train;
  int _index = 0;

  RoomMeta get _meta => RoomCatalog.byId(RoomId.bonusAi);

  List<_Clue> get _items => _phase == _Phase.train ? _train : _test;
  List<_Animal?> get _answers => _phase == _Phase.train ? _trainAnswers : _testAnswers;
  int get _labeled => _answers.where((a) => a != null).length;
  int _correctOf(List<_Clue> items, List<_Animal?> answers) {
    var c = 0;
    for (var i = 0; i < items.length; i++) {
      if (answers[i] == items[i].animal) c++;
    }
    return c;
  }

  @override
  void initState() {
    super.initState();
    _deal();
  }

  /// Acak kumpulan contoh: 10 untuk latih, 15 berbeda untuk uji.
  void _deal() {
    final shuffled = [..._pool]..shuffle(Random());
    _train = shuffled.sublist(0, _trainCount);
    _test = shuffled.sublist(_trainCount, _trainCount + _testCount);
    _trainAnswers = List.filled(_trainCount, null);
    _testAnswers = List.filled(_testCount, null);
    _phase = _Phase.train;
    _index = 0;
  }

  void _label(_Animal a) {
    if (_answers[_index] != null && _phase == _Phase.train) return;
    setState(() => _answers[_index] = a);
    final delay = _phase == _Phase.train ? const Duration(milliseconds: 1100) : const Duration(milliseconds: 250);
    final phaseAtTap = _phase;
    final indexAtTap = _index;
    Future<void>.delayed(delay, () {
      if (!mounted || _phase != phaseAtTap || _index != indexAtTap) return;
      setState(() {
        final next = _answers.indexWhere((x) => x == null);
        if (next != -1) _index = next;
      });
    });
  }

  RoomCheck _check() {
    if (_phase == _Phase.train) {
      if (_labeled < _trainCount) {
        return RoomCheckIncomplete('Latih dulu: masih ${_trainCount - _labeled} contoh yang belum diberi label.');
      }
      setState(() {
        _phase = _Phase.test;
        _index = 0;
      });
      return const RoomCheckIncomplete(
        'Latihan selesai! Sekarang AI-mu diuji dengan 15 contoh baru — kali ini tanpa koreksi.',
      );
    }
    if (_labeled < _testCount) {
      return RoomCheckIncomplete('Masih ${_testCount - _labeled} contoh uji yang belum dijawab.');
    }
    final correct = _correctOf(_test, _testAnswers);
    if (correct < _passCount) {
      return RoomCheckWrong(
        'Akurasi uji baru $correct dari $_testCount (butuh minimal $_passCount). Tap nomor contoh untuk memperbaiki jawaban, lalu uji lagi.',
      );
    }
    return RoomCheckCorrect('Akurasi $correct/$_testCount! AI-mu lulus uji dan bisa mengenali 5 hewan.');
  }

  @override
  Widget build(BuildContext context) {
    final clue = _items[_index];
    final answer = _answers[_index];
    final isTrain = _phase == _Phase.train;
    final trainCorrect = _correctOf(_train, _trainAnswers);

    return RoomScaffold(
      meta: _meta,
      storyLead: 'AI-nya masih bayi, belum kenal hewan satu pun.',
      storyBody: isTrain
          ? 'Tahap 1 — Latih: baca cirinya, tap nama hewannya. AI langsung memberi tahu benar atau salah, '
              'jadi kamu (dan AI-nya) belajar dari $_trainCount contoh ini.'
          : 'Tahap 2 — Uji: $_testCount contoh baru tanpa koreksi. Lulus kalau minimal $_passCount benar — '
              'persis cara AI sungguhan dinilai.',
      hints: const [
        'Fokus ke satu ciri paling khas di tiap kartu: suara, cara bergerak, atau tempat tinggalnya.',
        'Kucing: meong, kumis, mendengkur. Anjing: guk guk, bola, lidah. Burung: paruh, sayap, berkicau. Ikan: insang, sirip, air. Kelinci: telinga panjang, wortel, melompat.',
        'Saat tahap Latih, perhatikan koreksinya — ciri yang sama akan muncul lagi dengan kalimat berbeda saat Uji. Butuh 11 dari 15 benar untuk lulus.',
      ],
      modeLabel: 'Tap label',
      stageCount: 2,
      stagesDone: isTrain ? 0 : 1,
      checkLabel: isTrain ? 'Selesai Latih' : 'Uji AI',
      onCheck: _check,
      onReset: () => setState(_deal),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppPill(
                label: isTrain ? 'LATIH · $_labeled/$_trainCount' : 'UJI · $_labeled/$_testCount',
                foreground: _meta.accent,
                icon: isTrain ? Icons.school_outlined : Icons.fact_check_outlined,
              ),
              const Spacer(),
              if (isTrain && _labeled > 0)
                Text('Benar saat latih: $trainCorrect/$_labeled', style: AppTypography.captionXs),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SurfaceCard(
            color: AppColors.surfaceRaised,
            borderColor: _meta.accent,
            radius: AppRadius.xl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_outlined, size: 20, color: _meta.accent),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Contoh ${_index + 1} dari ${_items.length}', style: AppTypography.labelSection),
                    const Spacer(),
                    if (answer != null && !isTrain) AppPill(label: answer.label, foreground: _meta.accent),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(clue.text, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                if (isTrain && answer != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  StatusBanner(
                    kind: answer == clue.animal ? BannerKind.success : BannerKind.danger,
                    text: answer == clue.animal
                        ? 'Benar! AI mencatat: ini ciri ${clue.animal.label}.'
                        : 'Kurang tepat. Yang benar: ${clue.animal.label}. AI mencatat koreksinya.',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(builder: (context, c) {
            const gap = AppSpacing.xs;
            final w = (c.maxWidth - gap * 2) / 3;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final a in _Animal.values)
                  SizedBox(
                    width: w,
                    child: _LabelButton(
                      label: a.label,
                      icon: a.icon,
                      selected: answer == a,
                      accent: _meta.accent,
                      onTap: () => _label(a),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              for (var i = 0; i < _items.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _index = i),
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == _index ? AppColors.surfaceRaised : AppColors.surfaceDim,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _answers[i] == null
                            ? AppColors.outline
                            : isTrain
                                ? (_answers[i] == _items[i].animal ? AppColors.success : AppColors.danger)
                                : _meta.accent,
                      ),
                    ),
                    child: Text('${i + 1}', style: AppTypography.captionXs.copyWith(fontSize: 10)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          HelperPanel(
            label: isTrain ? 'Progres latihan' : 'Meter akurasi uji',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProgressRail(
                  value: _labeled / _items.length,
                  color: isTrain ? AppColors.surfaceHighest : _meta.accent,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isTrain
                      ? 'Setelah $_trainCount contoh, tekan "Selesai Latih" untuk masuk tahap Uji.'
                      : 'Jawab semua $_testCount contoh, lalu tekan "Uji AI". Hasil baru terlihat di akhir — seperti ujian beneran.',
                  style: AppTypography.captionXs,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SurfaceCard(
            color: AppColors.surfaceDim,
            borderColor: AppColors.outlineSubtle,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'Begini cara AI dibuat: dilatih dengan data berlabel (training), lalu diuji dengan data '
              'yang belum pernah dilihat (testing). Kalau akurasinya bagus di data baru, barulah AI dipakai.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  const _LabelButton({required this.label, required this.icon, required this.selected, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceRaised : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: selected ? accent : AppColors.outline, width: selected ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? accent : AppColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelButtonSm.copyWith(color: selected ? AppColors.textPrimary : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
