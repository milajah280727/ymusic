import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/ytdl_service.dart';
import '../providers/player_provider.dart';
import '../services/download_service.dart'; // IMPORT BARU

class YMusicPage extends StatefulWidget {
  const YMusicPage({super.key});

  @override
  State<YMusicPage> createState() => _YMusicPageState();
}

class _YMusicPageState extends State<YMusicPage> {
  // --- QUERY UNTUK CHIP KONTEN ---
  final Map<String, String> chipQueries = {
    "Untukmu": "placeholder",
    "Musik": "music",
    "Lofi": "lofi girl",
    "Gaming": "gaming music",
    "Chill": "chill vibes",
    "Pop": "pop music 2025",
  };

  List<Map<String, dynamic>> videos = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  int page = 1;
  String currentChip = "Untukmu";
  List<String> searchHistory = [];
  String? _recommendationQuery;

  @override
  void initState() {
    super.initState();
    _loadHistoryAndRecommend();
  }

  Future<void> _loadHistoryAndRecommend() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('search_history') ?? [];
    setState(() => searchHistory = history.reversed.toList());
    
    _buildRecommendationQuery();
    _fetchVideos();
  }

  void _buildRecommendationQuery() {
    if (searchHistory.isEmpty) {
      _recommendationQuery = "trending music in indonesia";
    } else {
      final lastFiveSearches = searchHistory.take(5);
      _recommendationQuery = lastFiveSearches.map((query) => '"$query"').join(' OR ');
    }
  }

  Future<void> _fetchVideos({bool loadMore = false}) async {
    String actualQuery;

    if (currentChip == "Untukmu") {
      actualQuery = _recommendationQuery ?? "trending music";
    } else {
      actualQuery = chipQueries[currentChip]!;
    }

    if (!loadMore) {
      setState(() {
        videos.clear();
        page = 1;
        isLoading = true;
      });
    } else {
      setState(() => isLoadingMore = true);
    }

    final data = await YTDLService.search('$actualQuery page $page');
    if (!mounted) return;

    setState(() {
      if (loadMore) {
        videos.addAll(data);
      } else {
        videos = data;
      }
      isLoading = false;
      isLoadingMore = false;
      page++;
    });
  }

  void _onChipTap(String chip) {
    if (currentChip == chip) return;
    setState(() => currentChip = chip);
    _fetchVideos();
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
    return LazyLoadScrollView(
      isLoading: isLoadingMore,
      onEndOfPage: () => _fetchVideos(loadMore: true),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: chipQueries.keys.length,
                itemBuilder: (context, i) {
                  final chip = chipQueries.keys.elementAt(i);
                  final selected = currentChip == chip;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _onChipTap(chip),
                      child: Chip(
                        backgroundColor: selected ? Colors.pink : Colors.grey[800],
                        label: Text(
                          chip,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.grey[300],
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: selected ? Colors.pink : Colors.transparent),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                currentChip == "Untukmu" ? 'Rekomendasi untukmu' : 'Rekomendasi $currentChip',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),

          if (isLoading)
            const SliverToBoxAdapter(
              child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.pink))),
            )
          else if (videos.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.music_off, size: 80, color: Colors.grey),
                    Text('Tidak ada video', style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                      onPressed: () => _fetchVideos(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          else
            Consumer<PlayerProvider>(
              builder: (context, playerProvider, child) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final v = videos[i];
                      return InkWell(
                        onTap: () {
                          if (playerProvider.isAudioServiceReady) {
                            _play(v['id'], v['title'], v['channel']);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pemutar musik sedang disiapkan...')),
                            );
                          }
                        },
                        child: Opacity(
                          opacity: playerProvider.isAudioServiceReady ? 1.0 : 0.5,
                          child: IgnorePointer(
                            ignoring: !playerProvider.isAudioServiceReady,
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
                          ),
                        ),
                      );
                    },
                    childCount: videos.length,
                  ),
                );
              },
            ),

          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(color: Colors.pink)),
              ),
            ),
        ],
      ),
    );
  }
}