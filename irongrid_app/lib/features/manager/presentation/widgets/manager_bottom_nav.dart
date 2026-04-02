import 'package:flutter/material.dart';
import '../screens/manager_alerts_screen.dart';
import '../screens/manager_dashboard_screen.dart';
import '../screens/manager_messages_screen.dart';
import '../screens/manager_settings_screen.dart';
import 'manager_badge_store.dart';

class ManagerBottomNav extends StatelessWidget {
  final int currentIndex;

  const ManagerBottomNav({
    super.key,
    required this.currentIndex,
  });

  static const Color _primaryColor = Color(0xFF3F51B5);
  static const Color _backgroundColor = Colors.white;
  static const Color _unselectedColor = Color(0xFF8A94A6);

  void _goTo(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        _goTo(context, const ManagerDashboardScreen());
        break;
      case 1:
        _goTo(context, const ManagerAlertsScreen());
        break;
      case 2:
        _goTo(context, const ManagerMessagesScreen());
        break;
      case 3:
        _goTo(context, const ManagerSettingsScreen());
        break;
    }
  }

  Widget _badgeIcon({
    required Widget icon,
    required ValueNotifier<int> notifier,
  }) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (_, count, __) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            icon,
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
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
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
    );
  }

  BottomNavigationBarItem _buildItem({
    required int index,
    required Widget icon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;

    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? _primaryColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IconTheme(
          data: IconThemeData(
            color: isSelected ? _primaryColor : _unselectedColor,
            size: 24,
          ),
          child: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE9EDF5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: _backgroundColor,
          elevation: 0,
          selectedItemColor: _primaryColor,
          unselectedItemColor: _unselectedColor,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          onTap: (index) => _onTap(context, index),
          items: [
            _buildItem(
              index: 0,
              icon: const Icon(Icons.grid_view_rounded),
              label: 'Dashboard',
            ),
            _buildItem(
              index: 1,
              icon: _badgeIcon(
                icon: const Icon(Icons.notifications_none_rounded),
                notifier: ManagerBadgeStore.unreadAlerts,
              ),
              label: 'Alerts',
            ),
            _buildItem(
              index: 2,
              icon: _badgeIcon(
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                notifier: ManagerBadgeStore.unreadMessages,
              ),
              label: 'Messages',
            ),
            _buildItem(
              index: 3,
              icon: const Icon(Icons.settings_outlined),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }
}