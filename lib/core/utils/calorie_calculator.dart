import '../constants/app_constants.dart';

class CalorieCalculator {
  CalorieCalculator._();

  /// Mifflin-St Jeor equation for BMR
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    if (isMale) {
      return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
  }

  /// TDEE = BMR * activity multiplier
  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    final multiplier =
        AppConstants.activityMultipliers[activityLevel] ?? 1.2;
    return bmr * multiplier;
  }

  /// Target calories based on goal
  static double calculateTargetCalories({
    required double tdee,
    required String goal,
  }) {
    final multiplier = AppConstants.goalMultipliers[goal] ?? 1.0;
    return tdee * multiplier;
  }

  /// Macro split (grams) for a given calorie target
  /// Default: 30% protein, 40% carbs, 30% fat
  static Map<String, double> calculateMacros({
    required double targetCalories,
    double proteinPct = 0.30,
    double carbsPct = 0.40,
    double fatPct = 0.30,
  }) {
    return {
      'protein': (targetCalories * proteinPct) / AppConstants.proteinCalPerGram,
      'carbs': (targetCalories * carbsPct) / AppConstants.carbsCalPerGram,
      'fat': (targetCalories * fatPct) / AppConstants.fatCalPerGram,
    };
  }
}
