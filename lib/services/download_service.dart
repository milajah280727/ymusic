// lib/services/download_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart'; // Tidak lagi diperlukan untuk pendekatan ini

class DownloadService {
  static final Dio _dio = Dio();

  static Future<void> downloadFile({
    required String url,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      // 1. Dapatkan direktori Downloads menggunakan API modern
      // Ini akan memicu dialog izin sistem jika diperlukan (di Android 10+)
      Directory? downloadsDirectory = await getDownloadsDirectory();

      if (downloadsDirectory == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat mengakses folder Download.')),
          );
        }
        return;
      }

      // Buat sub-folder 'YMusic' di dalam folder Download
      final yMusicDirectory = Directory('${downloadsDirectory.path}/YMusic');
      if (!await yMusicDirectory.exists()) {
        await yMusicDirectory.create(recursive: true);
      }
      
      final savePath = '${yMusicDirectory.path}/$fileName';

      // 2. Tampilkan notifikasi bahwa proses unduhan dimulai
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                SizedBox(width: 20),
                Text('Mengunduh...'),
              ],
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }

      // 3. Mulai unduhan dengan Dio
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            int progress = ((received / total) * 100).toInt();
            print('Progress: $progress%');
          }
        },
      );

      // 4. Tampilkan notifikasi sukses
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil! File disimpan di folder Download/YMusic')),
        );
      }
    } catch (e) {
      // 5. Tangani error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh: $e')),
        );
      }
    }
  }
}