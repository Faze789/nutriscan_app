import 'package:flutter/foundation.dart';
import '../../services/supabase_service.dart';
import '../models/user_profile.dart';

class UserRepository {
  static const _table = 'user_profiles';

  Future<UserProfile?> getUser(String uid) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (response == null) return null;
      return UserProfile.fromSupabase(response);
    } catch (e) {
      debugPrint('UserRepository.getUser error: $e');
      return null;
    }
  }

  Future<void> saveUser(UserProfile user) async {
    try {
      await SupabaseService.client.from(_table).upsert(user.toSupabase());
    } catch (e) {
      debugPrint('UserRepository.saveUser error: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await SupabaseService.client.from(_table).delete().eq('id', uid);
    } catch (e) {
      debugPrint('UserRepository.deleteUser error: $e');
    }
  }
}
