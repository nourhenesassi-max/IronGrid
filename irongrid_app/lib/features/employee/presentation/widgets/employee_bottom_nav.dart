
import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import 'employee_badge_store.dart';

class EmployeeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EmployeeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
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
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            _Nav(
              iconWidget: Icon(
                Icons.grid_view_rounded,
                color:
                    currentIndex == 0 ? AppColors.primary : AppColors.textMuted,
              ),
              label: "Accueil",
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _Nav(
              iconWidget: Icon(
                Icons.access_time,
                color:
                    currentIndex == 1 ? AppColors.primary : AppColors.textMuted,
              ),
              label: "Temps",
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _Nav(
              iconWidget: ValueListenableBuilder<int>(
                valueListenable: EmployeeBadgeStore.unreadMessages,
                builder: (_, count, __) {
                  final color = currentIndex == 2
                      ? AppColors.primary
                      : AppColors.textMuted;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: color),
                      if (count > 0)
                        Positioned(
                          right: -8,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              label: "Messages",
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _Nav(
              iconWidget: Icon(
                Icons.person_outline,
                color:
                    currentIndex == 3 ? AppColors.primary : AppColors.textMuted,
              ),
              label: "Profil",
              selected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Nav({
    required this.iconWidget,
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
              iconWidget,
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
