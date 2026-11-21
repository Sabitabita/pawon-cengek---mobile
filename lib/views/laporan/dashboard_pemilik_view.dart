import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/lbs_sensor_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/pos_viewmodel.dart';
import '../auth/login_view.dart';
import '../inventory/stok_view.dart';
import '../pos/pos_kasir_view.dart';

class DashboardPemilikView extends StatefulWidget {
  const DashboardPemilikView({super.key});

  @override
  State<DashboardPemilikView> createState() => _DashboardPemilikViewState();
}

class _DashboardPemilikViewState extends State<DashboardPemilikView> {
  final LbsSensorService _lbsSensor = LbsSensorService();
  String _lokasiWarung = 'Mendeteksi lokasi GPS warung...';
  StreamSubscription? _shakeSub;

  @override
  void initState() {
    super.initState();
    _loadLokasi();
    _shakeSub = _lbsSensor.listenShake(() {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sensor Shake terdeteksi: Data laporan diperbarui!'),
        ),
      );
      setState(() {});
    });
  }

  Future<void> _loadLokasi() async {
    final loc = await _lbsSensor.getWarungCoordinates();
    if (mounted) setState(() => _lokasiWarung = loc);
  }

  @override
  void dispose() {
    _shakeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posVm = context.watch<PosViewModel>();
    final authVm = context.read<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pemilik'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authVm.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: Colors.deepOrange,
                ),
                title: const Text('Validasi Lokasi Warung (LBS GPS)'),
                subtitle: Text(_lokasiWarung),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Total Omset Hari Ini',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rp ${posVm.totalOmsetHariIni}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Goyangkan perangkat (Accelerometer) untuk refresh data',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.inventory),
                label: const Text('KELOLA INVENTORI & TELEPON SUPPLIER'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StokView()),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.point_of_sale),
                label: const Text('BUKA MODE KASIR (POS)'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PosKasirView()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
