import 'package:flutter/foundation.dart' show kIsWeb;
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
    // On web, use the current origin so the reset link redirects back
    // to the deployed app (e.g. https://nutriscan-app-alpha.vercel.app)
    // instead of Supabase's default Site URL (localhost:3000).
    final redirectTo = kIsWeb ? Uri.base.origin : null;
    await _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
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
