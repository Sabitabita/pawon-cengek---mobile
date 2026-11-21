import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../pos/pos_kasir_view.dart';
import '../laporan/dashboard_pemilik_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtrl = TextEditingController(text: 'kasir@pawoncengek.id');
  final _passCtrl = TextEditingController(text: '123456');

  Future<void> _handleLogin() async {
    final authVm = context.read<AuthViewModel>();
    final success = await authVm.login(_emailCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;
    if (success) {
      // RBAC: Pemilik masuk Dashboard Pemilik, Kasir langsung ke POS Kasir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => authVm.isPemilik
              ? const DashboardPemilikView()
              : const PosKasirView(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.restaurant_menu,
                size: 72,
                color: Colors.deepOrange,
              ),
              const SizedBox(height: 12),
              const Text(
                'Warung Makan Pawon Cengek',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Sistem Kasir & Manajemen Inventori',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email (kasir@... / pemilik@...)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Kata Sandi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              if (authVm.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  authVm.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 50, // Memenuhi syarat aksesibilitas sentuh >= 48dp
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: authVm.isLoading ? null : _handleLogin,
                  child: authVm.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'MASUK',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
