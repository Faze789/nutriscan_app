import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Mock authentication service with local session persistence.
/// Drop-in replaceable with Firebase Auth.
class AuthService {
  static const _keyUid = 'auth_uid';
  static const _keyEmail = 'auth_email';
  static const _keyName = 'auth_name';
  static const _keyLoggedIn = 'auth_logged_in';

  final Uuid _uuid = const Uuid();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Check if user is logged in.
  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  /// Get current user UID.
  Future<String?> getCurrentUid() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUid);
  }

  /// Mock sign-up: generates a UID and persists session.
  Future<String> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // In production, replace with Firebase Auth createUserWithEmailAndPassword
    final uid = _uuid.v4();
    final prefs = await _prefs;
    await prefs.setString(_keyUid, uid);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyName, name);
    await prefs.setBool(_keyLoggedIn, true);
    return uid;
  }

  /// Mock login: validates against stored email (demo only).
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final prefs = await _prefs;
    final storedEmail = prefs.getString(_keyEmail);

    if (storedEmail == null) {
      throw Exception('No account found. Please sign up first.');
    }
    if (storedEmail != email) {
      throw Exception('Invalid email or password.');
    }

    await prefs.setBool(_keyLoggedIn, true);
    return prefs.getString(_keyUid)!;
  }

  /// Logout: clears session flag (keeps account data for re-login).
  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.setBool(_keyLoggedIn, false);
  }

  /// Get stored user name.
  Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_keyName);
  }

  /// Get stored email.
  Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_keyEmail);
  }
}
