import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../services/music_service.dart';
import 'playlist_detail_screen.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});
  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final _service = MusicService();
  bool _loading = true;
  List<Playlist> _items = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _items = await _service.fetchPlaylists(); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _create() async {
    final name = await _promptText('Tạo playlist mới');
    if (name == null || name.trim().isEmpty) return;
    await _service.createPlaylist(name.trim());
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
            child: Row(children: [
              const Expanded(child: Text('Thư viện', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Color(0xFFB3B3B3))),
              IconButton(
                onPressed: _create,
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: const Color(0xFF1DB954), borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.add, color: Colors.black, size: 20),
                ),
              ),
            ]),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
                : _items.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.queue_music_rounded, size: 64, color: Color(0xFF535353)),
                        const SizedBox(height: 16),
                        const Text('Chưa có playlist nào', style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 16)),
                        const SizedBox(height: 8),
                        TextButton(onPressed: _create, child: const Text('Tạo playlist đầu tiên', style: TextStyle(color: Color(0xFF1DB954)))),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final p = _items[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            leading: Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(color: const Color(0xFF282828), borderRadius: BorderRadius.circular(6)),
                              child: const Icon(Icons.queue_music_rounded, color: Color(0xFF1DB954)),
                            ),
                            title: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            subtitle: Text('${p.songCount ?? 0} bài', style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 13)),
                            trailing: const Icon(Icons.chevron_right, color: Color(0xFF535353)),
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlistId: p.id, playlistName: p.name)));
                              await _load();
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<String?> _promptText(String title) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Tên playlist')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Color(0xFFB3B3B3)))),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Tạo')),
        ],
      ),
    );
    ctrl.dispose();
    return result;
  }
}
