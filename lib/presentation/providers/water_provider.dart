import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/water_intake.dart';
import 'providers.dart';

final todayWaterProvider = FutureProvider<DailyWaterIntake?>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return null;
  return ref.read(waterIntakeRepoProvider).getForDate(uid, DateTime.now());
});

final weeklyWaterProvider = FutureProvider<List<DailyWaterIntake>>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return [];
  return ref.read(waterIntakeRepoProvider).getWeeklyIntake(uid);
});
