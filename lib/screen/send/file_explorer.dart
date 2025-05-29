import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_s/helper/connection_service.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';

class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({super.key});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  List<FolderItem> folderListWidget = [];
  late final ValueListenable<Map<String, dynamic>?> payloadNotifier;
  final TextEditingController _folderNameController = TextEditingController();

  void _showCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Folder'),
          content: TextField(
            controller: _folderNameController,
            decoration: const InputDecoration(
              labelText: 'Enter Folder Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // String folderName = _folderNameController.text;
                // if (folderName.isNotEmpty) {
                //   if (ConnectionService().channel != null) {
                //     // Kirimkan request ke server untuk mendapatkan daftar gambar
                //     ConnectionService()
                //         .sendMessage("CREATE_DIRECTORY", folderName);
                //     final service = ConnectionService();
                //     service.messages.first.then((message) {
                //       try {
                //         _folderNameController.text == "";
                //         folderListWidget.add(FolderItem(
                //             path: message, value: message, type: "folder"));
                //         Navigator.of(context)
                //             .pop(); // Close the dialog after saving
                //         setState(() {});
                //       } catch (e) {
                //         print('Failed to decode image list: $e');
                //       }
                //     });
                //   }
                // } else {
                //   // Handle folder creation logic here
                //   Navigator.of(context).pop(); // Close the dialog after saving
                //   // Call your folder creation function here with the folder name
                // }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Menggunakan payloadNotifier untuk mendengarkan data yang diterima

    payloadNotifier = ConnectionService().payloadNotifier;
    payloadNotifier.addListener(() {
      var data = payloadNotifier.value;
      if (data != null) {
        _processReceivedData(data);
      }
    });

    _requestImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Icon(Icons.navigation, color: Colors.white, size: 32),
                  SizedBox(width: 8),
                  Text(
                    'Project S',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.tune, color: Colors.white),
                  SizedBox(width: 12),
                  Icon(Icons.settings, color: Colors.white),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search',
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),

            // List header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_upward, size: 16),
                  Spacer(),
                  Icon(Icons.grid_view, size: 20),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Folder list
            Expanded(
              child: ListView.builder(
                cacheExtent: 9999,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: folderListWidget.length,
                itemBuilder: (BuildContext context, int index) {
                  return FolderItem(
                      path: folderListWidget[index].path,
                      value: folderListWidget[index].value,
                      type: folderListWidget[index].type);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _requestImages() async {
    // Kirimkan permintaan ke server setelah callback sudah di-setup
    final message = {"type": "request", "data": "file_data"};
    await ConnectionService().sendToServer(message);
  }

  void _processReceivedData(Map<String, dynamic> data) {
    // Pastikan data yang diterima memiliki folder dan gambar
    if (data['folders'] != null) {
      for (var folder in data['folders']) {
        folderListWidget.add(FolderItem(
          path: folder['filePath'],
          value: folder['value'],
          type: 'folder',
        ));
      }
    }

    if (data['images'] != null) {
      for (var image in data['images']) {
        folderListWidget.add(FolderItem(
          path: image['filePath'],
          value: image['value'],
          type: 'image',
        ));
      }
    }

    // Update tampilan setelah data diterima
    setState(() {});
  }
}

class FolderItem extends StatelessWidget {
  final String path;
  final String value;
  final String type;

  const FolderItem(
      {super.key, required this.path, required this.value, required this.type});

  @override
  Widget build(BuildContext context) {
    return type == "folder"
        ? ListTile(
            leading: const Icon(Icons.folder, color: Colors.black),
            title: Text(p.basename(path)),
            trailing: const Icon(Icons.more_vert),
          )
        : ListTile(
            leading: Image.memory(
              base64Decode(value),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            title: Text(p.basename(path)),
            trailing: const Icon(Icons.more_vert),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: InteractiveViewer(
                    child: Image.memory(
                      base64Decode(value),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          );
  }
}
