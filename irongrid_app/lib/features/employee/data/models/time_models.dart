class SessionStateResponse {
  final int? sessionId;
  final String? project;
  final String status; // RUNNING / PAUSED / ENDED
  final String? startedAt;
  final String? endedAt;

  SessionStateResponse({
    required this.sessionId,
    required this.project,
    required this.status,
    required this.startedAt,
    required this.endedAt,
  });

  factory SessionStateResponse.fromJson(Map<String, dynamic> j) {
    return SessionStateResponse(
      sessionId: (j["sessionId"] as num?)?.toInt(),
      project: j["project"] as String?,
      status: (j["status"] as String?) ?? "ENDED",
      startedAt: j["startedAt"] as String?,
      endedAt: j["endedAt"] as String?,
    );
  }
}

class TimeSummaryResponse {
  final int minutesToday;
  final int minutesThisWeek;

  TimeSummaryResponse({
    required this.minutesToday,
    required this.minutesThisWeek,
  });

  factory TimeSummaryResponse.fromJson(Map<String, dynamic> j) {
    return TimeSummaryResponse(
      minutesToday: (j["minutesToday"] as num).toInt(),
      minutesThisWeek: (j["minutesThisWeek"] as num).toInt(),
    );
  }
}