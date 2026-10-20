import 'dart:math' as math;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application/providers/session_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

/// Web & desktop (Windows/macOS/Linux) punya layar lebar: app dibingkai
/// seukuran HP (430 px) di tengah supaya layout mini-game tetap benar.
bool get _isWideScreenPlatform =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.linux;

class CampusEscapeApp extends ConsumerWidget {
  const CampusEscapeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Background seluruh app mengikuti warna robot avatar yang dipilih.
    final tint = ref.watch(sessionProvider.select((s) => s.isRegistered ? s.avatar.color : null));
    final theme = AppTheme.tinted(tint);
    return MaterialApp.router(
      title: 'Campus Escape',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      // Di web & desktop (.exe), kunci lebar ke ukuran HP supaya layout
      // nggak melar. Di Android/iOS builder ini nggak ngapa-ngapain.
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        // Batasi skala font sistem (aksesibilitas) supaya layout mini-game
        // tetap muat di HP kecil maupun besar.
        final media = MediaQuery.of(context);
        final wide = _isWideScreenPlatform;
        final scaled = MediaQuery(
          data: media.copyWith(
            // Di web/desktop lebar dikunci 430, jadi MediaQuery.size ikut
            // dikunci supaya layout yang menghitung dari lebar layar benar.
            size: wide ? Size(math.min(media.size.width, 430), media.size.height) : media.size,
            textScaler: media.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.15),
          ),
          child: child,
        );
        if (!wide) return scaled;
        return ColoredBox(
          color: AppColors.surfaceDim,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: scaled,
            ),
          ),
        );
      },
    );
  }
}
