import 'package:flutter/material.dart';
import '../../data/manager_repository.dart';
import '../../data/models/notification_model.dart';
import 'manager_send_notification_screen.dart';

class ManagerNotificationsScreen extends StatefulWidget {
  const ManagerNotificationsScreen({super.key});

  @override
  State<ManagerNotificationsScreen> createState() =>
      _ManagerNotificationsScreenState();
}

class _ManagerNotificationsScreenState
    extends State<ManagerNotificationsScreen> {
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

      setState(() {
        _notifications = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
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
      default:
        return Colors.blueGrey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PROJECT_ASSIGNED':
        return Icons.assignment_outlined;
      case 'TASK_ASSIGNED':
        return Icons.task_alt_outlined;
      case 'PROJECT_UPDATED':
        return Icons.edit_note_outlined;
      case 'DEADLINE_REMINDER':
        return Icons.alarm_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatDate(String raw) {
    if (raw.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              'Erreur: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aucune notification.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildItem(NotificationModel item) {
    final color = _typeColor(item.type);
    final icon = _typeIcon(item.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/manager/alert_detail',
            arguments: item,
          );
        },
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: item.read ? FontWeight.w600 : FontWeight.w800,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.content),
            const SizedBox(height: 6),
            Text(
              _formatDate(item.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: item.read
            ? const Icon(Icons.done, color: Colors.green)
            : TextButton(
                onPressed: () => _markAsRead(item.id),
                child: const Text('Lire'),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
              ? _buildError()
              : _notifications.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          return _buildItem(item);
                        },
                      ),
                    ),
    );
  }
}