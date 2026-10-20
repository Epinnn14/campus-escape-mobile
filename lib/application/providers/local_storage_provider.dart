import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/local_storage_service.dart';

/// Di-override di main.dart setelah Hive siap, jadi provider lain cukup
/// `ref.read(localStorageProvider)`.
final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError(
    'localStorageProvider harus di-override di main() sebelum runApp().',
  );
});
