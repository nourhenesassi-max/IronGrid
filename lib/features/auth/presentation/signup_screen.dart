import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_widgets.dart';
import '../data/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = AuthService();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  final List<String> _roleLabels = const [
    "Manager",
    "RH",
    "Finance",
    "Employé",
  ];

  /// ✅ Must match login mapping
  final Map<String, String> _roleToApi = const {
    "Manager": "MANAGER",
    "RH": "RH",
    "Finance": "FINANCE",
    "Employé": "EMPLOYE",
  };

  String _roleLabel = "Employé";

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signup() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      _snack("Veuillez remplir tous les champs.");
      return;
    }

    setState(() => _loading = true);
    try {
      final roleApi = _roleToApi[_roleLabel]!;

      await _auth.signup(
        role: roleApi,
        name: name,
        email: email,
        password: pass,
      );

      if (!mounted) return;

      _snack("Compte créé. Connectez-vous.");
      Navigator.pushReplacementNamed(context, "/login"); // ✅ go to login
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: const Text("Créer un compte"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Rôle",
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              RoleDropdown(
                value: _roleLabel,
                items: _roleLabels,
                onChanged: (v) => setState(() => _roleLabel = v),
              ),
              const SizedBox(height: 16),
              AppInput(
                hint: "Nom complet",
                icon: Icons.badge_outlined,
                controller: _nameCtrl,
              ),
              const SizedBox(height: 14),
              AppInput(
                hint: "Email",
                icon: Icons.person_outline,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              AppInput(
                hint: "Mot de passe",
                icon: Icons.lock_outline,
                controller: _passCtrl,
                obscure: _obscure,
                suffix: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          "Créer le compte",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
