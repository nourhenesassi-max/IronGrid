import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/manager_repository.dart';
import '../widgets/project_card.dart';

class ProjectsTab extends StatelessWidget {
  final ManagerRepository repo;
  const ProjectsTab({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final projects = repo.getProjects();

    void toast(String msg) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      children: [
        const Text("Projets Actifs",
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark)),
        const SizedBox(height: 14),
        for (final p in projects) ...[
          ProjectCard(
            item: p,
            onTap: () => toast("Ouvrir projet (à brancher)"),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}
