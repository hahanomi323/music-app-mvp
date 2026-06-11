import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../services/music_service.dart';
import '../state/auth_state.dart';
import '../state/player_state.dart';
import 'player_screen.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});
  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  final _service = MusicService();
  bool _loadingFav = true, _loadingHistory = true;
  List<Song> _favorites = [], _history = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async { await Future.wait([_loadFav(), _loadHistory()]); }
  Future<void> _loadFav() async {
    setState(() => _loadingFav = true);
    try { _favorites = await _service.fetchFavorites(); } finally { if (mounted) setState(() => _loadingFav = false); }
  }
  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try { _history = await _service.fetchHistory(); } finally { if (mounted) setState(() => _loadingHistory = false); }
  }

  Future<void> _play(List<Song> songs, int index) async {
    final player = context.read<PlayerState>();
    await player.setQueueAndPlay(songs, index);
    if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final user = auth.user;

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
              child: Row(children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF282828),
                  radius: 24,
                  child: Text((user?.displayName ?? '?')[0].toUpperCase(),
                    style: const TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user?.displayName ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(user?.email ?? '', style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 12)),
                ])),
                IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded, color: Color(0xFFB3B3B3))),
                IconButton(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFB3B3B3)),
                  tooltip: 'Đăng xuất',
                ),
              ]),
            ),
            const TabBar(
              indicatorColor: Color(0xFF1DB954),
              tabs: [Tab(text: 'Yêu thích'), Tab(text: 'Lịch sử')],
            ),
            Expanded(
              child: TabBarView(children: [
                _buildList(_loadingFav, _favorites, 'Chưa có bài yêu thích', Icons.favorite_border_rounded),
                _buildList(_loadingHistory, _history, 'Chưa có lịch sử nghe', Icons.history_rounded),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(bool loading, List<Song> songs, String empty, IconData emptyIcon) {
    if (loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)));
    if (songs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(emptyIcon, size: 56, color: const Color(0xFF535353)),
      const SizedBox(height: 12),
      Text(empty, style: const TextStyle(color: Color(0xFFB3B3B3))),
    ]));
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final s = songs[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFF282828), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.music_note_rounded, color: Color(0xFF1DB954), size: 22),
          ),
          title: Text(s.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          subtitle: Text(s.artistName, style: const TextStyle(color: Color(0xFFB3B3B3))),
          onTap: () => _play(songs, index),
        );
      },
    );
  }
}
