import 'package:campus_escape/data/models/player_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneFormat', () {
    test('menerima format 08 dan +62', () {
      expect(PhoneFormat.isValid('081234567890'), isTrue);
      expect(PhoneFormat.isValid('+62 812-3456-7890'), isTrue);
      expect(PhoneFormat.isValid('6281234567890'), isTrue);
      expect(PhoneFormat.isValid('0812345678'), isTrue); // 10 digit
    });

    test('menolak format salah', () {
      expect(PhoneFormat.isValid(''), isFalse);
      expect(PhoneFormat.isValid('12345'), isFalse);
      expect(PhoneFormat.isValid('021123456'), isFalse); // telepon rumah
      expect(PhoneFormat.isValid('08123'), isFalse); // terlalu pendek
      expect(PhoneFormat.isValid('08123456789012345'), isFalse); // terlalu panjang
      expect(PhoneFormat.isValid('abcdefghijk'), isFalse);
    });

    test('normalisasi dan tampilan', () {
      expect(PhoneFormat.normalize('+62 812-3456-7890'), '081234567890');
      expect(PhoneFormat.pretty('081234567890'), '0812-3456-7890');
    });
  });

  group('NameFormat', () {
    test('nama valid', () {
      expect(NameFormat.validateFullName('Kevin Aprilio'), isNull);
      expect(NameFormat.validateFullName('Kevin'), isNull);
      expect(NameFormat.validateFullName("Siti Nur'aini"), isNull);
      expect(NameFormat.validateFullName('  Budi   Santoso '), isNull);
    });

    test('nama kosong atau tidak valid', () {
      expect(NameFormat.validateFullName(''), isNotNull);
      expect(NameFormat.validateFullName('  '), isNotNull);
      expect(NameFormat.validateFullName('Ka'), isNotNull);
      expect(NameFormat.validateFullName('Kevin 123'), isNotNull);
    });

    test('asal sekolah wajib diawali SMA/SMK + nama', () {
      expect(NameFormat.validateSchool('SMAN 1 Bekasi'), isNull);
      expect(NameFormat.validateSchool('smk negeri 2 bekasi'), isNull);
      expect(NameFormat.validateSchool('SMA Islam Al-Azhar'), isNull);
      expect(NameFormat.validateSchool(''), isNotNull);
      expect(NameFormat.validateSchool('SMA'), isNotNull);
      expect(NameFormat.validateSchool('SMK  '), isNotNull);
      expect(NameFormat.validateSchool('Bekasi 1'), isNotNull);
    });
  });
}
