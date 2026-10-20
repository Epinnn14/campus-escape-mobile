import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/session_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Splash singkat. Kalau regu sudah terdaftar (sesi tersimpan di Hive),
/// langsung ke Home; kalau belum, ke Landing.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final registered = ref.read(sessionProvider).isRegistered;
      context.go(registered ? '/home' : '/landing');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.outline),
              ),
              child: const Icon(Icons.key_rounded, size: 40, color: AppColors.accent),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Campus Escape', style: AppTypography.headlineLg),
            const SizedBox(height: AppSpacing.xxs),
            Text('SoCS Binus Bekasi', style: AppTypography.labelSection),
          ],
        ),
      ),
    );
  }
}
