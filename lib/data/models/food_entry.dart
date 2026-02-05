class FoodEntry {
  final String id;
  final String userUid;
  final DateTime date;
  final String mealType;
  final List<FoodItem> items;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final String? imagePath;
  final DateTime createdAt;

  FoodEntry({
    required this.id,
    required this.userUid,
    required this.date,
    required this.mealType,
    required this.items,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'userUid': userUid,
        'date': date.toIso8601String(),
        'mealType': mealType,
        'items': items.map((e) => e.toJson()).toList(),
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FoodEntry.fromJson(Map<String, dynamic> json) => FoodEntry(
        id: json['id'] as String,
        userUid: json['userUid'] as String,
        date: DateTime.parse(json['date'] as String),
        mealType: json['mealType'] as String,
        items: (json['items'] as List?)
            ?.map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        totalCalories: (json['totalCalories'] as num).toDouble(),
        totalProtein: (json['totalProtein'] as num).toDouble(),
        totalCarbs: (json['totalCarbs'] as num).toDouble(),
        totalFat: (json['totalFat'] as num).toDouble(),
        imagePath: json['imagePath'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userUid,
        'date': date.toIso8601String(),
        'meal_type': mealType,
        'items': items.map((e) => e.toJson()).toList(),
        'total_calories': totalCalories,
        'total_protein': totalProtein,
        'total_carbs': totalCarbs,
        'total_fat': totalFat,
        'image_path': imagePath,
        'created_at': createdAt.toIso8601String(),
      };

  factory FoodEntry.fromSupabase(Map<String, dynamic> json) => FoodEntry(
        id: json['id'] as String,
        userUid: json['user_id'] as String,
        date: DateTime.parse(json['date'] as String),
        mealType: json['meal_type'] as String,
        items: (json['items'] as List?)
            ?.map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        totalCalories: (json['total_calories'] as num).toDouble(),
        totalProtein: (json['total_protein'] as num).toDouble(),
        totalCarbs: (json['total_carbs'] as num).toDouble(),
        totalFat: (json['total_fat'] as num).toDouble(),
        imagePath: json['image_path'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class FoodItem {
  final String name;
  final String portion;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'portion': portion,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        name: json['name'] as String,
        portion: json['portion'] as String,
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
      );
}
