import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../data/manager_repository.dart';
import '../widgets/settings_tiles.dart';

class ProfileTab extends StatelessWidget {
  final ManagerRepository repo;
  const ProfileTab({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final profile = repo.getProfile();
    void toast(String msg) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      children: [
        ProfileCard(
          name: profile.name,
          role: profile.role,
          site: profile.site,
          avatarUrl: profile.avatarUrl,
        ),
        const SizedBox(height: 24),
        const Text("Paramètres",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        SettingsTile(
          icon: Icons.person_outline,
          title: "Informations Personnelles",
          onTap: () => toast("Infos personnelles (à brancher)"),
        ),
        const SizedBox(height: 10),
        SettingsTile(
          icon: Icons.notifications_none_outlined,
          title: "Notifications",
          onTap: () => toast("Notifications (à brancher)"),
        ),
        const SizedBox(height: 10),
        const OfflineTile(),
        const SizedBox(height: 10),
        SettingsTile(
          icon: Icons.sync,
          title: "Synchronisation",
          subtitle: "Dernière sync: Il y a 5 min",
          onTap: () => toast("Synchronisation (à brancher)"),
        ),
      ],
    );
  }
}
