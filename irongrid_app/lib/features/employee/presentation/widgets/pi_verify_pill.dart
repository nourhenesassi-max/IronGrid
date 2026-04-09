import 'package:flutter/material.dart';

class PiVerifyPill extends StatelessWidget {
  final bool isVerified;
  final VoidCallback? onTap;

  const PiVerifyPill({
    super.key,
    required this.isVerified,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0B8E5B).withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "Vérifié",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Color(0xFF0B8E5B),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "Vérifier",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}