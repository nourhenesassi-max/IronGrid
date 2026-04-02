import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import 'models/employee_models.dart';

class EmployeeRepository {
  final ApiClient _client = ApiClient();

  Future<List<EmployeeNotification>> getNotifications() async {
    final data = await _client.get(
      '/api/notifications',
      withAuth: true,
    );

    final items = data as List<dynamic>;
    return items
        .map((e) => EmployeeNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationAsRead(String id) async {
    await _client.patch(
      '/api/notifications/$id/read',
      withAuth: true,
    );
  }

  Future<void> deleteNotification(String id) async {
    await _client.delete(
      '/api/notifications/$id',
      withAuth: true,
    );
  }

  Future<List<EmployeeProject>> getAssignedProjects() async {
    final data = await _client.get(
      '/api/employee/projects',
      withAuth: true,
    );

    final items = data as List<dynamic>;
    return items
        .map((e) => EmployeeProject.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AttendanceCardData> getTodayAttendance() async {
    final data = await _client.get(
      '/api/attendance/today',
      withAuth: true,
    );

    return _mapAttendance(data as Map<String, dynamic>);
  }

  Future<void> checkIn(String line) async {
    await _client.post(
      '/api/attendance/check-in',
      withAuth: true,
      body: {
        'line': line,
      },
    );
  }

  Future<void> checkOut() async {
    await _client.post(
      '/api/attendance/check-out',
      withAuth: true,
      body: {},
    );
  }

  Future<void> endBreak() async {
    await _client.post(
      '/api/attendance/break/end',
      withAuth: true,
      body: {},
    );
  }

  Future<int> getUnreadMessagesCount() async {
    final data = await _client.get(
      '/api/messages/conversations',
      withAuth: true,
    );

    if (data is! List) return 0;

    int total = 0;

    for (final e in data) {
      if (e is! Map<String, dynamic>) continue;

      final unread = e['unreadCount'];

      if (unread is int) {
        total += unread;
      } else if (unread is String) {
        total += int.tryParse(unread) ?? 0;
      }
    }

    return total;
  }

  AttendanceCardData _mapAttendance(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString();

    return AttendanceCardData(
      status: _mapStatus(rawStatus),
      todayWorked: json['todayWorked']?.toString() ?? '0h 0m',
      weekWorked: json['weekWorked']?.toString() ?? '0h 0m',
      lastEventLabel: json['lastEvent']?.toString(),
      anomalyMessage: json['anomaly']?.toString(),
      primaryActionLabel: _getActionLabel(rawStatus),
      primaryActionIcon: _getActionIcon(rawStatus),
      canSelectLine: rawStatus != 'working' && rawStatus != 'pending',
    );
  }

  AttendanceStatus _mapStatus(String? status) {
    switch (status) {
      case 'working':
        return AttendanceStatus.working;
      case 'on_break':
        return AttendanceStatus.onBreak;
      case 'incomplete':
        return AttendanceStatus.incomplete;
      case 'pending':
        return AttendanceStatus.pendingValidation;
      case 'not_started':
      default:
        return AttendanceStatus.notStarted;
    }
  }

  String _getActionLabel(String? status) {
    switch (status) {
      case 'working':
        return 'Terminer';
      case 'on_break':
        return 'Reprendre';
      case 'incomplete':
        return 'Corriger';
      case 'pending':
        return 'En attente';
      default:
        return 'Démarrer';
    }
  }

  IconData _getActionIcon(String? status) {
    switch (status) {
      case 'working':
        return Icons.stop;
      case 'on_break':
        return Icons.play_arrow;
      case 'incomplete':
        return Icons.edit;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.play_arrow;
    }
  }
}