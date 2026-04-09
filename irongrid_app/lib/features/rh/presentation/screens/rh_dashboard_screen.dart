import 'package:flutter/material.dart';
import '../../data/rh_repository.dart';

class RhDashboardScreen extends StatelessWidget {
  const RhDashboardScreen({super.key});

  Color _statusColor(bool overloaded) {
    return overloaded ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final repo = RhRepository();
    final workloads = repo.getWorkloads();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard RH'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Suivi des heures',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Visualisez les charges de travail et les employés en surcharge.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          ...workloads.map(
            (item) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.employeeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Projet: ${item.projectName}'),
                    Text('Heures / jour: ${item.dailyHours} h'),
                    Text('Heures / semaine: ${item.weeklyHours} h'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _statusColor(item.isOverloaded).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.alertMessage,
                        style: TextStyle(
                          color: _statusColor(item.isOverloaded),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (item.isOverloaded) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Alerte envoyée au manager pour ${item.employeeName}',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.warning_amber_rounded),
                          label: const Text('Alerter le manager'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}