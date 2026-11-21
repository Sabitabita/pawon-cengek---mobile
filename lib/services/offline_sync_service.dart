import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/network/api_client.dart';
import '../models/transaksi_dto.dart';

class OfflineSyncService {
  final Box _box = Hive.box('pawon_offline_box');

  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Simpan transaksi ke server jika online, atau antrekan di Hive jika offline
  Future<bool> simpanTransaksi(TransaksiDto transaksi) async {
    if (await isOnline()) {
      try {
        await ApiClient.dio.post('/transaksi', data: {'fields': transaksi.toJson()});
        return true; // Terkirim langsung ke server
      } catch (_) {
        await _simpanKeAntreanLokal(transaksi);
        return false; // Tersimpan offline karena server gagal merespons
      }
    } else {
      await _simpanKeAntreanLokal(transaksi);
      return false; // Tersimpan di mode offline
    }
  }

  Future<void> _simpanKeAntreanLokal(TransaksiDto transaksi) async {
    final List<dynamic> antrean = _box.get('pending_transaksi', defaultValue: []);
    antrean.add(transaksi.toJson());
    await _box.put('pending_transaksi', antrean);
  }

  int get jumlahAntreanOffline {
    final List<dynamic> antrean = _box.get('pending_transaksi', defaultValue: []);
    return antrean.length;
  }

  /// Sinkronisasi otomatis seluruh transaksi tertunda saat kembali online
  Future<int> sinkronkanDataTertunda() async {
    if (!await isOnline()) return 0;

    final List<dynamic> antrean = _box.get('pending_transaksi', defaultValue: []);
    if (antrean.isEmpty) return 0;

    int berhasil = 0;
    final List<dynamic> sisaGagal = [];

    for (var item in antrean) {
      try {
        await ApiClient.dio.post('/transaksi', data: {'fields': item});
        berhasil++;
      } catch (_) {
        sisaGagal.add(item);
      }
    }

    await _box.put('pending_transaksi', sisaGagal);
    return berhasil;
  }
}