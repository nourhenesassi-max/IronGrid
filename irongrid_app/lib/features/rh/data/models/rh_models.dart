class RhEmployeeWorkload {
  final String employeeName;
  final String projectName;
  final double dailyHours;
  final double weeklyHours;
  final bool isOverloaded;
  final String alertMessage;

  RhEmployeeWorkload({
    required this.employeeName,
    required this.projectName,
    required this.dailyHours,
    required this.weeklyHours,
    required this.isOverloaded,
    required this.alertMessage,
  });
}