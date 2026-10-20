import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'application/providers/local_storage_provider.dart';
import 'application/providers/online_provider.dart';
import 'core/theme/app_colors.dart';
import 'data/local/local_storage_service.dart';
import 'data/remote/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surfaceDim,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storage = LocalStorageService();
  await storage.init();

  // Mode online aktif hanya kalau firebase_options.dart sudah di-generate
  // (`flutterfire configure`); kalau belum / gagal, app tetap jalan lokal.
  final firebase = await FirebaseService.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
        firebaseServiceProvider.overrideWithValue(firebase),
      ],
      child: const CampusEscapeApp(),
    ),
  );
}
