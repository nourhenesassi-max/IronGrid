// 🔹 TASK MODEL
class ProjectTaskModel {
  final String id;
  final String title;
  final String deadline;
  final bool isCompleted;

  ProjectTaskModel({
    required this.id,
    required this.title,
    required this.deadline,
    this.isCompleted = false,
  });

  factory ProjectTaskModel.fromJson(Map<String, dynamic> json) {
    return ProjectTaskModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      deadline: (json['deadline'] ?? '').toString(),
      isCompleted: json['isCompleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline,
      'isCompleted': isCompleted,
    };
  }
}

// 🔹 PROJECT MODEL
class ManagerProjectModel {
  final int id;
  final String projectName;
  final String employeeName;
  final String deadline;
  final String priority;
  final String description;
  final List<ProjectTaskModel> tasks;

  ManagerProjectModel({
    required this.id,
    required this.projectName,
    required this.employeeName,
    required this.deadline,
    required this.priority,
    required this.tasks,
    this.description = '',
  });

  factory ManagerProjectModel.fromJson(Map<String, dynamic> json) {
    return ManagerProjectModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      projectName: (json['projectName'] ?? '').toString(),
      employeeName: (json['employeeName'] ?? '').toString(),
      deadline: (json['deadline'] ?? '').toString(),
      priority: (json['priority'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),

      // 🔥 SAFE PARSING (supports null / empty)
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((e) => ProjectTaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectName': projectName,
      'employeeName': employeeName,
      'deadline': deadline,
      'priority': priority,
      'description': description,
      'tasks': tasks.map((e) => e.toJson()).toList(),
    };
  }
}