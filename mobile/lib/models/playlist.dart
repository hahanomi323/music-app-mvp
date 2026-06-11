import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final int? songCount;
  final List<Song>? songs;

  Playlist({required this.id, required this.name, this.songCount, this.songs});

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      songCount: (json['_count'] as Map?)?['songs'] as int?,
      songs: (json['songs'] is List)
          ? (json['songs'] as List).map((e) => Song.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }
}

