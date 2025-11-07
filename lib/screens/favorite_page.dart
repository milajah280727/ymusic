import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tidak lagi menggunakan Scaffold, langsung kembalikan body-nya
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Lagu yang kamu sukai akan muncul di sini.\n\nFITUR INI MASIH DALAM TAHAP PENGEMBANGAN DAN BELUM BISA DIGUNAKAN',
          style: TextStyle(fontSize: 18, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}