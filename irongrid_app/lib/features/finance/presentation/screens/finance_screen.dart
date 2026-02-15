import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Espace Finance"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Bienvenue Finance 👋",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12),
            Text("Gestion financière (à brancher)"),
          ],
        ),
      ),
    );
  }
}
