import '../models/user.dart';
import 'api_client.dart';

class AuthResult {
  final String token;
  final AppUser user;
  AuthResult({required this.token, required this.user});
}

class AuthService {
  Future<AuthResult> register({required String email, required String password, required String displayName}) async {
    final json = await ApiClient.I.post('/auth/register', body: {
      'email': email,
      'password': password,
      'displayName': displayName,
    });
    return AuthResult(token: json['token'], user: AppUser.fromJson(json['user']));
  }

  Future<AuthResult> login({required String email, required String password}) async {
    final json = await ApiClient.I.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    return AuthResult(token: json['token'], user: AppUser.fromJson(json['user']));
  }

  Future<AppUser?> me() async {
    final json = await ApiClient.I.get('/me');
    if (json == null) return null;
    return AppUser.fromJson((json as Map).cast<String, dynamic>());
  }
}

