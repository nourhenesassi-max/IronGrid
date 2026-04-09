import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/storage/secure_store.dart';
import '../../../../core/ui/app_colors.dart';
import '../../../employee/data/me_service.dart';
import '../../../employee/data/models/employee_profile.dart';

class ManagerProfileScreen extends StatefulWidget {
  const ManagerProfileScreen({super.key});

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  final MeService _meService = MeService();

  File? _profileImage;
  EmployeeProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final me = await _meService.getMe();

      final path = await SecureStore.getProfileImagePath();
      File? profileFile;

      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          profileFile = file;
        } else {
          await SecureStore.deleteProfileImagePath();
        }
      }

      if (!mounted) return;

      setState(() {
        _profileImage = profileFile;
        _profile = me;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement profil: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await SecureStore.clearSessionOnly();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
      (route) => false,
    );
  }

  Future<void> _editProfile() async {
    await Navigator.pushNamed(context, "/manager/edit-profile");
    await _loadProfileData();
  }

  ImageProvider? _buildAvatar() {
    if (_profileImage != null) return FileImage(_profileImage!);

    final avatarUrl = _profile?.avatarUrl ?? '';
    if (avatarUrl.isNotEmpty) {
      return NetworkImage(avatarUrl);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textDark,
        title: const Text(
          "Profil",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : profile == null
                ? const Center(child: Text('Aucun profil trouvé'))
                : RefreshIndicator(
                    onRefresh: _loadProfileData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: Column(
                        children: [
                          _buildHeaderCard(profile),
                          const SizedBox(height: 22),
                          _buildSectionTitle("Informations personnelles"),
                          const SizedBox(height: 12),
                          _infoCard(
                            icon: Icons.person_outline_rounded,
                            title: "Nom complet",
                            value: profile.name,
                          ),
                          const SizedBox(height: 12),
                          _infoCard(
                            icon: Icons.email_outlined,
                            title: "Email",
                            value: profile.email,
                          ),
                          const SizedBox(height: 12),
                          _infoCard(
                            icon: Icons.phone_outlined,
                            title: "Numéro de téléphone",
                            value: profile.phone,
                          ),
                          const SizedBox(height: 12),
                          _infoCard(
                            icon: Icons.apartment_outlined,
                            title: "Département",
                            value: profile.department,
                          ),
                          const SizedBox(height: 28),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeaderCard(EmployeeProfile profile) {
    final avatar = _buildAvatar();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.35), width: 2),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white.withOpacity(0.18),
              backgroundImage: avatar,
              child: avatar == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 46,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            profile.email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text(
              "Modifier profil",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text(
              "Déconnexion",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.withOpacity(0.75)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withOpacity(0.04),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primary.withOpacity(0.10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value.trim().isNotEmpty ? value : '-',
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}