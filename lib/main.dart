// lib/main.dart

import 'package:flutter/material.dart';
import 'package:music_app/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';

// Import Provider dan Widget
import 'providers/player_provider.dart';
import 'widgets/mini_player_widget.dart';
import 'widgets/top_navigation_chips.dart';

// Import Halaman
// Pastikan ini sesuai dengan nama file Anda
import 'screens/favorite_page.dart';
import 'screens/chart_page.dart';
import 'screens/search_page.dart';
import 'screens/search_result_page.dart';
import 'screens/download_page.dart'; // IMPORT BARU

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
        title: 'YMusic',
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

  static const List<String> _titles = [
    'Beranda',
    'Favorit',
    'Track Teratas',
    'Unduhan', // TAMBAHKAN INI
  ];

  static const List<IconData> _icons = [
    LineIcons.home,
    LineIcons.heart,
    LineIcons.barChart,
    LineIcons.download, // TAMBAHKAN INI
  ];

  static final List<Widget> _pages = [
    const YMusicPage(),
    const FavoritePage(),
    const ChartPage(),
    const DownloadPage(), // TAMBAHKAN INI
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        return ValueListenableBuilder(
          valueListenable: playerProvider.playerPercentageNotifier,
          builder: (context, _, __) {
            final percentage = playerProvider.playerPercentageNotifier.value;
            final shouldHideAppBar = playerProvider.isPlayerVisible && percentage > 0.95;

            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 28, 26, 26),
              appBar: shouldHideAppBar ? null : AppBar(
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
              body: Stack(
                children: [
                  Column(
                    children: [
                      TopNavigationChips(
                        titles: _titles,
                        icons: _icons,
                        selectedIndex: _selectedIndex,
                        onSelected: (index) => setState(() => _selectedIndex = index),
                      ),
                      Expanded(
                        child: _pages[_selectedIndex],
                      ),
                    ],
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: MiniPlayerWidget(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}