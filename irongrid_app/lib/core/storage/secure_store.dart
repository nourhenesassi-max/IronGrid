import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _kToken = "auth_token";
  static const String _kRole = "auth_role";

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _kToken, value: token);
  }

  static Future<String?> readToken() async {
    return await _storage.read(key: _kToken);
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: _kRole, value: role);
  }

  static Future<String?> readRole() async {
    return await _storage.read(key: _kRole);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
