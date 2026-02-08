import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../services/supabase_service.dart';
import '../models/water_intake.dart';

class WaterIntakeRepository {
  static const _table = 'daily_water_intake';

  Future<DailyWaterIntake?> getForDate(String uid, DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .eq('date', dateStr)
          .maybeSingle();

      if (response == null) return null;
      return DailyWaterIntake.fromSupabase(response);
    } catch (e) {
      debugPrint('WaterIntakeRepository.getForDate error: $e');
      return null;
    }
  }

  Future<DailyWaterIntake> addWater(String uid, DateTime date, double ml) async {
    try {
      final existing = await getForDate(uid, date);

      if (existing != null) {
        final newEntries = [...existing.entries, WaterEntry(ml: ml)];
        final updated = existing.copyWith(
          totalMl: existing.totalMl + ml,
          entries: newEntries,
        );
        await SupabaseService.client.from(_table).upsert(
          updated.toSupabase(),
          onConflict: 'user_id,date',
        );
        return updated;
      } else {
        final intake = DailyWaterIntake(
          id: const Uuid().v4(),
          userUid: uid,
          date: date,
          totalMl: ml,
          entries: [WaterEntry(ml: ml)],
        );
        await SupabaseService.client.from(_table).upsert(
          intake.toSupabase(),
          onConflict: 'user_id,date',
        );
        return intake;
      }
    } catch (e) {
      debugPrint('WaterIntakeRepository.addWater error: $e');
      return DailyWaterIntake(
        id: const Uuid().v4(),
        userUid: uid,
        date: date,
        totalMl: ml,
        entries: [WaterEntry(ml: ml)],
      );
    }
  }

  Future<List<DailyWaterIntake>> getWeeklyIntake(String uid) async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      final cutoffStr = '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';

      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .gte('date', cutoffStr)
          .order('date', ascending: true);

      return (response as List)
          .map((e) => DailyWaterIntake.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('WaterIntakeRepository.getWeeklyIntake error: $e');
      return [];
    }
  }
}
