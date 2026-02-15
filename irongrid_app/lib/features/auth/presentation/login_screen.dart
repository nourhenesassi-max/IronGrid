import 'package:flutter/material.dart';
import '../../../core/storage/secure_store.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/ui/app_widgets.dart';
import '../data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();

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

  /// Mapping UI -> backend
  final Map<String, String> _roleToApi = const {
    "Manager": "MANAGER",
    "RH": "RH",
    "Finance": "FINANCE",
    "Employé": "EMPLOYE",
  };

  /// 🔹 Default role for testing
  String _roleLabel = "Employé";

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// 🔐 LOGIN (TEMP MODE ALLOWS EMPTY FIELDS)
  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    // ✅ TEMPORARY: allow login without email/password
    if (email.isEmpty || pass.isEmpty) {
      final roleApi = _roleToApi[_roleLabel]!;

      await SecureStore.saveRole(roleApi);
      await SecureStore.saveToken("TEMP_TOKEN");

      if (!mounted) return;

      // ✅ Route by role (temporary)
      switch (roleApi) {
        case "EMPLOYE":
          Navigator.pushReplacementNamed(context, "/employe");
          break;
        case "MANAGER":
          Navigator.pushReplacementNamed(context, "/manager");
          break;
        case "RH":
          Navigator.pushReplacementNamed(context, "/rh");
          break;
        case "FINANCE":
          Navigator.pushReplacementNamed(context, "/finance");
          break;
        default:
          Navigator.pushReplacementNamed(context, "/login");
      }
      return;
    }

    // 🔹 Real login when fields filled
    setState(() => _loading = true);
    try {
      final roleApi = _roleToApi[_roleLabel]!;

      final token = await _auth.login(
        role: roleApi,
        email: email,
        password: pass,
      );

      await SecureStore.saveToken(token);
      await SecureStore.saveRole(roleApi);

      if (!mounted) return;

      // ✅ Route by role after real login
      switch (roleApi) {
        case "EMPLOYE":
          Navigator.pushReplacementNamed(context, "/employe");
          break;
        case "MANAGER":
          Navigator.pushReplacementNamed(context, "/manager");
          break;
        case "RH":
          Navigator.pushReplacementNamed(context, "/rh");
          break;
        case "FINANCE":
          Navigator.pushReplacementNamed(context, "/finance");
          break;
        default:
          Navigator.pushReplacementNamed(context, "/login");
      }
    } catch (e) {
      _snack("Erreur: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
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
                  child:
                      const Icon(Icons.factory, color: Colors.white, size: 44),
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
                  style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                ),
                const SizedBox(height: 26),
                _label("Sélectionner votre rôle"),
                const SizedBox(height: 8),
                RoleDropdown(
                  value: _roleLabel,
                  items: _roleLabels,
                  onChanged: (v) => setState(() => _roleLabel = v),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, "/reset-password"),
                    child: const Text(
                      "Mot de passe oublié?",
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
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Se Connecter",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
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
                      onPressed: () => Navigator.pushNamed(context, "/signup"),
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
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text("OU",
                          style: TextStyle(color: AppColors.textMuted)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _snack("Biométrie: à brancher après"),
                    icon: const Icon(Icons.fingerprint, size: 22),
                    label: const Text(
                      "Authentification biométrique",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String s) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          s,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
