class DailyRecord {
  final String id;
  final String userUid;
  final DateTime date;
  final double caloriesConsumed;
  final double caloriesBurned;
  final double waterMl;
  final int waterGlasses;
  final List<ExerciseEntry> exercises;
  final double? weightKg;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyRecord({
    required this.id,
    required this.userUid,
    required this.date,
    this.caloriesConsumed = 0,
    this.caloriesBurned = 0,
    this.waterMl = 0,
    this.waterGlasses = 0,
    this.exercises = const [],
    this.weightKg,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DailyRecord copyWith({
    double? caloriesConsumed,
    double? caloriesBurned,
    double? waterMl,
    int? waterGlasses,
    List<ExerciseEntry>? exercises,
    double? weightKg,
    String? notes,
  }) {
    return DailyRecord(
      id: id,
      userUid: userUid,
      date: date,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      waterMl: waterMl ?? this.waterMl,
      waterGlasses: waterGlasses ?? this.waterGlasses,
      exercises: exercises ?? this.exercises,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userUid': userUid,
        'date': date.toIso8601String(),
        'caloriesConsumed': caloriesConsumed,
        'caloriesBurned': caloriesBurned,
        'waterMl': waterMl,
        'waterGlasses': waterGlasses,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'weightKg': weightKg,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
        id: json['id'] as String,
        userUid: json['userUid'] as String,
        date: DateTime.parse(json['date'] as String),
        caloriesConsumed: (json['caloriesConsumed'] as num?)?.toDouble() ?? 0,
        caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 0,
        waterMl: (json['waterMl'] as num?)?.toDouble() ?? 0,
        waterGlasses: (json['waterGlasses'] as num?)?.toInt() ?? 0,
        exercises: (json['exercises'] as List?)
            ?.map((e) => ExerciseEntry.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        weightKg: json['weightKg'] != null
            ? (json['weightKg'] as num).toDouble()
            : null,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userUid,
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'calories_consumed': caloriesConsumed,
        'calories_burned': caloriesBurned,
        'water_ml': waterMl,
        'water_glasses': waterGlasses,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'weight_kg': weightKg,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory DailyRecord.fromSupabase(Map<String, dynamic> json) => DailyRecord(
        id: json['id'] as String,
        userUid: json['user_id'] as String,
        date: DateTime.parse(json['date'] as String),
        caloriesConsumed: (json['calories_consumed'] as num?)?.toDouble() ?? 0,
        caloriesBurned: (json['calories_burned'] as num?)?.toDouble() ?? 0,
        waterMl: (json['water_ml'] as num?)?.toDouble() ?? 0,
        waterGlasses: (json['water_glasses'] as num?)?.toInt() ?? 0,
        exercises: (json['exercises'] as List?)
            ?.map((e) => ExerciseEntry.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        weightKg: json['weight_kg'] != null
            ? (json['weight_kg'] as num).toDouble()
            : null,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

class ExerciseEntry {
  final String name;
  final int durationMinutes;
  final double caloriesBurned;

  ExerciseEntry({
    required this.name,
    required this.durationMinutes,
    required this.caloriesBurned,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'durationMinutes': durationMinutes,
        'caloriesBurned': caloriesBurned,
      };

  factory ExerciseEntry.fromJson(Map<String, dynamic> json) => ExerciseEntry(
        name: json['name'] as String,
        durationMinutes: json['durationMinutes'] as int,
        caloriesBurned: (json['caloriesBurned'] as num).toDouble(),
      );
}
