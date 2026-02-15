import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/manager_repository.dart';
import '../widgets/member_tile.dart';

class TeamTab extends StatelessWidget {
  final ManagerRepository repo;
  const TeamTab({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final team = repo.getTeam();
    void toast(String msg) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      children: [
        const Text("Équipe",
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark)),
        const SizedBox(height: 14),
        for (final m in team) ...[
          MemberTile(
              member: m, onTap: () => toast("Ouvrir membre (à brancher)")),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
