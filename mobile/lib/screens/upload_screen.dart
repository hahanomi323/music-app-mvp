import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/upload_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _albumCtrl = TextEditingController();

  PlatformFile? _audioFile;
  PlatformFile? _coverFile;
  bool _loading = false;
  String? _status;

  @override
  void dispose() {
    _titleCtrl.dispose(); _artistCtrl.dispose(); _albumCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true,
    );
    if (result != null) setState(() { _audioFile = result.files.first; });
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) setState(() { _coverFile = result.files.first; });
  }

  Future<void> _submit() async {
    if (_audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chọn file nhạc trước!'), backgroundColor: Colors.red));
      return;
    }
    if (_titleCtrl.text.trim().isEmpty || _artistCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nhập tên bài hát và ca sĩ!'), backgroundColor: Colors.red));
      return;
    }

    setState(() { _loading = true; _status = 'Đang upload...'; });

    try {
      await UploadService().uploadSong(
        audioBytes: _audioFile!.bytes!,
        audioFilename: _audioFile!.name,
        title: _titleCtrl.text.trim(),
        artistName: _artistCtrl.text.trim(),
        album: _albumCtrl.text.trim().isNotEmpty ? _albumCtrl.text.trim() : null,
        coverBytes: _coverFile?.bytes,
        coverFilename: _coverFile?.name,
      );

      if (mounted) {
        setState(() { _status = null; _audioFile = null; _coverFile = null; });
        _titleCtrl.clear(); _artistCtrl.clear(); _albumCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Upload thành công!'), backgroundColor: Color(0xFF1DB954)),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() { _loading = false; _status = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Upload nhạc', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Chia sẻ âm nhạc của bạn', style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 14)),
            const SizedBox(height: 28),

            // Pick audio
            GestureDetector(
              onTap: _loading ? null : _pickAudio,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF282828),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _audioFile != null ? const Color(0xFF1DB954) : const Color(0xFF535353),
                    width: 2,
                  ),
                ),
                child: Column(children: [
                  Icon(
                    _audioFile != null ? Icons.audio_file_rounded : Icons.upload_file_rounded,
                    size: 48, color: _audioFile != null ? const Color(0xFF1DB954) : const Color(0xFF535353),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _audioFile != null ? _audioFile!.name : 'Chọn file nhạc',
                    style: TextStyle(
                      color: _audioFile != null ? const Color(0xFF1DB954) : const Color(0xFFB3B3B3),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  if (_audioFile != null) ...[
                    const SizedBox(height: 4),
                    Text('${(_audioFile!.size / 1024 / 1024).toStringAsFixed(1)} MB',
                      style: const TextStyle(color: Color(0xFF535353), fontSize: 12)),
                  ],
                  const SizedBox(height: 4),
                  const Text('MP3, WAV, FLAC, AAC, M4A (tối đa 50MB)',
                    style: TextStyle(color: Color(0xFF535353), fontSize: 11)),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Pick cover
            GestureDetector(
              onTap: _loading ? null : _pickCover,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF282828),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF383838)),
                ),
                child: Row(children: [
                  _coverFile?.bytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.memory(_coverFile!.bytes!, width: 48, height: 48, fit: BoxFit.cover),
                        )
                      : Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: const Color(0xFF383838), borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.image_outlined, color: Color(0xFF535353)),
                        ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_coverFile != null ? _coverFile!.name : 'Chọn ảnh bìa (tuỳ chọn)',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Text('JPG, PNG (tối đa 5MB)', style: TextStyle(color: Color(0xFF535353), fontSize: 12)),
                  ])),
                  const Icon(Icons.chevron_right, color: Color(0xFF535353)),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            // Form fields
            _field(_titleCtrl, 'Tên bài hát *', Icons.music_note_rounded),
            const SizedBox(height: 12),
            _field(_artistCtrl, 'Ca sĩ / Nghệ sĩ *', Icons.person_rounded),
            const SizedBox(height: 12),
            _field(_albumCtrl, 'Album (tuỳ chọn)', Icons.album_rounded),
            const SizedBox(height: 32),

            // Upload button
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                        const SizedBox(width: 12),
                        Text(_status ?? 'Đang upload...', style: const TextStyle(color: Colors.black)),
                      ])
                    : const Text('UPLOAD NHẠC'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFB3B3B3)),
      ),
    );
  }
}
