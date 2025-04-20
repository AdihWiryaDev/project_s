import 'dart:convert';
import 'dart:io';

import 'package:project_s/shared/show_connection_manager.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  Socket? socket;

  Future<void> connect(String ip, int port, String password) async {
    if (socket != null) {
      return;
    }

    try {
      // Membuat koneksi ke server
      socket = await Socket.connect(ip, port);
      // Kirimkan password ke server untuk validasi
      socket?.write(password);
      await socket?.flush();

      // Menerima respon dari server
      final response = await utf8.decoder.bind(socket!).first;
      if (response.contains("Akses diterima!")) {
        showConnectionNotification("Terhubung dengan $ip:$port");
      } else {
        showConnectionNotification("Gagal terhubung");
        socket?.close();
        socket = null;
      }
    } catch (e) {
      showConnectionNotification("Error: $e");
      socket?.close();
      socket = null;
    }
  }

  void send(String message) {
    if (socket == null) {
      return;
    }
    socket?.write(message);
    socket?.flush();
  }

  void disconnect() {
    socket?.close();
    socket = null;
  }
}
