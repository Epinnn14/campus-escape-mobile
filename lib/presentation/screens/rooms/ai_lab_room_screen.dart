import 'dart:math';

import 'package:material_ui/material_ui.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 9 (bonus) — AI & Machine Learning: "Latih AI-mu".
/// Dua tahap seperti machine learning sungguhan, masing-masing 15 contoh:
/// 1. **Latih** — pemain memberi label; tiap jawaban langsung dikoreksi
///    (data berlabel = supervised learning). Jumlah contoh per hewan sengaja
///    tidak rata, jadi ada hewan yang jarang dilihat AI.
/// 2. **Uji** — AI menebak dulu 15 contoh baru berdasarkan hasil latihan.
///    Hewan yang jarang (atau salah) dilatih sering salah ditebak; pemain
///    memeriksa tebakan AI dan membetulkannya sebelum dinilai.
/// Enam jenis hewan supaya tidak bisa ditebak-tebak.
class AiLabRoomScreen extends StatefulWidget {
  const AiLabRoomScreen({super.key});

  @override
  State<AiLabRoomScreen> createState() => _AiLabRoomScreenState();
}

enum _Animal { kucing, anjing, burung, ikan, kelinci, bebek }

extension on _Animal {
  String get label => switch (this) {
        _Animal.kucing => 'Kucing',
        _Animal.anjing => 'Anjing',
        _Animal.burung => 'Burung',
        _Animal.ikan => 'Ikan',
        _Animal.kelinci => 'Kelinci',
        _Animal.bebek => 'Bebek',
      };
  IconData get icon => switch (this) {
        _Animal.kucing => Icons.pets_rounded,
        _Animal.anjing => Icons.pets_outlined,
        _Animal.burung => Icons.flight_rounded,
        _Animal.ikan => Icons.water_rounded,
        _Animal.kelinci => Icons.cruelty_free_rounded,
        _Animal.bebek => Icons.egg_outlined,
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
    _Clue('Punya sayap lebar, bisa terbang tinggi di langit', _Animal.burung),
    _Clue('Berkicau di pagi hari, bertelur di sarang di pohon', _Animal.burung),
    _Clue('Tubuhnya ditutupi bulu halus, bertengger di dahan', _Animal.burung),
    _Clue('Makan biji-bijian, ada yang bisa menirukan suara orang', _Animal.burung),
    _Clue('Dua kaki bercakar, bisa bermigrasi ribuan kilometer', _Animal.burung),
    _Clue('Mengepakkan sayap untuk terbang, tubuhnya sangat ringan', _Animal.burung),
    _Clue('Hidup di dalam air, bernapas dengan insang', _Animal.ikan),
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
    _Clue('Suaranya "kwek kwek", jalannya bergoyang ke kiri-kanan', _Animal.bebek),
    _Clue('Paruhnya pipih dan lebar, suka berenang di kolam', _Animal.bebek),
    _Clue('Kakinya berselaput seperti dayung, bulunya tidak basah kena air', _Animal.bebek),
    _Clue('Berbaris mengikuti induknya menuju sawah', _Animal.bebek),
    _Clue('Telurnya sering dijadikan telur asin', _Animal.bebek),
    _Clue('Menyelamkan kepala ke air mencari makan, ekornya menungging ke atas', _Animal.bebek),
  ];
  static const _trainCount = 15;
  static const _testCount = 15;
  static const _passCount = 12;

  /// Jumlah contoh per hewan (urutan hewannya diacak tiap main). Latihan
  /// sengaja tidak rata: dua hewan hanya muncul sekali, sehingga AI masih
  /// ragu pada hewan itu saat diuji.
  static const _trainPlan = [4, 4, 3, 2, 1, 1];
  static const _testPlan = [2, 2, 3, 3, 3, 2];

  late List<_Clue> _train;
  late List<_Clue> _test;
  late List<_Animal?> _trainAnswers;

  /// Tebakan awal AI untuk tiap contoh uji (diisi saat masuk tahap Uji).
  List<_Animal> _aiGuess = const [];

  /// Jawaban akhir tahap Uji: berawal dari tebakan AI, bisa dibetulkan pemain.
  List<_Animal?> _testAnswers = const [];

  /// Berapa contoh tiap hewan yang berhasil dipelajari AI (label benar).
  Map<_Animal, int> _learned = const {};
  _Phase _phase = _Phase.train;
  int _index = 0;

  RoomMeta get _meta => RoomCatalog.byId(RoomId.bonusAi);

  List<_Clue> get _items => _phase == _Phase.train ? _train : _test;
  List<_Animal?> get _answers => _phase == _Phase.train ? _trainAnswers : _testAnswers;
  int get _labeled => _trainAnswers.where((a) => a != null).length;
  int get _corrected {
    var c = 0;
    for (var i = 0; i < _aiGuess.length; i++) {
      if (_testAnswers[i] != _aiGuess[i]) c++;
    }
    return c;
  }

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

  /// Bagi 36 ciri jadi 15 contoh latih + 15 contoh uji yang berbeda, dengan
  /// jumlah per hewan mengikuti [_trainPlan] / [_testPlan].
  void _deal() {
    final rnd = Random();
    final animals = [..._Animal.values]..shuffle(rnd);
    final train = <_Clue>[];
    final test = <_Clue>[];
    for (var k = 0; k < animals.length; k++) {
      final clues = _pool.where((c) => c.animal == animals[k]).toList()..shuffle(rnd);
      train.addAll(clues.take(_trainPlan[k]));
      test.addAll(clues.skip(_trainPlan[k]).take(_testPlan[k]));
    }
    _train = train..shuffle(rnd);
    _test = test..shuffle(rnd);
    _trainAnswers = List.filled(_trainCount, null);
    _aiGuess = const [];
    _testAnswers = const [];
    _learned = const {};
    _phase = _Phase.train;
    _index = 0;
  }

  /// "Melatih" AI dari label pemain, lalu biarkan AI menebak semua contoh uji.
  ///
  /// Aturannya sederhana dan bisa dijelaskan ke pemain:
  /// - hewan yang dipelajari dari ≥ 2 contoh benar → AI menebaknya benar;
  /// - hanya 1 contoh benar → AI masih ragu, salah di setiap contoh kedua;
  /// - 0 contoh benar → AI belum kenal, selalu salah.
  /// Saat salah, AI menebak hewan yang paling sering ia lihat ketika latihan.
  void _runAi() {
    final learned = {for (final a in _Animal.values) a: 0};
    for (var i = 0; i < _train.length; i++) {
      if (_trainAnswers[i] == _train[i].animal) {
        learned[_train[i].animal] = learned[_train[i].animal]! + 1;
      }
    }
    final ranked = [..._Animal.values]..sort((a, b) => learned[b]!.compareTo(learned[a]!));
    final seen = <_Animal, int>{};
    final guesses = <_Animal>[];
    for (final clue in _test) {
      final n = seen.update(clue.animal, (v) => v + 1, ifAbsent: () => 0);
      final known = learned[clue.animal]!;
      final right = known >= 2 || (known == 1 && n.isEven);
      guesses.add(right ? clue.animal : ranked.firstWhere((a) => a != clue.animal));
    }
    _learned = learned;
    _aiGuess = guesses;
    _testAnswers = List<_Animal?>.of(guesses);
  }

  void _label(_Animal a) {
    final isTrain = _phase == _Phase.train;
    // Saat latih, jawaban pertama dikunci (langsung dikoreksi).
    if (isTrain && _answers[_index] != null) return;
    setState(() => _answers[_index] = a);
    final phaseAtTap = _phase;
    final indexAtTap = _index;
    Future<void>.delayed(Duration(milliseconds: isTrain ? 1100 : 300), () {
      if (!mounted || _phase != phaseAtTap || _index != indexAtTap) return;
      setState(() {
        if (isTrain) {
          final next = _answers.indexWhere((x) => x == null);
          if (next != -1) _index = next;
        } else if (_index < _items.length - 1) {
          _index++;
        }
      });
    });
  }

  void _go(int delta) => setState(() => _index = (_index + delta).clamp(0, _items.length - 1));

  RoomCheck _check() {
    if (_phase == _Phase.train) {
      if (_labeled < _trainCount) {
        return RoomCheckIncomplete('Latih dulu: masih ${_trainCount - _labeled} contoh yang belum diberi label.');
      }
      setState(() {
        _runAi();
        _phase = _Phase.test;
        _index = 0;
      });
      return const RoomCheckProgress(
        'Latihan selesai! AI sudah menebak 15 contoh baru. Periksa tebakannya dan betulkan yang salah, lalu tekan "Uji AI".',
      );
    }
    final correct = _correctOf(_test, _testAnswers);
    if (correct < _passCount) {
      return RoomCheckWrong(
        'Akurasi baru $correct dari $_testCount (butuh minimal $_passCount). AI masih salah di beberapa contoh — periksa hewan yang jarang dilatih, betulkan, lalu uji lagi.',
      );
    }
    final aiCorrect = _correctOf(_test, _aiGuess);
    return RoomCheckCorrect(
      'Akurasi $correct/$_testCount! Tebakan awal AI benar $aiCorrect, sisanya kamu yang membetulkan — begitulah manusia mengevaluasi AI.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final clue = _items[_index];
    final answer = _answers[_index];
    final isTrain = _phase == _Phase.train;
    final trainCorrect = _correctOf(_train, _trainAnswers);
    final changed = !isTrain && answer != _aiGuess[_index];

    return RoomScaffold(
      meta: _meta,
      storyLead: 'AI-nya masih bayi, belum kenal hewan satu pun.',
      storyBody: isTrain
          ? 'Tahap 1 — Latih: baca cirinya, tap nama hewannya. AI langsung memberi tahu benar atau salah, '
              'jadi kamu (dan AI-nya) belajar dari $_trainCount contoh ini.'
          : 'Tahap 2 — Uji: AI sudah menebak $_testCount contoh baru dari hasil latihanmu. Periksa tiap tebakan, '
              'betulkan yang salah. Lulus kalau minimal $_passCount benar.',
      hints: const [
        'Fokus ke satu ciri paling khas di tiap kartu: suara, cara bergerak, atau tempat tinggalnya.',
        'Kucing: meong, kumis, mendengkur. Anjing: guk guk, bola, lidah. Burung: sayap, berkicau, terbang. Ikan: insang, sirip, sisik. Kelinci: telinga panjang, wortel, melompat. Bebek: kwek kwek, paruh pipih, kaki berselaput.',
        'Saat Uji, lihat panel "Yang dipelajari AI": hewan yang contohnya cuma 0–1 paling sering salah ditebak. Periksa contoh-contoh itu lebih dulu. Butuh 12 dari 15 benar.',
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
                label: isTrain ? 'LATIH · $_labeled/$_trainCount' : 'UJI · contoh ${_index + 1}/$_testCount',
                foreground: _meta.accent,
                icon: isTrain ? Icons.school_outlined : Icons.fact_check_outlined,
              ),
              const Spacer(),
              if (isTrain && _labeled > 0)
                Text('Benar saat latih: $trainCorrect/$_labeled', style: AppTypography.captionXs)
              else if (!isTrain)
                Text('Kamu betulkan: $_corrected', style: AppTypography.captionXs),
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
                        : 'Kurang tepat. Yang benar: ${clue.animal.label}. AI tidak belajar dari contoh ini.',
                  ),
                ],
                if (!isTrain) ...[
                  const SizedBox(height: AppSpacing.sm),
                  StatusBanner(
                    kind: BannerKind.info,
                    text: changed
                        ? 'AI menebak ${_aiGuess[_index].label}, kamu ganti jadi ${answer!.label}.'
                        : 'Tebakan AI: ${_aiGuess[_index].label}. Setuju? Lanjut. Salah? Tap hewan yang benar.',
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
          if (!isTrain) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(child: SecondaryButton(label: 'Sebelumnya', onPressed: _index == 0 ? null : () => _go(-1))),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: SecondaryButton(label: 'Berikutnya', onPressed: _index == _items.length - 1 ? null : () => _go(1)),
                ),
              ],
            ),
          ],
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
                        width: i == _index ? 1.5 : 1,
                        color: isTrain
                            ? (_answers[i] == null
                                ? AppColors.outline
                                : (_answers[i] == _items[i].animal ? AppColors.success : AppColors.danger))
                            // Uji: nomor yang kamu betulkan diberi warna aksen.
                            : (_testAnswers[i] != _aiGuess[i] ? _meta.accent : AppColors.outline),
                      ),
                    ),
                    child: Text('${i + 1}', style: AppTypography.captionXs.copyWith(fontSize: 10)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isTrain)
            HelperPanel(
              label: 'Progres latihan',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProgressRail(value: _labeled / _trainCount, color: AppColors.surfaceHighest),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Setelah $_trainCount contoh, tekan "Selesai Latih". AI akan menebak $_testCount contoh baru dari apa yang ia pelajari.',
                    style: AppTypography.captionXs,
                  ),
                ],
              ),
            )
          else
            HelperPanel(
              label: 'Yang dipelajari AI saat latihan',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final a in _Animal.values)
                        AppPill(
                          label: '${a.label} · ${_learned[a] ?? 0} contoh',
                          foreground: (_learned[a] ?? 0) >= 2 ? AppColors.success : AppColors.warning,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Hewan dengan 0–1 contoh paling sering salah ditebak: AI belum cukup "melihat" hewan itu. '
                    'Itulah kenapa AI butuh banyak data yang seimbang.',
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
              'yang belum pernah dilihat (testing). Manusia memeriksa hasilnya — kalau akurasinya bagus di data baru, barulah AI dipakai.',
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
