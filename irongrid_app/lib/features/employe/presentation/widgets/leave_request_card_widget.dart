import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/employee_models.dart';

class LeaveRequestCardWidget extends StatelessWidget {
  final LeaveStats leave;
  final VoidCallback onNewRequest;

  const LeaveRequestCardWidget({
    super.key,
    required this.leave,
    required this.onNewRequest,
  });

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
          const Text("Demande de Congé",
              style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _LeaveMini(
                      title: leave.annualDays, subtitle: "Congés Annuels")),
              const SizedBox(width: 10),
              Expanded(
                  child: _LeaveMini(
                      title: leave.sickDays, subtitle: "Congés Maladie")),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE07A00).withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFE07A00), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    leave.pendingApprovals,
                    style: const TextStyle(
                        color: Color(0xFFE07A00), fontWeight: FontWeight.w800),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onNewRequest,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Nouvelle Demande",
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaveMini extends StatelessWidget {
  final String title;
  final String subtitle;

  const _LeaveMini({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textMuted.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(
                  color: AppColors.textMuted, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
