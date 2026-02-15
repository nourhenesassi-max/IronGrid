import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/manager_models.dart';

class HeaderCard extends StatelessWidget {
  final ManagerProfile profile;
  const HeaderCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: CircleAvatar(
                radius: 26, backgroundImage: NetworkImage(profile.avatarUrl)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(profile.name,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text(profile.site,
                  style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
                color: Color(0xFFE52929), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text("${profile.notifCount}",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14)),
          )
        ],
      ),
    );
  }
}
