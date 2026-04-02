import 'package:flutter/material.dart';

import 'src/screens/surveillance_home_screen.dart';

void main() {
  runApp(const IronGridSurveillanceApp());
}

class IronGridSurveillanceApp extends StatelessWidget {
  const IronGridSurveillanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1F3C88);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IronGrid Surveillance',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFFF4F7FC),
          foregroundColor: Color(0xFF0D1B2A),
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: seed,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const SurveillanceHomeScreen(),
    );
  }
}
