import '../../services/supabase_service.dart';
import '../models/daily_record.dart';

class DailyRecordRepository {
  static const _table = 'daily_records';

  Future<DailyRecord?> getRecordForDate(String uid, DateTime date) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .eq('date', dateStr)
        .maybeSingle();

    if (response == null) return null;
    return DailyRecord.fromSupabase(response);
  }

  Future<void> saveRecord(DailyRecord record) async {
    await SupabaseService.client.from(_table).upsert(
      record.toSupabase(),
      onConflict: 'user_id,date',
    );
  }

  Future<List<DailyRecord>> getRecentRecords(String uid, {int days = 7}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffStr = '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';

    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .gte('date', cutoffStr)
        .order('date', ascending: true);

    return (response as List)
        .map((e) => DailyRecord.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DailyRecord>> getRecordsForRange(
      String uid, DateTime start, DateTime end) async {
    final startStr =
        '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endStr =
        '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

    final response = await SupabaseService.client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .gte('date', startStr)
        .lte('date', endStr)
        .order('date', ascending: true);

    return (response as List)
        .map((e) => DailyRecord.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteRecord(String id) async {
    await SupabaseService.client.from(_table).delete().eq('id', id);
  }
}
