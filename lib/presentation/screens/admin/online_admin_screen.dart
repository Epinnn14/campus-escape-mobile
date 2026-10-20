import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/online_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/event_info.dart';
import '../../../data/models/player_record.dart';
import '../../../data/models/room_meta.dart';
import '../../../data/models/room_settings.dart';
import '../../../data/remote/event_repository.dart';
import '../../../domain/services/admin_export_service.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import 'admin_widgets.dart';
import 'csv_view_screen.dart';

/// Panel admin ONLINE (setelah login username + password):
/// - buat/tutup acara (kode per kunjungan) dan atur ruangan per acara,
/// - pantau peserta real-time dari HP masing-masing,
/// - tetapkan pemenang dari leaderboard (muncul di HP semua peserta),
/// - ekspor CSV (lihat tabel / unduh file) lengkap dengan no HP (hanya admin).
class OnlineAdminScreen extends ConsumerStatefulWidget {
  const OnlineAdminScreen({super.key});

  @override
  ConsumerState<OnlineAdminScreen> createState() => _OnlineAdminScreenState();
}

class _OnlineAdminScreenState extends ConsumerState<OnlineAdminScreen> {
  bool _busy = false;

  EventRepository get _repo => ref.read(eventRepositoryProvider)!;

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _run(Future<void> Function() fn, {String? done}) async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    try {
      await fn();
      if (done != null) _toast(done);
    } catch (e) {
      _toast(e is StateError ? e.message : 'Gagal: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createEvent() async {
    final draft = await showDialog<({String name, String code})>(
      context: context,
      builder: (_) => const _CreateEventDialog(),
    );
    if (draft == null) return;
    await _run(() async {
      final username = ref.read(firebaseServiceProvider).adminUsername ?? 'admin';
      final ev = await _repo.adminCreateEvent(code: draft.code, name: draft.name, createdBy: username);
      if (!mounted) return;
      Navigator.of(context).push(EventDetailScreen.route(ev.code));
    }, done: 'Acara dibuat. Bagikan kodenya ke peserta.');
  }

  Future<void> _logout() async {
    await ref.read(firebaseServiceProvider).adminSignOut();
    if (mounted) context.pop();
  }

  /// Tombol back sistem: tetap logout supaya sesi admin tidak tertinggal.
  void _onPopped(bool didPop, Object? result) {
    if (didPop) ref.read(firebaseServiceProvider).adminSignOut();
  }

  // ------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(adminSignedInProvider).valueOrNull ?? false;
    final username = ref.watch(firebaseServiceProvider).adminUsername ?? '-';
    final events = ref.watch(adminEventsProvider);

    return PopScope(
      onPopInvokedWithResult: _onPopped,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Panel Admin'),
              Text('online · $username', style: AppTypography.captionXs),
            ],
          ),
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: _logout),
          actions: [
            IconButton(tooltip: 'Logout', icon: const Icon(Icons.logout_rounded), onPressed: _logout),
          ],
        ),
        body: SafeArea(
          top: false,
          child: !signedIn
              ? _SessionEnded(onLogin: () => context.pushReplacement('/admin/login'))
              : events.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _ErrorBox('Tidak bisa memuat acara: $e'),
                  data: (list) => _buildList(list),
                ),
        ),
      ),
    );
  }

  /// Daftar acara (kunjungan). Tap satu acara → halaman detailnya.
  Widget _buildList(List<EventInfo> events) {
    final active = events.where((e) => e.active).toList();
    final closed = events.where((e) => !e.active).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SectionLabel('Acara (${events.length})')),
              TextButton.icon(
                onPressed: _busy ? null : _createEvent,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Acara baru'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (events.isEmpty)
            SurfaceCard(
              color: AppColors.surfaceDim,
              borderColor: AppColors.outlineSubtle,
              child: Text(
                'Belum ada acara. Buat satu acara per kunjungan sekolah, lalu bagikan kodenya ke peserta.',
                style: AppTypography.caption,
              ),
            ),
          for (final ev in active) ...[
            _EventListTile(event: ev, onTap: () => Navigator.of(context).push(EventDetailScreen.route(ev.code))),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (closed.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            SectionLabel('Sudah ditutup (${closed.length})'),
            const SizedBox(height: AppSpacing.xs),
            for (final ev in closed) ...[
              _EventListTile(event: ev, onTap: () => Navigator.of(context).push(EventDetailScreen.route(ev.code))),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ],
      ),
    );
  }
}

/// Satu baris acara di daftar: kode, nama, status, jumlah peserta, pemenang.
class _EventListTile extends ConsumerWidget {
  final EventInfo event;
  final VoidCallback onTap;
  const _EventListTile({required this.event, required this.onTap});

  String _date(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider(event.code)).valueOrNull;
    final winner = event.winner;
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      radius: AppRadius.lg,
      borderColor: event.active ? AppColors.success : AppColors.outline,
      color: event.active ? AppColors.surface : AppColors.surfaceDim,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      event.code,
                      style: AppTypography.numberSm.copyWith(fontSize: 18, color: AppColors.accent, letterSpacing: 3),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AppPill(
                      label: event.active ? 'AKTIF' : 'DITUTUP',
                      foreground: event.active ? AppColors.success : AppColors.textMuted,
                      border: event.active ? AppColors.success : AppColors.outline,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  event.name,
                  style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_date(event.createdAt)} · ${stats == null ? '… peserta' : '${stats.total} peserta'}'
                  '${winner == null ? '' : ' · Pemenang: ${winner.name}'}',
                  style: AppTypography.captionXs,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

/// Halaman detail satu acara: kode, tutup/buka, pemenang, statistik,
/// ekspor CSV, peserta live, pengaturan ruangan, hapus.
class EventDetailScreen extends ConsumerStatefulWidget {
  final String code;
  const EventDetailScreen({super.key, required this.code});

  static Route<void> route(String code) => MaterialPageRoute(builder: (_) => EventDetailScreen(code: code));

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailState();
}

class _EventDetailState extends ConsumerState<EventDetailScreen> {
  bool _busy = false;

  EventRepository get _repo => ref.read(eventRepositoryProvider)!;

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _run(Future<void> Function() fn, {String? done}) async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    try {
      await fn();
      if (done != null) _toast(done);
    } catch (e) {
      _toast(e is StateError ? e.message : 'Gagal: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String body, {String action = 'Ya', bool danger = false}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: danger ? TextButton.styleFrom(foregroundColor: AppColors.danger) : null,
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<String?> _askText(String title, {String hint = '', String initial = ''}) =>
      showDialog<String>(
        context: context,
        builder: (_) => _TextPromptDialog(title: title, hint: hint, initial: initial),
      );

  Future<void> _toggleActive(EventInfo ev) async {
    if (ev.active &&
        !await _confirm(
          'Tutup acara?',
          'Setelah ditutup, skor peserta tidak bisa masuk lagi (ditolak server). Leaderboard & ekspor tetap bisa dilihat.',
          action: 'Tutup',
        )) {
      return;
    }
    await _run(() => _repo.adminSetActive(ev.code, !ev.active), done: ev.active ? 'Acara ditutup.' : 'Acara dibuka lagi.');
  }

  Future<void> _rename(EventInfo ev) async {
    final name = await _askText('Ganti nama acara', initial: ev.name);
    if (name == null) return;
    await _run(() => _repo.adminRename(ev.code, name));
  }

  Future<void> _deleteEvent(EventInfo ev) async {
    if (!await _confirm(
      'Hapus acara ${ev.code}?',
      'Semua data peserta acara ini dihapus permanen dari server. Ekspor dulu kalau masih dibutuhkan.',
      action: 'Hapus',
      danger: true,
    )) {
      return;
    }
    await _run(() async {
      await _repo.adminDeleteEvent(ev.code);
      if (mounted) Navigator.of(context).pop();
    }, done: 'Acara dihapus.');
  }

  Future<void> _setWinner(EventInfo ev, PlayerRecord p) async {
    if (!await _confirm(
      'Tetapkan pemenang?',
      '${p.name} (${p.school.isEmpty ? '-' : p.school}) · ${p.totalScore} XP.\n\nPengumuman langsung muncul di HP semua peserta.',
      action: 'Tetapkan',
    )) {
      return;
    }
    await _run(
      () => _repo.adminSetWinner(
        ev.code,
        EventWinner(uid: p.sessionId, name: p.name, school: p.school, score: p.totalScore, setAt: DateTime.now()),
      ),
      done: 'Pemenang ditetapkan: ${p.name}.',
    );
  }

  Future<void> _clearWinner(EventInfo ev) async {
    if (!await _confirm('Batalkan pemenang?', 'Banner pemenang di HP peserta akan hilang.', action: 'Batalkan')) return;
    await _run(() => _repo.adminSetWinner(ev.code, null), done: 'Pemenang dibatalkan.');
  }

  Future<void> _deletePlayer(EventInfo ev, PlayerRecord p) async {
    if (!await _confirm('Hapus ${p.name}?', 'Data peserta ini dihapus dari acara (HP-nya tetap bisa main, tapi skornya tidak masuk lagi).',
        action: 'Hapus', danger: true)) {
      return;
    }
    await _run(() => _repo.adminDeletePlayer(ev.code, p.sessionId), done: 'Peserta dihapus.');
  }

  Future<void> _downloadCsv(EventInfo ev) => _run(() async {
        final players = await _repo.adminFetchPlayersForExport(ev.code);
        await AdminExportService.downloadCsv(players, label: ev.code);
      });

  Future<void> _viewCsv(EventInfo ev) => _run(() async {
        final players = await _repo.adminFetchPlayersForExport(ev.code);
        if (!mounted) return;
        // Tidak di-await supaya tombol tidak terkunci selama tabel dibuka.
        Navigator.of(context).push(CsvViewScreen.route(title: '${ev.name} (${ev.code})', players: players));
      });

  Future<void> _deleteAllPlayers(EventInfo ev) async {
    if (ev.active) {
      _toast('Tutup acara dulu sebelum menghapus semua peserta.');
      return;
    }
    if (!await _confirm(
      'Hapus semua peserta ${ev.code}?',
      'Semua akun/data peserta acara ini dihapus permanen dari server (termasuk no HP). '
          'Acara & pengaturannya tetap ada. Unduh CSV dulu kalau masih dibutuhkan.',
      action: 'Hapus semua',
      danger: true,
    )) {
      return;
    }
    await _run(() async {
      final n = await _repo.adminDeleteAllPlayers(ev.code);
      _toast('$n peserta dihapus.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(adminEventProvider(widget.code)).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.code, style: const TextStyle(letterSpacing: 3)),
            Text(event?.name ?? 'Acara', style: AppTypography.captionXs, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        top: false,
        child: event == null
            ? Center(child: Text('Acara tidak ditemukan (mungkin sudah dihapus).', style: AppTypography.caption))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.xxl),
                child: _EventPanel(code: widget.code, host: this),
              ),
      ),
    );
  }
}

/// Isi halaman detail acara (stream acara & peserta hanya untuk acara ini).
class _EventPanel extends ConsumerWidget {
  final String code;
  final _EventDetailState host;
  const _EventPanel({required this.code, required this.host});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(adminEventProvider(code)).valueOrNull;
    if (event == null) return const SizedBox.shrink();
    final players = ref.watch(adminPlayersProvider(code));
    final list = players.valueOrNull ?? const <PlayerRecord>[];
    // Statistik seluruh peserta dari aggregate (daftar live hanya top-100).
    final stats = ref.watch(adminStatsProvider(code)).valueOrNull;
    final total = stats?.total ?? list.length;
    final finished = stats?.finished ?? list.where((p) => p.finished).length;
    final avg = stats?.avgScore ?? (list.isEmpty ? 0 : (list.fold<int>(0, (s, p) => s + p.totalScore) / list.length).round());
    final top = list.isEmpty ? null : list.first;
    final busy = host._busy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Kartu acara ----
        SurfaceCard(
          radius: AppRadius.xl,
          borderColor: event.active ? AppColors.success : AppColors.outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KODE ACARA', style: AppTypography.labelSection.copyWith(fontSize: 11)),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: event.code));
                            host._toast('Kode ${event.code} disalin.');
                          },
                          child: Text(
                            event.code,
                            style: AppTypography.displayTimer.copyWith(color: AppColors.accent, letterSpacing: 6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppPill(
                    label: event.active ? 'AKTIF' : 'DITUTUP',
                    foreground: event.active ? AppColors.success : AppColors.textMuted,
                    border: event.active ? AppColors.success : AppColors.outline,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(child: Text(event.name, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700))),
                  IconButton(
                    tooltip: 'Ganti nama',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: busy ? null : () => host._rename(event),
                  ),
                ],
              ),
              Text(
                'Peserta masukkan kode ini di halaman daftar. Satu kode = satu kunjungan.',
                style: AppTypography.captionXs,
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: event.active ? 'Tutup acara' : 'Buka acara lagi',
                icon: event.active ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                onPressed: busy ? null : () => host._toggleActive(event),
              ),
              const SizedBox(height: AppSpacing.xs),
              PrimaryButton(
                label: event.hasWinner ? 'Batalkan pemenang' : 'Tetapkan pemenang (juara 1)',
                icon: Icons.emoji_events_outlined,
                onPressed: busy || (top == null && !event.hasWinner)
                    ? null
                    : () => event.hasWinner ? host._clearWinner(event) : host._setWinner(event, top!),
              ),
              if (event.winner != null) ...[
                const SizedBox(height: AppSpacing.sm),
                StatusBanner(
                  text: 'Pemenang: ${event.winner!.name} · ${event.winner!.score} XP',
                  kind: BannerKind.success,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ---- Ringkasan ----
        Row(
          children: [
            Expanded(child: StatTile(value: '$total', caption: 'Peserta')),
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
                onPressed: total == 0 || busy ? null : () => host._viewCsv(event),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: PrimaryButton(
                label: busy ? 'Menyiapkan…' : 'Unduh CSV',
                icon: Icons.download_rounded,
                onPressed: total == 0 || busy ? null : () => host._downloadCsv(event),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // ---- Peserta live ----
        Row(
          children: [
            Expanded(child: SectionLabel(total > list.length ? 'Peserta live (top ${list.length} dari $total)' : 'Peserta live (${list.length})')),
            const Icon(Icons.wifi_tethering_rounded, size: 16, color: AppColors.success),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (players.isLoading && list.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.md), child: CircularProgressIndicator()))
        else if (list.isEmpty)
          SurfaceCard(
            color: AppColors.surfaceDim,
            borderColor: AppColors.outlineSubtle,
            child: Text('Belum ada peserta yang masuk dengan kode ini.', style: AppTypography.caption),
          )
        else
          for (var i = 0; i < list.length; i++) ...[
            AdminPlayerTile(
              record: list[i],
              isCurrent: event.winner?.uid == list[i].sessionId,
              badge: 'Pemenang',
              onTap: () => showAdminPlayerDetail(
                context,
                list[i],
                extraActions: Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Hapus',
                        icon: Icons.delete_outline_rounded,
                        onPressed: () {
                          Navigator.of(context).pop();
                          host._deletePlayer(event, list[i]);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Jadikan pemenang',
                        icon: Icons.emoji_events_outlined,
                        onPressed: () {
                          Navigator.of(context).pop();
                          host._setWinner(event, list[i]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        const SizedBox(height: AppSpacing.lg),

        // ---- Pengaturan ruangan per acara ----
        SectionLabel('Atur ruangan acara ini (${event.roomSettings.active.length} aktif)'),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Berlaku real-time ke semua HP peserta acara ini. Minimal satu ruang utama harus aktif.',
          style: AppTypography.captionXs,
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final meta in RoomCatalog.all) ...[
          AdminRoomSettingTile(
            meta: meta,
            enabled: event.roomSettings.isEnabled(meta.id),
            xp: event.roomSettings.xpOf(meta),
            onToggle: (v) => host._run(() => host._repo.adminSetRoomSettings(code, _toggled(event.roomSettings, meta, v))),
            onXp: (v) => host._run(() => host._repo.adminSetRoomSettings(code, _withXp(event.roomSettings, meta, v))),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: busy ? null : () => host._run(() => host._repo.adminSetRoomSettings(code, const RoomSettings())),
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Kembalikan default'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ---- Bahaya ----
        const SectionLabel('Data'),
        const SizedBox(height: AppSpacing.xs),
        AdminActionRow(
          icon: Icons.group_remove_outlined,
          title: 'Hapus semua peserta acara ini',
          subtitle: event.active
              ? 'Tutup acara dulu — baru bisa dihapus'
              : 'Semua akun peserta dihapus permanen; acara tetap ada',
          danger: !event.active,
          onTap: () => host._deleteAllPlayers(event),
        ),
        AdminActionRow(
          icon: Icons.delete_forever_outlined,
          title: 'Hapus acara ini',
          subtitle: 'Beserta semua peserta — permanen, unduh CSV dulu',
          danger: true,
          onTap: () => host._deleteEvent(event),
        ),
      ],
    );
  }

  static RoomSettings _toggled(RoomSettings s, RoomMeta meta, bool enabled) {
    final next = {...s.disabled};
    if (enabled) {
      next.remove(meta.id);
    } else {
      final remainingCore = RoomCatalog.core.where((m) => m.id != meta.id && !next.contains(m.id));
      if (remainingCore.isEmpty && !meta.isBonus) return s;
      next.add(meta.id);
    }
    return s.copyWith(disabled: next);
  }

  static RoomSettings _withXp(RoomSettings s, RoomMeta meta, int xp) {
    final clamped = xp.clamp(RoomSettings.minXp, RoomSettings.maxXp);
    final next = {...s.xpOverride};
    if (clamped == meta.xpReward) {
      next.remove(meta.id);
    } else {
      next[meta.id] = clamped;
    }
    return s.copyWith(xpOverride: next);
  }
}

class _SessionEnded extends StatelessWidget {
  final VoidCallback onLogin;
  const _SessionEnded({required this.onLogin});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 40, color: AppColors.textMuted),
              const SizedBox(height: AppSpacing.sm),
              Text('Sesi admin berakhir.', style: AppTypography.bodyMd),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(label: 'Login lagi', icon: Icons.login_rounded, onPressed: onLogin),
            ],
          ),
        ),
      );
}

class _ErrorBox extends StatelessWidget {
  final String text;
  const _ErrorBox(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        child: StatusBanner(text: text, kind: BannerKind.danger),
      );
}

/// Dialog teks sederhana (ganti nama acara). Controller dimiliki State
/// dialog sendiri supaya dibersihkan setelah dialog benar-benar tertutup.
class _TextPromptDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String initial;
  const _TextPromptDialog({required this.title, required this.hint, required this.initial});

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;
    Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: TextField(
          controller: _ctrl,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(hintText: widget.hint, counterText: ''),
          onSubmitted: (_) => _submit(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
          TextButton(onPressed: _submit, child: const Text('Simpan')),
        ],
      );
}

/// Dialog "Acara baru": nama kunjungan + kode acara (ditentukan admin,
/// format 3 huruf + 3 angka; tombol acak untuk saran kode).
class _CreateEventDialog extends StatefulWidget {
  const _CreateEventDialog();

  @override
  State<_CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<_CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  late final TextEditingController _codeCtrl = TextEditingController(text: EventCodeFormat.generate());

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((
      name: _nameCtrl.text.trim(),
      code: EventCodeFormat.normalize(_codeCtrl.text),
    ));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Acara baru'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama kunjungan', style: AppTypography.caption),
              TextFormField(
                controller: _nameCtrl,
                autofocus: true,
                maxLength: 40,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: 'Misal: Kunjungan SMAN 1 Bekasi', counterText: ''),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Nama kunjungan wajib diisi' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Kode acara (3 huruf + 3 angka)', style: AppTypography.caption),
              TextFormField(
                controller: _codeCtrl,
                maxLength: EventCodeFormat.length,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
                style: AppTypography.numberSm.copyWith(fontSize: 18, letterSpacing: 4),
                decoration: InputDecoration(
                  hintText: 'Misal: ABC321',
                  counterText: '',
                  suffixIcon: IconButton(
                    tooltip: 'Acak',
                    icon: const Icon(Icons.casino_outlined, size: 20),
                    onPressed: () => setState(() => _codeCtrl.text = EventCodeFormat.generate()),
                  ),
                ),
                validator: EventCodeFormat.validate,
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
          TextButton(onPressed: _submit, child: const Text('Buat')),
        ],
      );
}
