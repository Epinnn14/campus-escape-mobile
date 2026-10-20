import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/player_record.dart';
import '../../data/models/room_meta.dart';

/// Ekspor data pemain untuk panel admin: CSV — bisa diunduh/dibagikan
/// sebagai file (share sheet) atau dilihat langsung di app (CsvViewScreen).
abstract class AdminExportService {
  static String _two(int n) => n.toString().padLeft(2, '0');
  static String _stamp(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}';

  static String _csvCell(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  /// Header kolom (urut sama dengan [rows]).
  static List<String> get header => [
        'no',
        'nama',
        'sekolah',
        'no_hp',
        'skor_total',
        'ruang_selesai',
        'ruang_total',
        'status',
        'mulai',
        'terakhir_main',
        for (final m in RoomCatalog.all) 'skor_${m.id.name}',
        'id',
      ];

  /// Baris data (string semua) — dipakai CSV dan tampilan tabel.
  static List<List<String>> rows(List<PlayerRecord> players) => [
        for (var i = 0; i < players.length; i++)
          [
            '${i + 1}',
            players[i].name,
            players[i].school,
            players[i].phone,
            '${players[i].totalScore}',
            '${players[i].roomsCompleted}',
            '${players[i].roomsTotal}',
            players[i].finished ? 'selesai' : 'berjalan',
            _stamp(players[i].startedAt),
            _stamp(players[i].lastPlayedAt),
            for (final m in RoomCatalog.all) '${players[i].roomScores[m.id.name] ?? 0}',
            players[i].sessionId,
          ],
      ];

  /// CSV lengkap (koma, baris baru \n, UTF-8).
  static String csv(List<PlayerRecord> players) {
    final lines = <String>[header.join(',')];
    for (final r in rows(players)) {
      lines.add(r.map(_csvCell).join(','));
    }
    return lines.join('\n');
  }

  /// Nama file aman: Campus_Escape_<label>_YYYYMMDD-HHMM.csv
  static String fileName(String label) {
    final now = DateTime.now();
    final safe = label.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
    return 'Campus_Escape_${safe}_${now.year}${_two(now.month)}${_two(now.day)}-${_two(now.hour)}${_two(now.minute)}.csv';
  }

  /// Tulis CSV ke file sementara lalu buka share sheet (simpan ke Files/Drive,
  /// kirim WhatsApp/email, dll). Mengembalikan path file-nya.
  static Future<String> downloadCsv(List<PlayerRecord> players, {required String label}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${fileName(label)}');
    // BOM supaya Excel langsung membaca UTF-8 (nama dengan aksen, dll).
    await file.writeAsString('﻿${csv(players)}', flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Data peserta Campus Escape ($label)',
        text: '${players.length} peserta · dibuat ${_stamp(DateTime.now())}',
      ),
    );
    return file.path;
  }
}
