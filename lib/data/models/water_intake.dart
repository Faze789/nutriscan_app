class DailyWaterIntake {
  final String id;
  final String userUid;
  final DateTime date;
  final double totalMl;
  final double goalMl;
  final List<WaterEntry> entries;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyWaterIntake({
    required this.id,
    required this.userUid,
    required this.date,
    this.totalMl = 0,
    this.goalMl = 2000,
    this.entries = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DailyWaterIntake copyWith({
    double? totalMl,
    double? goalMl,
    List<WaterEntry>? entries,
  }) {
    return DailyWaterIntake(
      id: id,
      userUid: userUid,
      date: date,
      totalMl: totalMl ?? this.totalMl,
      goalMl: goalMl ?? this.goalMl,
      entries: entries ?? this.entries,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  double get progressPercent => goalMl > 0 ? (totalMl / goalMl).clamp(0.0, 1.0) : 0;

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userUid,
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'total_ml': totalMl,
        'goal_ml': goalMl,
        'entries': entries.map((e) => e.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory DailyWaterIntake.fromSupabase(Map<String, dynamic> json) => DailyWaterIntake(
        id: json['id'] as String,
        userUid: json['user_id'] as String,
        date: DateTime.parse(json['date'] as String),
        totalMl: (json['total_ml'] as num).toDouble(),
        goalMl: (json['goal_ml'] as num).toDouble(),
        entries: (json['entries'] as List?)
                ?.map((e) => WaterEntry.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
}

class WaterEntry {
  final double ml;
  final DateTime time;

  WaterEntry({required this.ml, DateTime? time}) : time = time ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'ml': ml,
        'time': time.toIso8601String(),
      };

  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry(
        ml: (json['ml'] as num).toDouble(),
        time: DateTime.parse(json['time'] as String),
      );
}
