import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

class EmployeSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const EmployeSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!,
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700)),
                    ],
                  ]),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class EmployeOfflineTile extends StatefulWidget {
  const EmployeOfflineTile({super.key});

  @override
  State<EmployeOfflineTile> createState() => _EmployeOfflineTileState();
}

class _EmployeOfflineTileState extends State<EmployeOfflineTile> {
  bool _offline = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          const Icon(Icons.cloud_outlined, color: AppColors.primary),
          const SizedBox(width: 14),
          const Expanded(
            child: Text("Mode Hors Ligne",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          Switch(
            value: _offline,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _offline = v),
          ),
        ],
      ),
    );
  }
}
