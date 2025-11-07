import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/ytdl_service.dart';
import '../providers/player_provider.dart';

class YMusicPage extends StatefulWidget {
  const YMusicPage({super.key});

  @override
  State<YMusicPage> createState() => _YMusicPageState();
}

class _YMusicPageState extends State<YMusicPage> {
  // --- QUERY UNTUK CHIP KONTEN ---
  final Map<String, String> chipQueries = {
    "Untukmu": "placeholder", // Chip khusus untuk rekomendasi
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
  String currentChip = "Untukmu"; // Default ke chip rekomendasi
  List<String> searchHistory = [];
  String? _recommendationQuery; // Untuk menyimpan query gabungan

  @override
  void initState() {
    super.initState();
    _loadHistoryAndRecommend();
  }

  Future<void> _loadHistoryAndRecommend() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('search_history') ?? [];
    setState(() => searchHistory = history.reversed.toList());
    
    // Buat query rekomendasi saat halaman dimuat
    _buildRecommendationQuery();
    _fetchVideos(); // Panggil tanpa parameter karena kita akan gunakan _recommendationQuery
  }

  // --- FUNGSI UNTUK MEMBUAT QUERY GABUNGAN DARI RIWAYAT ---
  void _buildRecommendationQuery() {
    if (searchHistory.isEmpty) {
      _recommendationQuery = "trending music in indonesia"; // Query default
    } else {
      // Ambil 5 kata kunci terakhir dan gabungkan dengan 'OR'
      final lastFiveSearches = searchHistory.take(5);
      _recommendationQuery = lastFiveSearches.map((query) => '"$query"').join(' OR ');
    }
  }

  // --- FUNGSI UTAMA UNTUK MENGAMBIL DATA VIDEO ---
  Future<void> _fetchVideos({bool loadMore = false}) async {
    String actualQuery;

    if (currentChip == "Untukmu") {
      // Gunakan query rekomendasi yang sudah dibuat
      actualQuery = _recommendationQuery ?? "trending music";
    } else {
      // Gunakan query dari chip lain
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
    Provider.of<PlayerProvider>(context, listen: false).playVideo(
      videoId: id,
      title: title,
      channel: channel,
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- TIDAK LAGI MENGGUNAKAN SCAFFOLD ---
    // Langsung kembalikan widget konten utama
    return LazyLoadScrollView(
      isLoading: isLoadingMore,
      onEndOfPage: () => _fetchVideos(loadMore: true),
      child: CustomScrollView(
        slivers: [
          // --- SLIVER UNTUK CHIP KONTEN ---
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
          
          // --- SLIVER UNTUK JUDUL HALAMAN ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                currentChip == "Untukmu" ? 'Rekomendasi untukmu' : 'Rekomendasi $currentChip',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),

          // --- SLIVER UNTUK INDIKATOR LOADING ATAU PESAN KOSONG ---
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
            // --- SLIVER UNTUK DAFTAR VIDEO ---
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final v = videos[i];
                  return InkWell(
                    onTap: () => _play(v['id'], v['title'], v['channel']),
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                          const Icon(Icons.more_vert, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
                childCount: videos.length,
              ),
            ),

          // --- SLIVER UNTUK INDIKATOR LOAD MORE ---
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