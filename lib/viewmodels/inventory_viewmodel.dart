import 'package:flutter/material.dart';

import '../models/bahan_baku_dto.dart';
import '../services/notif_telephony_service.dart';

class InventoryViewModel extends ChangeNotifier {
  final NotifTelephonyService _notifService = NotifTelephonyService();

  InventoryViewModel() {
    _notifService.initNotification();
  }

  final List<BahanBakuDto> daftarBahan = [
    BahanBakuDto(
      bahanId: 'BH-01',
      namaBahan: 'Cabai Rawit (Cengek)',
      stokSaatIni: 600,
      satuan: 'gram',
      stokMinimum: 500,
    ),
    BahanBakuDto(
      bahanId: 'BH-02',
      namaBahan: 'Beras Putih',
      stokSaatIni: 12,
      satuan: 'kg',
      stokMinimum: 5,
    ),
    BahanBakuDto(
      bahanId: 'BH-03',
      namaBahan: 'Ayam Potong',
      stokSaatIni: 4,
      satuan: 'pcs',
      stokMinimum: 5,
    ),
    BahanBakuDto(
      bahanId: 'BH-04',
      namaBahan: 'Minyak Goreng',
      stokSaatIni: 0,
      satuan: 'ml',
      stokMinimum: 1000,
    ),
  ];

  Future<void> potongStokOtomatis([int jumlahPorsi = 1]) async {
    for (int i = 0; i < daftarBahan.length; i++) {
      final b = daftarBahan[i];
      final pengurangan = b.satuan == 'gram'
          ? (50.0 * jumlahPorsi)
          : (1.0 * jumlahPorsi);
      final sisaBaru = (b.stokSaatIni - pengurangan).clamp(0.0, 99999.0);

      daftarBahan[i] = BahanBakuDto(
        bahanId: b.bahanId,
        namaBahan: b.namaBahan,
        stokSaatIni: sisaBaru,
        satuan: b.satuan,
        stokMinimum: b.stokMinimum,
      );

      if (sisaBaru <= b.stokMinimum) {
        await _notifService.showLowStockNotification(
          b.namaBahan,
          sisaBaru,
          b.satuan,
        );
      }
    }
    notifyListeners();
  }

  void restockBahan(int index, double tambahan) {
    final b = daftarBahan[index];
    daftarBahan[index] = BahanBakuDto(
      bahanId: b.bahanId,
      namaBahan: b.namaBahan,
      stokSaatIni: b.stokSaatIni + tambahan,
      satuan: b.satuan,
      stokMinimum: b.stokMinimum,
    );
    notifyListeners();
  }

  Future<void> hubungiSupplier() async {
    await _notifService.callSupplier('081234567890');
  }
}
