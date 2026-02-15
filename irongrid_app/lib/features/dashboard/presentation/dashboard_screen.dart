import 'package:flutter/material.dart';
import '../../../core/storage/secure_store.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await SecureStore.clearAll();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, "/");
            }
          },
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
