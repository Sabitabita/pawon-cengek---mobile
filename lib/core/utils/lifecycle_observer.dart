import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/offline_sync_service.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  final OfflineSyncService _syncService = OfflineSyncService();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final box = Hive.box('pawon_offline_box');

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Simpan status terakhir saat aplikasi masuk ke background
      await box.put('last_paused_at', DateTime.now().toIso8601String());
    } else if (state == AppLifecycleState.resumed) {
      // Otomatis sinkronisasi transaksi offline saat aplikasi dibuka kembali
      await _syncService.sinkronkanDataTertunda();
    }
  }
}