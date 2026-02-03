import '../datasources/local_database.dart';
import '../models/food_entry.dart';

class FoodRepository {
  static const _collection = 'food_entries';

  Future<List<FoodEntry>> getEntriesForDate(String uid, DateTime date) async {
    final items = await LocalDatabase.readAll(_collection);
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return items
        .map((e) => FoodEntry.fromJson(e))
        .where((e) =>
            e.userUid == uid &&
            !e.date.isBefore(start) &&
            e.date.isBefore(end))
        .toList();
  }

  Future<void> addEntry(FoodEntry entry) async {
    final items = await LocalDatabase.readAll(_collection);
    items.add(entry.toJson());
    await LocalDatabase.writeAll(_collection, items);
  }

  Future<void> deleteEntry(String id) async {
    final items = await LocalDatabase.readAll(_collection);
    items.removeWhere((e) => e['id'] == id);
    await LocalDatabase.writeAll(_collection, items);
  }

  Future<List<FoodEntry>> getRecentEntries(String uid, {int days = 7}) async {
    final items = await LocalDatabase.readAll(_collection);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return items
        .map((e) => FoodEntry.fromJson(e))
        .where((e) => e.userUid == uid && e.date.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
