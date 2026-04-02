class Project {
  final int id;
  final String name;
  final String manager;
  final String deadline;
  final String status;
  final String priority;
  final List<String> tasks;

  Project({
    required this.id,
    required this.name,
    required this.manager,
    required this.deadline,
    required this.status,
    required this.priority,
    required this.tasks,
  });
}