import 'package:flutter/material.dart';

/// Kategori kartu info di Galeri.
enum FactCategory { kampus, program, komunitas, kompetisi }

extension FactCategoryLabel on FactCategory {
  String get label => switch (this) {
        FactCategory.kampus => 'Kampus',
        FactCategory.program => 'Program',
        FactCategory.komunitas => 'Komunitas',
        FactCategory.kompetisi => 'Prestasi',
      };
}

/// Foto fasilitas kampus BINUS @Bekasi untuk Galeri, carousel Home, dan
/// dekorasi peta. File di assets/images/gallery/ (foto asli dari tim SoCS).
class CampusPhoto {
  final String asset;
  final String title;
  final String caption;
  const CampusPhoto({required this.asset, required this.title, required this.caption});
}

abstract class CampusPhotos {
  /// Foto untuk hero Landing (bagian atas, memudar ke warna latar).
  static const String heroAsset = 'assets/images/gallery/campus_hero_wide.jpg';

  static const List<CampusPhoto> all = [
    CampusPhoto(
      asset: 'assets/images/gallery/campus_hero.jpg',
      title: 'Gedung BINUS @Bekasi',
      caption: 'Kampus BINUS di kawasan Summarecon Bekasi — rumah bagi program '
          'Computer Science – Software Engineering dan School of Computer Science.',
    ),
    CampusPhoto(
      asset: 'assets/images/gallery/campus_01.jpg',
      title: 'Library',
      caption: 'Ruang baca modern dua lantai yang luas dan terang dengan dinding kaca. '
          'Ribuan buku dan referensi, area diskusi kasual, plus discussion room '
          'untuk belajar yang lebih privat.',
    ),
    CampusPhoto(
      asset: 'assets/images/gallery/campus_02.jpg',
      title: 'Classroom',
      caption: 'Kelas luas dengan meja panjang, kursi ergonomis warna-warni, dan papan '
          'tulis ganda berukuran besar — dibuat untuk pembelajaran yang interaktif '
          'dan dinamis, bukan ceramah satu arah.',
    ),
    CampusPhoto(
      asset: 'assets/images/gallery/campus_03.jpg',
      title: 'Computer Lab',
      caption: 'Laboratorium komputer dengan meja melingkar dan loker penyimpanan '
          'pribadi, rumah untuk praktikum, pemrograman, dan riset berbasis digital.',
    ),
    CampusPhoto(
      asset: 'assets/images/gallery/campus_04.jpg',
      title: 'Conference Room',
      caption: 'Tribun berundak kayu yang megah, lengkap dengan proyektor dan podium. '
          'Tempat seminar, presentasi besar, dan forum diskusi dengan suasana '
          'semi-formal.',
    ),
    CampusPhoto(
      asset: 'assets/images/gallery/campus_05.jpg',
      title: 'Creative Class',
      caption: 'Ruang kelas non-formal penuh warna: sofa santai, meja modular, dan layar '
          'besar di dinding. Dirancang untuk memicu kreativitas, kerja kelompok, '
          'dan brainstorming ide baru.',
    ),
  ];
}

/// Logo resmi untuk peta & sertifikat (assets/images/logos/).
abstract class BrandLogos {
  static const String binus = 'assets/images/logos/binus.png';
  static const String himti = 'assets/images/logos/himti.png';
}

/// Info tentang SoCS / Software Engineering BINUS @Bekasi.
///
/// Sumber: halaman resmi binus.ac.id/bekasi/csse, binus.ac.id/bekasi, dan
/// socs.binus.ac.id (diakses 14 Oktober 2026). Kalau ada info yang berubah, cukup edit di sini.
class SocsFact {
  final int order;
  final String title;
  final String body;
  final FactCategory category;
  final IconData icon;
  final String sourceUrl;

  const SocsFact({
    required this.order,
    required this.title,
    required this.body,
    required this.category,
    required this.icon,
    required this.sourceUrl,
  });
}

abstract class SocsFactCatalog {
  static const String _csse = 'https://binus.ac.id/bekasi/csse/';
  static const String _bekasi = 'https://binus.ac.id/bekasi/';
  static const String _socs = 'https://socs.binus.ac.id/';

  static const List<SocsFact> all = [
    SocsFact(
      order: 1,
      title: 'Apa itu Computer Science – Software Engineering (CSSE)?',
      body:
          'Program S1 (gelar Sarjana Komputer, 4 tahun) di BINUS @Bekasi yang '
          'membekali mahasiswa dengan kompetensi rekayasa perangkat lunak dari '
          'desain, pengembangan, pengujian, sampai deployment dan maintenance — '
          'persis alur yang kamu mainkan di 10 ruangan Campus Escape.',
      category: FactCategory.program,
      icon: Icons.code_rounded,
      sourceUrl: _csse,
    ),
    SocsFact(
      order: 2,
      title: 'Belajar cara kerja tim software sungguhan',
      body:
          'Mahasiswa CSSE mempelajari metodologi Waterfall, Agile, Scrum, dan '
          'DevOps, serta pengembangan aplikasi lintas platform dengan fokus pada '
          'kinerja, keamanan, skalabilitas, dan user experience.',
      category: FactCategory.program,
      icon: Icons.account_tree_outlined,
      sourceUrl: _csse,
    ),
    SocsFact(
      order: 3,
      title: 'Case-Based Learning: belajar dari kasus nyata industri',
      body:
          'CSSE memakai studi kasus nyata dari industri untuk merancang solusi '
          'perangkat lunak. Pendekatan ini mengasah berpikir kritis, problem '
          'solving, dan pengambilan keputusan — bukan cuma hafalan.',
      category: FactCategory.program,
      icon: Icons.lightbulb_outline_rounded,
      sourceUrl: _csse,
    ),
    SocsFact(
      order: 4,
      title: 'Perjalanan 4 tahun: dari fondasi sampai siap industri',
      body:
          'Tahun 1 Foundation Path (pemrograman dasar, algoritma, logika, basis '
          'data). Tahun 2 Development Path (pengembangan aplikasi). Tahun 3 '
          'Professional Path (quality assurance, keamanan, Agile/Scrum/DevOps). '
          'Tahun 4 Industry & Final Path (internship dan Tugas Akhir).',
      category: FactCategory.program,
      icon: Icons.timeline_rounded,
      sourceUrl: _csse,
    ),
    SocsFact(
      order: 5,
      title: 'Karier setelah lulus',
      body:
          'Lulusan CSSE bisa menjadi Software Engineer, Software Developer, '
          'Full-Stack Developer, DevOps Engineer, sampai IT Project Manager — '
          'dari membangun produk hingga memimpin tim.',
      category: FactCategory.program,
      icon: Icons.work_outline_rounded,
      sourceUrl: _csse,
    ),
    SocsFact(
      order: 6,
      title: 'Kampus BINUS @Bekasi',
      body:
          'Berlokasi di Jalan Lingkar Boulevar Blok WA No.1, Summarecon Bekasi, '
          'Bekasi Utara. Fasilitasnya: Library dua lantai, Computer Lab, Creative '
          'Class, Conference Room bertribun, dan Classroom interaktif — lihat '
          'fotonya di bagian atas Galeri.',
      category: FactCategory.kampus,
      icon: Icons.location_city_outlined,
      sourceUrl: _csse,
    ),
    SocsFact(
      order: 7,
      title: 'Juara 3 Garuda Hacks 6.0',
      body:
          'Mahasiswa CSSE BINUS @Bekasi meraih Juara 3 Track Sustainability di '
          'Garuda Hacks 6.0 (diumumkan Februari 2026) — hackathon membuat '
          'aplikasi dalam waktu singkat, seperti versi besar dari Campus Escape.',
      category: FactCategory.kompetisi,
      icon: Icons.emoji_events_outlined,
      sourceUrl: _csse,
    ),
    SocsFact(
      order: 8,
      title: '"Pecah telur" di DINACOM',
      body:
          'Prestasi pertama CSSE BINUS @Bekasi di Dinus Application Competition '
          '(DINACOM), kompetisi pembuatan aplikasi antar mahasiswa (Februari 2026).',
      category: FactCategory.kompetisi,
      icon: Icons.military_tech_outlined,
      sourceUrl: _csse,
    ),
    SocsFact(
      order: 9,
      title: 'Kunjungan industri ke pusat distribusi nasional',
      body:
          'Mahasiswa CSSE mengunjungi PT Anugerah Pharmindo Lestari – National '
          'Distribution Center di Cikarang untuk melihat langsung bagaimana '
          'software dipakai di operasional perusahaan.',
      category: FactCategory.komunitas,
      icon: Icons.factory_outlined,
      sourceUrl: _csse,
    ),
    SocsFact(
      order: 10,
      title: 'Riset dosen & mahasiswa: AI, deep learning, pariwisata',
      body:
          'Contoh riset CSSE BINUS @Bekasi: perbandingan YOLOv8/v5/v11 untuk '
          'segmentasi citra alam, chatbot di layanan kesehatan, AI untuk '
          'ekowisata di Kabupaten Bekasi, dan deteksi sleep apnea dari sinyal EKG.',
      category: FactCategory.komunitas,
      icon: Icons.science_outlined,
      sourceUrl: _csse,
    ),
    SocsFact(
      order: 11,
      title: 'Cerita mahasiswa: dari lab assistant sampai juara',
      body:
          'Kerry Fendy (mahasiswa CSSE) menjadi Junior Lab Assistant di Software '
          'Lab Center, staf E-Sport Burn Cup 2023, Juara 1 Jeromepiade BINUS, dan '
          'Best Tutor 2024/2025 — teori langsung dipraktikkan.',
      category: FactCategory.komunitas,
      icon: Icons.person_outline_rounded,
      sourceUrl: _csse,
    ),
    SocsFact(
      order: 12,
      title: 'Satu tahun Enrichment: magang atau kuliah di luar negeri',
      body:
          'Skema (2+1)+1 BINUS memberi mahasiswa satu tahun Enrichment, misalnya '
          'Internship di industri atau Study Abroad. Aplikasi Campus Escape ini '
          'dibuat mahasiswa Software Engineering sebagai proyek Internship Enrichment.',
      category: FactCategory.program,
      icon: Icons.flight_takeoff_rounded,
      sourceUrl: _bekasi,
    ),
    SocsFact(
      order: 13,
      title: 'HIMTI dan komunitas mahasiswa SoCS',
      body:
          'Mahasiswa SoCS bernaung di HIMTI (Himpunan Mahasiswa Teknik Informatika). '
          'Ada juga JollyBee (competitive programming), PETIR (cyber security), '
          'dan Ureeka (tim pembuat produk digital).',
      category: FactCategory.komunitas,
      icon: Icons.groups_outlined,
      sourceUrl: _socs,
    ),
    SocsFact(
      order: 14,
      title: 'Banyak peminatan di School of Computer Science',
      body:
          'SoCS BINUS menaungi Computer Science, Mobile Application and Technology, '
          'Game Application and Technology, Cyber Security, Data Science, dan '
          'Artificial Intelligence. Setiap ruangan di game ini mewakili salah satunya.',
      category: FactCategory.program,
      icon: Icons.school_outlined,
      sourceUrl: _socs,
    ),
    SocsFact(
      order: 15,
      title: 'Shuttle bus gratis antar kampus',
      body:
          'Ada shuttle bus gratis antara BINUS Kemanggisan dan BINUS @Bekasi '
          'dengan keberangkatan pagi dan sore.',
      category: FactCategory.kampus,
      icon: Icons.directions_bus_outlined,
      sourceUrl: _bekasi,
    ),
  ];
}
