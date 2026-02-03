import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/daily_record.dart';
import 'providers.dart';

final todayRecordProvider = FutureProvider<DailyRecord?>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return null;
  return ref.read(dailyRecordRepoProvider).getRecordForDate(uid, DateTime.now());
});

final weeklyRecordsProvider = FutureProvider<List<DailyRecord>>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return [];
  return ref.read(dailyRecordRepoProvider).getRecentRecords(uid, days: 7);
});

final monthlyRecordsProvider = FutureProvider<List<DailyRecord>>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return [];
  return ref.read(dailyRecordRepoProvider).getRecentRecords(uid, days: 30);
});
