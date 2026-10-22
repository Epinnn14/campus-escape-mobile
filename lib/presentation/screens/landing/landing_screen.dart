import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/online_provider.dart';
import '../../../application/providers/session_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/event_info.dart';
import '../../../data/models/player_session.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/buttons.dart';
import '../../../data/models/socs_fact.dart';
import '../../widgets/common.dart';
import '../../widgets/photo_carousel.dart';
import '../admin/admin_screen.dart';

/// Landing Page = pembuka + registrasi (nama lengkap, no HP, asal sekolah —
/// semuanya wajib — dan robot avatar). Tanpa password, tanpa batas waktu. Background layar
/// langsung berubah mengikuti warna robot yang dipilih.
class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  int _avatar = 0;
  bool _joining = false;
  String? _codeError;

  @override
  void dispose() {
    _teamCtrl.dispose();
    _schoolCtrl.dispose();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _start() async {
    if (_joining) return;
    final online = ref.read(isOnlineModeProvider);
    if (!_formKey.currentState!.validate()) {
      _snack(online
          ? 'Lengkapi dulu kode acara, nama lengkap, nomor HP, dan asal sekolah.'
          : 'Lengkapi dulu nama lengkap, nomor HP, dan asal sekolah.');
      return;
    }

    var eventCode = '';
    var uid = '';
    if (online) {
      // Mode online: kode acara wajib valid & aktif, lalu login anonim
      // dengan UID BARU supaya pemain sebelumnya di HP ini tidak tertimpa.
      setState(() {
        _joining = true;
        _codeError = null;
      });
      try {
        final code = EventCodeFormat.normalize(_codeCtrl.text);
        final fb = ref.read(firebaseServiceProvider);
        // Rules mewajibkan sudah login untuk membaca acara → login anonim dulu
        // (UID lama dipakai untuk cek kode; UID baru dibuat setelah kode valid).
        await fb.ensureParticipant();
        final event = await ref.read(eventRepositoryProvider)!.fetchEvent(code);
        if (!mounted) return;
        if (event == null) {
          setState(() => _codeError = 'Kode acara tidak ditemukan. Cek lagi ke admin.');
          return;
        }
        if (!event.active) {
          // Boleh tetap main, hanya skornya tidak masuk leaderboard acara.
          _snack('Acara ${event.name} sudah ditutup admin — kamu tetap bisa main, tapi skor tidak tersimpan ke leaderboard.');
        }
        uid = await fb.ensureParticipant(fresh: true);
        eventCode = code;
      } on FirebaseException catch (e) {
        _snack(e.code == 'permission-denied'
            ? 'Server menolak akses (Firestore Rules belum di-deploy?). Hubungi admin.'
            : 'Butuh koneksi internet untuk masuk acara (${e.code}). Coba lagi.');
        return;
      } catch (e) {
        _snack('Butuh koneksi internet untuk masuk acara. Coba lagi.');
        return;
      } finally {
        if (mounted) setState(() => _joining = false);
      }
    }

    if (!mounted) return;
    ref.read(sessionProvider.notifier).register(
          teamName: _teamCtrl.text,
          schoolOrigin: _schoolCtrl.text,
          phone: _phoneCtrl.text,
          avatarIndex: _avatar,
          eventCode: eventCode,
          onlineUid: uid,
        );
    context.go('/home');
  }

  String? _validatePhone(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return 'Nomor HP wajib diisi';
    if (!PhoneFormat.isValid(v)) {
      return 'Format nomor belum benar, contoh: 08123456789';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tint = RobotAvatars.at(_avatar).color;
    final online = ref.watch(isOnlineModeProvider);
    // Background langsung ikut warna robot yang dipilih (pratinjau).
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      color: AppColors.tintedGround(tint),
      child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto BINUS @Bekasi di atas, memudar ke warna latar.
                _HeroPhoto(fade: AppColors.tintedGround(tint)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Row(
                  children: [
                    Expanded(child: Text('SoCS BINUS @BEKASI', style: AppTypography.labelSection)),
                    const AppPill.accent(label: 'Escape Room'),
                    if (online) ...[
                      const SizedBox(width: AppSpacing.xs),
                      // Ikon kunci yang sama dengan di Home: admin masuk dari
                      // sini untuk membuat acara & mendapatkan kodenya.
                      const AdminKeyButton(),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Taklukkan ${RoomCatalog.all.length} Ruangan Terkunci Kampus',
                  style: AppTypography.headlineLg.copyWith(color: tint),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Main ${RoomCatalog.all.length} mini-game seru dan kenalan dengan dunia '
                  'Software Engineering & Computer Science. Santai, tanpa batas waktu, '
                  'cocok untuk siswa maupun orang tua.',
                  style: AppTypography.bodyLg.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),

                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        value: '${RoomCatalog.coreCount}',
                        caption: 'Ruang utama',
                        valueColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        value: '${RoomCatalog.bonus.length}',
                        caption: 'Ruang bonus',
                        valueColor: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: StatTile(value: '±3', caption: 'Menit / ruang'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                const SectionLabel('Cara main'),
                const SizedBox(height: AppSpacing.xs),
                const _BriefRow(
                  icon: Icons.meeting_room_outlined,
                  title: 'Masuk ruangan satu per satu',
                  body: 'Tiap ruangan punya satu mini-game khas jurusannya.',
                ),
                const _BriefRow(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Ada petunjuk kalau bingung',
                  body: 'Tiga petunjuk per ruangan, dari yang umum sampai hampir jawaban.',
                ),
                const _BriefRow(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Sertifikat di akhir',
                  body: 'Selesaikan semua ruangan dan unduh sertifikat PDF-mu langsung.',
                ),
                const SizedBox(height: AppSpacing.xl),

                const SectionLabel('Daftar dulu'),
                const SizedBox(height: AppSpacing.sm),
                if (online) ...[
                  const _FieldLabel('Kode acara'),
                  TextFormField(
                    controller: _codeCtrl,
                    maxLength: EventCodeFormat.length,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      const _UpperCaseFormatter(),
                    ],
                    style: AppTypography.numberSm.copyWith(fontSize: 18, letterSpacing: 4),
                    decoration: InputDecoration(
                      hintText: 'Misal: ABC321',
                      counterText: '',
                      prefixIcon: const Icon(Icons.confirmation_number_outlined, size: 20),
                      errorText: _codeError,
                    ),
                    onChanged: (_) {
                      if (_codeError != null) setState(() => _codeError = null);
                    },
                    validator: EventCodeFormat.validate,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                const _FieldLabel('Nama lengkap'),
                TextFormField(
                  controller: _teamCtrl,
                  maxLength: 40,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    hintText: 'Misal: Prabowo Subianto',
                    counterText: '',
                    prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  ),
                  validator: NameFormat.validateFullName,
                ),
                const SizedBox(height: AppSpacing.md),
                const _FieldLabel('Nomor HP'),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 16,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                  decoration: const InputDecoration(
                    hintText: 'Misal: 08123456789',
                    counterText: '',
                    prefixIcon: Icon(Icons.phone_android_outlined, size: 20),
                  ),
                  validator: _validatePhone,
                ),
                const SizedBox(height: AppSpacing.md),
                const _FieldLabel('Asal sekolah (SMA/SMK)'),
                TextFormField(
                  controller: _schoolCtrl,
                  maxLength: 40,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onFieldSubmitted: (_) => _start(),
                  decoration: const InputDecoration(
                    hintText: 'Misal: SMAN 1 Bekasi atau SMK Negeri 2 Bekasi',
                    counterText: '',
                    prefixIcon: Icon(Icons.school_outlined, size: 20),
                  ),
                  validator: NameFormat.validateSchool,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _FieldLabel('Pilih robot temanmu'),
                    AppPill(label: 'Tema: ${RobotAvatars.at(_avatar).name}', foreground: tint, border: tint),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: AppSpacing.xs,
                    crossAxisSpacing: AppSpacing.xs,
                    mainAxisExtent: 92,
                  ),
                  itemCount: RobotAvatars.all.length,
                  itemBuilder: (context, i) => _RobotTile(
                    variant: RobotAvatars.all[i],
                    selected: _avatar == i,
                    accent: tint,
                    onTap: () => setState(() => _avatar = i),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: _joining ? 'Mengecek kode acara…' : 'Mulai Petualangan',
                  icon: _joining ? Icons.hourglass_top_rounded : Icons.arrow_forward_rounded,
                  onPressed: _joining ? null : _start,
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    online
                        ? 'Skor tersimpan di perangkat ini dan dikirim ke leaderboard acara.'
                        : 'Progres tersimpan otomatis di perangkat ini.',
                    style: AppTypography.captionXs,
                    textAlign: TextAlign.center,
                  ),
                ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// Foto kampus di bagian atas Landing: tidak menutupi seluruh layar, hanya
/// bagian atas lalu memudar (gradasi) ke warna latar yang ikut robot.
class _HeroPhoto extends StatelessWidget {
  final Color fade;
  const _HeroPhoto({required this.fade});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 230 + top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CampusImage(asset: CampusPhotos.heroAsset),
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  fade.withValues(alpha: 0.25),
                  fade.withValues(alpha: 0.55),
                  fade,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.screenH,
            bottom: AppSpacing.sm,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const CampusImage(cacheWidth: 160, asset: BrandLogos.binus, fit: BoxFit.contain),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('BINUS @Bekasi', style: AppTypography.titleMd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: AppTypography.bodySm.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _BriefRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _BriefRow({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: SurfaceCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        radius: AppRadius.md,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                  Text(body, style: AppTypography.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RobotTile extends StatelessWidget {
  final RobotVariant variant;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  const _RobotTile({required this.variant, required this.selected, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceRaised : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: selected ? accent : AppColors.outline,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RobotAvatar(variant: variant, size: 44),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      variant.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.captionXs.copyWith(
                        fontSize: 10,
                        color: selected ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.check_circle, size: 16, color: accent),
              ),
          ],
        ),
      ),
    );
  }
}

/// Paksa huruf besar untuk kode acara (kursor tetap di posisi yang sama).
class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
