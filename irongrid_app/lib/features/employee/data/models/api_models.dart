class TimeSummaryDto {
  final String today; // "0h 0m"
  final String week; // "32h 30m"
  final String status; // "RUNNING" / "PAUSED" / "ENDED"
  final List<RecentEntryDto> recent;

  TimeSummaryDto({
    required this.today,
    required this.week,
    required this.status,
    required this.recent,
  });

  factory TimeSummaryDto.fromJson(Map<String, dynamic> j) {
    final items = (j["recent"] as List? ?? [])
        .map((e) => RecentEntryDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return TimeSummaryDto(
      today: (j["today"] ?? "0h 0m") as String,
      week: (j["week"] ?? "0h 0m") as String,
      status: (j["status"] ?? "ENDED") as String,
      recent: items,
    );
  }
}

class RecentEntryDto {
  final String title;
  final String dateRange;
  final String duration;

  RecentEntryDto({
    required this.title,
    required this.dateRange,
    required this.duration,
  });

  factory RecentEntryDto.fromJson(Map<String, dynamic> j) {
    return RecentEntryDto(
      title: (j["title"] ?? "") as String,
      dateRange: (j["dateRange"] ?? "") as String,
      duration: (j["duration"] ?? "") as String,
    );
  }
}

class LeaveStatsDto {
  final String annualDays;
  final String sickDays;
  final String pendingApprovals;

  LeaveStatsDto({
    required this.annualDays,
    required this.sickDays,
    required this.pendingApprovals,
  });

  factory LeaveStatsDto.fromJson(Map<String, dynamic> j) {
    return LeaveStatsDto(
      annualDays: (j["annualDays"] ?? "0 jours") as String,
      sickDays: (j["sickDays"] ?? "0 jours") as String,
      pendingApprovals: (j["pendingApprovals"] ?? "0") as String,
    );
  }
}

class MeDto {
  final String email;
  final String role;

  MeDto({required this.email, required this.role});

  factory MeDto.fromJson(Map<String, dynamic> j) {
    // auth.getAuthorities() renvoie une liste genre [{"authority":"ROLE_EMPLOYE"}] parfois
    String role = "";
    final auths = j["authorities"];
    if (auths is List && auths.isNotEmpty) {
      final first = auths.first;
      if (first is Map && first["authority"] != null) {
        role = (first["authority"] as String).replaceFirst("ROLE_", "");
      }
    }
    return MeDto(email: (j["email"] ?? "") as String, role: role);
  }
}