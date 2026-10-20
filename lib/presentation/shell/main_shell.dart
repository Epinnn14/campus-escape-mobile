import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class _Tab {
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _Tab(this.path, this.icon, this.selectedIcon, this.label);
}

const _tabs = <_Tab>[
  _Tab('/home', Icons.home_outlined, Icons.home_rounded, 'Home'),
  _Tab('/map', Icons.map_outlined, Icons.map_rounded, 'Peta'),
  _Tab('/collection', Icons.school_outlined, Icons.school_rounded, 'Kampus'),
  _Tab('/leaderboard', Icons.emoji_events_outlined, Icons.emoji_events_rounded, 'Peringkat'),
  _Tab('/profile', Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
];

/// 5 hub screen berbagi bottom nav (DESIGN.md: Home, Peta, Galeri,
/// Peringkat, Profil). Room screen tidak pernah memakai shell ini.
class MainShell extends StatelessWidget {
  final Widget child;
  final String location;
  const MainShell({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    final index = _tabs.indexWhere((t) => location.startsWith(t.path));
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(6, 10, 6, bottomInset + 12),
        decoration: const BoxDecoration(
          color: AppColors.surfaceDim,
          border: Border(top: BorderSide(color: AppColors.outlineSubtle)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < _tabs.length; i++)
              Expanded(
                child: _NavItem(
                  tab: _tabs[i],
                  selected: i == index,
                  onTap: () => context.go(_tabs[i].path),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.tab, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textDisabled;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.iconButton),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? tab.selectedIcon : tab.icon, size: 22, color: color),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                tab.label,
                style: AppTypography.labelNav.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
