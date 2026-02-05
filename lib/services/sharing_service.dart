import 'package:share_plus/share_plus.dart';
import '../data/models/user_streak.dart';

class SharingService {
  static Future<void> shareProgress({
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    final text = '''
Check out my daily nutrition progress on NutriScan!

Calories: ${calories.round()} kcal
Protein: ${protein.round()}g
Carbs: ${carbs.round()}g
Fat: ${fat.round()}g

Track your nutrition with NutriScan!
''';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  static Future<void> shareStreak(UserStreak streak) async {
    final text = '''
I'm on a ${streak.currentStreak}-day streak on NutriScan!

Total days logged: ${streak.totalDaysLogged}
Longest streak: ${streak.longestStreak} days
Badges earned: ${streak.badges.length}

Join me in tracking nutrition with NutriScan!
''';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  static Future<void> shareMeal({
    required String mealType,
    required double calories,
    required int itemCount,
  }) async {
    final text = '''
Just logged my $mealType on NutriScan!

$itemCount items totaling ${calories.round()} kcal

Track your meals with NutriScan!
''';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  static Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
