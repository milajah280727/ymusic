import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart'; // Import LineIcons

import 'providers/player_provider.dart';
import 'widgets/mini_player_widget.dart';
import 'widgets/top_navigation_chips.dart'; // Import widget yang sudah diubah
import 'screens/home_page.dart';
import 'screens/favorite_page.dart';
import 'screens/chart_page.dart';
import 'screens/search_page.dart';
import 'screens/search_result_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlayerProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Music App',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color.fromARGB(255, 28, 26, 26),
        ),
        initialRoute: '/main',
        routes: {
          '/main': (context) => const MainNavigator(),
          '/search': (context) => const SearchPage(),
          '/search_result': (context) => SearchResultPage(
            query: ModalRoute.of(context)!.settings.arguments as String,
          ),
        },
        builder: (context, child) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

          return Stack(
            children: [
              child!,
              Positioned(
                left: 0,
                right: 0,
                bottom: keyboardHeight > 0 ? keyboardHeight : 0.0,
                child: const MiniPlayerWidget(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // --- PERUBAHAN: Tambahkan data ikon ---
  static const List<String> _titles = [
    'Beranda',
    'Favorit',
    'Track Teratas',
  ];

  static const List<IconData> _icons = [
    LineIcons.home,
    LineIcons.heart,
    LineIcons.barChart,
  ];

  static const List<Widget> _pages = [
    YMusicPage(),
    FavoritePage(),
    ChartPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 28, 26, 26),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 43, 41, 41),
        title: const Text('YMusic', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- GUNAKAN WIDGET NAVIGASI IKON YANG BARU ---
          TopNavigationChips(
            titles: _titles,
            icons: _icons, // Kirim data ikon
            selectedIndex: _selectedIndex,
            onSelected: (index) => setState(() => _selectedIndex = index),
          ),
          // Konten halaman yang dipilih
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}