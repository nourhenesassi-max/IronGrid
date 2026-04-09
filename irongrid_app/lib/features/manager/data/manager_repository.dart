import 'models/employee_model.dart';
import 'models/manager_project_model.dart';
import 'models/notification_model.dart';
import 'services/manager_api_service.dart';

class ManagerRepository {
  final ManagerApiService _api = ManagerApiService();

  Future<List<EmployeeModel>> getEmployees() async {
    return _api.getEmployees();
  }

  Future<void> removeEmployeeFromTeam(int employeeId) async {
    return _api.removeEmployeeFromTeam(employeeId);
  }

  Future<void> assignProject({
    required String projectName,
    required int employeeId,
    required String deadline,
    required String priority,
    required List<ProjectTaskModel> tasks,
    String description = '',
  }) async {
    return _api.assignProject(
      projectName: projectName,
      employeeId: employeeId,
      deadline: deadline,
      priority: priority,
      description: description,
      tasks: tasks.map((task) => task.toJson()).toList(),
    );
  }

  Future<void> updateProject({
    required int projectId,
    required String projectName,
    required int employeeId,
    required String deadline,
    required String priority,
    required List<ProjectTaskModel> tasks,
    String description = '',
  }) async {
    return _api.updateProject(
      projectId: projectId,
      projectName: projectName,
      employeeId: employeeId,
      deadline: deadline,
      priority: priority,
      description: description,
      tasks: tasks.map((task) => task.toJson()).toList(),
    );
  }

  Future<List<ManagerProjectModel>> getProjects() async {
    return _api.getManagerProjects();
  }

  Future<void> deleteProject(int projectId) async {
    return _api.deleteProject(projectId);
  }

  Future<List<NotificationModel>> getNotifications() async {
    return _api.getNotifications();
  }

  Future<void> markNotificationAsRead(int id) async {
    return _api.markNotificationAsRead(id);
  }

  Future<void> sendNotification({
    required String title,
    required String content,
    required String type,
    required int receiverId,
  }) async {
    return _api.sendNotification(
      title: title,
      content: content,
      type: type,
      receiverId: receiverId,
    );
  }
}