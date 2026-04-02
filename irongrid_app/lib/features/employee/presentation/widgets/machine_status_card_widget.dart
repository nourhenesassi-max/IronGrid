import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

class MachineStatusCardWidget extends StatelessWidget {
  final List<dynamic> machines;
  final ValueChanged<String> onTapState;
  final VoidCallback onLongPressScan;

  const MachineStatusCardWidget({
    super.key,
    required this.machines,
    required this.onTapState,
    required this.onLongPressScan,
  });

  String _readLabel(dynamic item) {
    try {
      final dynamic v = item.label;
      if (v != null) return v.toString();
    } catch (_) {}

    try {
      final dynamic v = item.name;
      if (v != null) return v.toString();
    } catch (_) {}

    try {
      final dynamic v = item.title;
      if (v != null) return v.toString();
    } catch (_) {}

    return "";
  }

  int _readCount(dynamic item) {
    try {
      final dynamic v = item.count;
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString()) ?? 0;
    } catch (_) {}

    try {
      final dynamic v = item.total;
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString()) ?? 0;
    } catch (_) {}

    try {
      final dynamic v = item.value;
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString()) ?? 0;
    } catch (_) {}

    return 0;
  }

  int _countFor(String label) {
    for (final item in machines) {
      final itemLabel = _readLabel(item).toLowerCase().trim();
      if (itemLabel == label.toLowerCase().trim()) {
        return _readCount(item);
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final actifCount = _countFor("Actif");
    final maintenanceCount = _countFor("Maintenance");
    final panneCount = _countFor("En panne");

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "État des machines",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StateTile(
                  label: "Actif",
                  count: actifCount,
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                  onTap: () => onTapState("Actif"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StateTile(
                  label: "Maintenance",
                  count: maintenanceCount,
                  color: Colors.orange,
                  icon: Icons.build_circle_outlined,
                  onTap: () => onTapState("Maintenance"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StateTile(
                  label: "En panne",
                  count: panneCount,
                  color: Colors.red,
                  icon: Icons.error_outline,
                  onTap: () => onTapState("En panne"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onLongPress: onLongPressScan,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  "Maintenir pour scanner",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _StateTile({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                "$count",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}