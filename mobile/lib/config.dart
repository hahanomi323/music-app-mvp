import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    if (kIsWeb) return 'http://localhost:4000';
    // Android emulator
    if (Platform.isAndroid) return 'http://192.168.100.29:4000';
    // iOS simulator / device
    return 'http://192.168.100.29:4000';
  }
}
