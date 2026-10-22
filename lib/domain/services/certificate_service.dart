import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/socs_fact.dart' show BrandLogos;

/// Data yang dicetak di sertifikat.
class CertificateData {
  final String name;
  final String school;
  final String predicate;
  final int totalScore;
  final int roomsCompleted;
  final int roomsTotal;
  final String verificationCode;
  final DateTime date;

  /// Satu baris per ruangan; yang skornya > 0 dianggap sudah dijelajahi dan
  /// namanya dicetak sebagai "bidang yang dijelajahi".
  final List<({String room, int score, int stars})> rows;

  const CertificateData({
    required this.name,
    required this.school,
    required this.predicate,
    required this.totalScore,
    required this.roomsCompleted,
    required this.roomsTotal,
    required this.verificationCode,
    required this.date,
    required this.rows,
  });
}

/// Membuat sertifikat PDF (A4 landscape) sepenuhnya di perangkat.
///
/// Gaya sertifikat kursus online: kertas putih bersih dengan bingkai tipis,
/// logo BINUS besar di kiri atas, tanggal, nama peserta, judul program,
/// daftar bidang yang dijelajahi, dan pita (ribbon) di sisi kanan berisi
/// label predikat + stempel bulat School of Computer Science BINUS @Bekasi.
abstract class CertificateService {
  static const _paper = PdfColor.fromInt(0xFFFFFFFF);
  static const _ink = PdfColor.fromInt(0xFF1F2733);
  static const _muted = PdfColor.fromInt(0xFF6B7684);
  static const _frame = PdfColor.fromInt(0xFFC9D0DA);
  static const _frameSoft = PdfColor.fromInt(0xFFE6EAF0);
  static const _blue = PdfColor.fromInt(0xFF123C78);
  static const _blueSoft = PdfColor.fromInt(0xFFE8EEF8);
  static const _orange = PdfColor.fromInt(0xFFF58220);
  static const _ribbon = PdfColor.fromInt(0xFFD6DCE6);
  static const _ribbonDark = PdfColor.fromInt(0xFFB9C2D0);
  static const _gold = PdfColor.fromInt(0xFFF4C430);
  static const _pattern = PdfColor.fromInt(0xFFF3F5F9);

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static Future<Uint8List> build(CertificateData d) async {
    final doc = pw.Document(
      title: 'Sertifikat Campus Escape',
      author: 'Campus Escape - SoCS BINUS @Bekasi',
    );
    final bold = pw.Font.helveticaBold();
    final regular = pw.Font.helvetica();
    final binusLogo = await _tryLoad(BrandLogos.binus);

    final dateText = '${d.date.day} ${_months[d.date.month - 1]} ${d.date.year}';
    final explored = [for (final r in d.rows) if (r.score > 0) r.room];

    const pageW = 841.89, pageH = 595.28;
    const ribbonW = 200.0, ribbonRight = 70.0;
    const ribbonLeft = pageW - ribbonRight - ribbonW;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => pw.Stack(
          children: [
            pw.Positioned.fill(child: pw.Container(color: _paper)),
            // Pola halus + bingkai
            pw.Positioned.fill(
              child: pw.CustomPaint(painter: (canvas, size) => _paintFrame(canvas, size)),
            ),

            // ---- Pita di kanan ----
            pw.Positioned(
              left: ribbonLeft,
              top: 0,
              child: pw.SizedBox(
                width: ribbonW,
                height: 400,
                child: pw.CustomPaint(painter: (canvas, size) => _paintRibbon(canvas, size)),
              ),
            ),
            pw.Positioned(
              left: ribbonLeft,
              top: 46,
              child: pw.SizedBox(
                width: ribbonW,
                child: pw.Column(
                  children: [
                    pw.Text('CAMPUS ESCAPE', style: pw.TextStyle(font: bold, fontSize: 11, color: _ink, letterSpacing: 3)),
                    pw.SizedBox(height: 3),
                    pw.Text('CERTIFICATE', style: pw.TextStyle(font: bold, fontSize: 11, color: _ink, letterSpacing: 3)),
                    pw.SizedBox(height: 18),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                      color: _gold,
                      child: pw.Text(
                        d.predicate.toUpperCase(),
                        style: pw.TextStyle(font: bold, fontSize: 8, color: _ink, letterSpacing: 1.5),
                      ),
                    ),
                    pw.SizedBox(height: 26),
                    _seal(binusLogo, bold, regular),
                  ],
                ),
              ),
            ),

            // ---- Isi kiri ----
            pw.Positioned(
              left: 64,
              top: 48,
              child: pw.SizedBox(
                width: ribbonLeft - 64 - 36,
                height: pageH - 48 - 60,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (binusLogo != null)
                      pw.Container(height: 92, child: pw.Image(binusLogo, fit: pw.BoxFit.contain, alignment: pw.Alignment.centerLeft))
                    else
                      pw.Text('BINUS UNIVERSITY', style: pw.TextStyle(font: bold, fontSize: 30, color: _blue, letterSpacing: 2)),
                    pw.SizedBox(height: 6),
                    pw.Text('School of Computer Science  |  BINUS @Bekasi',
                        style: pw.TextStyle(font: regular, fontSize: 9.5, color: _muted, letterSpacing: 0.5)),
                    pw.SizedBox(height: 34),

                    pw.Text(dateText, style: pw.TextStyle(font: regular, fontSize: 10, color: _muted, letterSpacing: 1)),
                    pw.SizedBox(height: 10),
                    pw.Text(d.name, style: pw.TextStyle(font: regular, fontSize: 30, color: _ink)),
                    if (d.school.isNotEmpty)
                      pw.Text(d.school, style: pw.TextStyle(font: regular, fontSize: 11, color: _muted)),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'telah berhasil menyelesaikan ${d.roomsCompleted} dari ${d.roomsTotal} ruangan dengan predikat ${d.predicate}',
                      style: pw.TextStyle(font: regular, fontSize: 10.5, color: _ink),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Text('Campus Escape: Junior IT Explorer', style: pw.TextStyle(font: bold, fontSize: 17, color: _ink)),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'program edukasi escape room untuk mengenal dunia Computer Science & Software Engineering, '
                      'diselenggarakan oleh School of Computer Science BINUS University @Bekasi.',
                      style: pw.TextStyle(font: regular, fontSize: 9.5, color: _muted, lineSpacing: 2),
                    ),
                    pw.SizedBox(height: 16),

                    // Bidang yang dijelajahi
                    pw.Text('BIDANG YANG DIJELAJAHI', style: pw.TextStyle(font: bold, fontSize: 7.5, color: _muted, letterSpacing: 1.5)),
                    pw.SizedBox(height: 6),
                    pw.Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        for (final name in explored)
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: pw.BoxDecoration(
                              color: _blueSoft,
                              borderRadius: pw.BorderRadius.circular(99),
                              border: pw.Border.all(color: _blueSoft),
                            ),
                            child: pw.Text(name, style: pw.TextStyle(font: bold, fontSize: 8, color: _blue)),
                          ),
                        if (explored.isEmpty)
                          pw.Text('-', style: pw.TextStyle(font: regular, fontSize: 9, color: _muted)),
                      ],
                    ),

                    pw.Spacer(),

                    // Penerbit (pengganti tanda tangan) + skor
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(width: 190, height: 1, color: _frame),
                            pw.SizedBox(height: 5),
                            pw.Text('School of Computer Science', style: pw.TextStyle(font: bold, fontSize: 9, color: _ink)),
                            pw.Text('BINUS University @Bekasi', style: pw.TextStyle(font: regular, fontSize: 8.5, color: _muted)),
                          ],
                        ),
                        pw.SizedBox(width: 30),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('SKOR', style: pw.TextStyle(font: bold, fontSize: 7, color: _muted, letterSpacing: 1.5)),
                            pw.Text('${d.totalScore} XP', style: pw.TextStyle(font: bold, fontSize: 14, color: _orange)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ---- Verifikasi (kanan bawah) ----
            pw.Positioned(
              right: 64,
              bottom: 52,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('ID verifikasi:', style: pw.TextStyle(font: regular, fontSize: 8, color: _muted)),
                  pw.Text(d.verificationCode, style: pw.TextStyle(font: bold, fontSize: 10, color: _blue, letterSpacing: 1)),
                  pw.SizedBox(height: 2),
                  pw.Text('Dibuat otomatis oleh aplikasi Campus Escape. Tunjukkan ID ini',
                      style: pw.TextStyle(font: regular, fontSize: 6.5, color: _muted)),
                  pw.Text('di meja registrasi SoCS BINUS @Bekasi untuk verifikasi.',
                      style: pw.TextStyle(font: regular, fontSize: 6.5, color: _muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }

  static Future<pw.MemoryImage?> _tryLoad(String asset) async {
    try {
      final data = await rootBundle.load(asset);
      return pw.MemoryImage(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    } catch (_) {
      return null;
    }
  }

  /// Stempel bulat: cincin ganda + teks melingkar + logo BINUS di tengah.
  static pw.Widget _seal(pw.MemoryImage? logo, pw.Font bold, pw.Font regular) {
    const size = 128.0;
    const r = size / 2;
    const textR = r - 13.0;
    const ringText = 'SCHOOL OF COMPUTER SCIENCE  *  BINUS @BEKASI  *  ';
    final chars = ringText.split('');
    final step = 2 * math.pi / chars.length;

    return pw.SizedBox(
      width: size,
      height: size,
      child: pw.Stack(
        children: [
          pw.Positioned.fill(
            child: pw.CustomPaint(
              painter: (canvas, s) {
                canvas
                  ..setFillColor(_paper)
                  ..drawEllipse(r, r, r, r)
                  ..fillPath()
                  ..setStrokeColor(_ink)
                  ..setLineWidth(1.6)
                  ..drawEllipse(r, r, r - 1, r - 1)
                  ..strokePath()
                  ..setLineWidth(0.8)
                  ..drawEllipse(r, r, r - 5, r - 5)
                  ..strokePath()
                  ..drawEllipse(r, r, r - 22, r - 22)
                  ..strokePath();
                // titik-titik kecil di antara dua cincin dalam
                canvas.setFillColor(_ink);
                for (var i = 0; i < 48; i++) {
                  final a = i * 2 * math.pi / 48;
                  canvas.drawEllipse(r + math.cos(a) * (r - 7.5), r + math.sin(a) * (r - 7.5), 0.6, 0.6);
                  canvas.fillPath();
                }
              },
            ),
          ),
          // Teks melingkar: satu huruf per posisi, diputar mengikuti lingkaran.
          for (var i = 0; i < chars.length; i++)
            pw.Positioned(
              left: r + textR * math.cos(-math.pi / 2 + i * step) - 4,
              top: r + textR * math.sin(-math.pi / 2 + i * step) - 4,
              child: pw.SizedBox(
                width: 8,
                height: 8,
                child: pw.Transform.rotate(
                  angle: -(i * step),
                  child: pw.Center(
                    child: pw.Text(chars[i], style: pw.TextStyle(font: bold, fontSize: 6.2, color: _ink)),
                  ),
                ),
              ),
            ),
          // Logo di tengah
          pw.Positioned(
            left: 26,
            top: 26,
            child: pw.SizedBox(
              width: size - 52,
              height: size - 52,
              child: logo != null
                  ? pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Image(logo, fit: pw.BoxFit.contain))
                  : pw.Center(child: pw.Text('BINUS', style: pw.TextStyle(font: bold, fontSize: 14, color: _blue))),
            ),
          ),
        ],
      ),
    );
  }

  /// Pita: persegi panjang dari tepi atas dengan ujung lancip (takik) di
  /// bawah, plus bayangan tipis di kiri supaya terasa "menempel" di kertas.
  static void _paintRibbon(PdfGraphics canvas, PdfPoint size) {
    final w = size.x, h = size.y;
    // Koordinat PDF: y=0 di bawah. Pita menempel ke tepi atas (y = h).
    canvas.setFillColor(_ribbonDark);
    canvas
      ..moveTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w, 70)
      ..lineTo(w / 2, 22)
      ..lineTo(0, 70)
      ..closePath()
      ..fillPath();
    canvas.setFillColor(_ribbon);
    canvas
      ..moveTo(6, h)
      ..lineTo(w, h)
      ..lineTo(w, 72)
      ..lineTo(w / 2, 28)
      ..lineTo(6, 72)
      ..closePath()
      ..fillPath();
  }

  /// Bingkai ganda tipis + ornamen sudut + pola guilloche ringan.
  static void _paintFrame(PdfGraphics canvas, PdfPoint size) {
    final w = size.x, h = size.y;

    // Pola latar: lengkung-lengkung besar sangat tipis di kanan bawah & kiri atas.
    canvas
      ..setStrokeColor(_pattern)
      ..setLineWidth(1.0);
    for (var i = 0; i < 14; i++) {
      final rr = 90.0 + i * 26;
      canvas.drawEllipse(w - 120, 40, rr, rr * 0.72);
      canvas.strokePath();
      canvas.drawEllipse(60, h - 30, rr * 0.9, rr * 0.62);
      canvas.strokePath();
    }

    // Bingkai luar & dalam
    canvas
      ..setStrokeColor(_frame)
      ..setLineWidth(1.4)
      ..drawRect(18, 18, w - 36, h - 36)
      ..strokePath()
      ..setStrokeColor(_frameSoft)
      ..setLineWidth(0.8)
      ..drawRect(25, 25, w - 50, h - 50)
      ..strokePath();

    // Ornamen sudut: siku kecil di empat sudut
    canvas
      ..setStrokeColor(_frame)
      ..setLineWidth(1.4);
    const len = 26.0, off = 32.0;
    final corners = [
      [off, h - off, 1.0, -1.0],
      [w - off, h - off, -1.0, -1.0],
      [off, off, 1.0, 1.0],
      [w - off, off, -1.0, 1.0],
    ];
    for (final c in corners) {
      final x = c[0], y = c[1], sx = c[2], sy = c[3];
      canvas
        ..moveTo(x, y)
        ..lineTo(x + sx * len, y)
        ..strokePath()
        ..moveTo(x, y)
        ..lineTo(x, y + sy * len)
        ..strokePath();
      canvas.setFillColor(_orange);
      canvas.drawEllipse(x, y, 2.2, 2.2);
      canvas.fillPath();
    }

    // Garis aksen biru-oranye tipis di tepi bawah bingkai
    canvas.setFillColor(_blue);
    canvas.drawRect(25, 25, (w - 50) * 0.7, 2.2);
    canvas.fillPath();
    canvas.setFillColor(_orange);
    canvas.drawRect(25 + (w - 50) * 0.7, 25, (w - 50) * 0.3, 2.2);
    canvas.fillPath();
  }
}
