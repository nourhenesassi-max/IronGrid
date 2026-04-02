
class LeaveStatsResponse {
  final int annualDaysRemaining;
  final int sickDaysRemaining;
  final int pendingCount;

  LeaveStatsResponse({
    required this.annualDaysRemaining,
    required this.sickDaysRemaining,
    required this.pendingCount,
  });

  factory LeaveStatsResponse.fromJson(Map<String, dynamic> json) {
    return LeaveStatsResponse(
      annualDaysRemaining: (json["annualDaysRemaining"] as num?)?.toInt() ?? 0,
      sickDaysRemaining: (json["sickDaysRemaining"] as num?)?.toInt() ?? 0,
      pendingCount: (json["pendingCount"] as num?)?.toInt() ?? 0,
    );
  }
}

class LeaveResponse {
  final int id;
  final String type;
  final String startDate;
  final String endDate;
  final String? reason;
  final String status;

  LeaveResponse({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });

  factory LeaveResponse.fromJson(Map<String, dynamic> json) {
    return LeaveResponse(
      id: (json["id"] as num?)?.toInt() ?? 0,
      type: (json["type"] ?? "").toString(),
      startDate: (json["startDate"] ?? "").toString(),
      endDate: (json["endDate"] ?? "").toString(),
      reason: json["reason"]?.toString(),
      status: (json["status"] ?? "").toString(),
    );
  }

  bool get isPending => status.toUpperCase() == "PENDING";
}
