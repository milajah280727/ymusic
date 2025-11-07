import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:provider/provider.dart';
import '../services/ytdl_service.dart';
import '../providers/player_provider.dart';

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
        // --- PERUBAHAN: Buat judul dapat diklik ---
        title: GestureDetector(
          onTap: () {
            // Kembali ke halaman pencarian dan bawa query saat ini
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
              // Tambahkan garis bawah untuk menunjukkan bahwa ini adalah link
              decoration: TextDecoration.underline,
              decorationColor: Colors.white70,
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => Navigator.pop(context)),
        ],
      ),
      // --- KEMBALIKAN KE STRUKTUR AWAL ---
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
                Provider.of<PlayerProvider>(context, listen: false).playVideo(
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
                    const Icon(Icons.more_vert, color: Colors.grey),
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