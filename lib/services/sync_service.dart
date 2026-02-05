import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'connectivity_service.dart';
import 'offline_cache_service.dart';
import 'supabase_service.dart';

class SyncService {
  static bool _syncing = false;

  static Future<int> syncPending() async {
    if (!ConnectivityService.isOnline) return 0;
    if (_syncing) return 0;
    _syncing = true;

    try {
      final pending = OfflineCacheService.getPendingSyncs();
      int synced = 0;

      for (final item in pending) {
        final type = item['type'] as String;
        final id = item['id'] as String;

        try {
          switch (type) {
            case 'food_entry':
              await _syncFoodEntry(id);
              break;
            case 'water_intake':
              await _syncWaterIntake(id);
              break;
            case 'daily_record':
              await _syncDailyRecord(id);
              break;
          }
          await OfflineCacheService.clearPendingSync(type, id);
          synced++;
        } catch (_) {
          // Keep in pending queue for next sync attempt
        }
      }

      return synced;
    } finally {
      _syncing = false;
    }
  }

  static Future<void> _syncFoodEntry(String id) async {
    final box = Hive.box<String>(OfflineCacheService.foodEntriesBox);
    final cached = box.get(id);
    if (cached == null) return;

    final data = jsonDecode(cached) as Map<String, dynamic>;
    await SupabaseService.client.from('food_entries').upsert(data);
    await box.delete(id);
  }

  static Future<void> _syncWaterIntake(String key) async {
    final box = Hive.box<String>(OfflineCacheService.waterIntakeBox);
    final cached = box.get(key);
    if (cached == null) return;

    final data = jsonDecode(cached) as Map<String, dynamic>;
    await SupabaseService.client
        .from('daily_water_intake')
        .upsert(data, onConflict: 'user_id,date');
    await box.delete(key);
  }

  static Future<void> _syncDailyRecord(String id) async {
    final box = Hive.box<String>(OfflineCacheService.dailyRecordsBox);
    final cached = box.get(id);
    if (cached == null) return;

    final data = jsonDecode(cached) as Map<String, dynamic>;
    await SupabaseService.client
        .from('daily_records')
        .upsert(data, onConflict: 'user_id,date');
    await box.delete(id);
  }
}
