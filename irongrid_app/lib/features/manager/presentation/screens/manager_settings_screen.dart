import 'package:flutter/material.dart';

import '../../../../core/storage/secure_store.dart';
import '../widgets/manager_bottom_nav.dart';

class ManagerSettingsScreen extends StatelessWidget {
  const ManagerSettingsScreen({super.key});

  static const Color _primaryColor = Color(0xFF3F51B5);
  static const Color _backgroundColor = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            elevation: 0,
            backgroundColor: _primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 20,
                bottom: 16,
              ),
              title: const Text(
                'Parametres Manager',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3F51B5),
                      Color(0xFF5C6BC0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -20,
                      child: _DecorCircle(size: 140, opacity: 0.10),
                    ),
                    Positioned(
                      bottom: -40,
                      left: -30,
                      child: _DecorCircle(size: 120, opacity: 0.08),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 58,
                      child: Text(
                        'Gerez votre profil, votre equipe\net vos outils en toute simplicite',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Compte'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Profil',
                    subtitle: 'Voir et modifier les informations personnelles',
                    onTap: () {
                      Navigator.pushNamed(context, '/manager/profile');
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.group_outlined,
                    title: 'Gestion de equipe',
                    subtitle: 'Gerer les employes et les roles',
                    onTap: () {
                      Navigator.pushNamed(context, '/manager/team');
                    },
                  ),
                  const SizedBox(height: 20),
                  const _SectionTitle('Outils'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.assignment_outlined,
                    title: 'Assigner des taches',
                    subtitle: 'Attribuer des taches aux employes',
                    onTap: () {
                      Navigator.pushNamed(context, '/manager/assign_task');
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.videocam_outlined,
                    title: 'Supervision cameras',
                    subtitle: 'Lister, gerer les DVR et visualiser les flux',
                    onTap: () {
                      Navigator.pushNamed(context, '/manager/surveillance');
                    },
                  ),
                  const SizedBox(height: 20),
                  const _SectionTitle('Session'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Deconnexion',
                    subtitle: 'Se deconnecter de application',
                    isDestructive: true,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ManagerBottomNav(currentIndex: 3),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Deconnexion',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Voulez-vous vraiment vous deconnecter de votre compte ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              await SecureStore.clearSessionOnly();
              if (!context.mounted) {
                return;
              }
              navigator.pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            child: const Text('Se deconnecter'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
        isDestructive ? Colors.redAccent : ManagerSettingsScreen._primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accentColor, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
            color: isDestructive ? Colors.redAccent : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.2,
              color: Colors.grey.shade600,
              height: 1.35,
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey.shade500,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: Colors.grey.shade600,
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorCircle({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
