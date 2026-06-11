import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/music_service.dart';
import '../state/player_state.dart';
import 'player_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  final String playlistName;
  const PlaylistDetailScreen({super.key, required this.playlistId, required this.playlistName});
  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final _service = MusicService();
  bool _loading = true;
  String _name = '';
  List<Song> _songs = [];

  @override
  void initState() { super.initState(); _name = widget.playlistName; _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { final p = await _service.fetchPlaylistDetail(widget.playlistId); _name = p.name; _songs = p.songs ?? []; }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _rename() async {
    final ctrl = TextEditingController(text: _name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Đổi tên', style: TextStyle(color: Colors.white)),
        content: TextField(controller: ctrl, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Color(0xFFB3B3B3)))),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Lưu')),
        ],
      ),
    );
    ctrl.dispose();
    if (name == null || name.trim().isEmpty) return;
    await _service.renamePlaylist(widget.playlistId, name.trim());
    await _load();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text('Xóa playlist?', style: TextStyle(color: Colors.white)),
        content: Text('Xóa "$_name"?', style: const TextStyle(color: Color(0xFFB3B3B3))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy', style: TextStyle(color: Color(0xFFB3B3B3)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _service.deletePlaylist(widget.playlistId);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_name),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
          IconButton(onPressed: _rename, icon: const Icon(Icons.edit_rounded)),
          IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : _songs.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.music_off_rounded, size: 64, color: Color(0xFF535353)),
                  SizedBox(height: 16),
                  Text('Playlist trống', style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Mở bài hát → bấm "Thêm vào playlist"', style: TextStyle(color: Color(0xFF535353), fontSize: 13)),
                ]))
              : ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: const Color(0xFF282828), borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.music_note_rounded, color: Color(0xFF1DB954), size: 22),
                      ),
                      title: Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: Text(song.artistName, style: const TextStyle(color: Color(0xFFB3B3B3))),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFF535353)),
                        onPressed: () async { await _service.removeSongFromPlaylist(widget.playlistId, song.id); await _load(); },
                      ),
                      onTap: () async {
                        final player = context.read<PlayerState>();
                        await player.setQueueAndPlay(_songs, index);
                        if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
                      },
                    );
                  },
                ),
    );
  }
}
