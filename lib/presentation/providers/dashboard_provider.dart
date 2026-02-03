import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/food_entry.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/diet_plan.dart';
import 'providers.dart';

// User profile for the logged-in user
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return null;
  return ref.read(userRepoProvider).getUser(uid);
});

// Today's food entries
final todayEntriesProvider = FutureProvider<List<FoodEntry>>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return [];
  return ref.read(foodRepoProvider).getEntriesForDate(uid, DateTime.now());
});

// Computed daily totals
final dailyTotalsProvider = FutureProvider<Map<String, double>>((ref) async {
  final entries = await ref.watch(todayEntriesProvider.future);
  double cal = 0, pro = 0, carb = 0, fat = 0;
  for (final e in entries) {
    cal += e.totalCalories;
    pro += e.totalProtein;
    carb += e.totalCarbs;
    fat += e.totalFat;
  }
  return {'calories': cal, 'protein': pro, 'carbs': carb, 'fat': fat};
});

// Latest diet plan
final dietPlanProvider = FutureProvider<DietPlan?>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return null;
  return ref.read(dietPlanRepoProvider).getLatestPlan(uid);
});
