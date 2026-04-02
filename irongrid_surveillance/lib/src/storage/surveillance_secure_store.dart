import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SurveillanceSecureStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'surveillance_token';
  static const String _apiBaseUrlKey = 'surveillance_api_base_url';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> readToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> saveApiBaseUrl(String value) async {
    await _storage.write(key: _apiBaseUrlKey, value: value);
  }

  static Future<String?> readApiBaseUrl() async {
    return _storage.read(key: _apiBaseUrlKey);
  }
}
