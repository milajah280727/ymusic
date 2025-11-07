import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.red),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo bisa diganti nanti
                Text('YT', style: TextStyle(fontSize: 40, color: Colors.white)),
                SizedBox(height: 10),
                Text('YouTube Clone', style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),

          _menuItem(Icons.home, 'Beranda', context),
          _menuItem(Icons.explore, 'Jelajah', context),
          _menuItem(Icons.subscriptions, 'Langganan', context),
          const Divider(),
          _menuItem(Icons.settings, 'Pengaturan', context),
          _menuItem(Icons.help, 'Bantuan', context),
        ],
      ),
      
    );
  }

  // Fungsi bantu biar kode drawer lebih rapi
  Widget _menuItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.pop(context), // Tutup drawer
    );
  }
}