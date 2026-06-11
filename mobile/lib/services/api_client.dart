import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();
  static final ApiClient I = ApiClient._();

  String? _token;
  String? get currentToken => _token;

  void setToken(String? token) { _token = token; }

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${AppConfig.apiBaseUrl}$path').replace(queryParameters: query);

  Map<String, String> _headers() {
    final headers = <String, String>{'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (_token != null) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers());
    return _handle(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await http.post(_uri(path), headers: _headers(), body: jsonEncode(body ?? {}));
    return _handle(res);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final res = await http.patch(_uri(path), headers: _headers(), body: jsonEncode(body ?? {}));
    return _handle(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(_uri(path), headers: _headers());
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    dynamic json;
    try { json = res.body.isNotEmpty ? jsonDecode(res.body) : null; } catch (_) { json = null; }
    if (res.statusCode >= 200 && res.statusCode < 300) return json;
    final msg = (json is Map && json['message'] is String) ? json['message'] as String : 'Lỗi API';
    throw ApiException(res.statusCode, msg);
  }
}
