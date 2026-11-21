import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/pos_viewmodel.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../auth/login_view.dart';
import '../inventory/stok_view.dart';

class PosKasirView extends StatelessWidget {
  const PosKasirView({super.key});

  @override
  Widget build(BuildContext context) {
    final posVm = context.watch<PosViewModel>();
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Kasir — Pawon Cengek'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Sinkronkan Offline',
            icon: Badge(
              label: Text('${posVm.jumlahOfflinePending}'),
              isLabelVisible: posVm.jumlahOfflinePending > 0,
              child: const Icon(Icons.sync),
            ),
            onPressed: () => posVm.sinkronManual(),
          ),
          IconButton(
            tooltip: 'Cek Stok & LBS/Sensor',
            icon: const Icon(Icons.inventory_2),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StokView()),
            ),
          ),
          IconButton(
            tooltip: 'Keluar',
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
      body: Column(
        children: [
          // Banner status koneksi & antrean offline
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: posVm.jumlahOfflinePending > 0
                ? Colors.amber.shade100
                : Colors.green.shade50,
            child: Text(
              'Status: ${posVm.statusKoneksi}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),

          // Daftar Menu Warung
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posVm.daftarMenu.length,
              itemBuilder: (context, index) {
                final menu = posVm.daftarMenu[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepOrange.shade100,
                      child: const Icon(Icons.fastfood, color: Colors.deepOrange),
                    ),
                    title: Text(menu.namaMenu,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${menu.kategori} • Rp ${menu.harga}'),
                    trailing: ElevatedButton(
                      onPressed: () => posVm.tambahKeKeranjang(menu),
                      child: const Text('+ Tambah'),
                    ),
                  ),
                );
              },
            ),
          ),

          // Ringkasan Keranjang & Tombol Bayar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (posVm.itemKeranjang.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView(
                      children: posVm.itemKeranjang
                          .map((item) => Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.namaMenu} x${item.jumlahPorsi}'),
                                  Text('Rp ${item.subtotal}'),
                                ],
                              ))
                          .toList(),
                    ),
                  ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Bayar:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Rp ${posVm.totalBayar}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.payments),
                        label: const Text('Bayar Cash'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: posVm.isProcessing
                            ? null
                            : () async {
                                final msg = await posVm.prosesPembayaran(
                                  metode: 'Cash',
                                  kasirId: authVm.currentUser?.userId ?? 'USR-KASIR',
                                );
                                if (!context.mounted) return;
                                // Potong stok otomatis & cek notifikasi stok rendah
                                await context
                                    .read<InventoryViewModel>()
                                    .potongStokOtomatis();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(msg)));
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('Bayar QRIS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: posVm.isProcessing
                            ? null
                            : () async {
                                final msg = await posVm.prosesPembayaran(
                                  metode: 'QRIS',
                                  kasirId: authVm.currentUser?.userId ?? 'USR-KASIR',
                                );
                                if (!context.mounted) return;
                                await context
                                    .read<InventoryViewModel>()
                                    .potongStokOtomatis();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(msg)));
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}