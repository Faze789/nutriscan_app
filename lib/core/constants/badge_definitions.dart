import 'package:flutter/material.dart';

class BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class BadgeDefinitions {
  BadgeDefinitions._();

  static const Map<String, BadgeDefinition> all = {
    'first_log': BadgeDefinition(
      id: 'first_log',
      name: 'First Step',
      description: 'Log your first meal',
      icon: Icons.emoji_events,
      color: Color(0xFFFFD700),
    ),
    'streak_3': BadgeDefinition(
      id: 'streak_3',
      name: 'On a Roll',
      description: '3-day logging streak',
      icon: Icons.local_fire_department,
      color: Color(0xFFFF6B35),
    ),
    'streak_7': BadgeDefinition(
      id: 'streak_7',
      name: 'Week Warrior',
      description: '7-day logging streak',
      icon: Icons.military_tech,
      color: Color(0xFFE91E63),
    ),
    'streak_30': BadgeDefinition(
      id: 'streak_30',
      name: 'Monthly Master',
      description: '30-day logging streak',
      icon: Icons.workspace_premium,
      color: Color(0xFF9C27B0),
    ),
    'water_hero': BadgeDefinition(
      id: 'water_hero',
      name: 'Hydration Hero',
      description: 'Hit water goal 7 days in a row',
      icon: Icons.water_drop,
      color: Color(0xFF2196F3),
    ),
    'scan_10': BadgeDefinition(
      id: 'scan_10',
      name: 'Scanner Pro',
      description: 'Scan 10 meals',
      icon: Icons.camera_alt,
      color: Color(0xFF4CAF50),
    ),
    'macro_balance': BadgeDefinition(
      id: 'macro_balance',
      name: 'Macro Master',
      description: 'Hit all macro targets in a day',
      icon: Icons.balance,
      color: Color(0xFFFF9800),
    ),
  };
}
