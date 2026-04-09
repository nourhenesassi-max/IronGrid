import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_store.dart';
import 'models/employee_profile.dart';

class MeService {
  final ApiClient _api = ApiClient();

  Future<EmployeeProfile> getMe() async {
    final data = await _api.get(
      '/api/me',
      withAuth: true,
    ) as Map<String, dynamic>;

    return EmployeeProfile.fromProfileJson(data);
  }

  Future<EmployeeProfile> updateMe({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String department,
  }) async {
    final token = await SecureStore.readToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token introuvable');
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/me'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'address': address,
        'department': department,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // si le backend renvoie un token rafraîchi, on le garde
      final refreshedToken = data['token']?.toString();
      if (refreshedToken != null && refreshedToken.isNotEmpty) {
        await SecureStore.saveToken(refreshedToken);
      }

      return EmployeeProfile.fromProfileJson(data);
    }

    throw Exception(
      'Erreur update profil (${response.statusCode}) : ${response.body}',
    );
  }

  Future<String> uploadAvatar(String filePath) async {
    final token = await SecureStore.readToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token introuvable');
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('Fichier avatar introuvable');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/api/me/avatar'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.files.add(
      await http.MultipartFile.fromPath('avatar', file.path),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data.containsKey('avatarUrl')) {
        return data['avatarUrl'].toString();
      }

      if (data.containsKey('url')) {
        return data['url'].toString();
      }

      return '';
    }

    throw Exception(
      'Erreur upload avatar (${response.statusCode}) : ${response.body}',
    );
  }
}