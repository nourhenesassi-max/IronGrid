import 'models/employee_models.dart';

class EmployeeRepository {
  EmployeeProfile getProfile() => EmployeeProfile(
        name: "Jean Dupont",
        avatarUrl: "https://i.pravatar.cc/150?img=11",
        teamLabel: "Équipe Matin (06:00 - 14:00)",
        projectLabel: "Ligne Production A - Assemblage Moteurs",
      );

  TimeStats getTimeStats() => TimeStats(today: "0h 0m", week: "32h 30m");

  List<String> getLines() =>
      ["Ligne Production A", "Ligne Production B", "Ligne Production C"];

  List<RecentEntry> getRecentEntries() => [
        RecentEntry(
          title: "Ligne Production A",
          dateRange: "2026-02-13 06:00 - 2026-02-13 10:00",
          duration: "4h 0m",
        ),
        RecentEntry(
          title: "Maintenance Préventive",
          dateRange: "2026-02-13 10:15 - 2026-02-13 12:00",
          duration: "1h 45m",
        ),
      ];

  List<MachineStatus> getMachines() => [
        MachineStatus(
          name: "Presse Hydraulique #3",
          code: "MCH-001",
          statusText: "Opérationnel",
          statusColorValue: 0xFF0B8E5B,
          lastCheck: "Dernière vérification: 2026-02-13 08:30",
        ),
        MachineStatus(
          name: "Tour CNC #7",
          code: "MCH-002",
          statusText: "Maintenance",
          statusColorValue: 0xFFE07A00,
          lastCheck: "Dernière vérification: 2026-02-13 07:15",
        ),
        MachineStatus(
          name: "Fraiseuse #12",
          code: "MCH-003",
          statusText: "En Panne",
          statusColorValue: 0xFFE52929,
          lastCheck: "Dernière vérification: 2026-02-13 09:45",
        ),
      ];

  LeaveStats getLeaveStats() => LeaveStats(
        annualDays: "15 jours",
        sickDays: "5 jours",
        pendingApprovals: "2 demande(s) en attente d'approbation",
      );
}
