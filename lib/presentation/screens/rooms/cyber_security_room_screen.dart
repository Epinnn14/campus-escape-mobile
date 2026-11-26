import 'dart:math';

import 'package:material_ui/material_ui.dart';
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
/// Tahap 3: "Tangkap pesan jebakan" — nilai 4 pesan masuk, mana yang aman dan
/// mana yang phishing. Urutan pesan diacak tiap kali ruangan dibuka.
class CyberSecurityRoomScreen extends StatefulWidget {
  const CyberSecurityRoomScreen({super.key});

  @override
  State<CyberSecurityRoomScreen> createState() => _CyberSecurityRoomScreenState();
}

/// Satu pesan masuk di tahap 3.
class _Inbox {
  final String from;
  final String text;
  final bool phishing;
  const _Inbox(this.from, this.text, {required this.phishing});
}

class _CyberSecurityRoomScreenState extends State<CyberSecurityRoomScreen> {
  static const _plainText = 'BINUS';
  static const _maxShift = 10;
  static const _passwords = ['binus123', 'Kampus@Bekasi#2026', 'password'];
  static const _passwordCorrect = 1;
  static const _inbox = [
    _Inbox(
      'Undian Kampus',
      'Selamat, kamu menang iPhone! Klaim sekarang di binus-hadiah.xyz dan masukkan password-mu.',
      phishing: true,
    ),
    _Inbox(
      'Dosen Algoritma',
      'Pengingat: kelas besok pindah ke Lab 3 lantai 2. Sampai jumpa jam 9.',
      phishing: false,
    ),
    _Inbox(
      'Admin (nomor tak dikenal)',
      'Akunmu akan DIBLOKIR dalam 5 menit! Segera balas pesan ini dengan kode OTP yang baru masuk.',
      phishing: true,
    ),
    _Inbox(
      'Perpustakaan',
      'Buku yang kamu pinjam jatuh tempo hari Jumat. Kembalikan di meja depan ya.',
      phishing: false,
    ),
  ];

  late int _secretShift;
  late String _cipherText;
  int _shift = 0;
  int? _password;

  /// Urutan tampil pesan (indeks ke [_inbox]) dan penilaian pemain per pesan:
  /// true = jebakan, false = aman, null = belum dinilai.
  late List<int> _inboxOrder;
  final Map<int, bool> _verdicts = {};

  RoomMeta get _meta => RoomCatalog.byId(RoomId.bonusCyber);
  String get _decoded => CipherEngine.decode(_cipherText, _shift);
  bool get _cipherSolved => _decoded == _plainText;

  @override
  void initState() {
    super.initState();
    _newSecret();
  }

  /// Pilih jarak geser acak 1..10, sandikan kata rahasianya, acak urutan pesan.
  void _newSecret() {
    final rnd = Random();
    _secretShift = 1 + rnd.nextInt(_maxShift);
    _cipherText = CipherEngine.shift(_plainText, _secretShift);
    _shift = 0;
    _password = null;
    _inboxOrder = List.generate(_inbox.length, (i) => i)..shuffle(rnd);
    _verdicts.clear();
  }

  RoomCheck _check() {
    if (!_cipherSolved) {
      return const RoomCheckWrong('Sandi belum terbaca. Geser angkanya pelan-pelan sampai jadi kata yang kamu kenal.');
    }
    if (_password == null) return const RoomCheckIncomplete('Sandi terpecahkan! Sekarang pilih password yang paling aman.');
    if (_password != _passwordCorrect) {
      return const RoomCheckWrong('Password itu gampang ditebak. Yang aman: panjang, campur huruf besar-kecil, angka, dan simbol.');
    }
    if (_verdicts.length < _inbox.length) {
      return RoomCheckIncomplete('Password aman! Tinggal tahap 3: masih ${_inbox.length - _verdicts.length} pesan yang belum kamu nilai.');
    }
    var wrong = 0;
    for (var i = 0; i < _inbox.length; i++) {
      if (_verdicts[i] != _inbox[i].phishing) wrong++;
    }
    if (wrong > 0) {
      return RoomCheckWrong(
        '$wrong pesan salah kamu nilai. Ciri jebakan: minta password atau kode OTP, mengancam dan terburu-buru, atau memakai link yang bukan alamat resmi.',
      );
    }
    return const RoomCheckCorrect('Brankas terbuka! Sandi terpecahkan, password kuat, jebakan terdeteksi — kampus aman di tanganmu.');
  }

  @override
  Widget build(BuildContext context) {
    final passwordPicked = _password != null;
    return RoomScaffold(
      meta: _meta,
      storyLead: 'Ini pintu terakhir.',
      storyBody:
          'Pesan rahasia dari admin tersandi. Geser hurufnya sampai terbaca, pilih password '
          'paling aman untuk mengunci brankas, lalu tangkap pesan jebakan yang mengincar akunmu.',
      hints: const [
        'Sandi Caesar menggeser setiap huruf dengan jarak yang sama. Coba naikkan angkanya satu per satu (maksimal 10) dan lihat kotak hasilnya.',
        'Kata rahasianya adalah nama kampus tempat kamu berada sekarang, 5 huruf: geser sampai huruf pertamanya jadi "B". Password paling aman adalah yang panjang dan ada simbolnya.',
        'Pesan jebakan (phishing) biasanya meminta password atau kode OTP, mengancam supaya kamu terburu-buru, atau memberi link yang bukan alamat resmi. Dua dari empat pesan adalah jebakan.',
      ],
      modeLabel: 'Tap − / +',
      stageCount: 3,
      stagesDone: (_cipherSolved ? 1 : 0) + (passwordPicked ? 1 : 0),
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
          _Locked(
            locked: !_cipherSolved,
            child: ChoiceTask(
              question: 'Tahap 2 · Password mana yang paling aman?',
              options: _passwords,
              selected: _password,
              accent: _meta.accent,
              onSelect: (i) => setState(() => _password = i),
            ),
          ),
          if (!_cipherSolved) ...[
            const SizedBox(height: AppSpacing.xs),
            Text('Tahap 2 terbuka setelah sandi terpecahkan.', style: AppTypography.captionXs),
          ],
          const SizedBox(height: AppSpacing.lg),
          _Locked(
            locked: !passwordPicked,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Tahap 3 · Tangkap pesan jebakan'),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Empat pesan masuk ke HP-mu. Tandai mana yang aman dan mana yang jebakan (phishing).',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                for (final i in _inboxOrder) ...[
                  _InboxCard(
                    message: _inbox[i],
                    verdict: _verdicts[i],
                    accent: _meta.accent,
                    onVerdict: (v) => setState(() => _verdicts[i] = v),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ],
            ),
          ),
          if (!passwordPicked)
            Text('Tahap 3 terbuka setelah kamu memilih password.', style: AppTypography.captionXs),
          const SizedBox(height: AppSpacing.md),
          SurfaceCard(
            color: AppColors.surfaceDim,
            borderColor: AppColors.outlineSubtle,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'Enkripsi (menyandikan pesan), password kuat, dan waspada terhadap pesan jebakan adalah tiga pertahanan paling dasar. '
              'Cyber Security Engineer berpikir seperti penyerang untuk menutup celah lebih dulu.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

/// Meredupkan dan menonaktifkan tahap yang belum terbuka.
class _Locked extends StatelessWidget {
  final bool locked;
  final Widget child;
  const _Locked({required this.locked, required this.child});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.5 : 1,
      child: IgnorePointer(ignoring: locked, child: child),
    );
  }
}

/// Kartu satu pesan masuk + dua tombol penilaian (Aman / Jebakan).
class _InboxCard extends StatelessWidget {
  final _Inbox message;
  final bool? verdict;
  final Color accent;
  final ValueChanged<bool> onVerdict;
  const _InboxCard({required this.message, required this.verdict, required this.accent, required this.onVerdict});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      borderColor: verdict == null ? AppColors.outline : accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sms_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  message.from,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(message.text, style: AppTypography.bodyMd),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _VerdictButton(
                  label: 'Aman',
                  icon: Icons.gpp_good_outlined,
                  selected: verdict == false,
                  accent: accent,
                  onTap: () => onVerdict(false),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _VerdictButton(
                  label: 'Jebakan',
                  icon: Icons.gpp_bad_outlined,
                  selected: verdict == true,
                  accent: accent,
                  onTap: () => onVerdict(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerdictButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  const _VerdictButton({required this.label, required this.icon, required this.selected, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceRaised : AppColors.surfaceDim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(color: selected ? accent : AppColors.outline, width: selected ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? accent : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelButtonSm.copyWith(color: selected ? AppColors.textPrimary : AppColors.textSecondary),
              ),
            ],
          ),
        ),
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
