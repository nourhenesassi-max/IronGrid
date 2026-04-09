// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/secure_store.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static const Duration _defaultTimeout = Duration(seconds: 5);
  static const Duration _multipartTimeout = Duration(seconds: 15);

  Future<Map<String, String>> _headers({required bool withAuth}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (withAuth) {
      final token = await SecureStore.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(
    String path, {
    bool withAuth = true,
  }) async {
    return _requestJson(
      'GET',
      path,
      withAuth: withAuth,
    );
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    bool withAuth = true,
  }) async {
    return _requestJson(
      'POST',
      path,
      withAuth: withAuth,
      body: body,
    );
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    bool withAuth = true,
  }) async {
    return _requestJson(
      'PUT',
      path,
      withAuth: withAuth,
      body: body,
    );
  }

  Future<dynamic> patch(
    String path, {
    Object? body,
    bool withAuth = true,
  }) async {
    return _requestJson(
      'PATCH',
      path,
      withAuth: withAuth,
      body: body,
    );
  }

  Future<dynamic> delete(
    String path, {
    Object? body,
    bool withAuth = true,
  }) async {
    return _requestJson(
      'DELETE',
      path,
      withAuth: withAuth,
      body: body,
    );
  }

  Future<dynamic> _requestJson(
    String method,
    String path, {
    Object? body,
    required bool withAuth,
  }) async {
    final headers = await _headers(withAuth: withAuth);
    final encodedBody = body == null ? null : jsonEncode(body);
    final attempts = <String>[];

    for (final baseUrl in ApiConfig.candidateBaseUrls) {
      final uri = Uri.parse('$baseUrl$path');
      attempts.add(baseUrl);

      print('========== API $method ==========');
      print('URL     : $uri');
      print('HEADERS : $headers');
      if (encodedBody != null) {
        print('BODY    : $encodedBody');
      }

      try {
        late final http.Response response;

        switch (method) {
          case 'GET':
            response = await http
                .get(uri, headers: headers)
                .timeout(_defaultTimeout);
            break;
          case 'POST':
            response = await http
                .post(uri, headers: headers, body: encodedBody)
                .timeout(_defaultTimeout);
            break;
          case 'PUT':
            response = await http
                .put(uri, headers: headers, body: encodedBody)
                .timeout(_defaultTimeout);
            break;
          case 'PATCH':
            response = await http
                .patch(uri, headers: headers, body: encodedBody)
                .timeout(_defaultTimeout);
            break;
          case 'DELETE':
            response = await http
                .delete(uri, headers: headers, body: encodedBody)
                .timeout(_defaultTimeout);
            break;
          default:
            throw Exception('Méthode HTTP non supportée: $method');
        }

        print('STATUS  : ${response.statusCode}');
        print('BODY    : ${response.body}');

        if (_looksLikeWrongServer(response, path)) {
          print('SKIP BASE URL: $baseUrl returned HTML instead of API JSON');
          continue;
        }

        final data = _handleResponse(response);
        await _rememberWorkingBaseUrl(baseUrl);
        return data;
      } on ApiException {
        rethrow;
      } on SocketException catch (e) {
        print('SOCKET ERROR $method: $e');
      } on TimeoutException catch (e) {
        print('TIMEOUT $method: $e');
      } catch (e, st) {
        print('$method ERROR: $e');
        print(st);
        throw Exception('Erreur $method: $e');
      }
    }

    throw ApiException(_networkFailureMessage(attempts));
  }

  Future<http.StreamedResponse> multipartPost(
    String path, {
    required Map<String, String> fields,
    File? file,
    String fileFieldName = 'receipt',
    bool withAuth = true,
  }) async {
    final attempts = <String>[];

    for (final baseUrl in ApiConfig.candidateBaseUrls) {
      final uri = Uri.parse('$baseUrl$path');
      final req = http.MultipartRequest('POST', uri);
      attempts.add(baseUrl);

      req.fields.addAll(fields);

      if (withAuth) {
        final token = await SecureStore.readToken();
        if (token != null && token.isNotEmpty) {
          req.headers['Authorization'] = 'Bearer $token';
        }
      }

      if (file != null) {
        req.files.add(
          await http.MultipartFile.fromPath(fileFieldName, file.path),
        );
      }

      print('====== API MULTIPART POST ======');
      print('URL     : $uri');
      print('FIELDS  : $fields');
      print('HEADERS : ${req.headers}');

      try {
        final response = await req.send().timeout(_multipartTimeout);
        print('STATUS  : ${response.statusCode}');
        await _rememberWorkingBaseUrl(baseUrl);
        return response;
      } on SocketException catch (e) {
        print('SOCKET ERROR MULTIPART: $e');
      } on TimeoutException catch (e) {
        print('TIMEOUT MULTIPART: $e');
      } catch (e, st) {
        print('MULTIPART ERROR: $e');
        print(st);
        throw Exception('Erreur multipart POST: $e');
      }
    }

    throw ApiException(_networkFailureMessage(attempts));
  }

  Future<void> _rememberWorkingBaseUrl(String baseUrl) async {
    ApiConfig.setActiveBaseUrl(baseUrl);
    await SecureStore.saveApiBaseUrl(ApiConfig.baseUrl);
  }

  String _networkFailureMessage(List<String> attempts) {
    final testedUrls = attempts.join(', ');
    return 'Impossible de joindre le serveur. Adresses testées: $testedUrls. '
        'Si tu testes par USB, active adb reverse tcp:8081 tcp:8081.';
  }

  bool _looksLikeWrongServer(http.Response response, String path) {
    if (!path.startsWith('/api/')) return false;

    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    final body = response.body.trimLeft().toLowerCase();
    final looksLikeHtml = contentType.contains('text/html') ||
        body.startsWith('<!doctype html') ||
        body.startsWith('<html') ||
        body.contains('<title>404 not found</title>') ||
        body.contains('requested url was not found');

    return looksLikeHtml;
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.trim();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return null;

      try {
        return jsonDecode(body);
      } catch (_) {
        return body;
      }
    }

    print('API ERROR STATUS: ${response.statusCode}');
    print('API ERROR BODY  : $body');

    var message = body;

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        message = (decoded['message'] ??
                decoded['error'] ??
                decoded['details'] ??
                decoded['path'] ??
                body)
            .toString();
      }
    } catch (_) {
      // Keep raw body.
    }

    throw ApiException(
      'Erreur API ${response.statusCode}: $message',
      statusCode: response.statusCode,
    );
  }
}
