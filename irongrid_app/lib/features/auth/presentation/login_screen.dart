import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/secure_store.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_widgets.dart';
import '../data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return "Veuillez saisir votre email.";
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email)) return "Adresse email invalide.";
    return null;
  }

  Future<void> _saveAuthSession({
    required String token,
    required String role,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final existingImagePath = await SecureStore.getProfileImagePath();
    final existingProfileName = await SecureStore.getProfileName();
    final existingProfileEmail = await SecureStore.getProfileEmail();
    final existingProfilePhone = await SecureStore.getProfilePhone();
    final existingProfileDepartment = await SecureStore.getProfileDepartment();

    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('email', email);

    await SecureStore.saveToken(token);
    await SecureStore.saveRole(role);
    await SecureStore.saveManagerEmail(email);
    await SecureStore.saveManagerRole(role);

    final existingManagerName = await SecureStore.getManagerName();
    final existingManagerPhone = await SecureStore.getManagerPhone();

    if (existingManagerName == null) {
      await SecureStore.saveManagerName('');
    }

    if (existingManagerPhone == null) {
      await SecureStore.saveManagerPhone('');
    }

    if (existingImagePath != null && existingImagePath.isNotEmpty) {
      await SecureStore.saveProfileImagePath(existingImagePath);
    }

    if (existingProfileName != null ||
        existingProfileEmail != null ||
        existingProfilePhone != null ||
        existingProfileDepartment != null) {
      await SecureStore.saveProfile(
        name: existingProfileName ?? '',
        email: existingProfileEmail ?? '',
        phone: existingProfilePhone ?? '',
        department: existingProfileDepartment ?? '',
      );
    }
  }

  void _goToHomeByRole(String roleApi) {
    if (!mounted) return;

    switch (roleApi.toUpperCase()) {
      case "ADMIN":
        Navigator.pushNamedAndRemoveUntil(context, "/admin", (route) => false);
        break;
      case "EMPLOYE":
      case "EMPLOYEE":
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/employe",
          (route) => false,
        );
        break;
      case "MANAGER":
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/manager",
          (route) => false,
        );
        break;
      case "RH":
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/rh/dashboard",
          (route) => false,
        );
        break;
      case "FINANCE":
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/finance",
          (route) => false,
        );
        break;
      default:
        _snack("Rôle non reconnu : $roleApi");
    }
  }

  Future<void> _login() async {
    if (_loading) return;

    final email = _emailCtrl.text.trim().toLowerCase();
    final pass = _passCtrl.text.trim();

    final emailError = _validateEmail(email);
    if (emailError != null) {
      _snack(emailError);
      return;
    }

    if (pass.isEmpty) {
      _snack("Veuillez saisir votre mot de passe.");
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await _auth.login(
        email: email,
        password: pass,
      );

      await _saveAuthSession(
        token: result.token,
        role: result.role,
        email: result.email,
      );

      if (!mounted) return;

      _snack("Connexion réussie");
      await Future.delayed(const Duration(milliseconds: 300));

      _goToHomeByRole(result.role);
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.factory,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "IronGrid",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  "Bienvenue",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Connectez-vous pour continuer",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 26),
                AppInput(
                  hint: "Email",
                  icon: Icons.email_outlined,
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
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.pushNamed(context, "/reset-password"),
                    child: const Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
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
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.4,
                            ),
                          )
                        : const Text(
                            "Se connecter",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Pas de compte ? ",
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.pushNamed(context, "/signup"),
                      child: const Text(
                        "Créer un compte",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}