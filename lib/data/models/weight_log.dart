class WeightLog {
  final String id;
  final String userUid;
  final DateTime date;
  final double weightKg;
  final String? notes;
  final DateTime createdAt;

  WeightLog({
    required this.id,
    required this.userUid,
    required this.date,
    required this.weightKg,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userUid,
        'date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'weight_kg': weightKg,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory WeightLog.fromSupabase(Map<String, dynamic> json) => WeightLog(
        id: json['id'] as String,
        userUid: json['user_id'] as String,
        date: DateTime.parse(json['date'] as String),
        weightKg: (json['weight_kg'] as num).toDouble(),
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
