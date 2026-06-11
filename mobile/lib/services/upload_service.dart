import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'api_client.dart';

class UploadService {
  Future<Map<String, dynamic>> uploadSong({
    required Uint8List audioBytes,
    required String audioFilename,
    required String title,
    required String artistName,
    String? album,
    Uint8List? coverBytes,
    String? coverFilename,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/upload/song');
    final request = http.MultipartRequest('POST', uri);

    // Auth header
    final token = ApiClient.I.currentToken;
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    // Audio file
    request.files.add(http.MultipartFile.fromBytes('audio', audioBytes, filename: audioFilename));

    // Cover (optional)
    if (coverBytes != null && coverFilename != null) {
      request.files.add(http.MultipartFile.fromBytes('cover', coverBytes, filename: coverFilename));
    }

    // Fields
    request.fields['title'] = title;
    request.fields['artistName'] = artistName;
    if (album != null) request.fields['album'] = album;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'ok': true};
    }
    throw Exception('Upload thất bại: ${response.statusCode} ${response.body}');
  }
}
