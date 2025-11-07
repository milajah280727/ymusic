import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/search_history.dart';
import 'search_result_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _historyKey = GlobalKey();

  /// Simpan hasil pencarian terakhir agar bisa muncul di halaman utama (chip "Semua")
  Future<void> _saveSearchedVideos(List<Map<String, dynamic>> results) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encoded = results.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList('searched_videos', encoded);
  }

  /// Navigasi ke halaman hasil pencarian
  void _goToResult(String query) async {
    if (query.trim().isEmpty) return;

    // buka halaman hasil pencarian dan tunggu hasilnya kembali
    final results = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultPage(query: query),
      ),
    );

    // simpan history keyword
    (_historyKey.currentState as dynamic)?.addSearch(query);

    // kalau SearchResultPage mengembalikan hasil pencarian, simpan ke local
    if (results != null && results.isNotEmpty) {
      await _saveSearchedVideos(results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 28, 26, 26),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 43, 41, 41),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Cari lagu, artis, atau video...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onSubmitted: _goToResult,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _goToResult(_controller.text),
          ),
        ],
      ),
      body: SearchHistoryWidget(
        key: _historyKey,
        onSearch: _goToResult,
      ),
    );
  }
}
