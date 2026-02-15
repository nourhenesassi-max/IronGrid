class ManagerProfile {
  final String name;
  final String site;
  final String role;
  final int notifCount;
  final String avatarUrl;

  ManagerProfile({
    required this.name,
    required this.site,
    required this.role,
    required this.notifCount,
    required this.avatarUrl,
  });
}

class StatKpi {
  final String value;
  final String label;
  final String badge;
  final int iconCodePoint;
  final int colorValue;

  StatKpi({
    required this.value,
    required this.label,
    required this.badge,
    required this.iconCodePoint,
    required this.colorValue,
  });
}

class ApprovalItem {
  final String avatarUrl;
  final String name;
  final String pill;
  final String project;
  final String week;
  final String submitted;
  final String amountOrHours;

  ApprovalItem({
    required this.avatarUrl,
    required this.name,
    required this.pill,
    required this.project,
    required this.week,
    required this.submitted,
    required this.amountOrHours,
  });
}

class ProjectItem {
  final String title;
  final String subtitle;
  final String statusText;
  final int statusColorValue;
  final double progress;
  final String due;
  final String team;
  final String budget;
  final String spent;

  ProjectItem({
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusColorValue,
    required this.progress,
    required this.due,
    required this.team,
    required this.budget,
    required this.spent,
  });
}

class TeamMember {
  final String name;
  final String role;
  final String avatarUrl;

  TeamMember({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });
}
