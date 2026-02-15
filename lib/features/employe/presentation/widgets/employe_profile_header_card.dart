import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/employee_models.dart';

class EmployeProfileHeaderCard extends StatelessWidget {
  final EmployeeProfile profile;
  const EmployeProfileHeaderCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 54,
            backgroundColor: AppColors.primary,
            child: CircleAvatar(
              radius: 51,
              backgroundImage: NetworkImage(profile.avatarUrl),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            profile.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 6),

          // ✅ Use teamLabel instead of role
          Text(
            profile.teamLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Use projectLabel instead of site
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              profile.projectLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
