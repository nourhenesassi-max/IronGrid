import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/api_config.dart';
import '../models/manager_leave_request.dart';

class ManagerLeaveService {
  final String baseUrl = '${ApiConfig.baseUrl}/api';

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token introuvable. Veuillez vous reconnecter.');
    }

    return token;
  }

  Future<List<ManagerLeaveRequest>> getLeaveRequests({String? status}) async {
    final token = await _getToken();

    final uri = Uri.parse(
      status == null || status.isEmpty
          ? '$baseUrl/manager/leaves'
          : '$baseUrl/manager/leaves?status=$status',
    );

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    print('========== API GET ==========');
    print('URL     : $uri');
    print('HEADERS : $headers');

    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 10));

    print('STATUS  : ${response.statusCode}');
    print('BODY    : ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur chargement demandes congés (${response.statusCode}): ${response.body}',
      );
    }

    final List data = jsonDecode(response.body);

    return data.map((e) {
      return ManagerLeaveRequest(
        id: e['id'],
        employeeName: e['employeeName'] ?? e['employeeEmail'] ?? '',
        employeeTeam: '',
        leaveType: _mapLeaveType(e['type']),
        startDate: e['startDate'] ?? '',
        endDate: e['endDate'] ?? '',
        daysCount: _calculateDays(e['startDate'], e['endDate']),
        reason: e['reason'] ?? '',
        status: e['status'] ?? 'PENDING',
        managerComment: e['managerComment'],
      );
    }).toList();
  }

  Future<void> approveLeave(int id, {String? comment}) async {
    final token = await _getToken();

    final uri = Uri.parse('$baseUrl/manager/leaves/$id/approve');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    print('========== API POST ==========');
    print('URL     : $uri');
    print('HEADERS : $headers');

    final response = await http
        .post(
          uri,
          headers: headers,
          body: jsonEncode({
            'managerComment': comment,
          }),
        )
        .timeout(const Duration(seconds: 10));

    print('STATUS  : ${response.statusCode}');
    print('BODY    : ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur approbation (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> rejectLeave(int id, {String? reason}) async {
    final token = await _getToken();

    final uri = Uri.parse('$baseUrl/manager/leaves/$id/reject');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    print('========== API POST ==========');
    print('URL     : $uri');
    print('HEADERS : $headers');

    final response = await http
        .post(
          uri,
          headers: headers,
          body: jsonEncode({
            'managerComment': reason,
          }),
        )
        .timeout(const Duration(seconds: 10));

    print('STATUS  : ${response.statusCode}');
    print('BODY    : ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur refus (${response.statusCode}): ${response.body}',
      );
    }
  }

  String _mapLeaveType(String? type) {
    switch (type) {
      case 'ANNUAL':
        return 'Congé annuel';
      case 'SICK':
        return 'Maladie';
      case 'MATERNITY':
        return 'Maternité';
      case 'PATERNITY':
        return 'Paternité';
      case 'UNPAID':
        return 'Sans solde';
      default:
        return 'Autre';
    }
  }

  int _calculateDays(String? start, String? end) {
    if (start == null || end == null) return 0;

    try {
      final s = DateTime.parse(start);
      final e = DateTime.parse(end);
      return e.difference(s).inDays + 1;
    } catch (_) {
      return 0;
    }
  }
}
