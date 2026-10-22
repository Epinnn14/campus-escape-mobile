import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Buka link di browser/app luar. Kalau gagal (emulator tanpa browser,
/// platform tidak mendukung), link disalin ke clipboard sebagai cadangan.
Future<void> openLink(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  var opened = false;
  if (uri != null) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
  }
  if (opened || !context.mounted) return;
  await Clipboard.setData(ClipboardData(text: url));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Browser tidak bisa dibuka — link disalin ke clipboard.')),
  );
}
