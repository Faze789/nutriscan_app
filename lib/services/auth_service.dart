import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  SupabaseClient get _client => SupabaseService.client;

  Future<bool> isLoggedIn() async {
    return _client.auth.currentUser != null;
  }

  Future<String?> getCurrentUid() async {
    return _client.auth.currentUser?.id;
  }

  Future<String> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    if (response.user == null) {
      throw Exception('Sign up failed');
    }

    return response.user!.id;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Invalid email or password');
    }

    return response.user!.id;
  }

  Future<void> resetPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword({required String newPassword}) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Future<String?> getUserName() async {
    return _client.auth.currentUser?.userMetadata?['name'] as String?;
  }

  Future<String?> getUserEmail() async {
    return _client.auth.currentUser?.email;
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
