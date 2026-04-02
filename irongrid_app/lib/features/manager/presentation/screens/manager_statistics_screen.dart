import 'package:flutter/material.dart';

class ManagerStatisticsScreen extends StatelessWidget {
  const ManagerStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'title': 'Monthly Production', 'value': '24 500 units'},
      {'title': 'Average Downtime', 'value': '1.8 h'},
      {'title': 'Resolved Incidents', 'value': '92%'},
      {'title': 'Employee Attendance', 'value': '96%'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Statistics'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.withOpacity(0.12),
                child:
                    const Icon(Icons.analytics_outlined, color: Colors.indigo),
              ),
              title: Text(stat['title']!),
              subtitle: Text(
                stat['value']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}