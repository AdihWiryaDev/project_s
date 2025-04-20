import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:project_s/shared/show_connection_manager.dart';
import 'package:project_s/shared/shared.dart';
import 'package:permission_handler/permission_handler.dart';

class ServerService {
  static final ServerService _instance = ServerService._internal();
  factory ServerService() => _instance;
  ServerService._internal();

  ServerSocket? server;
  Socket? sockerServer;

  void send(String message) {
    if (sockerServer == null) {
      showConnectionNotification("Tidak ada koneksi.");
      return;
    }
    sockerServer?.write(message);
    sockerServer?.flush();
  }

  void disconnect() {
    server?.close();
    server = null;
    sockerServer?.close();
    sockerServer = null;
  }

  Future<List<Directory>> getDCIMFolders() async {
    await requestPermissions();

    Directory? dcimDir;

    if (await Permission.manageExternalStorage.isGranted ||
        await Permission.storage.isGranted) {
      // Hardcode path DCIM karena path_provider nggak support DCIM langsung
      dcimDir = Directory("/storage/emulated/0/DCIM");
    }

    if (dcimDir != null && await dcimDir.exists()) {
      final entities = dcimDir.listSync();
      return entities.whereType<Directory>().toList();
    }

    return [];
  }

  void startSocketListenerInBackground(Socket sockerServer) {
    final receivePort = ReceivePort();

    Isolate.spawn(socketListenerIsolate, [receivePort.sendPort, sockerServer]);

    receivePort.listen((message) {
      if (message is String) {
        sockerServer.write(message);
        sockerServer.flush();
      }
    });
  }

  static Future<void> socketListenerIsolate(List<dynamic> args) async {
    final SendPort sendPort = args[0];
    final Socket sockerServer = args[1];

    sockerServer.listen((data) async {
      final request = utf8.decode(data).trim();

      if (request == 'get_images') {
        final images = await ServerService().getDCIMFolders();
        sendPort.send(jsonEncode(images));
      } else {
        sendPort.send("Perintah tidak dikenal");
      }
    }, onError: (error) {
      sendPort.send("Error: $error");
      sockerServer.close();
    }, onDone: () {
      sendPort.send("Koneksi ditutup oleh client.");
      sockerServer.close();
    });
  }
}
