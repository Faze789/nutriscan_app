import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/badge_definitions.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/streak_provider.dart';
import '../../../services/sharing_service.dart';
import '../../widgets/glass_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(userStreakProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        actions: [
          streakAsync.whenOrNull(
                data: (streak) => IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Share',
                  onPressed: () => SharingService.shareStreak(streak),
                ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(context)),
        child: streakAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (streak) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        icon: Icons.local_fire_department,
                        value: '${streak.currentStreak}',
                        label: 'Current\nStreak',
                        color: const Color(0xFFFF6B35),
                      ),
                      _StatColumn(
                        icon: Icons.military_tech,
                        value: '${streak.longestStreak}',
                        label: 'Longest\nStreak',
                        color: const Color(0xFFE91E63),
                      ),
                      _StatColumn(
                        icon: Icons.calendar_month,
                        value: '${streak.totalDaysLogged}',
                        label: 'Total\nDays',
                        color: AppTheme.primary,
                      ),
                      _StatColumn(
                        icon: Icons.emoji_events,
                        value: '${streak.badges.length}',
                        label: 'Badges\nEarned',
                        color: const Color(0xFFFFD700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Badges',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                ...BadgeDefinitions.all.values.map((def) {
                  final earned = streak.hasBadge(def.id);

                  return GlassCard(
                    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: earned
                                ? def.color.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(def.icon,
                              color: earned ? def.color : Colors.grey.shade400,
                              size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(def.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: earned ? null : Colors.grey,
                                  )),
                              Text(def.description,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        if (earned)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: def.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Earned',
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600, color: def.color)),
                          )
                        else
                          Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 20),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}
