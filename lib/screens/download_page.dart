// lib/screens/download_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  List<FileSystemEntity> _downloadedFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    setState(() => _isLoading = true);
    try {
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        final yMusicDir = Directory('${directory.path}/YMusic');
        if (await yMusicDir.exists()) {
          final files = yMusicDir.listSync();
          setState(() {
            _downloadedFiles = files.where((file) => file.path.endsWith('.mp3') || file.path.endsWith('.mp4')).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _downloadedFiles = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading downloaded files: $e');
      setState(() => _isLoading = false);
    }
  }

  void _playLocalFile(FileSystemEntity file) {
    final filePath = file.path;
    final fileName = file.path.split('/').last;
    
    Provider.of<PlayerProvider>(context, listen: false).playLocalFile(
      filePath: filePath,
      fileName: fileName,
    );
  }

  Future<void> _deleteFile(FileSystemEntity file, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus File'),
        content: Text('Apakah Anda yakin ingin menghapus ${file.path.split('/').last}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await file.delete(recursive: false);
        setState(() {
          _downloadedFiles.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File berhasil dihapus')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.pink));
    }

    if (_downloadedFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download_done_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Belum ada file yang diunduh',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cari Lagu'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _downloadedFiles.length,
      itemBuilder: (context, index) {
        final file = _downloadedFiles[index];
        final fileName = file.path.split('/').last;
        final isVideo = fileName.endsWith('.mp4');

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[800],
            child: Icon(
              isVideo ? Icons.videocam : Icons.music_note,
              color: Colors.pink,
            ),
          ),
          title: Text(
            fileName.replaceAll('_', ' ').replaceAll('.mp3', '').replaceAll('.mp4', ''),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(isVideo ? 'Video File' : 'Audio File', style: TextStyle(color: Colors.grey[400])),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _deleteFile(file, index),
          ),
          onTap: () => _playLocalFile(file),
        );
      },
    );
  }
}