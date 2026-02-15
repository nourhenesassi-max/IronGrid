import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/manager_models.dart';

class StatCard extends StatelessWidget {
  final StatKpi kpi;
  const StatCard({super.key, required this.kpi});

  @override
  Widget build(BuildContext context) {
    final color = Color(kpi.colorValue);
    final icon = IconData(kpi.iconCodePoint, fontFamily: 'MaterialIcons');

    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25), width: 1.4),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(999)),
            child: Text(kpi.badge,
                style: TextStyle(color: color, fontWeight: FontWeight.w900)),
          )
        ]),
        const SizedBox(height: 16),
        Text(kpi.value,
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 6),
        const Text("",
            style: TextStyle(fontSize: 1)), // keeps spacing stable across fonts
        Text(kpi.label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted)),
      ]),
    );
  }
}
