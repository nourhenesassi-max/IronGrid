import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';

class ManagerAlertDetailScreen extends StatelessWidget {
  const ManagerAlertDetailScreen({super.key});

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case "PROJECT_ASSIGNED":
        return Colors.indigo;
      case "TASK_ASSIGNED":
        return Colors.orange;
      case "DEADLINE_REMINDER":
        return Colors.red;
      case "NEW_EMPLOYEE_ACCEPTED":
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toUpperCase()) {
      case "PROJECT_ASSIGNED":
        return Icons.assignment_outlined;
      case "TASK_ASSIGNED":
        return Icons.task_alt_outlined;
      case "DEADLINE_REMINDER":
        return Icons.alarm_outlined;
      case "NEW_EMPLOYEE_ACCEPTED":
        return Icons.person_add_alt_1_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case "PROJECT_ASSIGNED":
        return "Projet assigné";
      case "TASK_ASSIGNED":
        return "Tâche assignée";
      case "DEADLINE_REMINDER":
        return "Rappel deadline";
      case "NEW_EMPLOYEE_ACCEPTED":
        return "Nouvel employé accepté";
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notification =
        ModalRoute.of(context)!.settings.arguments as NotificationModel;

    final color = _typeColor(notification.type);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail alerte"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(_typeIcon(notification.type),
                      color: color, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _typeLabel(notification.type),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  notification.content,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  'Date: ${notification.createdAt}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}