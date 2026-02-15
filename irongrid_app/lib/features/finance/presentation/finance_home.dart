import 'package:flutter/material.dart';
import '../data/finance_service.dart';

class FinanceHome extends StatelessWidget {
  const FinanceHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Finance")),
      body: FutureBuilder(
        future: FinanceService().home(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          final data = snapshot.data as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text("Bienvenue Finance ✅\n$data"),
          );
        },
      ),
    );
  }
}
