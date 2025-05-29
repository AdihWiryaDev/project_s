import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class ServerService {
  String? connectedEndpointId;

  Future<void> startServer(
    String userName,
    Strategy strategy,
    String password, {
    required void Function() onClientConnected,
  }) async {
    await Nearby().stopAdvertising();

    await Nearby().startAdvertising(
      userName,
      strategy,
      onConnectionInitiated: (id, info) {
        Nearby().acceptConnection(
          id,
          onPayLoadRecieved: (endid, payload) async {
            // Decode the payload bytes
            final receivedData = String.fromCharCodes(payload.bytes!);
            final jsonData = jsonDecode(receivedData);

            if (jsonData['type'] == 'request' &&
                jsonData['data'] == 'file_data') {
              var result = sendFileToClient(id);
              final payload = jsonEncode({
                'operationType': 'file',
                'file': result,
              });

              final bytes = Uint8List.fromList(payload.codeUnits);
              await Nearby().sendBytesPayload(endid, bytes);
            }
          },
          onPayloadTransferUpdate: (_, __) {},
        );
      },
      onConnectionResult: (id, status) async {
        if (status == Status.CONNECTED) {
          connectedEndpointId = id;
          final jsonPayload = jsonEncode({
            'operationType': 'connection',
            'password': password, // Tambahkan password atau informasi lainnya
          });
          final bytes = Uint8List.fromList(jsonPayload.codeUnits);
          await Nearby().sendBytesPayload(id, bytes);

          onClientConnected();
        }
      },
      onDisconnected: (id) {},
    );
  }

  Future<Map<String, dynamic>> sendFileToClient(String endpointId) async {
    final result =
        await getFolderAndImages(); // Ambil data file (misalnya path atau konten)

    return result;
  }
}

Future<Map<String, dynamic>> getFolderAndImages() async {
  final directoryPath = await createFolderInPictures();
  Map<String, dynamic> result = {
    'folders': [],
    'images': [],
  };

  if (directoryPath != null) {
    final directory = Directory(directoryPath);
    final files = directory.listSync();

    for (var file in files) {
      if (file is File) {
        final filePath = file.path;

        // Mengecek apakah file tersebut gambar
        if (filePath.endsWith('.jpg') ||
            filePath.endsWith('.jpeg') ||
            filePath.endsWith('.png')) {
          // Mengonversi gambar ke base64
          final base64Image = await _convertImageToBase64(filePath);

          // Ambil nama file sebagai judul

          result['images'].add({
            'filePath': filePath, // Nama gambar
            'value': base64Image, // Gambar dalam format base64
          });
        }
      } else if (file is Directory) {
        result['folders'].add({
          'filePath': file.path, // Nama gambar
          'value': file.path, // Gambar dalam format base64
        });
      }
    }
  }

  return result;
}

Future<String?> createFolderInPictures() async {
  // Pastikan izin storage telah diberikan
  if (await Permission.storage.isGranted) {
    try {
      final directory = await _getOrCreateDirectory('ProjectImages');
      return directory.path; // <-- balikin path String di sini
    } catch (e) {
      return null;
    }
  } else {
    return null;
  }
}

Future<String> _convertImageToBase64(String filePath) async {
  final file = File(filePath);
  List<int> fileBytes = await file.readAsBytes();
  String base64Image = base64Encode(fileBytes);
  return base64Image;
}

Future<Directory> _getOrCreateDirectory(String folderName) async {
  final picturesDirectory = Directory('/storage/emulated/0/Pictures');
  final folderDirectory = Directory('${picturesDirectory.path}/$folderName');

  if (!(await folderDirectory.exists())) {
    await folderDirectory.create();
  }

  return folderDirectory;
}
