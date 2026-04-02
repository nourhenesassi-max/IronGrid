import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/models/expense_dto.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final ExpenseDto dto;
  final String? receiptFullUrl;

  const ExpenseDetailScreen({
    super.key,
    required this.dto,
    required this.receiptFullUrl,
  });

  @override
  Widget build(BuildContext context) {
    final d = dto.expenseDate;
    final dateStr =
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    final statusLabel = dto.status == "APPROVED"
        ? "Approuvé"
        : dto.status == "REJECTED"
            ? "Rejeté"
            : "En attente";

    final statusColor = dto.status == "APPROVED"
        ? const Color(0xFF0B8E5B)
        : dto.status == "REJECTED"
            ? const Color(0xFFE52929)
            : const Color(0xFFE07A00);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: const Text("Détail Frais"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Reçu",
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    color: AppColors.bg,
                    child: receiptFullUrl == null
                        ? const Center(
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      _FullImageScreen(url: receiptFullUrl!),
                                ),
                              );
                            },
                            child: Image.network(
                              receiptFullUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 34,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                if (receiptFullUrl != null) ...[
                  const SizedBox(height: 10),
                  const Text(
                    "Tap pour zoom",
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dto.category,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: AppColors.textDark,
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
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _Line(
                  label: "Montant",
                  value: "${dto.amount.toStringAsFixed(2)} ${dto.currency}",
                ),
                _Line(label: "Date", value: dateStr),
                if (dto.note.trim().isNotEmpty)
                  _Line(label: "Note", value: dto.note),
                if (dto.status == "REJECTED" &&
                    (dto.reviewReason ?? "").trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Raison de rejet: ${dto.reviewReason}",
                      style: const TextStyle(
                        color: Color(0xFFE52929),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: child,
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullImageScreen extends StatelessWidget {
  final String url;
  const _FullImageScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Zoom"),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.7,
          maxScale: 4.0,
          child: Image.network(url),
        ),
      ),
    );
  }
}