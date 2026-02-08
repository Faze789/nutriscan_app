import 'package:flutter/foundation.dart';
import '../../services/supabase_service.dart';
import '../models/user_reminder.dart';

class ReminderRepository {
  static const _table = 'user_reminders';

  Future<List<UserReminder>> getReminders(String uid) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .order('type', ascending: true);

      return (response as List)
          .map((e) => UserReminder.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ReminderRepository.getReminders error: $e');
      return [];
    }
  }

  Future<void> saveReminder(UserReminder reminder) async {
    try {
      await SupabaseService.client.from(_table).upsert(
        reminder.toSupabase(),
        onConflict: 'user_id,type',
      );
    } catch (e) {
      debugPrint('ReminderRepository.saveReminder error: $e');
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await SupabaseService.client.from(_table).delete().eq('id', id);
    } catch (e) {
      debugPrint('ReminderRepository.deleteReminder error: $e');
    }
  }
}
