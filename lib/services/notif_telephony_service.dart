import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class NotifTelephonyService {
  final FlutterLocalNotificationsPlugin _notifPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _notifPlugin.initialize(settings: initSettings);
  }

  Future<void> showLowStockNotification(
    String namaBahan,
    double sisa,
    String satuan,
  ) async {
    await HapticFeedback.heavyImpact();
    const androidDetails = AndroidNotificationDetails(
      'stok_channel',
      'Peringatan Stok Rendah',
      importance: Importance.max,
      priority: Priority.high,
    );
    await _notifPlugin.show(
      id: DateTime.now().millisecond,
      title: 'Peringatan Stok Menipis!',
      body: 'Stok $namaBahan tersisa $sisa $satuan. Segera hubungi supplier.',
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> callSupplier(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
