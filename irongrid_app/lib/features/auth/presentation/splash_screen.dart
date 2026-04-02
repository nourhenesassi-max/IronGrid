import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../core/storage/secure_store.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(seconds: 2));

    final savedBaseUrl = await SecureStore.getApiBaseUrl();
    if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
      ApiConfig.setActiveBaseUrl(savedBaseUrl);
    }

    if (!mounted) return;

    // ✅ Keep token (do NOT delete)
    final token = await SecureStore.getToken();

    if (!mounted) return;

    // 🔥 ALWAYS go to welcome first
    Navigator.pushReplacementNamed(
      context,
      '/welcome',
      arguments: {
        'hasToken': token != null && token.isNotEmpty,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
