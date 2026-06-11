class Song {
  final String id;
  final String title;
  final String artistName;
  final String? album;
  final String? coverUrl;
  final String audioUrl;
  final int? durationSec;

  Song({
    required this.id,
    required this.title,
    required this.artistName,
    required this.audioUrl,
    this.album,
    this.coverUrl,
    this.durationSec,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    final artist = (json['artist'] as Map?)?.cast<String, dynamic>();
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artistName: (artist?['name'] as String?) ?? 'Unknown',
      album: json['album'] as String?,
      coverUrl: json['coverUrl'] as String?,
      audioUrl: json['audioUrl'] as String,
      durationSec: json['durationSec'] as int?,
    );
  }
}

