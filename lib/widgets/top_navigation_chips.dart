import 'package:flutter/material.dart';

class TopNavigationChips extends StatelessWidget {
  final List<String> titles;
  final List<IconData> icons; // Tambahkan parameter untuk ikon
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const TopNavigationChips({
    super.key,
    required this.titles,
    required this.icons, // Wajib diisi
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 43, 41, 41), // Warna latar AppBar
      padding: const EdgeInsets.symmetric(vertical: 8),
      height: 90, // Tambahkan tinggi untuk menampung ikon dan teks
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: titles.length,
        itemBuilder: (context, i) {
          final title = titles[i];
          final icon = icons[i];
          final selected = selectedIndex == i;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected ? Colors.pink.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: selected ? Colors.pink : Colors.grey[400],
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.pink : Colors.grey[400],
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}