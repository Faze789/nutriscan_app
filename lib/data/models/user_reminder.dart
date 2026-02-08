class UserReminder {
  final String id;
  final String userUid;
  final String type;
  final String time; // "HH:mm" format
  final bool isActive;
  final DateTime createdAt;

  UserReminder({
    required this.id,
    required this.userUid,
    required this.type,
    required this.time,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get hour => int.parse(time.split(':')[0]);
  int get minute => int.parse(time.split(':')[1]);

  UserReminder copyWith({
    String? time,
    bool? isActive,
  }) {
    return UserReminder(
      id: id,
      userUid: userUid,
      type: type,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'user_id': userUid,
        'type': type,
        'time': time,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };

  factory UserReminder.fromSupabase(Map<String, dynamic> json) => UserReminder(
        id: json['id'] as String? ?? '',
        userUid: json['user_id'] as String? ?? '',
        type: json['type'] as String? ?? '',
        time: json['time'] as String? ?? '09:00',
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

class ReminderType {
  static const String breakfast = 'breakfast';
  static const String lunch = 'lunch';
  static const String dinner = 'dinner';
  static const String water = 'water';
  static const String weight = 'weight';

  static const all = [breakfast, lunch, dinner, water, weight];

  static String label(String type) {
    switch (type) {
      case breakfast:
        return 'Breakfast';
      case lunch:
        return 'Lunch';
      case dinner:
        return 'Dinner';
      case water:
        return 'Water';
      case weight:
        return 'Weight Log';
      default:
        return type;
    }
  }

  static String defaultTime(String type) {
    switch (type) {
      case breakfast:
        return '08:00';
      case lunch:
        return '12:30';
      case dinner:
        return '19:00';
      case water:
        return '10:00';
      case weight:
        return '07:00';
      default:
        return '09:00';
    }
  }

  static String body(String type) {
    switch (type) {
      case breakfast:
        return "Don't skip breakfast! Log your morning meal.";
      case lunch:
        return "Lunchtime! Remember to log what you eat.";
      case dinner:
        return "Dinner time! Track your evening meal.";
      case water:
        return "Stay hydrated! Have you had enough water today?";
      case weight:
        return "Time to log your weight and track progress!";
      default:
        return "Reminder from NutriScan";
    }
  }

  static int notificationId(String type) {
    switch (type) {
      case breakfast:
        return 100;
      case lunch:
        return 101;
      case dinner:
        return 102;
      case water:
        return 103;
      case weight:
        return 104;
      default:
        return 199;
    }
  }
}
