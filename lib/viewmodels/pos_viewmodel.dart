import 'package:flutter/material.dart';

import '../models/menu_dto.dart';
import '../models/transaksi_dto.dart';
import '../services/offline_sync_service.dart';

class PosViewModel extends ChangeNotifier {
  final OfflineSyncService _syncService = OfflineSyncService();
  int get totalOmsetHariIni => 125000 + totalBayar;
  // Daftar menu Warung Makan Pawon Cengek
  final List<MenuDto> daftarMenu = [
    MenuDto(
      menuId: 'MN-01',
      namaMenu: 'Ayam Geprek Cengek',
      kategori: 'Makanan Utama',
      harga: 18000,
      gambarUrl: '',
      statusTersedia: true,
    ),
    MenuDto(
      menuId: 'MN-02',
      namaMenu: 'Nasi Goreng Pawon',
      kategori: 'Makanan Utama',
      harga: 20000,
      gambarUrl: '',
      statusTersedia: true,
    ),
    MenuDto(
      menuId: 'MN-03',
      namaMenu: 'Bebek Sambal Cengek',
      kategori: 'Makanan Utama',
      harga: 28000,
      gambarUrl: '',
      statusTersedia: true,
    ),
    MenuDto(
      menuId: 'MN-04',
      namaMenu: 'Es Teh Manis',
      kategori: 'Minuman',
      harga: 5000,
      gambarUrl: '',
      statusTersedia: true,
    ),
    MenuDto(
      menuId: 'MN-05',
      namaMenu: 'Es Jeruk Peras',
      kategori: 'Minuman',
      harga: 7000,
      gambarUrl: '',
      statusTersedia: true,
    ),
  ];

  final Map<String, DetailTransaksiDto> _keranjang = {};
  bool isProcessing = false;
  String statusKoneksi = 'Siap Transaksi';

  List<DetailTransaksiDto> get itemKeranjang => _keranjang.values.toList();

  int get totalBayar =>
      _keranjang.values.fold(0, (sum, item) => sum + item.subtotal);

  int get jumlahOfflinePending => _syncService.jumlahAntreanOffline;

  void tambahKeKeranjang(MenuDto menu) {
    if (_keranjang.containsKey(menu.menuId)) {
      final lama = _keranjang[menu.menuId]!;
      final qtyBaru = lama.jumlahPorsi + 1;
      _keranjang[menu.menuId] = DetailTransaksiDto(
        menuId: menu.menuId,
        namaMenu: menu.namaMenu,
        jumlahPorsi: qtyBaru,
        subtotal: qtyBaru * menu.harga,
      );
    } else {
      _keranjang[menu.menuId] = DetailTransaksiDto(
        menuId: menu.menuId,
        namaMenu: menu.namaMenu,
        jumlahPorsi: 1,
        subtotal: menu.harga,
      );
    }
    notifyListeners();
  }

  void kurangiItem(String menuId, int hargaSatuan) {
    if (!_keranjang.containsKey(menuId)) return;
    final lama = _keranjang[menuId]!;
    if (lama.jumlahPorsi > 1) {
      final qtyBaru = lama.jumlahPorsi - 1;
      _keranjang[menuId] = DetailTransaksiDto(
        menuId: menuId,
        namaMenu: lama.namaMenu,
        jumlahPorsi: qtyBaru,
        subtotal: qtyBaru * hargaSatuan,
      );
    } else {
      _keranjang.remove(menuId);
    }
    notifyListeners();
  }

  Future<String> prosesPembayaran({
    required String metode,
    required String kasirId,
  }) async {
    if (_keranjang.isEmpty) return 'Keranjang masih kosong!';

    isProcessing = true;
    notifyListeners();

    final now = DateTime.now();
    final transaksi = TransaksiDto(
      transaksiId: 'TRX-${now.millisecondsSinceEpoch}',
      kodeTransaksi: 'PC-${now.hour}${now.minute}${now.second}',
      tanggalTransaksi: now.toIso8601String(),
      totalBayar: totalBayar,
      metodePembayaran: metode,
      kasirId: kasirId,
      items: itemKeranjang,
    );

    final terkirimOnline = await _syncService.simpanTransaksi(transaksi);
    _keranjang.clear();
    isProcessing = false;

    statusKoneksi = terkirimOnline
        ? 'Online — Transaksi terkirim ke Cloud'
        : 'Offline — Tersimpan di Hive (Antrean: $jumlahOfflinePending)';
    notifyListeners();

    return terkirimOnline
        ? 'Pembayaran ($metode) berhasil & tersinkron ke server!'
        : 'Internet terputus! Transaksi disimpan di cache offline & akan otomatis dikirim saat online.';
  }

  Future<void> sinkronManual() async {
    final count = await _syncService.sinkronkanDataTertunda();
    statusKoneksi = count > 0
        ? '$count transaksi offline berhasil disinkronkan!'
        : 'Tidak ada antrean offline / masih offline';
    notifyListeners();
  }
}
