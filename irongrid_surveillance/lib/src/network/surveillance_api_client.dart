import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/surveillance_api_config.dart';
import '../storage/surveillance_secure_store.dart';

class SurveillanceApiException implements Exception {
  final String message;
  final int? statusCode;

  SurveillanceApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class SurveillanceApiClient {
  static const Duration _defaultTimeout = Duration(seconds: 5);

  Future<dynamic> get(String path) async {
    final token = await SurveillanceSecureStore.readToken();
    if (token == null || token.trim().isEmpty) {
      throw SurveillanceApiException(
        'Aucune session manager disponible. Ouvre IronGrid Surveillance depuis l application principale.',
      );
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final attempts = <String>[];

    for (final baseUrl in SurveillanceApiConfig.candidateBaseUrls) {
      final uri = Uri.parse('$baseUrl$path');
      attempts.add(baseUrl);

      try {
        final response = await http
            .get(uri, headers: headers)
            .timeout(_defaultTimeout);

        if (_looksLikeWrongServer(response, path)) {
          continue;
        }

        final data = _handleResponse(response);
        SurveillanceApiConfig.setActiveBaseUrl(baseUrl);
        await SurveillanceSecureStore.saveApiBaseUrl(
          SurveillanceApiConfig.baseUrl,
        );
        return data;
      } on SocketException {
        // Try the next candidate.
      } on TimeoutException {
        // Try the next candidate.
      }
    }

    throw SurveillanceApiException(
      'Impossible de joindre le backend surveillance. Adresses testees: ${attempts.join(', ')}.',
    );
  }

  bool _looksLikeWrongServer(http.Response response, String path) {
    if (!path.startsWith('/api/')) {
      return false;
    }

    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    final body = response.body.trimLeft().toLowerCase();

    return contentType.contains('text/html') ||
        body.startsWith('<!doctype html') ||
        body.startsWith('<html') ||
        body.contains('<title>404 not found</title>') ||
        body.contains('requested url was not found');
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.trim();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) {
        return null;
      }
      return jsonDecode(body);
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw SurveillanceApiException(
        'Session manager invalide ou expiree. Reouvre la supervision depuis IronGrid.',
        statusCode: response.statusCode,
      );
    }

    var message = body;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        message = (decoded['message'] ??
                decoded['error'] ??
                decoded['details'] ??
                body)
            .toString();
      }
    } catch (_) {
      // Keep raw body.
    }

    throw SurveillanceApiException(
      'Erreur API ${response.statusCode}: $message',
      statusCode: response.statusCode,
    );
  }
}
