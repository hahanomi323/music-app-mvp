import '../models/playlist.dart';
import '../models/song.dart';
import 'api_client.dart';

class MusicService {
  Future<List<Song>> fetchSongs({String? q}) async {
    final json = await ApiClient.I.get('/songs', query: q != null && q.trim().isNotEmpty ? {'q': q.trim()} : null);
    final items = (json['items'] as List).cast<dynamic>();
    return items.map((e) => Song.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  Future<List<Song>> fetchFavorites() async {
    final json = await ApiClient.I.get('/favorites');
    final items = (json['items'] as List).cast<dynamic>();
    return items.map((e) => Song.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  Future<void> addFavorite(String songId) async {
    await ApiClient.I.post('/favorites/$songId');
  }

  Future<void> removeFavorite(String songId) async {
    await ApiClient.I.delete('/favorites/$songId');
  }

  Future<List<Playlist>> fetchPlaylists() async {
    final json = await ApiClient.I.get('/playlists');
    final items = (json['items'] as List).cast<dynamic>();
    return items.map((e) => Playlist.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  Future<Playlist> createPlaylist(String name) async {
    final json = await ApiClient.I.post('/playlists', body: {'name': name});
    return Playlist.fromJson((json as Map).cast<String, dynamic>());
  }

  Future<Playlist> renamePlaylist(String id, String name) async {
    final json = await ApiClient.I.patch('/playlists/$id', body: {'name': name});
    return Playlist.fromJson((json as Map).cast<String, dynamic>());
  }

  Future<void> deletePlaylist(String id) async {
    await ApiClient.I.delete('/playlists/$id');
  }

  Future<Playlist> fetchPlaylistDetail(String id) async {
    final json = await ApiClient.I.get('/playlists/$id');
    return Playlist.fromJson((json as Map).cast<String, dynamic>());
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await ApiClient.I.post('/playlists/$playlistId/songs/$songId');
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await ApiClient.I.delete('/playlists/$playlistId/songs/$songId');
  }

  Future<void> addHistory(String songId) async {
    await ApiClient.I.post('/history/$songId');
  }

  Future<List<Song>> fetchHistory() async {
    final json = await ApiClient.I.get('/history');
    final items = (json['items'] as List).cast<dynamic>();
    // Backend trả về: { items: [{ id, userId, songId, listenedAt, song: { ...song, artist: {...} } }] }
    return items.map((e) {
      final map = (e as Map).cast<String, dynamic>();
      final songMap = (map['song'] as Map).cast<String, dynamic>();
      return Song.fromJson(songMap);
    }).toList();
  }
}
