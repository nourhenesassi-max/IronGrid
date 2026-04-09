import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/me_service.dart';
import '../widgets/pi_avatar_picker.dart';
import '../widgets/pi_labeled_field.dart';
import '../../data/models/employee_profile.dart';

class PersonalInfoScreen extends StatefulWidget {
  final EmployeeProfile profile;

  const PersonalInfoScreen({
    super.key,
    required this.profile,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _meService = MeService();

  static const Color _bgColor = Color(0xFFF4F7FB);
  static const Color _primary = Color(0xFF0F172A);
  static const Color _secondary = Color(0xFF2563EB);
  static const Color _accent = Color(0xFF7C3AED);
  static const Color _surface = Colors.white;
  static const Color _muted = Color(0xFF64748B);

  late final TextEditingController nom;
  late final TextEditingController prenom;
  late final TextEditingController telephone;
  late final TextEditingController email;
  late final TextEditingController address;
  late final TextEditingController department;

  String? _avatarPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    nom = TextEditingController(text: widget.profile.lastName);
    prenom = TextEditingController(text: widget.profile.firstName);
    telephone = TextEditingController(text: widget.profile.phone);
    email = TextEditingController(text: widget.profile.email);
    address = TextEditingController(text: widget.profile.address);
    department = TextEditingController(text: widget.profile.department);
    _avatarPath = widget.profile.avatarPath;
  }

  @override
  void dispose() {
    nom.dispose();
    prenom.dispose();
    telephone.dispose();
    email.dispose();
    address.dispose();
    department.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    if (_saving) return;

    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );

    if (file == null) return;

    setState(() {
      _avatarPath = file.path;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      String? uploadedAvatarUrl;

      if (_avatarPath != null &&
          _avatarPath!.isNotEmpty &&
          File(_avatarPath!).existsSync()) {
        uploadedAvatarUrl = await _meService.uploadAvatar(_avatarPath!);
      }

      final updated = await _meService.updateMe(
        firstName: prenom.text.trim(),
        lastName: nom.text.trim(),
        email: email.text.trim(),
        phone: telephone.text.trim(),
        address: address.text.trim(),
        department: department.text.trim(),
      );

      final finalProfile = updated.copyWith(
        avatarPath: _avatarPath,
        avatarUrl: (uploadedAvatarUrl != null && uploadedAvatarUrl.isNotEmpty)
            ? uploadedAvatarUrl
            : updated.avatarUrl,
        name: "${prenom.text.trim()} ${nom.text.trim()}".trim(),
        address: address.text.trim(),
        department: department.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, finalProfile);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Erreur: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLocalAvatar = _avatarPath != null &&
        _avatarPath!.isNotEmpty &&
        File(_avatarPath!).existsSync();

    final String liveName =
        "${prenom.text.trim()} ${nom.text.trim()}".trim().isNotEmpty
            ? "${prenom.text.trim()} ${nom.text.trim()}".trim()
            : "Utilisateur";

    final String networkAvatar = widget.profile.avatarUrl.isNotEmpty
        ? widget.profile.avatarUrl
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(liveName)}';

    final ImageProvider<Object> avatarProvider = hasLocalAvatar
        ? FileImage(File(_avatarPath!)) as ImageProvider<Object>
        : NetworkImage(networkAvatar) as ImageProvider<Object>;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          const _TopBackground(),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      children: [
                        _ProfileHeroCard(
                          name: liveName,
                          email: email.text.trim().isNotEmpty
                              ? email.text.trim()
                              : widget.profile.email,
                          avatar: avatarProvider,
                          onPickAvatar: _pickAvatar,
                        ),
                        const SizedBox(height: 18),
                        _FormCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionHeader(
                                title: "Informations personnelles",
                                subtitle:
                                    "Mettez à jour vos données de profil en toute sécurité.",
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 18),
                              PiLabeledField(
                                label: "Nom",
                                controller: nom,
                                hintText: "Ex: Dupont",
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? "Nom requis"
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              PiLabeledField(
                                label: "Prénom",
                                controller: prenom,
                                hintText: "Ex: Jean",
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? "Prénom requis"
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              PiLabeledField(
                                label: "Email",
                                controller: email,
                                hintText: "ex: jean@mail.com",
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  final s = (v ?? "").trim();
                                  if (s.isEmpty) return "Email requis";
                                  return RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(s)
                                      ? null
                                      : "Email invalide";
                                },
                              ),
                              const SizedBox(height: 14),
                              PiLabeledField(
                                label: "Téléphone",
                                controller: telephone,
                                hintText: "Ex: 06 00 00 00 00",
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 14),
                              PiLabeledField(
                                label: "Adresse",
                                controller: address,
                                hintText: "Ex: Tunis, Ariana...",
                              ),
                              const SizedBox(height: 14),
                              PiLabeledField(
                                label: "Département",
                                controller: department,
                                hintText: "Ex: Informatique",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _InfoNotice(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                disabledBackgroundColor: _primary.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_outlined, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Enregistrer les modifications",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBackground extends StatelessWidget {
  const _TopBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _PersonalInfoScreenState._primary,
            _PersonalInfoScreenState._secondary,
            _PersonalInfoScreenState._accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -20,
            child: _DecorBubble(
              size: 170,
              opacity: 0.10,
            ),
          ),
          Positioned(
            top: 120,
            left: -30,
            child: _DecorBubble(
              size: 130,
              opacity: 0.08,
            ),
          ),
          Positioned(
            top: 62,
            right: 80,
            child: _DecorBubble(
              size: 28,
              opacity: 0.16,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        children: [
          Material(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(16),
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Mon profil",
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final String name;
  final String email;
  final ImageProvider<Object> avatar;
  final VoidCallback onPickAvatar;

  const _ProfileHeroCard({
    required this.name,
    required this.email,
    required this.avatar,
    required this.onPickAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _PersonalInfoScreenState._secondary,
                  _PersonalInfoScreenState._accent,
                ],
              ),
            ),
            child: PiAvatarPicker(
              avatar: avatar,
              onPick: onPickAvatar,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    "Profil professionnel",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _PersonalInfoScreenState._primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 21,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: _PersonalInfoScreenState._primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email.trim().isNotEmpty
                      ? email
                      : "Aucune adresse email renseignée",
                  style: const TextStyle(
                    color: _PersonalInfoScreenState._muted,
                    fontSize: 13.2,
                    height: 1.35,
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

class _FormCard extends StatelessWidget {
  final Widget child;

  const _FormCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _PersonalInfoScreenState._surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _PersonalInfoScreenState._primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: _PersonalInfoScreenState._primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: _PersonalInfoScreenState._primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.8,
                  height: 1.35,
                  color: _PersonalInfoScreenState._muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoNotice extends StatelessWidget {
  const _InfoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD7E5FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF2563EB),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Le comportement reste inchangé : avatar, validations, sauvegarde API et retour du profil mis à jour.",
              style: TextStyle(
                fontSize: 12.8,
                height: 1.4,
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorBubble extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorBubble({
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
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}