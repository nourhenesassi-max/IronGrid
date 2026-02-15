import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import 'package:irongrid_app/features/employe/presentation/screens/employee_dashboard_screen.dart';
import '../../data/expense_repository.dart';
import '../../data/models/expense_model.dart';

class EmployeFraisListScreen extends StatelessWidget {
  const EmployeFraisListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = ExpenseRepository().getAll();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const EmployeeDashboardScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  final tween =
                      Tween(begin: const Offset(-1, 0), end: Offset.zero);
                  final curved =
                      CurvedAnimation(parent: animation, curve: Curves.easeOut);

                  return SlideTransition(
                    position: tween.animate(curved),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        title: const Text("Mes Frais"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, "/employe-scan-frais"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Nouveau"),
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Text(
                "Aucun frais pour le moment",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              itemCount: expenses.length,
              itemBuilder: (_, i) => _ExpenseCard(expense: expenses[i]),
            ),
    );
  }
}

/// ✅ Card widget INSIDE the same file
class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final d = expense.date;
    final dateStr =
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(expense.imagePath),
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Montant: ${expense.amount.toStringAsFixed(2)} TND",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  "Date: $dateStr",
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (expense.note.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    expense.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
