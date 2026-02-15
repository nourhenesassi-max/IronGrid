import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/employee_models.dart';

class ShiftInfoHeaderWidget extends StatelessWidget {
  final EmployeeProfile profile;
  const ShiftInfoHeaderWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bonjour,",
              style: TextStyle(
                  color: AppColors.textMuted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  profile.name,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark),
                ),
              ),
              CircleAvatar(
                  backgroundImage: NetworkImage(profile.avatarUrl), radius: 18),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Équipe Actuelle",
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700)),
                      Text(profile.teamLabel,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.work_outline,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Projet Actif",
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700)),
                      Text(profile.projectLabel,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
