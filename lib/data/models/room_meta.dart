import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 8 core room + 2 bonus room. Urutan enum = urutan level di peta.
enum RoomId {
  algorithm,
  uiUx,
  dataScience,
  gameDev,
  mobileDev,
  networking,
  softwareEngineering,
  database,
  bonusAi,
  bonusCyber,
}

/// Data statis per ruangan (ROOM_META di ERD) — bukan per user.
/// Accent dipakai HANYA untuk ikon + stripe di card (DESIGN.md).
class RoomMeta {
  final RoomId id;
  final int order;
  final String title;
  final String shortTitle;
  final String discipline;
  final Color accent;
  final IconData icon;
  final bool isBonus;
  final int xpReward;

  /// Nama mini-game khas ruangan (ditampilkan di peta & master sheet).
  final String mechanic;
  final String insightTitle;
  final String insightBody;

  const RoomMeta({
    required this.id,
    required this.order,
    required this.title,
    required this.shortTitle,
    required this.discipline,
    required this.accent,
    required this.icon,
    required this.isBonus,
    required this.xpReward,
    required this.mechanic,
    required this.insightTitle,
    required this.insightBody,
  });

  String get route => '/room/${id.name}';
  String get levelLabel => isBonus ? 'Bonus Room $order' : 'Ruang $order';
}

abstract class RoomCatalog {
  static const List<RoomMeta> all = [
    RoomMeta(
      id: RoomId.algorithm,
      order: 1,
      title: 'Algoritma & Logika',
      shortTitle: 'Algoritma',
      discipline: 'Core CS',
      accent: Color(0xFF60A5FA),
      icon: Icons.smart_toy_outlined,
      isBonus: false,
      xpReward: 200,
      mechanic: 'Robot Pengantar',
      insightTitle: 'Apa itu algoritma?',
      insightBody:
          'Algoritma adalah urutan langkah yang jelas untuk menyelesaikan sesuatu, '
          'seperti resep masakan. Komputer tidak bisa menebak; ia hanya mengikuti '
          'langkah persis seperti yang ditulis. Barusan kamu menulis algoritma untuk robot.',
    ),
    RoomMeta(
      id: RoomId.uiUx,
      order: 2,
      title: 'UI/UX Design',
      shortTitle: 'UI/UX',
      discipline: 'Core CS',
      accent: Color(0xFFF472B6),
      icon: Icons.dashboard_customize_outlined,
      isBonus: false,
      xpReward: 200,
      mechanic: 'Mana yang lebih enak dipakai?',
      insightTitle: 'Desain itu soal rasa "gampang"',
      insightBody:
          'UI/UX Designer memastikan aplikasi mudah dipakai siapa saja: tombol gampang '
          'ditekan, tulisan gampang dibaca, menu gampang dimengerti. Mereka riset ke '
          'pengguna, membuat contoh tampilan, lalu mengujinya lagi.',
    ),
    RoomMeta(
      id: RoomId.dataScience,
      order: 3,
      title: 'Data Science',
      shortTitle: 'Data Science',
      discipline: 'Core CS',
      accent: Color(0xFF38BDF8),
      icon: Icons.bar_chart_rounded,
      isBonus: false,
      xpReward: 200,
      mechanic: 'Sortir Data',
      insightTitle: 'Data kotor, keputusan keliru',
      insightBody:
          'Sebelum membuat grafik atau kesimpulan, Data Scientist membersihkan data '
          'dulu: membuang yang salah, melengkapi yang kosong. Barulah angka-angkanya '
          'bisa dipercaya untuk mengambil keputusan.',
    ),
    RoomMeta(
      id: RoomId.gameDev,
      order: 4,
      title: 'Game Development',
      shortTitle: 'Game Dev',
      discipline: 'Core CS',
      accent: Color(0xFFE879F9),
      icon: Icons.sports_esports_outlined,
      isBonus: false,
      xpReward: 200,
      mechanic: 'Lompat Tepat Waktu',
      insightTitle: 'Semua game punya satu loop',
      insightBody:
          'Di balik layar, game mengulang tiga hal puluhan kali per detik: baca input '
          'pemain, update posisi, gambar ulang. Game Developer mengatur ritme ini '
          'supaya game terasa responsif dan seru.',
    ),
    RoomMeta(
      id: RoomId.mobileDev,
      order: 5,
      title: 'Mobile App Development',
      shortTitle: 'Mobile App',
      discipline: 'Core CS',
      accent: Color(0xFFA3E635),
      icon: Icons.smartphone_outlined,
      isBonus: false,
      xpReward: 200,
      mechanic: 'Rakit Layar Aplikasi',
      insightTitle: 'Aplikasi disusun dari komponen',
      insightBody:
          'Layar aplikasi dibangun dari komponen kecil: judul, gambar, teks, tombol. '
          'Mobile Developer menyusunnya rapi dan memastikan tetap enak dipakai di '
          'berbagai ukuran HP. Campus Escape ini pun dibuat begitu, dengan Flutter.',
    ),
    RoomMeta(
      id: RoomId.networking,
      order: 6,
      title: 'Jaringan Komputer',
      shortTitle: 'Jaringan',
      discipline: 'Core CS',
      accent: Color(0xFFFB7185),
      icon: Icons.hub_outlined,
      isBonus: false,
      xpReward: 200,
      mechanic: 'Antar Paket',
      insightTitle: 'Internet itu paket yang dioper',
      insightBody:
          'Setiap pesan atau foto dipecah jadi paket kecil, lalu dioper dari router '
          'ke router sampai tujuan. Network Engineer merancang jalur ini supaya cepat, '
          'aman, dan tidak nyasar.',
    ),
    RoomMeta(
      id: RoomId.softwareEngineering,
      order: 7,
      title: 'Software Engineering',
      shortTitle: 'Software Eng.',
      discipline: 'Core CS',
      accent: Color(0xFF818CF8),
      icon: Icons.code_rounded,
      isBonus: false,
      xpReward: 200,
      mechanic: 'Cari Bug',
      insightTitle: 'Mencari dan memperbaiki bug',
      insightBody:
          'Software Engineer membangun aplikasi dan menjaganya tetap benar: menulis '
          'kode, mengujinya, lalu memperbaiki kesalahan (bug) bersama tim. Satu tanda '
          '"<" yang salah saja bisa bikin program keliru, makanya ketelitian penting.',
    ),
    RoomMeta(
      id: RoomId.database,
      order: 8,
      title: 'Database Systems',
      shortTitle: 'Database',
      discipline: 'Core CS',
      accent: Color(0xFFFACC15),
      icon: Icons.storage_rounded,
      isBonus: false,
      xpReward: 200,
      mechanic: 'Cocokkan Data',
      insightTitle: 'Tabel terpisah, dihubungkan kunci',
      insightBody:
          'Database menyimpan data dalam tabel-tabel terpisah supaya rapi, lalu '
          'menghubungkannya lewat nomor kunci. Database Engineer menjaga data ini '
          'tetap benar, aman, dan cepat diakses jutaan kali sehari.',
    ),
    RoomMeta(
      id: RoomId.bonusAi,
      order: 9,
      title: 'AI & Machine Learning',
      shortTitle: 'AI & ML',
      discipline: 'Bonus Specialization',
      accent: AppColors.bonusAI,
      icon: Icons.auto_awesome_outlined,
      isBonus: true,
      xpReward: 150,
      mechanic: 'Latih AI-mu',
      insightTitle: 'AI belajar dari contoh',
      insightBody:
          'AI tidak diprogram aturan satu per satu. Ia dilatih dengan ribuan contoh '
          'berlabel, lalu diuji akurasinya. Kalau contohnya salah atau berat sebelah, '
          'hasilnya ikut salah, makanya data latih harus baik.',
    ),
    RoomMeta(
      id: RoomId.bonusCyber,
      order: 10,
      title: 'Cyber Security',
      shortTitle: 'Cyber Security',
      discipline: 'Bonus Specialization',
      accent: AppColors.bonusCyber,
      icon: Icons.shield_outlined,
      isBonus: true,
      xpReward: 200,
      mechanic: 'Pecahkan Sandi',
      insightTitle: 'Keamanan itu kebiasaan',
      insightBody:
          'Enkripsi (menyandikan pesan) dan password kuat adalah lapis pertahanan '
          'paling dasar. Cyber Security Engineer berpikir seperti penyerang untuk '
          'menutup celah lebih dulu, dan mengingatkan kita untuk tidak memakai "password123".',
    ),
  ];

  static RoomMeta byId(RoomId id) => all.firstWhere((r) => r.id == id);
  static List<RoomMeta> get core => all.where((r) => !r.isBonus).toList();
  static List<RoomMeta> get bonus => all.where((r) => r.isBonus).toList();
  static int get coreCount => core.length;
}
