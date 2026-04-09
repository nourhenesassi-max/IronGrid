import '../../../../core/network/api_client.dart';
import '../models/employee_model.dart';
import '../models/manager_project_model.dart';
import '../models/notification_model.dart';

class ManagerApiService {
  final ApiClient _client = ApiClient();

  Future<List<EmployeeModel>> getEmployees() async {
    try {
      final data = await _client.get(
        '/api/users/employees',
        withAuth: true,
      ) as List<dynamic>;

      return data
          .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur chargement employés: $e');
    }
  }

  Future<void> removeEmployeeFromTeam(int employeeId) async {
    try {
      await _client.delete(
        '/api/users/employees/$employeeId/team',
        withAuth: true,
      );
    } catch (e) {
      throw Exception('Erreur suppression employé $employeeId: $e');
    }
  }

  Future<void> assignProject({
    required String projectName,
    required int employeeId,
    required String deadline,
    required String priority,
    required List<Map<String, dynamic>> tasks,
    String description = '',
  }) async {
    try {
      await _client.post(
        '/api/manager/projects',
        withAuth: true,
        body: {
          'projectName': projectName,
          'employeeId': employeeId,
          'deadline': deadline,
          'priority': priority,
          'description': description,
          'tasks': tasks,
        },
      );
    } catch (e) {
      throw Exception('Erreur assignation projet: $e');
    }
  }

  Future<void> updateProject({
    required int projectId,
    required String projectName,
    required int employeeId,
    required String deadline,
    required String priority,
    required List<Map<String, dynamic>> tasks,
    String description = '',
  }) async {
    try {
      await _client.put(
        '/api/manager/projects/$projectId',
        withAuth: true,
        body: {
          'projectName': projectName,
          'employeeId': employeeId,
          'deadline': deadline,
          'priority': priority,
          'description': description,
          'tasks': tasks,
        },
      );
    } catch (e) {
      throw Exception('Erreur modification projet: $e');
    }
  }

  Future<List<ManagerProjectModel>> getManagerProjects() async {
    try {
      final data = await _client.get(
        '/api/manager/projects',
        withAuth: true,
      ) as List<dynamic>;

      return data
          .map((e) => ManagerProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur chargement projets: $e');
    }
  }

  Future<void> deleteProject(int projectId) async {
    try {
      await _client.delete(
        '/api/manager/projects/$projectId',
        withAuth: true,
      );
    } catch (e) {
      throw Exception('Erreur suppression projet: $e');
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final data = await _client.get(
        '/api/notifications',
        withAuth: true,
      ) as List<dynamic>;

      return data
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur chargement notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(int id) async {
    try {
      await _client.patch(
        '/api/notifications/$id/read',
        withAuth: true,
      );
    } catch (e) {
      throw Exception('Erreur lecture notification: $e');
    }
  }

  Future<void> sendNotification({
    required String title,
    required String content,
    required String type,
    required int receiverId,
  }) async {
    try {
      await _client.post(
        '/api/notifications/send',
        withAuth: true,
        body: {
          'title': title,
          'content': content,
          'type': type,
          'receiverId': receiverId,
        },
      );
    } catch (e) {
      throw Exception('Erreur envoi notification: $e');
    }
  }
}