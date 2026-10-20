import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/online_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/event_info.dart';
import '../../../data/remote/firebase_service.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

/// Login admin untuk panel admin ONLINE: username + password (tanpa
/// email). Akun dibuat sekali oleh pengelola di Firebase Console — lihat
/// docs/FIREBASE_SETUP.md. Percobaan login dibatasi otomatis oleh Firebase
/// Auth (too-many-requests) jadi tidak bisa ditebak-tebak dengan cepat.
class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(firebaseServiceProvider).adminSignIn(
            username: _userCtrl.text,
            password: _passCtrl.text,
          );
      if (!mounted) return;
      context.pushReplacement('/admin');
    } on AdminLoginException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Gagal login: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Admin'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.lg, AppSpacing.screenH, AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.accent, size: 28),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Panel Admin Online', style: AppTypography.headlineSm),
                          Text('Pantau peserta, atur ruangan, tetapkan pemenang.', style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionLabel('Username'),
                const SizedBox(height: AppSpacing.xxs),
                TextFormField(
                  controller: _userCtrl,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9._]'))],
                  decoration: const InputDecoration(
                    hintText: 'misal: admin',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                  validator: (v) => AdminUsername.isValid(v ?? '') ? null : 'Username 3–24 karakter (huruf kecil/angka/._)',
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                const SectionLabel('Password'),
                const SizedBox(height: AppSpacing.xxs),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.key_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v ?? '').length >= 6 ? null : 'Password minimal 6 karakter',
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  StatusBanner(text: _error!, kind: BannerKind.danger),
                ],
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: _busy ? 'Masuk…' : 'Masuk',
                  icon: Icons.login_rounded,
                  onPressed: _busy ? null : _login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
