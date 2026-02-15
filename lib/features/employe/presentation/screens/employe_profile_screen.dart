import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/employee_repository.dart';
import '../widgets/employe_profile_header_card.dart';
import '../widgets/employe_settings_tiles.dart';
import '../widgets/employee_bottom_nav.dart';

class EmployeProfileScreen extends StatefulWidget {
  const EmployeProfileScreen({super.key});

  @override
  State<EmployeProfileScreen> createState() => _EmployeProfileScreenState();
}

class _EmployeProfileScreenState extends State<EmployeProfileScreen> {
  final _repo = EmployeeRepository();
  int _bottomIndex = 4; // profile selected

  @override
  Widget build(BuildContext context) {
    final profile = _repo.getProfile();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: const Text("Profil"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          EmployeProfileHeaderCard(profile: profile), //error
          const SizedBox(height: 22),
          const Text(
            "Paramètres",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          EmployeSettingsTile(
            icon: Icons.person_outline,
            title: "Informations Personnelles",
            onTap: () => _toast("Informations Personnelles (à brancher)"),
          ),
          const SizedBox(height: 10),
          EmployeSettingsTile(
            icon: Icons.notifications_none_outlined,
            title: "Notifications",
            onTap: () => _toast("Notifications (à brancher)"),
          ),
          const SizedBox(height: 10),
          const EmployeOfflineTile(),
          const SizedBox(height: 10),
          EmployeSettingsTile(
            icon: Icons.sync,
            title: "Synchronisation",
            subtitle: "Dernière sync: Il y a 5 min",
            onTap: () => _toast("Synchronisation (à brancher)"),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _toast("Déconnexion (à brancher)"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE52929),
                side: const BorderSide(color: Color(0xFFE52929), width: 1.6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Déconnexion",
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: EmployeeBottomNav(
        currentIndex: _bottomIndex,
        onTap: (i) => _handleBottomNav(context, i),
      ),
    );
  }

  void _handleBottomNav(BuildContext context, int index) {
    // If user taps profile again -> do nothing
    if (index == 4) return;

    // Navigate to dashboard (or other screens later)
    if (index == 0) {
      Navigator.pushReplacementNamed(context, "/employe");
      return;
    }

    _toast("Bottom nav: $index (à brancher)");
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
