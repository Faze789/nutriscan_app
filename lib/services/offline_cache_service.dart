import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class OfflineCacheService {
  static const foodEntriesBox = 'offline_food_entries';
  static const waterIntakeBox = 'offline_water_intake';
  static const dailyRecordsBox = 'offline_daily_records';
  static const pendingSyncBox = 'pending_sync';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(foodEntriesBox);
    await Hive.openBox<String>(waterIntakeBox);
    await Hive.openBox<String>(dailyRecordsBox);
    await Hive.openBox<String>(pendingSyncBox);
  }

  // Food entries cache
  static Future<void> cacheFoodEntry(Map<String, dynamic> entry) async {
    final box = Hive.box<String>(foodEntriesBox);
    await box.put(entry['id'], jsonEncode(entry));
    await _addPendingSync('food_entry', entry['id'] as String);
  }

  static List<Map<String, dynamic>> getCachedFoodEntries() {
    final box = Hive.box<String>(foodEntriesBox);
    return box.values
        .map((v) => jsonDecode(v) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> removeCachedFoodEntry(String id) async {
    final box = Hive.box<String>(foodEntriesBox);
    await box.delete(id);
  }

  // Water intake cache
  static Future<void> cacheWaterIntake(Map<String, dynamic> data) async {
    final box = Hive.box<String>(waterIntakeBox);
    final key = '${data['user_id']}_${data['date']}';
    await box.put(key, jsonEncode(data));
    await _addPendingSync('water_intake', key);
  }

  static Map<String, dynamic>? getCachedWaterIntake(
      String uid, String dateStr) {
    final box = Hive.box<String>(waterIntakeBox);
    final key = '${uid}_$dateStr';
    final cached = box.get(key);
    if (cached == null) return null;
    return jsonDecode(cached) as Map<String, dynamic>;
  }

  // Daily records cache
  static Future<void> cacheDailyRecord(Map<String, dynamic> record) async {
    final box = Hive.box<String>(dailyRecordsBox);
    await box.put(record['id'], jsonEncode(record));
    await _addPendingSync('daily_record', record['id'] as String);
  }

  static Map<String, dynamic>? getCachedDailyRecord(String id) {
    final box = Hive.box<String>(dailyRecordsBox);
    final cached = box.get(id);
    if (cached == null) return null;
    return jsonDecode(cached) as Map<String, dynamic>;
  }

  // Pending sync management
  static Future<void> _addPendingSync(String type, String id) async {
    final box = Hive.box<String>(pendingSyncBox);
    final key = '${type}_$id';
    await box.put(key, jsonEncode({'type': type, 'id': id}));
  }

  static List<Map<String, dynamic>> getPendingSyncs() {
    final box = Hive.box<String>(pendingSyncBox);
    return box.values
        .map((v) => jsonDecode(v) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> clearPendingSync(String type, String id) async {
    final box = Hive.box<String>(pendingSyncBox);
    await box.delete('${type}_$id');
  }

  static Future<void> clearAllPendingSyncs() async {
    final box = Hive.box<String>(pendingSyncBox);
    await box.clear();
  }

  static int get pendingSyncCount {
    final box = Hive.box<String>(pendingSyncBox);
    return box.length;
  }
}
