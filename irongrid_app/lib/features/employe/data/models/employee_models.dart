class EmployeeProfile {
  final String name;
  final String avatarUrl;
  final String teamLabel; // Equipe Actuelle
  final String projectLabel; // Projet Actif

  EmployeeProfile({
    required this.name,
    required this.avatarUrl,
    required this.teamLabel,
    required this.projectLabel,
  });
}

class TimeStats {
  final String today;
  final String week;

  TimeStats({required this.today, required this.week});
}

class RecentEntry {
  final String title;
  final String dateRange;
  final String duration;

  RecentEntry({
    required this.title,
    required this.dateRange,
    required this.duration,
  });
}

class MachineStatus {
  final String name;
  final String code;
  final String statusText;
  final int statusColorValue;
  final String lastCheck;

  MachineStatus({
    required this.name,
    required this.code,
    required this.statusText,
    required this.statusColorValue,
    required this.lastCheck,
  });
}

class LeaveStats {
  final String annualDays;
  final String sickDays;
  final String pendingApprovals;

  LeaveStats({
    required this.annualDays,
    required this.sickDays,
    required this.pendingApprovals,
  });
}
