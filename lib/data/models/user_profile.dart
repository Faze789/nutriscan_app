class UserProfile {
  final String uid;
  final String name;
  final String email;
  final double weightKg;
  final double heightCm;
  final int age;
  final bool isMale;
  final ActivityLevel activityLevel;
  final DietGoal goal;
  final double dailyCalorieTarget;
  final double proteinTargetG;
  final double carbsTargetG;
  final double fatTargetG;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.isMale,
    required this.activityLevel,
    required this.goal,
    required this.dailyCalorieTarget,
    required this.proteinTargetG,
    required this.carbsTargetG,
    required this.fatTargetG,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'age': age,
        'isMale': isMale,
        'activityLevel': activityLevel.name,
        'goal': goal.name,
        'dailyCalorieTarget': dailyCalorieTarget,
        'proteinTargetG': proteinTargetG,
        'carbsTargetG': carbsTargetG,
        'fatTargetG': fatTargetG,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        uid: json['uid'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        weightKg: (json['weightKg'] as num).toDouble(),
        heightCm: (json['heightCm'] as num).toDouble(),
        age: json['age'] as int,
        isMale: json['isMale'] as bool,
        activityLevel: ActivityLevel.values.byName(json['activityLevel'] as String),
        goal: DietGoal.values.byName(json['goal'] as String),
        dailyCalorieTarget: (json['dailyCalorieTarget'] as num).toDouble(),
        proteinTargetG: (json['proteinTargetG'] as num).toDouble(),
        carbsTargetG: (json['carbsTargetG'] as num).toDouble(),
        fatTargetG: (json['fatTargetG'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive;

  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.light:
        return 'Lightly Active';
      case ActivityLevel.moderate:
        return 'Moderately Active';
      case ActivityLevel.active:
        return 'Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
    }
  }

  String get key {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'sedentary';
      case ActivityLevel.light:
        return 'light';
      case ActivityLevel.moderate:
        return 'moderate';
      case ActivityLevel.active:
        return 'active';
      case ActivityLevel.veryActive:
        return 'very_active';
    }
  }
}

enum DietGoal {
  lose,
  maintain,
  gain;

  String get label {
    switch (this) {
      case DietGoal.lose:
        return 'Lose Weight';
      case DietGoal.maintain:
        return 'Maintain Weight';
      case DietGoal.gain:
        return 'Gain Weight';
    }
  }
}
