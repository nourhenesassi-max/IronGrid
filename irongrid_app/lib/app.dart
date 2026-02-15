import 'package:flutter/material.dart';

import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';

import 'features/employe/presentation/screens/employee_dashboard_screen.dart';
import 'features/employe/presentation/screens/employe_profile_screen.dart';

import 'features/manager/presentation/screens/manager_screen.dart';
import 'features/rh/presentation/screens/rh_screen.dart';
import 'features/finance/presentation/screens/finance_screen.dart';

import 'features/frais/presentation/screens/employe_scan_frais_screen.dart';
import 'features/frais/presentation/screens/employe_frais_list_screen.dart';

class IndustrialManagerApp extends StatelessWidget {
  const IndustrialManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IronGrid',
      initialRoute: "/login",
      routes: {
        "/login": (_) => const LoginScreen(),
        "/signup": (_) => const SignUpScreen(),
        "/employe": (_) => const EmployeeDashboardScreen(),
        "/employe-profile": (_) => const EmployeProfileScreen(),
        "/employe-scan-frais": (_) => EmployeScanFraisScreen(),
        "/employe-frais": (_) => EmployeFraisListScreen(),
        "/manager": (_) => const ManagerScreen(),
        "/rh": (_) => const RHScreen(),
        "/finance": (_) => const FinanceScreen(),
      },
    );
  }
}
