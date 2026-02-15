import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/manager_models.dart';

class ApprovalCard extends StatelessWidget {
  final ApprovalItem item;
  final bool showActions;
  final VoidCallback? onReject;
  final VoidCallback? onApprove;

  const ApprovalCard({
    super.key,
    required this.item,
    required this.showActions,
    this.onReject,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Row(children: [
            CircleAvatar(
                backgroundImage: NetworkImage(item.avatarUrl), radius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999)),
              child: Text(item.pill,
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w900)),
            )
          ]),
          const SizedBox(height: 14),
          Row(children: [
            const Expanded(
                child: Text("Projet",
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700))),
            Text("Heures",
                style: TextStyle(
                    color: AppColors.textMuted.withOpacity(0.9),
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(
              child: Text(item.project,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark)),
            ),
            Text(item.amountOrHours,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(item.week,
                style: const TextStyle(
                    color: AppColors.textMuted, fontWeight: FontWeight.w700)),
            const SizedBox(width: 14),
            const Icon(Icons.access_time, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(item.submitted,
                style: const TextStyle(
                    color: AppColors.textMuted, fontWeight: FontWeight.w700)),
          ]),
          if (showActions) ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE52929),
                      side: const BorderSide(
                          color: Color(0xFFE52929), width: 1.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text("Rejeter",
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B8E5B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text("Approuver",
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ]),
          ]
        ],
      ),
    );
  }
}
