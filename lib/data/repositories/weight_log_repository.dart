import 'package:flutter/foundation.dart';
import '../../services/supabase_service.dart';
import '../models/weight_log.dart';

class WeightLogRepository {
  static const _table = 'weight_logs';

  Future<List<WeightLog>> getLogs(String uid, {int limit = 90}) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .order('date', ascending: false)
          .limit(limit);

      return (response as List)
          .map((e) => WeightLog.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('WeightLogRepository.getLogs error: $e');
      return [];
    }
  }

  Future<WeightLog?> getLatest(String uid) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .order('date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return WeightLog.fromSupabase(response);
    } catch (e) {
      debugPrint('WeightLogRepository.getLatest error: $e');
      return null;
    }
  }

  Future<void> addLog(WeightLog log) async {
    try {
      await SupabaseService.client.from(_table).upsert(
        log.toSupabase(),
        onConflict: 'user_id,date',
      );
    } catch (e) {
      debugPrint('WeightLogRepository.addLog error: $e');
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      await SupabaseService.client.from(_table).delete().eq('id', id);
    } catch (e) {
      debugPrint('WeightLogRepository.deleteLog error: $e');
    }
  }

  Future<List<WeightLog>> getLogsForRange(
      String uid, DateTime start, DateTime end) async {
    try {
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
          .map((e) => WeightLog.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('WeightLogRepository.getLogsForRange error: $e');
      return [];
    }
  }
}
