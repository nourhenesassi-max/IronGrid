import 'models/manager_models.dart';

class ManagerRepository {
  ManagerProfile getProfile() {
    return ManagerProfile(
      name: "Sophie Martin",
      site: "Site de Production Lyon",
      role: "Responsable d'Équipe",
      notifCount: 7,
      avatarUrl: "https://i.pravatar.cc/150?img=47",
    );
  }

  List<StatKpi> getKpis() => [
        StatKpi(
          value: "12",
          label: "Projets Actifs",
          badge: "+2",
          iconCodePoint: 0xe54c, // Icons.work_outline
          colorValue: 0xFF163B8A,
        ),
        StatKpi(
          value: "94%",
          label: "Taux de Présence",
          badge: "+3%",
          iconCodePoint: 0xe3b3, // Icons.group_outlined
          colorValue: 0xFF0B8E5B,
        ),
        StatKpi(
          value: "7",
          label: "Approbations",
          badge: "!",
          iconCodePoint: 0xe4c3, // Icons.pending_actions_outlined
          colorValue: 0xFFE07A00,
        ),
      ];

  List<ApprovalItem> getApprovals() => [
        ApprovalItem(
          avatarUrl: "https://i.pravatar.cc/150?img=12",
          name: "Marc Dubois",
          pill: "Feuille de Temps",
          project: "Maintenance Préventive",
          week: "Semaine 7",
          submitted: "Soumis le 2026-02-12",
          amountOrHours: "42.5h",
        ),
        ApprovalItem(
          avatarUrl: "https://i.pravatar.cc/150?img=32",
          name: "Julie Bernard",
          pill: "Frais",
          project: "Installation Ligne 4",
          week: "Semaine 7",
          submitted: "Soumis le 2026-02-11",
          amountOrHours: "128 €",
        ),
      ];

  List<ProjectItem> getProjects() => [
        ProjectItem(
          title: "Maintenance Préventive",
          subtitle: "Production Interne",
          statusText: "Dans les temps",
          statusColorValue: 0xFF0B8E5B,
          progress: 0.75,
          due: "2026-03-15",
          team: "8 membres",
          budget: "45 000 €",
          spent: "33 750 €",
        ),
        ProjectItem(
          title: "Installation Ligne 4",
          subtitle: "Expansion Usine",
          statusText: "À risque",
          statusColorValue: 0xFFE07A00,
          progress: 0.45,
          due: "2026-04-30",
          team: "12 membres",
          budget: "120 000 €",
          spent: "62 000 €",
        ),
      ];

  List<TeamMember> getTeam() => [
        TeamMember(
          name: "Marc Dubois",
          role: "Technicien",
          avatarUrl: "https://i.pravatar.cc/150?img=12",
        ),
        TeamMember(
          name: "Julie Bernard",
          role: "Assistante",
          avatarUrl: "https://i.pravatar.cc/150?img=32",
        ),
        TeamMember(
          name: "Karim Benali",
          role: "Ingénieur",
          avatarUrl: "https://i.pravatar.cc/150?img=68",
        ),
      ];
}
