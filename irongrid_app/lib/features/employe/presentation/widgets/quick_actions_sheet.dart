import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

class QuickActionsSheet extends StatelessWidget {
  final void Function(String action) onTap;
  const QuickActionsSheet({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Actions Rapides",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 12),
          _ActionTile(
              icon: Icons.login,
              title: "Pointer Entrée/Sortie",
              onTap: () => onTap("Pointer Entrée/Sortie")),
          _ActionTile(
              icon: Icons.report_outlined,
              title: "Signaler Incident",
              onTap: () => onTap("Signaler Incident")),
          _ActionTile(
              icon: Icons.camera_alt_outlined,
              title: "Capturer Frais",
              onTap: () => onTap("Capturer Frais")),
          _ActionTile(
              icon: Icons.qr_code_scanner,
              title: "Scanner QR Machine",
              onTap: () => onTap("Scanner QR Machine")),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.textMuted.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800))),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
