import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:provider/provider.dart';
import '../services/ytdl_service.dart';
import '../providers/player_provider.dart';
import '../services/download_service.dart'; // IMPORT BARU

class SearchResultPage extends StatefulWidget {
  final String query;
  const SearchResultPage({super.key, required this.query});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  List<Map<String, dynamic>> results = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  int page = 1;

  @override
  void initState() {
    super.initState();
    _search(widget.query);
  }

  Future<void> _search(String query, {bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        results.clear();
        page = 1;
        isLoading = true;
      });
    } else {
      setState(() => isLoadingMore = true);
    }

    final data = await YTDLService.search(query);
    if (!mounted) return;

    setState(() {
      if (loadMore) {
        results.addAll(data);
      } else {
        results = data;
      }
      isLoading = false;
      isLoadingMore = false;
      page++;
    });
  }

  // FUNGSI BARU UNTUK UNDUHAN
  Future<void> _download(String videoId, String title, bool isAudio) async {
    final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    final fileName = '${safeTitle}.${isAudio ? 'mp3' : 'mp4'}';
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mempersiapkan unduhan...')));

    try {
      final url = isAudio
          ? await YTDLService.getAudioStream(videoId)
          : await YTDLService.getVideoStream(videoId);
      
      DownloadService.downloadFile(
        url: url,
        fileName: fileName,
        context: context,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mempersiapkan unduhan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 28, 26, 26),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 43, 41, 41),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(
              context,
              '/search',
              arguments: widget.query,
            );
          },
          child: Text(
            widget.query,
            style: const TextStyle(
              fontSize: 16,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white70,
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: LazyLoadScrollView(
        isLoading: isLoadingMore,
        onEndOfPage: () => _search(widget.query, loadMore: true),
        child: ListView.builder(
          itemCount: results.length + (isLoading ? 1 : 0),
          itemBuilder: (context, i) {
            if (i == results.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(color: Colors.pink)),
              );
            }

            final v = results[i];
            return InkWell(
              onTap: () {
                Provider.of<PlayerProvider>(context, listen: false).playMusic(
                  videoId: v['id'],
                  title: v['title'],
                  channel: v['channel'],
                );
              },
              splashColor: Colors.pink.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Hero(
                      tag: v['id'],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          v['thumbnail'],
                          width: 90,
                          height: 60,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, loading) => loading == null
                              ? child
                              : Container(
                                  width: 90,
                                  height: 60,
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v['title'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          Text('${v['channel']} • ${v['duration']}',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
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
        ),
      ),
    );
  }
}