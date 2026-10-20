import 'dart:math';

import 'package:campus_escape/data/models/event_info.dart';
import 'package:campus_escape/data/models/room_meta.dart';
import 'package:campus_escape/data/models/room_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventCodeFormat', () {
    test('generate: 3 huruf (tanpa I/O) + 3 angka', () {
      final rng = Random(42);
      for (var i = 0; i < 200; i++) {
        final code = EventCodeFormat.generate(rng);
        expect(code, matches(RegExp(r'^[A-Z]{3}[0-9]{3}$')), reason: code);
        expect(code.substring(0, 3).contains(RegExp('[IO]')), isFalse, reason: code);
        expect(EventCodeFormat.isValid(code), isTrue, reason: code);
      }
    });

    test('normalize: huruf kecil, spasi, dan salah ketik O/0 I/1 dibetulkan per posisi', () {
      expect(EventCodeFormat.normalize(' abc-3 21 '), 'ABC321');
      expect(EventCodeFormat.normalize('ab0 32o'), 'ABO320'); // 0 di depan → O, O di belakang → 0
      expect(EventCodeFormat.normalize('a1c I2l'), 'AIC121');
    });

    test('validate menolak kosong, panjang salah, dan urutan salah', () {
      expect(EventCodeFormat.validate(''), isNotNull);
      expect(EventCodeFormat.validate('ABC3'), isNotNull);
      expect(EventCodeFormat.validate('ABC321'), isNull);
      expect(EventCodeFormat.validate('abc321'), isNull);
      expect(EventCodeFormat.validate('123ABC'), isNotNull);
      expect(EventCodeFormat.validate('ABCDEF'), isNotNull);
    });
  });

  group('AdminUsername', () {
    test('valid: huruf kecil, angka, titik, garis bawah, 3–24 karakter', () {
      expect(AdminUsername.isValid('panitia'), isTrue);
      expect(AdminUsername.isValid('Panitia'), isTrue); // dinormalisasi
      expect(AdminUsername.isValid('socs.bekasi_1'), isTrue);
      expect(AdminUsername.isValid('ab'), isFalse);
      expect(AdminUsername.isValid('nama dengan spasi'), isFalse);
      expect(AdminUsername.isValid('a' * 25), isFalse);
    });

    test('toEmail/fromEmail saling berkebalikan', () {
      final email = AdminUsername.toEmail('Panitia');
      expect(email, 'panitia@admin.campusescape.app');
      expect(AdminUsername.fromEmail(email), 'panitia');
      expect(AdminUsername.fromEmail('orang@gmail.com'), isNull);
      expect(AdminUsername.fromEmail(null), isNull);
    });
  });

  group('EventInfo', () {
    test('toMap/fromMap round-trip termasuk roomSettings dan winner', () {
      final info = EventInfo(
        code: 'ABC321',
        name: 'Kunjungan SMAN 1',
        active: true,
        createdAt: DateTime(2026, 10, 12, 9),
        createdBy: 'panitia',
        roomSettings: const RoomSettings(disabled: {RoomId.gameDev}, xpOverride: {RoomId.algorithm: 200}),
        winner: EventWinner(uid: 'u1', name: 'Kevin', school: 'SMAN 1', score: 1200, setAt: DateTime(2026, 10, 12, 11)),
      );
      final back = EventInfo.fromMap(info.code, info.toMap());
      expect(back.name, info.name);
      expect(back.active, isTrue);
      expect(back.roomSettings.isEnabled(RoomId.gameDev), isFalse);
      expect(back.roomSettings.xpOverride[RoomId.algorithm], 200);
      expect(back.winner?.name, 'Kevin');
      expect(back.winner?.score, 1200);
    });

    test('winner null kalau map kosong', () {
      final back = EventInfo.fromMap('ABC321', {'name': 'X', 'active': false});
      expect(back.hasWinner, isFalse);
      expect(back.active, isFalse);
    });
  });
}
