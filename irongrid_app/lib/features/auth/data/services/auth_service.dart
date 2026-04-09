import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_store.dart';

class AuthResult {
  final String token;
  final String role;
  final String email;

  AuthResult({
    required this.token,
    required this.role,
    required this.email,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final token =
        (json['token'] ?? json['accessToken'] ?? json['jwt'] ?? '').toString();

    final role = (json['role'] ??
            (json['user'] is Map<String, dynamic>
                ? json['user']['role']
                : null) ??
            '')
        .toString();

    final email = (json['email'] ??
            (json['user'] is Map<String, dynamic>
                ? json['user']['email']
                : null) ??
            '')
        .toString();

    return AuthResult(
      token: token,
      role: role,
      email: email,
    );
  }
}

class AuthService {
  final ApiClient _api = ApiClient();

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      '/api/auth/login',
      withAuth: false,
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    ) as Map<String, dynamic>;

    final result = AuthResult.fromJson(data);

    if (result.token.isEmpty) {
      throw Exception('Token manquant dans la réponse backend.');
    }

    if (result.role.isEmpty) {
      throw Exception('Rôle manquant dans la réponse backend.');
    }

    await SecureStore.saveToken(result.token);
    await SecureStore.saveRole(result.role.toUpperCase());

    return result;
  }

  Future<String> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      '/api/auth/signup',
      withAuth: false,
      body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    ) as Map<String, dynamic>;

    return (data['message'] ??
            "Votre demande d'inscription est en attente de l'acceptation par l'administrateur.")
        .toString();
  }

  Future<String> forgotPassword({
    required String email,
  }) async {
    final data = await _api.post(
      '/api/auth/forgot-password',
      withAuth: false,
      body: {
        'email': email.trim().toLowerCase(),
      },
    ) as Map<String, dynamic>;

    return (data['message'] ??
            'Si cette adresse existe, le code de réinitialisation a été envoyé.')
        .toString();
  }

  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final data = await _api.post(
      '/api/auth/reset-password',
      withAuth: false,
      body: {
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        'newPassword': newPassword,
      },
    ) as Map<String, dynamic>;

    return (data['message'] ?? 'Mot de passe modifié avec succès').toString();
  }

  Future<void> logout() async {
    await SecureStore.clearAll();
  }
}
