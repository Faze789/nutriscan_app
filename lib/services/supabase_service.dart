import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _supabaseUrl = 'https://drntcpqncllhbkonargz.supabase.co';
  static const String _supabaseAnonKey = 'sb_publishable_IlNspkZWGh1pI6ImpCoriA_-FQ70ygj';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
