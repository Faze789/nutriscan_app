class DietPlan {
  final String id;
  final String userUid;
  final DateTime generatedAt;
  final List<DayPlan> days;

  DietPlan({
    required this.id,
    required this.userUid,
    required this.generatedAt,
    required this.days,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userUid': userUid,
        'generatedAt': generatedAt.toIso8601String(),
        'days': days.map((e) => e.toJson()).toList(),
      };

  factory DietPlan.fromJson(Map<String, dynamic> json) => DietPlan(
        id: json['id'] as String,
        userUid: json['userUid'] as String,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        days: (json['days'] as List)
            .map((e) => DayPlan.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class DayPlan {
  final int dayNumber;
  final String dayName;
  final List<MealPlan> meals;
  final double totalCalories;

  DayPlan({
    required this.dayNumber,
    required this.dayName,
    required this.meals,
    required this.totalCalories,
  });

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'dayName': dayName,
        'meals': meals.map((e) => e.toJson()).toList(),
        'totalCalories': totalCalories,
      };

  factory DayPlan.fromJson(Map<String, dynamic> json) => DayPlan(
        dayNumber: json['dayNumber'] as int,
        dayName: json['dayName'] as String,
        meals: (json['meals'] as List)
            .map((e) => MealPlan.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCalories: (json['totalCalories'] as num).toDouble(),
      );
}

class MealPlan {
  final String mealType;
  final String name;
  final String description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  MealPlan({
    required this.mealType,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() => {
        'mealType': mealType,
        'name': name,
        'description': description,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
        mealType: json['mealType'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
      );
}
