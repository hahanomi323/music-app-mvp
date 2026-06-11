import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/music_service.dart';
import '../state/auth_state.dart';
import '../state/player_state.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = MusicService();
  final _search = TextEditingController();
  bool _loading = true;
  List<Song> _songs = [];

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load([String? q]) async {
    setState(() => _loading = true);
    try { _songs = await _service.fetchSongs(q: q); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final hello = auth.user?.displayName ?? 'User';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Xin chào,', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                    Text(hello, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  ],
                )),
                IconButton(
                  onPressed: () => _load(_search.text),
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1DB954)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm bài hát, ca sĩ...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFB3B3B3)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF1DB954)),
                  onPressed: () => _load(_search.text),
                ),
              ),
              onSubmitted: _load,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Tất cả bài hát', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      return _SongTile(song: song, onTap: () async {
                        final player = context.read<PlayerState>();
                        await player.setQueueAndPlay(_songs, index);
                        if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  const _SongTile({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 52, height: 52,
                child: song.coverUrl == null
                    ? Container(color: const Color(0xFF282828), child: const Icon(Icons.music_note_rounded, color: Color(0xFF1DB954), size: 28))
                    : CachedNetworkImage(imageUrl: song.coverUrl!, fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: const Color(0xFF282828)),
                        errorWidget: (_, __, ___) => Container(color: const Color(0xFF282828), child: const Icon(Icons.music_note_rounded, color: Color(0xFF1DB954)))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(song.artistName, style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.more_vert_rounded, color: Color(0xFF535353), size: 20),
          ],
        ),
      ),
    );
  }
}
