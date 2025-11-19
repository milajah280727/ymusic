import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/player_provider.dart';
import '../services/download_service.dart'; // IMPORT BARU
import '../services/ytdl_service.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<Map<String, dynamic>> recentVideos = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList('recent_played');
    if (saved == null || saved.isEmpty) {
      if (mounted) setState(() => recentVideos = []);
      return;
    }

    final List<Map<String, dynamic>> loaded = [];
    for (var jsonStr in saved.reversed.take(20)) {
      final parts = jsonStr.split('|||');
      if (parts.length != 5) continue;

      loaded.add({
        'id': parts[0],
        'title': parts[1],
        'channel': parts[2],
        'duration': parts[3],
        'thumbnail': parts[4],
      });
    }
    if (mounted) setState(() => recentVideos = loaded);
  }

  void _play(String id, String title, String channel) {
    Provider.of<PlayerProvider>(context, listen: false).playMusic(
      videoId: id,
      title: title,
      channel: channel,
    );
  }

  // FUNGSI BARU UNTUK UNDUHAN
  Future<void> _download(String videoId, String title, bool isAudio) async {
    final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    final fileName = '$safeTitle.${isAudio ? 'mp3' : 'mp4'}';
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mempersiapkan unduhan...')));

    try {
      // Perlu import YTDLService jika belum ada
      final url = isAudio
          ? await YTDLService.getAudioStream(videoId)
          : await YTDLService.getVideoStream(videoId);
      
      DownloadService.downloadFile(
        url: url,
        fileName: fileName,
        // ignore: use_build_context_synchronously
        context: context,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mempersiapkan unduhan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (recentVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Belum ada lagu yang diputar',
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
      itemCount: recentVideos.length,
      itemBuilder: (context, i) {
        final v = recentVideos[i];
        return InkWell(
          onTap: () => _play(v['id'], v['title'], v['channel']),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
                    textAlign: TextAlign.center,
                  ),
                ),
                Hero(
                  tag: 'chart_${v['id']}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      v['thumbnail'],
                      width: 90,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 60,
                        color: Colors.grey[800],
                        child: const Icon(Icons.music_video, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${v['channel']} • ${v['duration']}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // --- PERUBAHAN DIMULAI DI SINI ---
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (String value) {
                    if (value == 'download_audio') {
                      _download(v['id'], v['title'], true);
                    } else if (value == 'download_video') {
                      _download(v['id'], v['title'], false);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'download_audio',
                      child: Row(
                        children: [
                          Icon(Icons.music_note, color: Colors.pink),
                          SizedBox(width: 8),
                          Text('Unduh Musik'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'download_video',
                      child: Row(
                        children: [
                          Icon(Icons.videocam, color: Colors.pink),
                          SizedBox(width: 8),
                          Text('Unduh Video'),
                        ],
                      ),
                    ),
                  ],
                ),
                // --- PERUBAHAN SELESAI DI SINI ---
              ],
            ),
          ),
        );
      },
    );
  }
}