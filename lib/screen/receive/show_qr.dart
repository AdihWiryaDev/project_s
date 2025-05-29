import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:project_s/helper/helper.dart';
import 'package:project_s/helper/server_service.dart';
import 'package:project_s/shared/shared.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowQrScreen extends StatefulWidget {
  const ShowQrScreen({super.key});

  @override
  State<ShowQrScreen> createState() => _ShowQrScreenState();
}

class _ShowQrScreenState extends State<ShowQrScreen> {
  TextEditingController serverController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final Strategy strategy = Strategy.P2P_CLUSTER;
  String jsonServer = "";
  String? connectedEndpoint;
  @override
  void initState() {
    initNearby();
    super.initState();
  }

  Future<void> initNearby() async {
    await askPermissions(); // Tunggu permission beres
    startServer(); // Lanjut start server
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
    await Nearby().stopAdvertising();

    int port = await getAvailablePort();
    final ip = await getLocalIpAddress();
    String password = generateRandomString(8);

    Map<String, dynamic> jsonData = {
      "server": "$ip:$port",
      "password": password
    };

    serverController.text = "Server-${DateTime.now().millisecondsSinceEpoch}";
    passwordController.text = password;

    setState(() {
      jsonServer = jsonEncode(jsonData);
    });

    ServerService().startServer(
      serverController.text,
      strategy,
      password,
      onClientConnected: () {
        if (mounted) {
          Navigator.pop(context); // ➜ kembali ke screen sebelumnya
        }
      },
    );
  }
}
