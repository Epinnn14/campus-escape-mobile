// Membuat CONTOH sertifikat (PDF asli dari CertificateService, data contoh)
// untuk ditunjukkan ke supervisor / dokumentasi — bukan bagian dari app.
//
// Jalankan dari root project:
//
//   flutter test tool/contoh_sertifikat.dart
//
// Hasil: assets/contoh/sertifikat_contoh.pdf
// (folder itu tidak didaftarkan di pubspec.yaml, jadi tidak ikut ke dalam APK).
import 'dart:io';

import 'package:campus_escape/data/models/room_meta.dart';
import 'package:campus_escape/domain/services/certificate_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buat contoh sertifikat', () async {
    final rooms = RoomCatalog.all;
    final bytes = await CertificateService.build(
      CertificateData(
        name: 'Nadia Putri',
        school: 'SMAN 1 Bekasi',
        predicate: 'Distinction',
        totalScore: rooms.fold<int>(0, (sum, r) => sum + r.xpReward),
        roomsCompleted: rooms.length,
        roomsTotal: rooms.length,
        verificationCode: 'CE-2026-CONTOH',
        date: DateTime.now(),
        rows: [for (final r in rooms) (room: r.title, score: r.xpReward, stars: 3)],
      ),
    );

    final out = File('assets/contoh/sertifikat_contoh.pdf')..createSync(recursive: true);
    out.writeAsBytesSync(bytes);
    expect(out.lengthSync(), greaterThan(1000));
  });
}
