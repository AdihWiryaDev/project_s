import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_s/helper/helper.dart';
import 'package:project_s/helper/server_service.dart';
import 'package:project_s/shared/show_connection_manager.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowQrScreen extends StatefulWidget {
  const ShowQrScreen({super.key});

  @override
  State<ShowQrScreen> createState() => _ShowQrScreenState();
}

class _ShowQrScreenState extends State<ShowQrScreen> {
  TextEditingController serverController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String jsonServer = "";

  @override
  void initState() {
    startServer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.rocket_launch, size: 32),
                  Text(
                    'Project S',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Icon(Icons.settings, size: 28),
                ],
              ),
            ),
            // Body
            Expanded(
              child: Container(
                color: Colors.white,
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Setup Backup Storage',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'To continue this device as Backup Storage,\nplease scan QR Code below',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // QR Code Placeholder
                    Center(
                      child: QrImageView(
                        data: jsonServer, // Data for QR code
                        size: MediaQuery.of(context).size.width /
                            2, // Set size for the QR code
                      ),
                    ),
                    const SizedBox(height: 32),
                    // SSID Input
                    TextField(
                      readOnly: true,
                      controller: serverController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        hintText: 'Server',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password Input
                    TextField(
                      readOnly: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void startServer() async {
    int port = await getAvailablePort();
    final ip = await getLocalIpAddress();
    String password = generateRandomString(8);

    Map<String, dynamic> jsonData = {
      "server": "$ip:$port",
      "password": password
    };

    serverController.text = "$ip:$port";
    passwordController.text = password;

    setState(() {
      jsonServer = jsonEncode(jsonData);
    });

    final conn = ServerService();
    conn.server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    debugPrint("Server dimulai di $ip:$port");

    conn.server!.listen((Socket client) async {
      debugPrint("Client mencoba terhubung: ${client.remoteAddress.address}");

      // Simpan koneksi client ke service
      conn.sockerServer = client;

      final clientInput = await utf8.decoder.bind(client).first;

      if (clientInput.trim() != password) {
        client.write("ERROR: Password salah\n");
        await client.flush();
        client.close();
        return;
      }

      try {
        client.write("Akses diterima!");
        await client.flush();

        showConnectionNotification(
            "Terhubung dengan ${client.remoteAddress.address}:${client.remotePort}");

        // Start listener untuk tangani perintah dari client
        conn.startSocketListenerInBackground(client);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint("Error saat koneksi: $e");
        client.close();
      }
    });
  }

  Future<List<String>> _getAllImages() async {
    // Simulasi ambil path gambar dari direktori app
    final dir = await getExternalStorageDirectory();
    final files = dir?.listSync(recursive: true) ?? [];
    final images = files
        .whereType<File>()
        .where((f) =>
            f.path.endsWith('.jpg') ||
            f.path.endsWith('.jpeg') ||
            f.path.endsWith('.png'))
        .map((f) => f.path)
        .toList();

    return images;
  }
}
