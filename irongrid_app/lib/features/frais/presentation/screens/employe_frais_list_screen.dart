import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/expense_service.dart';
import '../../data/models/expense_dto.dart';
import 'expense_detail_screen.dart';

class EmployeFraisListScreen extends StatefulWidget {
  const EmployeFraisListScreen({super.key});

  @override
  State<EmployeFraisListScreen> createState() => _EmployeFraisListScreenState();
}

class _EmployeFraisListScreenState extends State<EmployeFraisListScreen> {
  final _service = ExpenseService();
  late Future<List<ExpenseDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.myExpenses();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.myExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: const Text("Mes Frais"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, "/employe-scan-frais")
            .then((_) => _reload()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Nouveau"),
      ),
      body: FutureBuilder<List<ExpenseDto>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Erreur: ${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final expenses = snapshot.data ?? [];
          if (expenses.isEmpty) {
            return const Center(
              child: Text(
                "Aucun frais pour le moment",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              itemCount: expenses.length,
              itemBuilder: (_, i) => _ExpenseCard(
                dto: expenses[i],
                receiptFullUrl:
                    _service.resolveReceiptUrl(expenses[i].receiptUrl),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseDto dto;
  final String? receiptFullUrl;

  const _ExpenseCard({
    required this.dto,
    required this.receiptFullUrl,
  });

  @override
  Widget build(BuildContext context) {
    final d = dto.expenseDate;
    final dateStr =
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExpenseDetailScreen(
              dto: dto,
              receiptFullUrl: receiptFullUrl,
            ),
          ),
        );
      },
      child: Container(
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
              child: Container(
                width: 64,
                height: 64,
                color: AppColors.bg,
                child: receiptFullUrl == null
                    ? const Icon(Icons.receipt_long, color: AppColors.primary)
                    : Image.network(
                        receiptFullUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textMuted,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dto.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Montant: ${dto.amount.toStringAsFixed(2)} ${dto.currency}",
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
                  const SizedBox(height: 4),
                  Text(
                    dto.status,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}