import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/storage/secure_store.dart';
import '../../../../core/ui/app_colors.dart';
import '../../../../core/ui/app_widgets.dart';
import '../../../employee/data/me_service.dart';
import '../../../employee/data/models/employee_profile.dart';

class ManagerEditProfileScreen extends StatefulWidget {
  const ManagerEditProfileScreen({super.key});

  @override
  State<ManagerEditProfileScreen> createState() =>
      _ManagerEditProfileScreenState();
}

class _ManagerEditProfileScreenState extends State<ManagerEditProfileScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final MeService _meService = MeService();

  File? _profileImage;
  String _avatarUrl = '';
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfileFromApi();
  }

  Future<void> _loadProfileFromApi() async {
    try {
      final EmployeeProfile me = await _meService.getMe();

      _firstNameCtrl.text = me.firstName;
      _lastNameCtrl.text = me.lastName;
      _emailCtrl.text = me.email;
      _phoneCtrl.text = me.phone;
      _addressCtrl.text = me.address;
      _departmentCtrl.text = me.department;
      _avatarUrl = me.avatarUrl;

      final localImagePath = await SecureStore.getProfileImagePath();
      if (localImagePath != null && localImagePath.isNotEmpty) {
        final file = File(localImagePath);
        if (await file.exists()) {
          _profileImage = file;
        } else {
          await SecureStore.deleteProfileImagePath();
        }
      }

      await _saveProfileLocally(me);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur chargement profil: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveProfileLocally(EmployeeProfile me) async {
    await SecureStore.saveProfile(
      name: me.name,
      email: me.email,
      phone: me.phone,
      department: me.department,
    );
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      final avatarUrl = await _meService.uploadAvatar(picked.path);

      if (!mounted) return;

      setState(() {
        _profileImage = File(picked.path);
        _avatarUrl = avatarUrl;
        _isUploadingPhoto = false;
      });

      await SecureStore.saveProfileImagePath(picked.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo enregistrée avec succès'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l’upload de l’image: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final department = _departmentCtrl.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prénom, nom et email sont obligatoires'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      final updated = await _meService.updateMe(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        department: department,
      );

      await _saveProfileLocally(updated);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _firstNameCtrl.text = updated.firstName;
        _lastNameCtrl.text = updated.lastName;
        _emailCtrl.text = updated.email;
        _phoneCtrl.text = updated.phone;
        _addressCtrl.text = updated.address;
        _departmentCtrl.text = updated.department;
        if (updated.avatarUrl.isNotEmpty) {
          _avatarUrl = updated.avatarUrl;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil mis à jour avec succès'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await SecureStore.clearSessionOnly();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _departmentCtrl.dispose();
    super.dispose();
  }

  ImageProvider? _buildAvatarImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    }

    if (_avatarUrl.isNotEmpty) {
      return NetworkImage(_avatarUrl);
    }

    return null;
  }

  String _fullName() {
    return '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        titleSpacing: 20,
        title: const Text(
          'Modifier profil',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBanner(),
                    const SizedBox(height: 22),
                    _buildPhotoSection(),
                    const SizedBox(height: 22),
                    _buildFormSection(),
                    const SizedBox(height: 26),
                    _buildActions(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            const Color(0xFF7B61FF),
            const Color(0xFFFF6BAA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personnalisez votre profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Ajoutez une photo et gardez vos informations à jour.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    final avatarImage = _buildAvatarImage();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF4E8),
            Color(0xFFF4EEFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isUploadingPhoto ? null : _pickImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFA94D),
                        Color(0xFF7B61FF),
                        Color(0xFFFF6BAA),
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: AppColors.primary.withOpacity(0.9),
                          )
                        : null,
                  ),
                ),
                if (_isUploadingPhoto)
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _fullName().isNotEmpty ? _fullName() : 'Manager',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Touchez la photo pour la modifier',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textDark.withOpacity(0.65),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFF1E7FF),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7B61FF),
                      Color(0xFFFF6BAA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations personnelles',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ces données seront enregistrées dans la base.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppInput(
            hint: 'Prénom',
            icon: Icons.person_outline,
            controller: _firstNameCtrl,
          ),
          const SizedBox(height: 14),
          AppInput(
            hint: 'Nom',
            icon: Icons.person_outline,
            controller: _lastNameCtrl,
          ),
          const SizedBox(height: 14),
          AppInput(
            hint: 'Email',
            icon: Icons.email_outlined,
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          AppInput(
            hint: 'Téléphone',
            icon: Icons.phone_outlined,
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          AppInput(
            hint: 'Adresse',
            icon: Icons.location_on_outlined,
            controller: _addressCtrl,
          ),
          const SizedBox(height: 14),
          AppInput(
            hint: 'Département',
            icon: Icons.apartment_outlined,
            controller: _departmentCtrl,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7B61FF),
                    Color(0xFFFF6BAA),
                    Color(0xFFFF8E53),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B61FF).withOpacity(0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 20, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Enregistrer les modifications',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'Déconnexion',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: const Color(0xFFFFF0F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}