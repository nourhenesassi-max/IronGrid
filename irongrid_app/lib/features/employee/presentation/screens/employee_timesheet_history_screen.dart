import 'package:flutter/material.dart';

class _TimesheetHistoryItem {
  final String projectName;
  final String taskName;
  final String date;
  final String startTime;
  final String endTime;
  final double pauseHours;
  final double workedHours;
  final String status;

  const _TimesheetHistoryItem({
    required this.projectName,
    required this.taskName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.pauseHours,
    required this.workedHours,
    required this.status,
  });
}

class EmployeeTimesheetHistoryScreen extends StatelessWidget {
  const EmployeeTimesheetHistoryScreen({super.key});

  Color _statusColor(String status, double workedHours) {
    if (status.toLowerCase() == 'overtime' || workedHours > 9) {
      return Colors.red;
    }
    if (status.toLowerCase() == 'below minimum' || workedHours < 7) {
      return Colors.orange;
    }
    if (status.toLowerCase() == 'sunday') {
      return Colors.blueGrey;
    }
    return Colors.green;
  }

  String _statusLabel(String status, double workedHours) {
    if (status.toLowerCase() == 'overtime' || workedHours > 9) {
      return 'Heures dépassées';
    }
    if (status.toLowerCase() == 'below minimum' || workedHours < 7) {
      return 'Heures insuffisantes';
    }
    if (status.toLowerCase() == 'sunday') {
      return 'Dimanche';
    }
    return 'Valide';
  }

  @override
  Widget build(BuildContext context) {
    final entries = <_TimesheetHistoryItem>[
      const _TimesheetHistoryItem(
        projectName: 'Projet maintenance ligne A',
        taskName: 'Vérification machine M-204',
        date: '2026-03-07',
        startTime: '08:00',
        endTime: '17:00',
        pauseHours: 1,
        workedHours: 8,
        status: 'valid',
      ),
      const _TimesheetHistoryItem(
        projectName: 'Projet stock',
        taskName: 'Contrôle matières premières',
        date: '2026-03-06',
        startTime: '08:00',
        endTime: '19:00',
        pauseHours: 1,
        workedHours: 10,
        status: 'overtime',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique Timesheet'),
        centerTitle: true,
      ),
      body: entries.isEmpty
          ? const Center(
              child: Text(
                'Aucune entrée enregistrée.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final statusColor =
                    _statusColor(entry.status, entry.workedHours);
                final statusLabel =
                    _statusLabel(entry.status, entry.workedHours);

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.projectName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.taskName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Date: ${entry.date}'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Horaire: ${entry.startTime} - ${entry.endTime}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.free_breakfast_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Pause: ${entry.pauseHours} h'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${entry.workedHours.toStringAsFixed(1)} h',
                                style: const TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}