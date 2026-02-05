import '../constants/app_constants.dart';

class CalorieCalculator {
  CalorieCalculator._();

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

  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    final multiplier =
        AppConstants.activityMultipliers[activityLevel] ?? 1.2;
    return bmr * multiplier;
  }

  static double calculateTargetCalories({
    required double tdee,
    required String goal,
  }) {
    final multiplier = AppConstants.goalMultipliers[goal] ?? 1.0;
    return tdee * multiplier;
  }

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
