import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

class ExpenseCaptureCardWidget extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onAuto;
  final VoidCallback onCat;

  const ExpenseCaptureCardWidget({
    super.key,
    required this.onScan,
    required this.onAuto,
    required this.onCat,
  });

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
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Capture de Frais",
              style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text(
            "Scannez vos reçus et factures pour un\nremboursement rapide",
            style: TextStyle(
                color: AppColors.textMuted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text("Scanner un Reçu",
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAuto,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side:
                        BorderSide(color: AppColors.textMuted.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                  label: const Text("Traitement\nautomatique",
                      textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCat,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side:
                        BorderSide(color: AppColors.textMuted.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.category_outlined, size: 18),
                  label:
                      const Text("Catégorisation", textAlign: TextAlign.center),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
