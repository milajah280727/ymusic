// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';

// Import Provider dan Widget
import 'providers/player_provider.dart';
import 'widgets/mini_player_widget.dart';
import 'widgets/top_navigation_chips.dart';

// Import Halaman
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
  ];

  static const List<IconData> _icons = [
    LineIcons.home,
    LineIcons.heart,
    LineIcons.barChart,
  ];

  static final List<Widget> _pages = [
    const YMusicPage(),
    const FavoritePage(),
    const ChartPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        // Gunakan ValueListenableBuilder untuk mendengarkan perubahan persentase player
        return ValueListenableBuilder(
          valueListenable: playerProvider.playerPercentageNotifier,
          builder: (context, _, __) {
            // Ambil nilai persentase dari notifier
            final percentage = playerProvider.playerPercentageNotifier.value;
            
            // --- PERUBAHAN: SEMBUNYIKAN APPBAR SAAT PLAYER HAMPIR MAKSIMALKAN ---
            // Player dianggap maksimal jika persentasenya mendekati 1.0 (misalnya > 0.95)
            // Ini akan menyembunyikan AppBar hanya saat player hampir penuh
            final shouldHideAppBar = playerProvider.isPlayerVisible && percentage > 0.10;

            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 28, 26, 26),
              
              body: Stack(
                children: [
                  // Konten utama (Tab Navigasi dan Halaman)
                  Column(
                    children: [
                      TopNavigationChips(
                        titles: _titles,
                        icons: _icons,
                        selectedIndex: _selectedIndex,
                        onSelected: (index) => setState(() => _selectedIndex = index),
                      ),
                      // Konten halaman yang dipilih
                      Expanded(
                        child: _pages[_selectedIndex],
                      ),
                    ],
                  ),
                  // MiniPlayerWidget yang melayang di atas konten utama
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