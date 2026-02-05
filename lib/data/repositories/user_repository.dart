import '../../services/supabase_service.dart';
import '../models/user_profile.dart';

class UserRepository {
  static const _table = 'user_profiles';

  Future<UserProfile?> getUser(String uid) async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (response == null) return null;
    return UserProfile.fromSupabase(response);
  }

  Future<void> saveUser(UserProfile user) async {
    await SupabaseService.client.from(_table).upsert(user.toSupabase());
  }

  Future<void> deleteUser(String uid) async {
    await SupabaseService.client.from(_table).delete().eq('id', uid);
  }
}
