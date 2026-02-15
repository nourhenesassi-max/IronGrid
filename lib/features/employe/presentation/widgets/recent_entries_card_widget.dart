import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/employee_models.dart';

class RecentEntriesCardWidget extends StatelessWidget {
  final List<RecentEntry> entries;
  const RecentEntriesCardWidget({super.key, required this.entries});

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
          const Text("Entrées Récentes",
              style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          for (final e in entries) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text(e.dateRange,
                            style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700)),
                      ]),
                ),
                Text(e.duration,
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
