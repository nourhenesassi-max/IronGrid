import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'token';
  static const String _roleKey = 'role';
  static const String _apiBaseUrlKey = 'api_base_url';
  static const String _profileImagePathKey = 'profile_image_path';

  static const String _profileNameKey = 'profile_name';
  static const String _profileEmailKey = 'profile_email';
  static const String _profilePhoneKey = 'profile_phone';
  static const String _profileDepartmentKey = 'profile_department';

  // Real account / login manager info
  static const String _managerNameKey = 'manager_name';
  static const String _managerEmailKey = 'manager_email';
  static const String _managerPhoneKey = 'manager_phone';
  static const String _managerRoleKey = 'manager_role';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> writeToken(String token) async {
    await saveToken(token);
  }

  static Future<String?> readToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<String?> getToken() async {
    return readToken();
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _managerRoleKey, value: role);
  }

  static Future<String?> readRole() async {
    return _storage.read(key: _roleKey);
  }

  static Future<String?> getRole() async {
    final managerRole = await _storage.read(key: _managerRoleKey);
    if (managerRole != null && managerRole.isNotEmpty) {
      return managerRole;
    }
    return readRole();
  }

  static Future<void> deleteRole() async {
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _managerRoleKey);
  }

  static Future<void> saveApiBaseUrl(String value) async {
    await _storage.write(key: _apiBaseUrlKey, value: value);
  }

  static Future<String?> getApiBaseUrl() async {
    return _storage.read(key: _apiBaseUrlKey);
  }

  static Future<void> deleteApiBaseUrl() async {
    await _storage.delete(key: _apiBaseUrlKey);
  }

  // Profile image
  static Future<void> saveProfileImagePath(String path) async {
    await _storage.write(key: _profileImagePathKey, value: path);
  }

  static Future<void> writeProfileImagePath(String path) async {
    await saveProfileImagePath(path);
  }

  static Future<String?> readProfileImagePath() async {
    return _storage.read(key: _profileImagePathKey);
  }

  static Future<String?> getProfileImagePath() async {
    return readProfileImagePath();
  }

  static Future<void> deleteProfileImagePath() async {
    await _storage.delete(key: _profileImagePathKey);
  }

  // Editable profile data
  static Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
    required String department,
  }) async {
    await _storage.write(key: _profileNameKey, value: name);
    await _storage.write(key: _profileEmailKey, value: email);
    await _storage.write(key: _profilePhoneKey, value: phone);
    await _storage.write(key: _profileDepartmentKey, value: department);
  }

  static Future<void> saveProfileWithoutEmail({
    required String name,
    required String phone,
    required String department,
  }) async {
    await _storage.write(key: _profileNameKey, value: name);
    await _storage.write(key: _profilePhoneKey, value: phone);
    await _storage.write(key: _profileDepartmentKey, value: department);
  }

  static Future<String?> getProfileName() async {
    return _storage.read(key: _profileNameKey);
  }

  static Future<String?> getProfileEmail() async {
    return _storage.read(key: _profileEmailKey);
  }

  static Future<String?> getProfilePhone() async {
    return _storage.read(key: _profilePhoneKey);
  }

  static Future<String?> getProfileDepartment() async {
    return _storage.read(key: _profileDepartmentKey);
  }

  static Future<void> deleteProfileData() async {
    await _storage.delete(key: _profileNameKey);
    await _storage.delete(key: _profileEmailKey);
    await _storage.delete(key: _profilePhoneKey);
    await _storage.delete(key: _profileDepartmentKey);
  }

  // Real manager/account data from login/API
  static Future<void> saveManagerData({
    required String name,
    required String email,
    required String phone,
    required String role,
  }) async {
    await _storage.write(key: _managerNameKey, value: name);
    await _storage.write(key: _managerEmailKey, value: email);
    await _storage.write(key: _managerPhoneKey, value: phone);
    await _storage.write(key: _managerRoleKey, value: role);

    // Backward compatibility
    await _storage.write(key: _roleKey, value: role);
  }

  static Future<void> saveManagerName(String name) async {
    await _storage.write(key: _managerNameKey, value: name);
  }

  static Future<void> saveManagerEmail(String email) async {
    await _storage.write(key: _managerEmailKey, value: email);
  }

  static Future<void> saveManagerPhone(String phone) async {
    await _storage.write(key: _managerPhoneKey, value: phone);
  }

  static Future<void> saveManagerRole(String role) async {
    await _storage.write(key: _managerRoleKey, value: role);
    await _storage.write(key: _roleKey, value: role);
  }

  static Future<String?> getManagerName() async {
    return _storage.read(key: _managerNameKey);
  }

  static Future<String?> getManagerEmail() async {
    return _storage.read(key: _managerEmailKey);
  }

  static Future<String?> getManagerPhone() async {
    return _storage.read(key: _managerPhoneKey);
  }

  static Future<String?> getManagerRole() async {
    return _storage.read(key: _managerRoleKey);
  }

  static Future<void> deleteManagerData() async {
    await _storage.delete(key: _managerNameKey);
    await _storage.delete(key: _managerEmailKey);
    await _storage.delete(key: _managerPhoneKey);
    await _storage.delete(key: _managerRoleKey);
  }

  // Clears only login/session data, keeps profile and image
  static Future<void> clearSessionOnly() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _apiBaseUrlKey);

    await _storage.delete(key: _managerNameKey);
    await _storage.delete(key: _managerEmailKey);
    await _storage.delete(key: _managerPhoneKey);
    await _storage.delete(key: _managerRoleKey);
  }

  // Clears session and editable profile text, but keeps image
  static Future<void> clearSessionKeepProfileImage() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _apiBaseUrlKey);

    await _storage.delete(key: _managerNameKey);
    await _storage.delete(key: _managerEmailKey);
    await _storage.delete(key: _managerPhoneKey);
    await _storage.delete(key: _managerRoleKey);

    await _storage.delete(key: _profileNameKey);
    await _storage.delete(key: _profileEmailKey);
    await _storage.delete(key: _profilePhoneKey);
    await _storage.delete(key: _profileDepartmentKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<void> debugPrintStoredAuth() async {
    final token = await readToken();
    final role = await readRole();

    final profileName = await getProfileName();
    final profileEmail = await getProfileEmail();
    final profilePhone = await getProfilePhone();
    final profileDepartment = await getProfileDepartment();
    final imagePath = await getProfileImagePath();

    final managerName = await getManagerName();
    final managerEmail = await getManagerEmail();
    final managerPhone = await getManagerPhone();
    final managerRole = await getManagerRole();

    debugPrint(
      'SECURE STORE token exists = ${token != null && token.isNotEmpty}',
    );
    debugPrint('SECURE STORE role = $role');

    debugPrint('SECURE STORE profileName = $profileName');
    debugPrint('SECURE STORE profileEmail = $profileEmail');
    debugPrint('SECURE STORE profilePhone = $profilePhone');
    debugPrint('SECURE STORE profileDepartment = $profileDepartment');
    debugPrint('SECURE STORE imagePath = $imagePath');

    debugPrint('SECURE STORE managerName = $managerName');
    debugPrint('SECURE STORE managerEmail = $managerEmail');
    debugPrint('SECURE STORE managerPhone = $managerPhone');
    debugPrint('SECURE STORE managerRole = $managerRole');
  }
}
