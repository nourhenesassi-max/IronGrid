import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/manager_models.dart';

class MemberTile extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onTap;
  const MemberTile({super.key, required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(children: [
          CircleAvatar(
              backgroundImage: NetworkImage(member.avatarUrl), radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(member.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 2),
              Text(member.role,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontWeight: FontWeight.w700)),
            ]),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ]),
      ),
    );
  }
}
