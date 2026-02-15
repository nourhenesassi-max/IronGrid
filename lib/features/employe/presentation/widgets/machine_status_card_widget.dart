import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/employee_models.dart';

class MachineStatusCardWidget extends StatelessWidget {
  final List<MachineStatus> machines;
  final VoidCallback onLongPressScan;

  const MachineStatusCardWidget({
    super.key,
    required this.machines,
    required this.onLongPressScan,
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
          const Text("État des Machines",
              style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          for (final m in machines) ...[
            _MachineTile(machine: m, onLongPress: onLongPressScan),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _MachineTile extends StatelessWidget {
  final MachineStatus machine;
  final VoidCallback onLongPress;

  const _MachineTile({required this.machine, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(machine.statusColorValue);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      shape: BoxShape.circle),
                  child: Icon(Icons.circle, color: statusColor, size: 12),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(machine.name,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999)),
                  child: Text(machine.statusText,
                      style: TextStyle(
                          color: statusColor, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(machine.code,
                style: const TextStyle(
                    color: AppColors.textMuted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(machine.lastCheck,
                      style: const TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.qr_code_scanner, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  "Appuyez longuement pour scanner le QR",
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
