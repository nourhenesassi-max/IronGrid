import 'dart:convert';
import '../../../core/network/api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<String> login({
    required String role,
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      "/api/auth/login", // ✅ corrigé
      body: {
        "role": role,
        "email": email,
        "password": password,
      },
    );

    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data["token"] as String?;
      if (token == null || token.isEmpty) {
        throw Exception("Token manquant dans la réponse backend");
      }
      return token;
    }

    throw Exception("Login échoué (${res.statusCode}): ${res.body}");
  }

  Future<void> signup({
    required String role,
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      "/api/auth/signup", // ✅ corrigé
      body: {
        "role": role,
        "name": name,
        "email": email,
        "password": password,
      },
    );

    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    if (res.statusCode == 200 || res.statusCode == 201) {
      return;
    }

    throw Exception("SignUp échoué (${res.statusCode}): ${res.body}");
  }
}
