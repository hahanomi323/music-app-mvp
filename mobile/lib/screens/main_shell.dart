import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'playlists_screen.dart';
import 'upload_screen.dart';
import 'me_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _pages = const [HomeScreen(), PlaylistsScreen(), UploadScreen(), MeScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF282828), width: 1))),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (v) => setState(() => _index = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.queue_music_outlined), selectedIcon: Icon(Icons.queue_music_rounded), label: 'Thư viện'),
            NavigationDestination(icon: Icon(Icons.upload_outlined), selectedIcon: Icon(Icons.upload_rounded), label: 'Upload'),
            NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Tôi'),
          ],
        ),
      ),
    );
  }
}
