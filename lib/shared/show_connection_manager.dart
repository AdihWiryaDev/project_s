import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project_s/main.dart';

void showConnectionNotification(String deviceName) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'connection_channel', // ID channel
    'Device Connection', // Nama channel
    channelDescription: 'Notification for active device connection',
    importance: Importance.max,
    priority: Priority.high,
    ongoing: true, // <-- agar tidak bisa di-swipe
    autoCancel: false, // <-- agar tidak hilang kalau diklik
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    999, // ID notifikasi, boleh angka apa saja
    deviceName,
    'This device is connected and active',
    platformChannelSpecifics,
  );
}

void hideConnectionNotification() async {
  await flutterLocalNotificationsPlugin.cancel(999);
}
