import 'package:flutter/material.dart';
import 'package:project_s/screen/receive/show_qr.dart';
import 'package:project_s/screen/send/qr_scan.dart';
import 'package:project_s/shared/button_home.dart';
import 'package:project_s/shared/shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(
              child: Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
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
                      'Please login on both Android device then choose which Android device as Backup device',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ButtonHomeStyle(
                      label: 'This device as\nFile Sender',
                      color: const Color(0xFFDFF3D9),
                      onPressed: () async {
                        debugPrint("File Sender selected");
                        if (await requestStoragePermission()) {
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ShowQrScreen(),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ButtonHomeStyle(
                      label: 'This device as\nBackup Storage',
                      color: const Color(0xFFE5E1E5),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QrScanScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
