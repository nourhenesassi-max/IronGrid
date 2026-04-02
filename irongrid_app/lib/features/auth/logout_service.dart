import '../../core/storage/secure_store.dart';

class LogoutService {
  static Future<void> logout() async {
    await SecureStore.clearAll();
  }
}