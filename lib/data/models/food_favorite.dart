class FoodFavorite {
  final String id;
  final String userUid;
  final String name;
  final String portion;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? mealType;
  final int useCount;
  final DateTime createdAt;

  FoodFavorite({
    required this.id,
    required this.userUid,
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.mealType,
    this.useCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userUid,
        'name': name,
        'portion': portion,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'meal_type': mealType,
        'use_count': useCount,
        'created_at': createdAt.toIso8601String(),
      };

  factory FoodFavorite.fromSupabase(Map<String, dynamic> json) => FoodFavorite(
        id: json['id'] as String,
        userUid: json['user_id'] as String,
        name: json['name'] as String,
        portion: json['portion'] as String,
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        mealType: json['meal_type'] as String?,
        useCount: json['use_count'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
