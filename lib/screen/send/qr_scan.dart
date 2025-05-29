import 'dart:convert';

import 'package:nearby_connections/nearby_connections.dart';
import 'package:project_s/helper/connection_service.dart';
import 'package:project_s/screen/send/file_explorer.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/material.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final Strategy strategy = Strategy.P2P_CLUSTER;
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

  void _onQRViewCreated(QRViewController controller) {
    String userName = "Client-${DateTime.now().millisecondsSinceEpoch}";
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (!mounted) return;

      await controller.pauseCamera();

      try {
        final result = scanData.code;
        if (result == null || result.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("QR tidak terbaca")),
            );
          }
          return;
        }

        final jsonData = jsonDecode(result);
        final String password = jsonData['password'];

        final nearbyService = ConnectionService();
        nearbyService.stopAll(); // pastikan bersih

        await nearbyService.startDiscovery(
          userName,
          password,
          () {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FileExplorerScreen()),
              );
            }
          },
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Password mismatch")),
            );
          },
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("QR tidak valid")),
          );
        }
      }
    });
  }
}
