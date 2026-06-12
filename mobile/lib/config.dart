import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    if (kIsWeb) return 'https://music-app-backend-9ia5.onrender.com';
    // Mobile (Android + iOS)
    return 'https://music-app-backend-9ia5.onrender.com';
  }
}
