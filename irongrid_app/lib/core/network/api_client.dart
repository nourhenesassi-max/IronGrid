import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/secure_store.dart';

class ApiClient {
  Future<http.Response> post(
    String path, {
    Object? body,
    bool withAuth = false,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}$path");

    final headers = <String, String>{
      "Content-Type": "application/json",
    };

    if (withAuth) {
      final token = await SecureStore.readToken();
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    return http.post(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> get(
    String path, {
    bool withAuth = false,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}$path");

    final headers = <String, String>{};

    if (withAuth) {
      final token = await SecureStore.readToken();
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    return http.get(uri, headers: headers);
  }
}
