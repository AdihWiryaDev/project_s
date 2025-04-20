import 'package:flutter/material.dart';
import 'package:project_s/helper/connection_service.dart';

class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({super.key});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  @override
  void initState() {
    super.initState();
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
              child: ListView(
                children: const [
                  FolderItem(
                      title: 'Awareness ISO 27001', date: 'Oct 16, 2023'),
                  FolderItem(title: 'Foto Pre-wedding', date: 'Aug 23, 2023'),
                  FolderItem(title: 'Foto Wedding', date: 'Aug 23, 2023'),
                  FolderItem(title: 'IT Material', date: 'Oct 30, 2023'),
                  FolderItem(title: 'Video Pre-wedding', date: 'Aug 21, 2023'),
                  FolderItem(title: 'Video Wedding', date: 'Aug 23, 2023'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ConnectionService().send("get_images");
        },
        backgroundColor: Colors.purple.shade100,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class FolderItem extends StatelessWidget {
  final String title;
  final String date;

  const FolderItem({super.key, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder, color: Colors.black),
      title: Text(title),
      subtitle: Text('Modified $date'),
      trailing: const Icon(Icons.more_vert),
    );
  }
}
