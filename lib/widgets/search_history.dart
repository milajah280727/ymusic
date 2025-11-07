import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryWidget extends StatefulWidget {
  final Function(String) onSearch;
  const SearchHistoryWidget({super.key, required this.onSearch});

  @override
  State<SearchHistoryWidget> createState() => _SearchHistoryWidgetState();
}

class _SearchHistoryWidgetState extends State<SearchHistoryWidget> {
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _addHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    history.remove(query);
    history.insert(0, query);
    if (history.length > 20) history = history.sublist(0, 20);
    await prefs.setStringList('search_history', history);
    setState(() {});
  }

  // METHOD YANG DIPANGGIL DARI SEARCH PAGE
  void addSearch(String query) => _addHistory(query);

  Future<void> _removeHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    history.remove(query);
    await prefs.setStringList('search_history', history);
    setState(() {});
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    setState(() => history.clear());
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Belum ada riwayat', style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(onPressed: _clearAll, child: const Text('Hapus Semua')),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          itemBuilder: (context, i) {
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(history[i]),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => _removeHistory(history[i]),
              ),
              onTap: () {
                widget.onSearch(history[i]);
                _addHistory(history[i]);
              },
            );
          },
        ),
      ],
    );
  }
}