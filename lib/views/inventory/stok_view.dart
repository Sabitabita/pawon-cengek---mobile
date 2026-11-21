import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/inventory_viewmodel.dart';

class StokView extends StatelessWidget {
  const StokView({super.key});

  @override
  Widget build(BuildContext context) {
    final invVm = context.watch<InventoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Inventori'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Telepon Supplier',
            icon: const Icon(Icons.phone),
            onPressed: () => invVm.hubungiSupplier(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: invVm.daftarBahan.length,
        itemBuilder: (context, index) {
          final item = invVm.daftarBahan[index];
          final bool habis = item.stokSaatIni <= 0;
          final bool menipis = !habis && item.stokSaatIni <= item.stokMinimum;

          final Color statusColor = habis
              ? Colors.red
              : (menipis ? Colors.orange : Colors.green);
          final IconData statusIcon = habis
              ? Icons.cancel
              : (menipis ? Icons.warning : Icons.check_circle);
          final String statusText = habis
              ? 'Habis'
              : (menipis ? 'Menipis' : 'Cukup');

          return Card(
            child: ListTile(
              leading: Icon(statusIcon, color: statusColor, size: 32),
              title: Text(
                item.namaBahan,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Sisa: ${item.stokSaatIni} ${item.satuan} • Status: $statusText',
              ),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Restock'),
                onPressed: () => invVm.restockBahan(index, 10),
              ),
            ),
          );
        },
      ),
    );
  }
}
