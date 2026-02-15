import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, -6))
          ],
        ),
        child: Row(
          children: [
            _NavItem(
                icon: Icons.grid_view_rounded,
                label: "Accueil",
                selected: currentIndex == 0,
                onTap: () => onTap(0)),
            _CenterNavItem(
                icon: Icons.access_time,
                label: "Temps",
                selected: currentIndex == 1,
                onTap: onCenterTap),
            _NavItem(
                icon: Icons.receipt_long_outlined,
                label: "Frais",
                selected: currentIndex == 2,
                onTap: () => onTap(2)),
            _NavItem(
                icon: Icons.check_circle_outline,
                label: "Approbations",
                selected: currentIndex == 3,
                onTap: () => onTap(3)),
            _NavItem(
                icon: Icons.person_outline,
                label: "Profil",
                selected: currentIndex == 4,
                onTap: () => onTap(4)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CenterNavItem(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.textMuted.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6))
                ],
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
