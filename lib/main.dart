import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_s/helper/connection_service.dart';
import 'package:project_s/helper/server_service.dart';
import 'package:project_s/screen/home.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project_s/screen/send/file_explorer.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onNotificationSelected, // Menangani klik
  );
  PermissionStatus status = await Permission.notification.status;
  if (!status.isGranted) {
    // Jika belum, minta permission
    PermissionStatus newStatus = await Permission.notification.request();

    if (!newStatus.isGranted) {
      await Permission.notification.status;
    }
  }

  PermissionStatus statusStorage = await Permission.storage.request();
  if (!statusStorage.isGranted) {
    // Jika belum, minta permission
    PermissionStatus newStatus = await Permission.storage.request();

    if (!newStatus.isGranted) {
      await Permission.storage.request();
    }
  }

  runApp(const MyApp());
  if (ServerService().server != null) {
    ServerService().startSocketListenerInBackground(
        ServerService().sockerServer!); // Mulai listener
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ConnectionService().socket != null
          ? const FileExplorerScreen()
          : const HomeScreen(),
    );
  }
}

// Fungsi untuk menangani klik pada notifikasi
Future<void> onNotificationSelected(
    NotificationResponse notificationResponse) async {
  await flutterLocalNotificationsPlugin.cancel(999);
  ConnectionService().disconnect();
  ServerService().disconnect();
}
