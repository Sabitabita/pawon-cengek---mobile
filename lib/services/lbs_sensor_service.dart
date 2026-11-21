import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class LbsSensorService {
  // LBS: Mendapatkan koordinat GPS warung saat ini
  Future<String> getWarungCoordinates() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return 'GPS nonaktif (Lokasi Default: Malang)';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return 'Izin lokasi ditolak (Lokasi Warung: -7.9212, 112.5993)';
      }

      final pos = await Geolocator.getCurrentPosition();
      return 'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}';
    } catch (_) {
      return 'Lat: -7.9212, Lng: 112.5993 (Area UMM Malang)';
    }
  }

  // Sensor: Mendengarkan Accelerometer untuk fitur shake-to-refresh
  StreamSubscription listenShake(void Function() onShake) {
    return accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      if (magnitude > 22.0) {
        onShake();
      }
    });
  }
}
