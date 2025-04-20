import 'dart:convert';
import 'dart:io';

import 'package:project_s/helper/connection_service.dart';
import 'package:project_s/screen/send/file_explorer.dart';
import 'package:project_s/shared/show_connection_manager.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/material.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? result;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData.code;
      });

      // Optionally: Close scanner after first scan
      controller.pauseCamera();
      if (result != null) {
        Map<String, dynamic> jsonData = jsonDecode(result!);
        // Mendapatkan server (IP:Port) dan password
        String server = jsonData['server'];
        String password = jsonData['password'];

        // Memisahkan IP dan Port dari server
        List<String> serverParts = server.split(':');
        String ip = serverParts[0];
        int port = int.parse(serverParts[1]);

        connect(ip, port, password);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("gagal melakakukan scan qr")));
      }
    });
  }

  Future<void> connect(String ip, int port, String password) async {
    final conn = ConnectionService();

    if (conn.socket != null) {
      return;
    }

    try {
      // Membuat koneksi ke server
      conn.socket = await Socket.connect(ip, port);
      // Kirimkan password ke server untuk validasi
      conn.socket?.write(password);
      await conn.socket?.flush();

      // Menerima respon dari server
      final response = await utf8.decoder.bind(conn.socket!).first;
      if (response.contains("Akses diterima!")) {
        showConnectionNotification("Terhubung dengan $ip:$port");

        // Mulai listening untuk response berikutnya
        conn.socket!.listen(
          (data) {
            final message = utf8.decode(data);
            debugPrint("Dari server: $message");
            // Kamu bisa pakai event bus, StreamController, atau callback di sini untuk update UI
          },
          onError: (err) {
            debugPrint("Socket error: $err");
            conn.socket?.destroy();
          },
          onDone: () {
            debugPrint("Koneksi ditutup oleh server.");
            conn.socket?.destroy();
          },
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FileExplorerScreen(),
            ),
          );
        }
      } else {
        showConnectionNotification("Gagal terhubung");
        conn.socket?.close();
        conn.socket = null;
      }
    } catch (e) {
      showConnectionNotification("Error: $e");
      conn.socket?.close();
      conn.socket = null;
    }
  }
}
