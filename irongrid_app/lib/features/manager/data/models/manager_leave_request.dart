class ManagerLeaveRequest {
  final int id;
  final String employeeName;
  final String employeeTeam;
  final String leaveType;
  final String startDate;
  final String endDate;
  final int daysCount;
  final String reason;
  final String status; // pending, approved, rejected
  final String? managerComment;

  ManagerLeaveRequest({
    required this.id,
    required this.employeeName,
    required this.employeeTeam,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.reason,
    required this.status,
    this.managerComment,
  });
}