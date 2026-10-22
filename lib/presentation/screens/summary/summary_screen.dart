import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../../../application/providers/leaderboard_provider.dart';
import '../../../application/providers/room_progress_provider.dart';
import '../../../application/providers/room_settings_provider.dart';
import '../../../application/providers/session_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../../domain/services/certificate_service.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

/// Ringkasan Akhir & Sertifikat. Sertifikat PDF dibuat langsung di perangkat.
class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  bool _building = false;

  String _predicate(int total, bool escaped, bool allDone, int coreTotal) {
    if (allDone) return 'Distinction';
    if (escaped) return 'Escaped';
    if (coreTotal > 0 && total >= coreTotal ~/ 2) return 'Explorer';
    return 'Pemula';
  }

  CertificateData _data() {
    final session = ref.read(sessionProvider);
    final rooms = ref.read(roomProgressProvider);
    final done = ref.read(completedCountProvider);
    final totals = ref.read(roomTotalsProvider);
    final activeRooms = ref.read(activeRoomsProvider);
    final total = done.core + done.bonus;
    final escaped = totals.core > 0 && done.core == totals.core;
    final allDone = totals.total > 0 && total == totals.total;
    return CertificateData(
      name: session.displayName,
      school: session.schoolOrigin,
      predicate: _predicate(total, escaped, allDone, totals.core),
      totalScore: session.totalScore,
      roomsCompleted: total,
      roomsTotal: totals.total,
      verificationCode: session.verificationCode,
      date: DateTime.now(),
      rows: [
        for (final meta in activeRooms)
          (
            room: meta.title,
            score: rooms.firstWhere((r) => r.roomId == meta.id).score,
            stars: rooms.firstWhere((r) => r.roomId == meta.id).stars,
          ),
      ],
    );
  }

  Future<void> _download() async {
    setState(() => _building = true);
    try {
      final bytes = await CertificateService.build(_data());
      final name = ref.read(sessionProvider).displayName.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
      await Printing.sharePdf(bytes: bytes, filename: 'Sertifikat_Campus_Escape_$name.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _building = false);
    }
  }

  Future<void> _preview() async {
    setState(() => _building = true);
    try {
      await Printing.layoutPdf(
        onLayout: (_) => CertificateService.build(_data()),
        name: 'Sertifikat Campus Escape',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka pratinjau: $e')));
      }
    } finally {
      if (mounted) setState(() => _building = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final rooms = ref.watch(roomProgressProvider);
    final done = ref.watch(completedCountProvider);
    final rank = ref.watch(myRankProvider);
    final totals = ref.watch(roomTotalsProvider);
    final activeRooms = ref.watch(activeRoomsProvider);
    final total = done.core + done.bonus;
    final escaped = totals.core > 0 && done.core == totals.core;
    final allDone = totals.total > 0 && total == totals.total;

    final activeIds = {for (final m in activeRooms) m.id};
    final completed = rooms.where((r) => r.isCompleted && activeIds.contains(r.roomId)).toList();
    final playSeconds = completed.fold<int>(0, (s, r) => s + r.timeSpentSeconds);
    final strongest = completed.isEmpty ? null : completed.reduce((a, b) => a.score >= b.score ? a : b);
    final strongestMeta = strongest == null ? null : RoomCatalog.byId(strongest.roomId);
    final maxScore = rooms.fold<int>(0, (m, r) => r.score > m ? r.score : m);
    final predicate = _predicate(total, escaped, allDone, totals.core);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticLabel: 'Kembali',
                    onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                  ),
                  const Spacer(),
                  AppPill(
                    label: escaped ? 'Berhasil keluar' : 'Misi berjalan',
                    background: escaped ? AppColors.successSurface : AppColors.surface,
                    foreground: escaped ? AppColors.successText : AppColors.textSecondary,
                    border: escaped ? AppColors.successOutline : AppColors.outline,
                    icon: escaped ? Icons.verified_outlined : Icons.timelapse_rounded,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  RobotAvatar(variant: session.avatar, size: 64, selected: escaped),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          escaped ? 'Kamu berhasil keluar!' : 'Gerbang masih terkunci',
                          style: AppTypography.headlineLg.copyWith(fontSize: 26),
                        ),
                        Text('${session.displayName} · SoCS BINUS @Bekasi', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(child: StatTile(value: '${session.totalScore}', caption: 'Skor XP', valueColor: AppColors.accent)),
                  const SizedBox(width: 10),
                  Expanded(child: StatTile(value: '$total/${totals.total}', caption: 'Ruang selesai', valueColor: AppColors.success)),
                  const SizedBox(width: 10),
                  Expanded(child: StatTile(value: formatDuration(Duration(seconds: playSeconds)), caption: 'Waktu bermain')),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Sertifikat
              SurfaceCard(
                color: AppColors.surfaceRaised,
                borderColor: escaped ? AppColors.success : AppColors.outline,
                radius: AppRadius.xl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Sertifikat Junior IT Explorer'),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(session.displayName, style: AppTypography.headlineMd),
                    if (session.schoolOrigin.isNotEmpty) Text(session.schoolOrigin, style: AppTypography.caption),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PREDIKAT', style: AppTypography.labelSection.copyWith(fontSize: 10)),
                              Text(
                                '$predicate · $total/${totals.total} ruang',
                                style: AppTypography.bodyMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: escaped ? AppColors.successText : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text('ID SERTIFIKAT', style: AppTypography.labelSection.copyWith(fontSize: 10)),
                              Text(session.verificationCode, style: AppTypography.numberSm.copyWith(fontSize: 16)),
                            ],
                          ),
                        ),
                        Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.ground,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: const Icon(Icons.workspace_premium_outlined, size: 40, color: AppColors.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      escaped
                          ? 'Sertifikat sudah bisa diunduh. Kalau mau nilai lebih tinggi, selesaikan ruang bonus dulu.'
                          : 'Sertifikat bisa diunduh kapan saja; predikatnya mengikuti jumlah ruang yang selesai.',
                      style: AppTypography.captionXs,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              SurfaceCard(
                radius: AppRadius.xl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Skor per ruang'),
                    const SizedBox(height: AppSpacing.sm),
                    for (final meta in activeRooms) ...[
                      _ScoreRow(
                        meta: meta,
                        score: rooms.firstWhere((r) => r.roomId == meta.id).score,
                        max: maxScore == 0 ? 1 : maxScore,
                        strongest: strongestMeta?.id == meta.id,
                      ),
                      const SizedBox(height: 7),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              if (strongestMeta != null)
                SurfaceCard(
                  color: AppColors.surfaceRaised,
                  borderColor: AppColors.accent,
                  radius: AppRadius.lg,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(strongestMeta.icon, size: 26, color: strongestMeta.accent),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ruang terkuatmu', style: AppTypography.captionXs.copyWith(color: AppColors.textSecondary)),
                            Text(strongestMeta.title, style: AppTypography.titleMd),
                            Text('Kenalan lebih jauh dengan bidang ini di tab Kampus.', style: AppTypography.captionXs),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.md),

              Text('Peringkat saat ini: #$rank', style: AppTypography.caption),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: _building ? 'Menyiapkan PDF…' : 'Unduh Sertifikat (PDF)',
                icon: Icons.download_rounded,
                onPressed: _building ? null : _download,
              ),
              const SizedBox(height: AppSpacing.xs),
              SecondaryButton(
                label: 'Lihat / cetak sertifikat',
                icon: Icons.print_outlined,
                onPressed: _building ? null : _preview,
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: TextButton(onPressed: () => context.go('/home'), child: const Text('Kembali ke Home')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final RoomMeta meta;
  final int score;
  final int max;
  final bool strongest;
  const _ScoreRow({required this.meta, required this.score, required this.max, required this.strongest});

  @override
  Widget build(BuildContext context) {
    final color = strongest
        ? AppColors.accent
        : meta.isBonus
            ? meta.accent
            : AppColors.success;
    return Row(
      children: [
        SizedBox(
          width: 118,
          child: Row(
            children: [
              Flexible(
                child: Text(meta.shortTitle, style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (meta.isBonus) ...[
                const SizedBox(width: 4),
                Text('BONUS', style: AppTypography.labelBadge.copyWith(fontSize: 9, color: meta.accent)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: ProgressRail(value: score / max, color: color, height: 6)),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text('$score', textAlign: TextAlign.right, style: AppTypography.numberSm.copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}
