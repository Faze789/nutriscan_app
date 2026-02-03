import '../datasources/local_database.dart';
import '../models/diet_plan.dart';

class DietPlanRepository {
  static const _collection = 'diet_plans';

  Future<DietPlan?> getLatestPlan(String uid) async {
    final items = await LocalDatabase.readAll(_collection);
    final plans = items
        .map((e) => DietPlan.fromJson(e))
        .where((e) => e.userUid == uid)
        .toList()
      ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return plans.isEmpty ? null : plans.first;
  }

  Future<void> savePlan(DietPlan plan) async {
    final items = await LocalDatabase.readAll(_collection);
    items.add(plan.toJson());
    await LocalDatabase.writeAll(_collection, items);
  }
}
