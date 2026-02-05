import '../../data/models/user_profile.dart';
import '../../data/models/daily_record.dart';

class PersonalizedTip {
  final String icon;
  final String title;
  final String subtitle;
  final String colorHex;

  const PersonalizedTip({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorHex,
  });
}

class PersonalizationEngine {
  PersonalizationEngine._();

  static List<PersonalizedTip> generateTips(
    UserProfile profile,
    DailyRecord? todayRecord,
  ) {
    final tips = <PersonalizedTip>[];

    final glasses = todayRecord?.waterGlasses ?? 0;
    if (glasses < 4) {
      tips.add(const PersonalizedTip(
        icon: 'water_drop',
        title: 'Stay Hydrated',
        subtitle: 'You\'ve had less than 4 glasses today. Aim for 8!',
        colorHex: '2196F3',
      ));
    } else if (glasses >= 8) {
      tips.add(const PersonalizedTip(
        icon: 'water_drop',
        title: 'Great Hydration!',
        subtitle: 'You\'ve hit your water goal today. Keep it up!',
        colorHex: '4CAF50',
      ));
    }

    switch (profile.goal) {
      case DietGoal.lose:
        if (profile.activityLevel == ActivityLevel.sedentary) {
          tips.add(const PersonalizedTip(
            icon: 'directions_walk',
            title: 'Start Moving',
            subtitle: 'A 30-min walk burns ~150 cal. Small steps matter!',
            colorHex: 'FF9800',
          ));
        }
        tips.add(PersonalizedTip(
          icon: 'restaurant',
          title: 'Calorie Deficit',
          subtitle: 'Target: ${profile.dailyCalorieTarget.round()} kcal. Focus on protein-rich meals.',
          colorHex: 'E91E63',
        ));
      case DietGoal.gain:
        tips.add(PersonalizedTip(
          icon: 'fitness_center',
          title: 'Calorie Surplus',
          subtitle: 'Aim for ${profile.dailyCalorieTarget.round()} kcal with calorie-dense whole foods.',
          colorHex: '9C27B0',
        ));
        tips.add(const PersonalizedTip(
          icon: 'egg',
          title: 'Protein Priority',
          subtitle: 'Eat protein with every meal to support muscle growth.',
          colorHex: '3F51B5',
        ));
      case DietGoal.maintain:
        tips.add(const PersonalizedTip(
          icon: 'balance',
          title: 'Balanced Nutrition',
          subtitle: 'Keep hitting your macro targets for steady energy.',
          colorHex: '009688',
        ));
    }

    final exercised = todayRecord?.exercises.isNotEmpty ?? false;
    if (!exercised) {
      tips.add(const PersonalizedTip(
        icon: 'timer',
        title: 'Move Today',
        subtitle: 'No exercise logged yet. Even 15 minutes helps!',
        colorHex: 'FF5722',
      ));
    }

    return tips.take(4).toList();
  }
}
