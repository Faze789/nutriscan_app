class UserStreak {
  final String id;
  final String userUid;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastLoggedDate;
  final int totalDaysLogged;
  final List<Badge> badges;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserStreak({
    required this.id,
    required this.userUid,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastLoggedDate,
    this.totalDaysLogged = 0,
    this.badges = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  UserStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastLoggedDate,
    int? totalDaysLogged,
    List<Badge>? badges,
  }) {
    return UserStreak(
      id: id,
      userUid: userUid,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastLoggedDate: lastLoggedDate ?? this.lastLoggedDate,
      totalDaysLogged: totalDaysLogged ?? this.totalDaysLogged,
      badges: badges ?? this.badges,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userUid,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'last_logged_date': lastLoggedDate != null
            ? '${lastLoggedDate!.year}-${lastLoggedDate!.month.toString().padLeft(2, '0')}-${lastLoggedDate!.day.toString().padLeft(2, '0')}'
            : null,
        'total_days_logged': totalDaysLogged,
        'badges': badges.map((b) => b.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory UserStreak.fromSupabase(Map<String, dynamic> json) => UserStreak(
        id: json['id'] as String,
        userUid: json['user_id'] as String,
        currentStreak: json['current_streak'] as int? ?? 0,
        longestStreak: json['longest_streak'] as int? ?? 0,
        lastLoggedDate: json['last_logged_date'] != null
            ? DateTime.parse(json['last_logged_date'] as String)
            : null,
        totalDaysLogged: json['total_days_logged'] as int? ?? 0,
        badges: (json['badges'] as List?)
                ?.map((e) => Badge.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  bool hasBadge(String badgeId) => badges.any((b) => b.id == badgeId);
}

class Badge {
  final String id;
  final String name;
  final String description;
  final DateTime earnedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    DateTime? earnedAt,
  }) : earnedAt = earnedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'earnedAt': earnedAt.toIso8601String(),
      };

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        earnedAt: DateTime.parse(json['earnedAt'] as String),
      );
}
