import '../../services/supabase_service.dart';
import '../models/user_reminder.dart';

class ReminderRepository {
  static const _table = 'user_reminders';

  Future<List<UserReminder>> getReminders(String uid) async {
    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .order('type', ascending: true);

    return (response as List)
        .map((e) => UserReminder.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveReminder(UserReminder reminder) async {
    await SupabaseService.client.from(_table).upsert(
      reminder.toSupabase(),
      onConflict: 'user_id,type',
    );
  }

  Future<void> deleteReminder(String id) async {
    await SupabaseService.client.from(_table).delete().eq('id', id);
  }
}
