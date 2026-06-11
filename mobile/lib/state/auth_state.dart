import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AuthState extends ChangeNotifier {
  static const _kTokenKey = 'token';

  final _auth = AuthService();

  bool isLoading = true;
  String? token;
  AppUser? user;

  bool get isLoggedIn => token != null && user != null;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_kTokenKey);
    ApiClient.I.setToken(token);

    if (token != null) {
      try {
        user = await _auth.me();
      } catch (_) {
        token = null;
        user = null;
        ApiClient.I.setToken(null);
        await prefs.remove(_kTokenKey);
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final result = await _auth.login(email: email, password: password);
    token = result.token;
    user = result.user;
    ApiClient.I.setToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token!);
    notifyListeners();
  }

  Future<void> register(String email, String password, String displayName) async {
    final result = await _auth.register(email: email, password: password, displayName: displayName);
    token = result.token;
    user = result.user;
    ApiClient.I.setToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token!);
    notifyListeners();
  }

  Future<void> logout() async {
    token = null;
    user = null;
    ApiClient.I.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    notifyListeners();
  }
}

