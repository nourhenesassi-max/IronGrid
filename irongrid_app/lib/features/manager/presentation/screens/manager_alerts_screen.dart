import 'package:flutter/material.dart';
import '../../data/manager_repository.dart';
import '../../data/models/notification_model.dart';
import '../widgets/manager_badge_store.dart';
import '../widgets/manager_bottom_nav.dart';
import 'manager_send_notification_screen.dart';

class ManagerAlertsScreen extends StatefulWidget {
  const ManagerAlertsScreen({super.key});

  @override
  State<ManagerAlertsScreen> createState() => _ManagerAlertsScreenState();
}

class _ManagerAlertsScreenState extends State<ManagerAlertsScreen> {
  final ManagerRepository _repo = ManagerRepository();

  List<NotificationModel> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _repo.getNotifications();
      if (!mounted) return;

      final unreadCount = data.where((e) => !e.read).length;
      ManagerBadgeStore.setUnreadAlerts(unreadCount);

      setState(() {
        _notifications = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _repo.markNotificationAsRead(id);
      await _loadNotifications();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _openSendScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ManagerSendNotificationScreen(),
      ),
    );

    if (result == true) {
      _loadNotifications();
    }
  }

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'PROJECT_ASSIGNED':
        return Colors.indigo;
      case 'TASK_ASSIGNED':
        return Colors.orange;
      case 'PROJECT_UPDATED':
        return Colors.teal;
      case 'DEADLINE_REMINDER':
        return Colors.red;
      case 'NEW_EMPLOYEE_ACCEPTED':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'NEW_EMPLOYEE_ACCEPTED':
        return Icons.person_add_alt_1_outlined;
      case 'PROJECT_ASSIGNED':
        return Icons.assignment_outlined;
      case 'TASK_ASSIGNED':
        return Icons.task_alt_outlined;
      case 'DEADLINE_REMINDER':
        return Icons.alarm_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            onPressed: _openSendScreen,
            icon: const Icon(Icons.add_alert_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur: $_error'))
              : _notifications.isEmpty
                  ? const Center(child: Text('Aucune notification.'))
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final alert = _notifications[index];
                          final color = _typeColor(alert.type);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              onTap: () async {
                                if (!alert.read) {
                                  await _markAsRead(alert.id);
                                }
                                if (!context.mounted) return;
                                Navigator.pushNamed(
                                  context,
                                  '/manager/alert_detail',
                                  arguments: alert,
                                ).then((_) => _loadNotifications());
                              },
                              leading: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: color.withOpacity(0.12),
                                    child: Icon(_typeIcon(alert.type),
                                        color: color),
                                  ),
                                  if (!alert.read)
                                    Positioned(
                                      right: -1,
                                      top: -1,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Text(
                                alert.title,
                                style: TextStyle(
                                  fontWeight: alert.read
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  alert.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: !alert.read
                                  ? Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '1',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.done, color: Colors.green),
                            ),
                          );
                        },
                      ),
                    ),
      bottomNavigationBar: const ManagerBottomNav(currentIndex: 1),
    );
  }
}