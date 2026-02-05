import '../../data/models/daily_record.dart';
import '../../data/models/food_entry.dart';

class ReportData {
  final DateTime start;
  final DateTime end;
  final List<DailyRecord> records;
  final List<FoodEntry> entries;

  ReportData({
    required this.start,
    required this.end,
    required this.records,
    required this.entries,
  });

  int get totalDays => end.difference(start).inDays + 1;
  int get daysLogged => records.length;

  double get avgCalories =>
      daysLogged > 0
          ? records.fold(0.0, (s, r) => s + r.caloriesConsumed) / daysLogged
          : 0;

  double get avgProtein {
    if (entries.isEmpty) return 0;
    final total = entries.fold(0.0, (s, e) => s + e.totalProtein);
    return daysLogged > 0 ? total / daysLogged : 0;
  }

  double get avgCarbs {
    if (entries.isEmpty) return 0;
    final total = entries.fold(0.0, (s, e) => s + e.totalCarbs);
    return daysLogged > 0 ? total / daysLogged : 0;
  }

  double get avgFat {
    if (entries.isEmpty) return 0;
    final total = entries.fold(0.0, (s, e) => s + e.totalFat);
    return daysLogged > 0 ? total / daysLogged : 0;
  }

  double get totalCalories =>
      records.fold(0.0, (s, r) => s + r.caloriesConsumed);

  double get totalBurned =>
      records.fold(0.0, (s, r) => s + r.caloriesBurned);

  double get avgWaterGlasses =>
      daysLogged > 0
          ? records.fold(0.0, (s, r) => s + r.waterGlasses) / daysLogged
          : 0;

  int get totalExercises =>
      records.fold(0, (s, r) => s + r.exercises.length);

  int get totalMeals => entries.length;
}
