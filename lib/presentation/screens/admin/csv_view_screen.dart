import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/player_record.dart';
import '../../../domain/services/admin_export_service.dart';

/// Lihat data peserta sebagai tabel (isi CSV) langsung di app — bisa
/// digulir ke samping & bawah, plus tombol salin & unduh.
class CsvViewScreen extends StatefulWidget {
  final String title;
  final List<PlayerRecord> players;
  const CsvViewScreen({super.key, required this.title, required this.players});

  static Route<void> route({required String title, required List<PlayerRecord> players}) =>
      MaterialPageRoute(builder: (_) => CsvViewScreen(title: title, players: players));

  @override
  State<CsvViewScreen> createState() => _CsvViewScreenState();
}

class _CsvViewScreenState extends State<CsvViewScreen> {
  final _horizontal = ScrollController();
  bool _busy = false;

  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: AdminExportService.csv(widget.players)));
    _toast('CSV disalin ke clipboard.');
  }

  Future<void> _download() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await AdminExportService.downloadCsv(widget.players, label: widget.title);
    } catch (e) {
      _toast('Gagal mengunduh CSV: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final header = AdminExportService.header;
    final rows = AdminExportService.rows(widget.players);
    final cellStyle = AppTypography.bodySm.copyWith(fontFamily: 'monospace', fontSize: 12);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${widget.players.length} baris · ${header.length} kolom', style: AppTypography.captionXs),
          ],
        ),
        actions: [
          IconButton(tooltip: 'Salin CSV', icon: const Icon(Icons.copy_rounded), onPressed: _copy),
          IconButton(
            tooltip: 'Unduh CSV',
            icon: const Icon(Icons.download_rounded),
            onPressed: _busy ? null : _download,
          ),
        ],
      ),
      body: widget.players.isEmpty
          ? Center(child: Text('Belum ada data.', style: AppTypography.caption))
          : Scrollbar(
              controller: _horizontal,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontal,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.surfaceRaised),
                    dataRowMinHeight: 36,
                    dataRowMaxHeight: 44,
                    columnSpacing: 18,
                    horizontalMargin: 10,
                    border: TableBorder.all(color: AppColors.outlineSubtle, width: 0.5),
                    columns: [
                      for (final h in header)
                        DataColumn(label: Text(h, style: AppTypography.labelSection.copyWith(fontSize: 11))),
                    ],
                    rows: [
                      for (final r in rows) DataRow(cells: [for (final c in r) DataCell(Text(c, style: cellStyle))]),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
