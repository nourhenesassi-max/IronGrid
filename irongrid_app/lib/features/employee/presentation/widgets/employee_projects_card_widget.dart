import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/employee_models.dart';

class EmployeeProjectsCardWidget extends StatelessWidget {
  final List<EmployeeProject> projects;
  final VoidCallback onViewAll;
  final Function(EmployeeProject) onTapProject;

  const EmployeeProjectsCardWidget({
    super.key,
    required this.projects,
    required this.onViewAll,
    required this.onTapProject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Mes Projets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...projects.take(2).map(
                (project) => InkWell(
                  onTap: () => onTapProject(project),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.projectName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Manager: ${project.managerName}'),
                        Text('Deadline: ${project.deadline}'),
                        Text('Statut: ${project.status}'),
                        Text('Priorité: ${project.priority}'),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}