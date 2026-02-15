import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/manager_models.dart';

class ProjectCard extends StatelessWidget {
  final ProjectItem item;
  final VoidCallback onTap;
  const ProjectCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(item.statusColorValue);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: statusColor.withOpacity(0.25), width: 1.4),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(item.title,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999)),
              child: Text(item.statusText,
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.w900)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(item.subtitle,
              style: const TextStyle(
                  color: AppColors.textMuted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Row(children: [
            const Text("Progression",
                style: TextStyle(
                    color: AppColors.textMuted, fontWeight: FontWeight.w800)),
            const Spacer(),
            Text("${(item.progress * 100).round()}%",
                style:
                    TextStyle(color: statusColor, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.progress,
              minHeight: 10,
              backgroundColor: statusColor.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text("Échéance\n${item.due}",
                style: const TextStyle(
                    color: AppColors.textDark, fontWeight: FontWeight.w800)),
            const Spacer(),
            const Icon(Icons.group_outlined,
                size: 20, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text("Équipe\n${item.team}",
                style: const TextStyle(
                    color: AppColors.textDark, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF6A78C7).withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Expanded(
                child: Text("Budget\n${item.budget}",
                    style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900)),
              ),
              Text("Dépensé\n${item.spent}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.w900)),
            ]),
          )
        ]),
      ),
    );
  }
}
