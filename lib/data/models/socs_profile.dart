import 'package:flutter/material.dart';

/// Profil SoCS / CSSE BINUS @Bekasi untuk halaman "Kenali BINUS @Bekasi".
///
/// Sumber: materi resmi SoCS BINUS (video profil + teks dari tim SoCS),
/// binus.ac.id/bekasi/csse, dan ofog.himtibinus.or.id (diakses 14 Okt 2026).
/// Kalimat promosi di sini ditulis ulang supaya enak dibaca siswa SMA dan
/// orang tua, tapi semua klaim angka/akreditasi mengikuti materi resmi.
abstract class SocsProfile {
  static const videoAsset = 'assets/video/socs_profile.mp4';
  static const videoPoster = 'assets/video/socs_profile_poster.jpg';
  static const videoTitle = 'School of Computer Science BINUS University';
  static const videoCaption =
      'Video profil resmi SoCS — dibuka oleh Dekan, Prof. Dr. Ir. Derwin Suhartono, S.Kom., MTI.';

  /// Paragraf di bawah video.
  static const List<String> about = [
    'School of Computer Science (SoCS) BINUS University adalah school berkelas '
        'dunia yang berkomitmen mencetak talenta teknologi yang adaptif, inovatif, '
        'dan terdepan di bidangnya. Di sinilah tempat belajar cara membuat '
        'teknologi, bukan cuma memakainya.',
    'SoCS mengantongi akreditasi nasional A dari BAN-PT, sertifikasi '
        'internasional AUN-QA, dan akreditasi internasional ASIIN. Pada '
        'pemeringkatan QS World University Rankings by Subject 2024, bidang '
        'Computer Science BINUS berada di peringkat 351–400 dunia — peringkat '
        'ke-2 di Indonesia.',
    'Program Computer Science – Software Engineering (CSSE) di BINUS @Bekasi '
        'membekali mahasiswa dengan kompetensi rekayasa perangkat lunak yang '
        'terstruktur dan selaras dengan kebutuhan industri: dari desain, '
        'pengembangan, pengujian, sampai deployment dan maintenance. Mahasiswa '
        'belajar metodologi Waterfall, Agile, Scrum, dan DevOps, serta membangun '
        'aplikasi lintas platform dengan fokus pada kinerja, keamanan, '
        'skalabilitas, dan user experience.',
    'Pembelajarannya berbasis proyek, jadi selain coding kamu juga terlatih '
        'problem solving, kolaborasi, komunikasi profesional, dan etika — bekal '
        'untuk berbagai peran software di industri. Sepuluh ruangan yang kamu '
        'mainkan di Campus Escape adalah cuplikan kecil dari apa yang dipelajari '
        'di sini.',
  ];

  static const List<HighlightItem> whyCsse = [
    HighlightItem(
      icon: Icons.cases_outlined,
      title: 'Case-Based Learning',
      body:
          'Belajar lewat studi kasus nyata dari industri, bukan sekadar teori di '
          'papan tulis. Setiap kasus melatih berpikir kritis, problem solving, '
          'dan keberanian mengambil keputusan — persis yang dicari perusahaan '
          'teknologi dari seorang engineer.',
    ),
    HighlightItem(
      icon: Icons.all_inclusive_rounded,
      title: 'End-to-End Software Development',
      body:
          'Kamu mengalami seluruh siklus pembuatan software: merancang, '
          'membangun, menguji, merilis, sampai merawatnya. Dengan metodologi '
          'modern dan praktik terbaik industri, terbentuk kompetensi teknis dan '
          'pola pikir sistematis yang tahan terhadap perubahan teknologi.',
    ),
    HighlightItem(
      icon: Icons.rocket_launch_outlined,
      title: 'Industry-Ready, Future-Driven Graduates',
      body:
          'Lulusan CSSE disiapkan untuk berdaya saing tinggi dan adaptif. Bukan '
          'hanya siap kerja di hari pertama, tapi juga siap berinovasi di '
          'berbagai sektor industri berbasis teknologi informasi — dari startup '
          'sampai perusahaan multinasional.',
    ),
  ];

  static const List<AcademicPath> journey = [
    AcademicPath(
      year: 1,
      title: 'Foundation Path',
      summary: 'Membangun fondasi: pemrograman dasar, algoritma, logika komputasi, '
          'serta pengenalan sistem dan basis data.',
      detail:
          'Tahun pertama adalah tahun "belajar berpikir seperti komputer". Kamu '
          'mulai dari nol: menulis program pertama, memahami algoritma (seperti '
          'Robot Pengantar di ruang 1), logika komputasi, dan cara data disimpan '
          'di basis data. Tidak perlu sudah jago coding dari SMA — fondasinya '
          'dibangun di sini.',
    ),
    AcademicPath(
      year: 2,
      title: 'Development Path',
      summary: 'Menguatkan kemampuan teknis dan pengembangan aplikasi dengan '
          'Case-Based Learning.',
      detail:
          'Di tahun kedua kamu mulai membangun aplikasi sungguhan: web, mobile, '
          'dan sistem yang terhubung ke database. Kasus-kasus dari industri '
          'dipakai sebagai bahan latihan, jadi yang kamu buat bukan tugas '
          'mainan, melainkan solusi untuk masalah nyata.',
    ),
    AcademicPath(
      year: 3,
      title: 'Professional Path',
      summary: 'Kesiapan industri lewat proyek pengembangan aplikasi, quality '
          'assurance, keamanan, serta Agile, Scrum, dan DevOps.',
      detail:
          'Tahun ketiga rasanya seperti bekerja di tim software profesional: '
          'proyek dikerjakan dengan Agile/Scrum, kode diuji oleh quality '
          'assurance, keamanan diperhatikan sejak awal, dan rilis diotomatisasi '
          'dengan DevOps. Ruang Software Engineering dan Cyber Security di game '
          'ini adalah versi mininya.',
    ),
    AcademicPath(
      year: 4,
      title: 'Industry & Final Path',
      summary: 'Menjalani internship dan menyelesaikan Tugas Akhir untuk '
          'mengintegrasikan end-to-end software development dalam konteks industri.',
      detail:
          'Tahun terakhir kamu benar-benar terjun ke industri lewat internship '
          '(program Enrichment BINUS), lalu merangkum semuanya dalam Tugas Akhir. '
          'Aplikasi Campus Escape yang sedang kamu mainkan ini pun lahir dari '
          'program internship mahasiswa CSSE.',
    ),
  ];

  static const List<Lecturer> lecturers = [
    Lecturer(name: 'Kristien Margi Suryaningrum, S.Kom., M.Cs.', role: 'Head of Computer Science Software Engineering Program', photo: 'assets/images/lecturers/dosen_01.jpg'),
    Lecturer(name: 'Said Achmad, S.Kom., M.Kom.', role: 'Deputy Head of Computer Science Software Engineering Program', photo: 'assets/images/lecturers/dosen_02.jpg'),
    Lecturer(name: 'Panji Arisaputra, S.Kom., M.Kom.', role: 'Associate Lecturer Specialist – S2', photo: 'assets/images/lecturers/dosen_03.jpg'),
    Lecturer(name: 'Pandu Wicaksono, S.Kom., M.Kom.', role: 'Associate Lecturer Specialist – S2', photo: 'assets/images/lecturers/dosen_04.jpg'),
    Lecturer(name: 'Zahra Nabila Izdihar, S.T., M.Kom.', role: 'Associate Lecturer Specialist – S2', photo: 'assets/images/lecturers/dosen_05.jpg'),
  ];
  static const lecturersIntro =
      'Diampu dosen-dosen dengan latar belakang akademik dan praktik industri. '
      'Kelasnya kecil, jadi dosen kenal mahasiswanya satu per satu — bertanya '
      'tidak perlu sungkan.';

  static const himtiIntro =
      'Di luar kelas, mahasiswa SoCS bernaung di HIMTI — Himpunan Mahasiswa '
      'Teknik Informatika BINUS University, berdiri sejak 1992. Slogannya: '
      'One Family One Goal. Di sini kamu belajar memimpin, mengelola acara, dan '
      'membangun jaringan — hard skill dan soft skill jalan bareng.';
  static const List<HighlightItem> himti = [
    HighlightItem(
      icon: Icons.account_tree_outlined,
      title: '4 komisi, 8 divisi',
      body: 'Education (Academic Event, Responsi), Relation Expansion (Publication & '
          'Marketing, HIMTI Care), Research & Development (Creative & Design, Web '
          'Development), dan Resource Development (Supervisor, Human Resource '
          'Development). Ada tempat untuk yang suka coding, desain, maupun organisasi.',
    ),
    HighlightItem(
      icon: Icons.event_available_outlined,
      title: 'Agenda 2026',
      body: 'HISHOT 2026 (12 Juni), TECHFEST 2026 (25 Juli), dan TECHNO 2026 '
          '(27 September) — seminar, kompetisi, dan festival teknologi yang '
          'digarap langsung oleh mahasiswa.',
    ),
    HighlightItem(
      icon: Icons.history_edu_outlined,
      title: 'Jejak yang panjang',
      body: 'Dari Responsi (program belajar bareng senior) sejak 1994, HEXION '
          '(expo & kompetisi) sejak 2011, sampai rekor MURI papan ular tangga '
          'fakta teknologi terpanjang di Euphoria 2013 dan International Computer '
          'Festival 2018.',
    ),
  ];

  static const List<SourceLink> sources = [
    SourceLink('Profil & kurikulum CSSE BINUS @Bekasi', 'https://binus.ac.id/bekasi/csse/'),
    SourceLink('School of Computer Science BINUS', 'https://socs.binus.ac.id/'),
    SourceLink('HIMTI BINUS — One Family One Goal', 'https://ofog.himtibinus.or.id/'),
    SourceLink('Kampus BINUS @Bekasi', 'https://binus.ac.id/bekasi/'),
  ];
}

class HighlightItem {
  final IconData icon;
  final String title;
  final String body;
  const HighlightItem({required this.icon, required this.title, required this.body});
}

class AcademicPath {
  final int year;
  final String title;
  final String summary;
  final String detail;
  const AcademicPath({required this.year, required this.title, required this.summary, required this.detail});
}

class Lecturer {
  final String name;
  final String role;

  /// Foto profil dari halaman resmi binus.ac.id/bekasi/csse (bagian People).
  final String? photo;
  const Lecturer({required this.name, required this.role, this.photo});

  String get initials {
    final parts = name.split(',').first.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }
}

class SourceLink {
  final String label;
  final String url;
  const SourceLink(this.label, this.url);
}
