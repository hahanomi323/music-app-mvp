import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/music_service.dart';
import '../state/player_state.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _service = MusicService();
  bool _favLoading = false;
  bool _isFav = false;

  @override
  void didChangeDependencies() { super.didChangeDependencies(); _loadFav(); }

  Future<void> _loadFav() async {
    final songId = context.read<PlayerState>().currentSong?.id;
    if (songId == null) return;
    try {
      final favs = await _service.fetchFavorites();
      if (!mounted) return;
      setState(() => _isFav = favs.any((s) => s.id == songId));
    } catch (_) {}
  }

  Future<void> _toggleFav(Song song) async {
    if (_favLoading) return;
    setState(() => _favLoading = true);
    try {
      if (_isFav) { await _service.removeFavorite(song.id); if (mounted) setState(() => _isFav = false); }
      else { await _service.addFavorite(song.id); if (mounted) setState(() => _isFav = true); }
    } finally { if (mounted) setState(() => _favLoading = false); }
  }

  Future<void> _addToPlaylist(Song song) async {
    final playlists = await _service.fetchPlaylists();
    if (!mounted) return;
    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chưa có playlist. Tạo ở tab Playlist nhé.')));
      return;
    }
    final picked = await showModalBottomSheet<Playlist>(
      context: context,
      backgroundColor: const Color(0xFF282828),
      showDragHandle: true,
      builder: (context) => ListView(children: [
        const Padding(padding: EdgeInsets.all(16), child: Text('Thêm vào playlist', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
        ...playlists.map((p) => ListTile(
          leading: const Icon(Icons.queue_music_rounded, color: Color(0xFF1DB954)),
          title: Text(p.name, style: const TextStyle(color: Colors.white)),
          subtitle: p.songCount != null ? Text('${p.songCount} bài', style: const TextStyle(color: Color(0xFFB3B3B3))) : null,
          onTap: () => Navigator.of(context).pop(p),
        )),
      ]),
    );
    if (picked == null) return;
    await _service.addSongToPlaylist(picked.id, song.id);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm vào "${picked.name}"'), backgroundColor: const Color(0xFF1DB954)));
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerState>();
    final song = player.currentSong;
    if (song == null) return const Scaffold(body: Center(child: Text('Chưa chọn bài hát')));

    final duration = player.duration ?? Duration.zero;
    final pos = player.position;
    final maxMs = duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
    final posMs = pos.inMilliseconds.toDouble().clamp(0.0, maxMs);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1a3a2a), Color(0xFF121212)],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(children: [
                  IconButton(icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  const Expanded(child: Text('ĐANG PHÁT', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2))),
                  const SizedBox(width: 48),
                ]),
              ),
              const SizedBox(height: 24),
              // Cover art
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: song.coverUrl == null
                        ? Container(color: const Color(0xFF282828), child: const Icon(Icons.music_note_rounded, size: 80, color: Color(0xFF1DB954)))
                        : CachedNetworkImage(imageUrl: song.coverUrl!, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Song info + fav
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(song.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(song.artistName, style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 15)),
                  ])),
                  IconButton(
                    onPressed: _favLoading ? null : () => _toggleFav(song),
                    icon: Icon(_isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: _isFav ? const Color(0xFF1DB954) : const Color(0xFFB3B3B3), size: 28),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              // Slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  Slider(value: posMs, min: 0, max: maxMs, onChanged: (v) => player.seek(Duration(milliseconds: v.toInt()))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(_fmt(pos), style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 12)),
                      Text(_fmt(duration), style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 12)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              // Controls
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                IconButton(iconSize: 36, onPressed: player.prev, icon: const Icon(Icons.skip_previous_rounded, color: Colors.white)),
                GestureDetector(
                  onTap: player.togglePlay,
                  child: Container(
                    width: 64, height: 64,
                    decoration: const BoxDecoration(color: Color(0xFF1DB954), shape: BoxShape.circle),
                    child: Icon(player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black, size: 36),
                  ),
                ),
                IconButton(iconSize: 36, onPressed: player.next, icon: const Icon(Icons.skip_next_rounded, color: Colors.white)),
              ]),
              const SizedBox(height: 24),
              // Add to playlist
              TextButton.icon(
                onPressed: () => _addToPlaylist(song),
                icon: const Icon(Icons.playlist_add_rounded, color: Color(0xFFB3B3B3)),
                label: const Text('Thêm vào playlist', style: TextStyle(color: Color(0xFFB3B3B3))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}
