import '../../employee/data/models/leave_models.dart';
import '../../employee/data/models/employee_models.dart';

class LeaveMapper {
  static LeaveStats toUiStats(LeaveStatsResponse s) {
    final pending = s.pendingCount;

    return LeaveStats(
      annualDays: "${s.annualDaysRemaining} jours",
      sickDays: "${s.sickDaysRemaining} jours",
      pendingApprovals: "$pending ${pending > 1 ? 'demandes' : 'demande'}",
    );
  }
}