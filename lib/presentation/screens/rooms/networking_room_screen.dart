import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/room_meta.dart';
import '../../widgets/common.dart';
import '../../widgets/room_scaffold.dart';

/// Ruang 6 — Jaringan Komputer: "Antar Paket".
/// Tap kotak-kotak jaringan sesuai urutan perjalanan paket dari Lab ke
/// Server. Internet itu paket data yang dioper dari satu alat ke alat lain.
class NetworkingRoomScreen extends StatefulWidget {
  const NetworkingRoomScreen({super.key});

  @override
  State<NetworkingRoomScreen> createState() => _NetworkingRoomScreenState();
}

class _NetworkingRoomScreenState extends State<NetworkingRoomScreen> {
  static const _answer = ['Lab', 'Router A', 'Switch', 'Server'];
  final List<String> _path = [];

  RoomMeta get _meta => RoomCatalog.byId(RoomId.networking);

  void _tap(String node) {
    setState(() {
      if (_path.contains(node)) {
        _path.removeRange(_path.indexOf(node), _path.length);
        return;
      }
      if (_path.isEmpty && node != 'Lab') return;
      if (_path.length >= _answer.length) return;
      _path.add(node);
    });
  }

  /// Penjelasan di bawah peta yang berubah mengikuti langkah pemain —
  /// sekaligus jadi petunjuk halus tanpa memberi jawaban langsung.
  ({IconData icon, String title, String body, Color color}) get _guide {
    if (_path.isEmpty) {
      return (
        icon: Icons.computer_outlined,
        title: 'Mulai dari Lab',
        body: 'Lab adalah komputer pengirim. Setiap pesan, foto, atau video dipecah jadi "paket" kecil yang berangkat dari sini. Tap kotak Lab dulu.',
        color: AppColors.textSecondary,
      );
    }
    final last = _path.last;
    if (last == 'Lab') {
      return (
        icon: Icons.router_outlined,
        title: 'Berikutnya: router',
        body: 'Router adalah polisi lalu lintas yang menentukan ke mana paket diteruskan. Ada dua router — perhatikan lampunya: hijau artinya hidup, merah artinya mati. Paket tidak bisa lewat alat yang mati.',
        color: _meta.accent,
      );
    }
    if (last == 'Router B') {
      return (
        icon: Icons.warning_amber_rounded,
        title: 'Router B sedang mati',
        body: 'Lampunya merah: paket yang masuk ke sini akan hilang. Tap Router B lagi untuk membatalkan, lalu pilih router yang lampunya hijau.',
        color: AppColors.danger,
      );
    }
    if (last == 'Router A') {
      return (
        icon: Icons.device_hub_outlined,
        title: 'Router A meneruskan ke Switch',
        body: 'Switch membagi satu jalur ke banyak perangkat dalam satu gedung — seperti colokan cabang untuk internet. Paket lewat sini sebelum ke tujuan.',
        color: AppColors.success,
      );
    }
    if (last == 'Switch') {
      return (
        icon: Icons.dns_outlined,
        title: 'Tinggal satu langkah',
        body: 'Server adalah komputer tujuan yang menyimpan dan melayani data (misalnya server WhatsApp atau game online). Tap Server untuk menyelesaikan rute.',
        color: AppColors.success,
      );
    }
    return (
      icon: Icons.check_circle_outline_rounded,
      title: 'Rute lengkap',
      body: 'Paket sudah punya jalur dari Lab sampai Server. Tekan "Cek Jawaban" untuk mengirimnya.',
      color: AppColors.success,
    );
  }

  RoomCheck _check() {
    if (_path.isEmpty) return const RoomCheckIncomplete('Mulai dengan tap kotak "Lab", lalu lanjut ke alat berikutnya.');
    if (_path.length < _answer.length) return RoomCheckIncomplete('Rute belum sampai Server. Baru ${_path.length} dari ${_answer.length} langkah.');
    for (var i = 0; i < _answer.length; i++) {
      if (_path[i] != _answer[i]) {
        return const RoomCheckWrong('Paket nyasar. Router B sedang mati (lampu merah) — lewati yang lampunya hijau.');
      }
    }
    return const RoomCheckCorrect('Paket sampai ke Server! Begitulah pesan WhatsApp-mu berjalan tiap hari.');
  }

  @override
  Widget build(BuildContext context) {
    return RoomScaffold(
      meta: _meta,
      storyLead: 'Pesan dari Lab tidak sampai ke Server.',
      storyBody:
          'Paket data harus dioper lewat alat-alat jaringan. Tap kotak sesuai '
          'urutan perjalanannya: mulai dari Lab, berakhir di Server.',
      hints: const [
        'Paket selalu berangkat dari Lab dan berakhir di Server. Di antaranya ada 2 alat yang harus dilewati.',
        'Router adalah "polisi lalu lintas" yang meneruskan paket. Pilih router yang lampunya hijau (hidup), bukan merah (mati).',
        'Rutenya: Lab → Router A → Switch → Server.',
      ],
      modeLabel: 'Tap kotak',
      stageCount: _answer.length,
      stagesDone: _path.length,
      onCheck: _check,
      onReset: () => setState(_path.clear),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HelperPanel(
            label: 'Peta jaringan kampus',
            child: _Topology(path: _path, accent: _meta.accent, onTap: _tap),
          ),
          const SizedBox(height: AppSpacing.sm),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.route_rounded, size: 18, color: AppColors.textMuted),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    _path.isEmpty ? 'Rute: belum ada' : 'Rute: ${_path.join(' → ')}',
                    style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: SurfaceCard(
              key: ValueKey(_guide.title),
              color: AppColors.surfaceDim,
              borderColor: AppColors.outlineSubtle,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_guide.icon, size: 22, color: _guide.color),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_guide.title, style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w700, color: _guide.color)),
                        const SizedBox(height: 2),
                        Text(_guide.body, style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Network Engineer merancang jalur seperti ini supaya pesanmu sampai dalam hitungan milidetik.',
            style: AppTypography.captionXs,
          ),
        ],
      ),
    );
  }
}

class _Topology extends StatelessWidget {
  final List<String> path;
  final Color accent;
  final ValueChanged<String> onTap;
  const _Topology({required this.path, required this.accent, required this.onTap});

  bool _linked(String a, String b) {
    final ia = path.indexOf(a), ib = path.indexOf(b);
    return ia != -1 && ib == ia + 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      // 4 kolom node + 3 penghubung, menyesuaikan lebar layar.
      final edgeW = c.maxWidth >= 340 ? 22.0 : 12.0;
      final nodeW = ((c.maxWidth - edgeW * 3) / 4).clamp(52.0, 76.0);
      Widget node(String name, IconData icon, {bool? up}) => _NetNode(
            name: name,
            icon: icon,
            up: up,
            width: nodeW,
            order: path.contains(name) ? path.indexOf(name) + 1 : null,
            accent: accent,
            onTap: () => onTap(name),
          );
      Widget edge({bool vertical = false, bool active = false}) => Container(
            width: vertical ? 2 : edgeW,
            height: vertical ? 16 : 2,
            color: active ? accent : AppColors.outline,
          );

      return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        node('Lab', Icons.computer_outlined),
        edge(active: _linked('Lab', 'Router A') || _linked('Lab', 'Router B')),
        Column(
          children: [
            node('Router A', Icons.router_outlined, up: true),
            edge(vertical: true),
            node('Router B', Icons.router_outlined, up: false),
          ],
        ),
        edge(active: _linked('Router A', 'Switch') || _linked('Router B', 'Switch')),
        node('Switch', Icons.device_hub_outlined),
        edge(active: _linked('Switch', 'Server')),
        node('Server', Icons.dns_outlined),
      ],
    );
    });
  }
}

class _NetNode extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool? up;
  final int? order;
  final double width;
  final Color accent;
  final VoidCallback onTap;
  const _NetNode({required this.name, required this.icon, required this.up, required this.width, required this.order, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = order != null;
    final down = up == false;
    return Material(
      color: selected ? AppColors.surfaceRaised : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(color: selected ? accent : AppColors.outline, width: selected ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          width: width,
          height: 68,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 22, color: down ? AppColors.textDisabled : (selected ? accent : AppColors.textSecondary)),
                    const SizedBox(height: 3),
                    Text(name, style: AppTypography.captionXs.copyWith(fontSize: 9), maxLines: 1),
                    if (up != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(color: down ? AppColors.danger : AppColors.success, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 3),
                          Text(down ? 'mati' : 'hidup', style: AppTypography.captionXs.copyWith(fontSize: 8, color: down ? AppColors.danger : AppColors.success)),
                        ],
                      ),
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  top: 3,
                  right: 3,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                    child: Text('$order', style: AppTypography.labelBadge.copyWith(fontSize: 9, color: AppColors.onAccent)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
