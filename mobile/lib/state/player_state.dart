import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/music_service.dart';

class PlayerState extends ChangeNotifier {
  final _service = MusicService();
  final AudioPlayer _player = AudioPlayer();

  List<Song> _queue = [];
  int _index = -1;
  bool _isReady = false;

  bool get isReady => _isReady;
  bool get isPlaying => _player.playing;
  Song? get currentSong => (_index >= 0 && _index < _queue.length) ? _queue[_index] : null;

  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  PlayerState() {
    _init();
    _player.playerStateStream.listen((_) => notifyListeners());
    _player.positionStream.listen((_) => notifyListeners());
    _player.durationStream.listen((_) => notifyListeners());
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _isReady = true;
    notifyListeners();
  }

  Future<void> setQueueAndPlay(List<Song> songs, int index) async {
    _queue = songs;
    _index = index.clamp(0, songs.length - 1);
    await _loadCurrent();
    await play();
  }

  Future<void> _loadCurrent() async {
    final song = currentSong;
    if (song == null) return;
    await _player.setUrl(song.audioUrl);
    // fire-and-forget history
    _service.addHistory(song.id).catchError((_) {});
    notifyListeners();
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> togglePlay() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    _index = (_index + 1) % _queue.length;
    await _loadCurrent();
    await play();
  }

  Future<void> prev() async {
    if (_queue.isEmpty) return;
    _index = (_index - 1);
    if (_index < 0) _index = _queue.length - 1;
    await _loadCurrent();
    await play();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
    super.dispose();
  }
}

