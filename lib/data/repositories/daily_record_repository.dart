import '../datasources/local_database.dart';
import '../models/daily_record.dart';

class DailyRecordRepository {
  static const _collection = 'daily_records';

  Future<DailyRecord?> getRecordForDate(String uid, DateTime date) async {
    final items = await LocalDatabase.readAll(_collection);
    final dayStart = DateTime(date.year, date.month, date.day);
    final match = items.where((e) =>
        e['userUid'] == uid &&
        DateTime.parse(e['date'] as String).year == dayStart.year &&
        DateTime.parse(e['date'] as String).month == dayStart.month &&
        DateTime.parse(e['date'] as String).day == dayStart.day);
    if (match.isEmpty) return null;
    return DailyRecord.fromJson(match.first);
  }

  Future<void> saveRecord(DailyRecord record) async {
    final items = await LocalDatabase.readAll(_collection);
    final dayStart = DateTime(record.date.year, record.date.month, record.date.day);
    items.removeWhere((e) =>
        e['userUid'] == record.userUid &&
        DateTime.parse(e['date'] as String).year == dayStart.year &&
        DateTime.parse(e['date'] as String).month == dayStart.month &&
        DateTime.parse(e['date'] as String).day == dayStart.day);
    items.add(record.toJson());
    await LocalDatabase.writeAll(_collection, items);
  }

  Future<List<DailyRecord>> getRecentRecords(String uid, {int days = 7}) async {
    final items = await LocalDatabase.readAll(_collection);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return items
        .map((e) => DailyRecord.fromJson(e))
        .where((e) => e.userUid == uid && e.date.isAfter(cutoff))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> deleteRecord(String id) async {
    final items = await LocalDatabase.readAll(_collection);
    items.removeWhere((e) => e['id'] == id);
    await LocalDatabase.writeAll(_collection, items);
  }
}
