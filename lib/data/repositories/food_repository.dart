import 'package:flutter/foundation.dart';
import '../../services/supabase_service.dart';
import '../models/food_entry.dart';

class FoodRepository {
  static const _table = 'food_entries';

  Future<List<FoodEntry>> getEntriesForDate(String uid, DateTime date) async {
    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));

      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .gte('date', start.toIso8601String())
          .lt('date', end.toIso8601String());

      return (response as List)
          .map((e) => FoodEntry.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('FoodRepository.getEntriesForDate error: $e');
      return [];
    }
  }

  Future<void> addEntry(FoodEntry entry) async {
    try {
      await SupabaseService.client.from(_table).insert(entry.toSupabase());
    } catch (e) {
      debugPrint('FoodRepository.addEntry error: $e');
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await SupabaseService.client.from(_table).delete().eq('id', id);
    } catch (e) {
      debugPrint('FoodRepository.deleteEntry error: $e');
    }
  }

  Future<List<FoodEntry>> getEntriesForRange(
      String uid, DateTime start, DateTime end) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String())
          .order('date', ascending: true);

      return (response as List)
          .map((e) => FoodEntry.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('FoodRepository.getEntriesForRange error: $e');
      return [];
    }
  }

  Future<List<FoodEntry>> getRecentEntries(String uid, {int days = 7}) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));

      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .gte('date', cutoff.toIso8601String())
          .order('date', ascending: false);

      return (response as List)
          .map((e) => FoodEntry.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('FoodRepository.getRecentEntries error: $e');
      return [];
    }
  }
}
