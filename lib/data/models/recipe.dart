import 'food_entry.dart';

class Recipe {
  final String id;
  final String userUid;
  final String title;
  final List<FoodItem> ingredients;
  final int servings;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final String? instructions;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.userUid,
    required this.title,
    required this.ingredients,
    this.servings = 1,
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.instructions,
    this.imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get caloriesPerServing =>
      servings > 0 ? totalCalories / servings : totalCalories;
  double get proteinPerServing =>
      servings > 0 ? totalProtein / servings : totalProtein;
  double get carbsPerServing =>
      servings > 0 ? totalCarbs / servings : totalCarbs;
  double get fatPerServing =>
      servings > 0 ? totalFat / servings : totalFat;

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userUid,
        'title': title,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'servings': servings,
        'total_calories': totalCalories,
        'total_protein': totalProtein,
        'total_carbs': totalCarbs,
        'total_fat': totalFat,
        'instructions': instructions,
        'image_path': imagePath,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Recipe.fromSupabase(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        userUid: json['user_id'] as String,
        title: json['title'] as String,
        ingredients: (json['ingredients'] as List?)
            ?.map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        servings: json['servings'] as int? ?? 1,
        totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0,
        totalProtein: (json['total_protein'] as num?)?.toDouble() ?? 0,
        totalCarbs: (json['total_carbs'] as num?)?.toDouble() ?? 0,
        totalFat: (json['total_fat'] as num?)?.toDouble() ?? 0,
        instructions: json['instructions'] as String?,
        imagePath: json['image_path'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}
