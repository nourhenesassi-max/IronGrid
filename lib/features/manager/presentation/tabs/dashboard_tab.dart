import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/manager_repository.dart';
import '../widgets/stat_card.dart';
import '../widgets/approval_card.dart';

class DashboardTab extends StatelessWidget {
  final ManagerRepository repo;
  const DashboardTab({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final kpis = repo.getKpis();
    final approvals = repo.getApprovals();

    void toast(String msg) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < kpis.length; i++) ...[
                StatCard(kpi: kpis[i]),
                if (i != kpis.length - 1) const SizedBox(width: 12),
              ]
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text("Actions Rapides",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => toast("Nouvelle tâche (à brancher)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.playlist_add_check),
                  label: const Text("Nouvelle Tâche",
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => toast("Rapport (à brancher)"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side:
                        const BorderSide(color: AppColors.primary, width: 1.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.bar_chart_outlined),
                  label: const Text("Rapport",
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: const [
            Expanded(
              child: Text("Approbations en Attente",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark)),
            ),
            Text("Voir tout",
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 12),
        ApprovalCard(
          item: approvals.first,
          showActions: true,
          onReject: () => toast("Rejeter (à brancher)"),
          onApprove: () => toast("Approuver (à brancher)"),
        ),
        const SizedBox(height: 12),
        ApprovalCard(item: approvals.last, showActions: false),
      ],
    );
  }
}
