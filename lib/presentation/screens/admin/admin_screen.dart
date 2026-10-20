import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/insight_provider.dart';
import '../../../application/providers/local_storage_provider.dart';
import '../../../application/providers/online_provider.dart';
import '../../../application/providers/player_archive_provider.dart';
import '../../../application/providers/room_progress_provider.dart';
import '../../../application/providers/room_settings_provider.dart';
import '../../../application/providers/session_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/player_record.dart';
import '../../../data/models/room_meta.dart';
import '../../../data/models/room_settings.dart';
import '../../../domain/services/admin_export_service.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import 'admin_widgets.dart';
import 'csv_view_screen.dart';
import 'online_admin_screen.dart';

/// Buka panel admin dari ikon kunci di Landing/Home.
/// - Mode online: SELALU lewat layar login username + password (sesi admin
///   sebelumnya di-logout dulu, supaya HP yang pernah dipakai admin tidak
///   bisa langsung masuk panel).
/// - Mode lokal: dialog password saja (tanpa username) → panel lokal.
Future<void> openAdminPanel(BuildContext context, WidgetRef ref) async {
  if (ref.read(isOnlineModeProvider)) {
    await ref.read(firebaseServiceProvider).adminSignOut();
    if (context.mounted) context.push('/admin/login');
    return;
  }
  final ctrl = TextEditingController();
  var error = false;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('Akses admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masukkan password admin.', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: ctrl,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.key_rounded, size: 20),
                errorText: error ? 'Password salah' : null,
              ),
              onSubmitted: (_) {
                if (ref.read(adminConfigProvider).check(ctrl.text)) {
                  Navigator.of(ctx).pop(true);
                } else {
                  setDialogState(() => error = true);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (ref.read(adminConfigProvider).check(ctrl.text)) {
                Navigator.of(ctx).pop(true);
              } else {
                setDialogState(() => error = true);
              }
            },
            child: const Text('Masuk'),
          ),
        ],
      ),
    ),
  );
  // Dialog masih animasi menutup saat showDialog selesai — jangan dispose
  // controller sekarang (TextField-nya masih hidup sebentar).
  Future<void>.delayed(const Duration(milliseconds: 600), ctrl.dispose);
  if (ok == true && context.mounted) context.push('/admin');
}

/// Ikon kunci akses admin — tampilan sama di Home dan Landing.
class AdminKeyButton extends ConsumerWidget {
  const AdminKeyButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Tooltip(
        message: 'Akses admin',
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: const BorderSide(color: AppColors.outline),
          ),
          child: InkWell(
            onTap: () => openAdminPanel(context, ref),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: const SizedBox(
              width: AppSize.iconButton,
              height: AppSize.iconButton,
              child: Icon(Icons.key_rounded, size: 20, color: AppColors.accent),
            ),
          ),
        ),
      );
}

/// Pilih panel sesuai mode build: online (Firebase) atau lokal (Hive).
class AdminPanelRoute extends ConsumerWidget {
  const AdminPanelRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(isOnlineModeProvider) ? const OnlineAdminScreen() : const AdminScreen();
}

/// Panel admin LOKAL (mode tanpa Firebase): progres semua pemain di
/// perangkat ini, ekspor data, pengaturan ruangan, dan keamanan. Hanya bisa
/// dibuka lewat password.
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  bool _busy = false;

  List<PlayerRecord> _players() {
    // Pastikan pemain yang sedang aktif ikut masuk arsip.
    ref.read(playerArchiveProvider.notifier).syncCurrent();
    final list = [...ref.read(playerArchiveProvider)]
      ..sort((a, b) => b.lastPlayedAt.compareTo(a.lastPlayedAt));
    return list;
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _downloadCsv() async {
    setState(() => _busy = true);
    try {
      await AdminExportService.downloadCsv(_players(), label: 'lokal');
    } catch (e) {
      _toast('Gagal membuat CSV: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _viewCsv() {
    Navigator.of(context).push(CsvViewScreen.route(title: 'Data pemain (perangkat ini)', players: _players()));
  }

  Future<void> _changePassword() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti password admin'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Password baru (min. 4 karakter)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim().length >= 4), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok == true) {
      ref.read(adminConfigProvider.notifier).setPassword(ctrl.text);
      _toast('Password admin diganti.');
    } else if (ok == false && ctrl.text.trim().isNotEmpty) {
      _toast('Password minimal 4 karakter.');
    }
    Future<void>.delayed(const Duration(milliseconds: 600), ctrl.dispose);
  }

  Future<bool> _confirm(String title, String body, {String action = 'Hapus'}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _resetCurrentPlayer() async {
    if (!await _confirm(
      'Reset pemain aktif?',
      'Progres pemain yang sedang main akan dihapus dan app kembali ke halaman daftar. Datanya tetap tersimpan di arsip.',
      action: 'Reset',
    )) {
      return;
    }
    ref.read(playerArchiveProvider.notifier).syncCurrent();
    await ref.read(localStorageProvider).clearAll();
    ref.read(roomProgressProvider.notifier).resetAll();
    ref.read(insightProvider.notifier).resetAll();
    ref.read(sessionProvider.notifier).resetToFresh();
    if (mounted) context.go('/landing');
  }

  Future<void> _clearArchive() async {
    if (!await _confirm(
      'Hapus arsip semua pemain?',
      'Semua data pemain di perangkat ini dihapus permanen. Ekspor dulu kalau masih dibutuhkan.',
    )) {
      return;
    }
    ref.read(playerArchiveProvider.notifier).clearAll();
    _toast('Arsip pemain dihapus.');
  }

  @override
  Widget build(BuildContext context) {
    final archive = ref.watch(playerArchiveProvider);
    final session = ref.watch(sessionProvider);
    final settings = ref.watch(roomSettingsProvider);
    final totals = ref.watch(roomTotalsProvider);

    // Daftar untuk tampilan: arsip + pemain aktif (kalau belum tersimpan).
    final players = [...archive];
    if (session.isRegistered && !players.any((p) => p.sessionId == session.sessionId)) {
      players.add(PlayerRecord.fromCurrent(
        session: session,
        rooms: ref.watch(roomProgressProvider),
        activeRooms: settings.active,
      ));
    }
    players.sort((a, b) => b.lastPlayedAt.compareTo(a.lastPlayedAt));
    final finished = players.where((p) => p.finished).length;
    final avg = players.isEmpty ? 0 : (players.fold<int>(0, (s, p) => s + p.totalScore) / players.length).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Ringkasan ----
              Row(
                children: [
                  Expanded(child: StatTile(value: '${players.length}', caption: 'Pemain')),
                  const SizedBox(width: 10),
                  Expanded(child: StatTile(value: '$finished', caption: 'Selesai semua', valueColor: AppColors.success)),
                  const SizedBox(width: 10),
                  Expanded(child: StatTile(value: '$avg', caption: 'Rata-rata XP', valueColor: AppColors.accent)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ---- Ekspor ----
              const SectionLabel('Tarik data'),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Lihat CSV',
                      icon: Icons.table_chart_outlined,
                      onPressed: players.isEmpty ? null : _viewCsv,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: PrimaryButton(
                      label: _busy ? 'Menyiapkan…' : 'Unduh CSV',
                      icon: Icons.download_rounded,
                      onPressed: players.isEmpty || _busy ? null : _downloadCsv,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ---- Pemain ----
              SectionLabel('Progres pemain (${players.length})'),
              const SizedBox(height: AppSpacing.xs),
              if (players.isEmpty)
                SurfaceCard(
                  color: AppColors.surfaceDim,
                  borderColor: AppColors.outlineSubtle,
                  child: Text('Belum ada pemain yang mendaftar di perangkat ini.', style: AppTypography.caption),
                )
              else
                for (final p in players) ...[
                  AdminPlayerTile(
                    record: p,
                    isCurrent: p.sessionId == session.sessionId,
                    onTap: () => showAdminPlayerDetail(context, p),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
              const SizedBox(height: AppSpacing.lg),

              // ---- Pengaturan ruangan ----
              SectionLabel('Atur ruangan (${totals.total} aktif)'),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Matikan ruangan untuk melewatinya (urutan unlock menyesuaikan otomatis), atau ubah XP dasarnya. '
                'Berlaku langsung untuk pemain berikutnya. Minimal satu ruang utama harus aktif.',
                style: AppTypography.captionXs,
              ),
              const SizedBox(height: AppSpacing.xs),
              for (final meta in RoomCatalog.all) ...[
                AdminRoomSettingTile(
                  meta: meta,
                  enabled: settings.isEnabled(meta.id),
                  xp: settings.xpOf(meta),
                  onToggle: (v) {
                    ref.read(roomSettingsProvider.notifier).setEnabled(meta.id, v);
                    ref.read(roomProgressProvider.notifier).recomputeUnlocks();
                  },
                  onXp: (v) => ref.read(roomSettingsProvider.notifier).setXp(meta.id, v),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(roomSettingsProvider.notifier).resetToDefault();
                    ref.read(roomProgressProvider.notifier).recomputeUnlocks();
                    _toast('Pengaturan ruangan dikembalikan ke default.');
                  },
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text('Kembalikan default'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ---- Keamanan & data ----
              const SectionLabel('Keamanan & data'),
              const SizedBox(height: AppSpacing.xs),
              AdminActionRow(icon: Icons.password_rounded, title: 'Ganti password admin', subtitle: 'Default: ${AdminConfig.defaultPassword}', onTap: _changePassword),
              AdminActionRow(icon: Icons.person_remove_outlined, title: 'Reset pemain aktif', subtitle: 'Kembali ke halaman daftar; data tetap di arsip', onTap: _resetCurrentPlayer),
              AdminActionRow(icon: Icons.delete_outline_rounded, title: 'Hapus arsip semua pemain', subtitle: 'Permanen — ekspor dulu', danger: true, onTap: _clearArchive),
            ],
          ),
        ),
      ),
    );
  }
}

