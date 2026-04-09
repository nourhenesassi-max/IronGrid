import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

class EmployeeMachineStateHistoryScreen extends StatelessWidget {
  final String stateLabel;

  const EmployeeMachineStateHistoryScreen({
    super.key,
    required this.stateLabel,
  });

  List<Map<String, String>> _mockScannedMachines() {
    return [
      {
        "name": "Machine CNC 01",
        "code": "QR-CNC-001",
        "state": "Actif",
        "date": "Aujourd'hui - 08:10",
      },
      {
        "name": "Machine Presse 02",
        "code": "QR-PRS-002",
        "state": "En panne",
        "date": "Aujourd'hui - 09:25",
      },
      {
        "name": "Machine Soudure 03",
        "code": "QR-SOU-003",
        "state": "Maintenance",
        "date": "Hier - 16:40",
      },
      {
        "name": "Machine Découpe 04",
        "code": "QR-DEC-004",
        "state": "En panne",
        "date": "Hier - 14:12",
      },
      {
        "name": "Machine Emballage 05",
        "code": "QR-EMB-005",
        "state": "Actif",
        "date": "Aujourd'hui - 07:50",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final allScanned = _mockScannedMachines();
    final filtered = allScanned.where((m) => m["state"] == stateLabel).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.bg,
        title: Text(
          stateLabel,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: filtered.isEmpty
          ? const Center(
              child: Text(
                "Aucune machine scannée",
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final machine = filtered[index];

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.10),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              machine["name"] ?? "Machine",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Code : ${machine["code"] ?? "-"}",
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              machine["date"] ?? "",
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}