import 'package:uuid/uuid.dart';
import '../../services/supabase_service.dart';
import '../models/user_streak.dart';

class StreakRepository {
  static const _table = 'user_streaks';

  Future<UserStreak> getStreak(String uid) async {
    try {
      final response = await SupabaseService.client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .maybeSingle();

      if (response == null) {
        return UserStreak(id: const Uuid().v4(), userUid: uid);
      }
      return UserStreak.fromSupabase(response);
    } catch (_) {
      // Table may not exist yet — return empty streak
      return UserStreak(id: const Uuid().v4(), userUid: uid);
    }
  }

  Future<void> saveStreak(UserStreak streak) async {
    try {
      await SupabaseService.client.from(_table).upsert(streak.toSupabase());
    } catch (_) {
      // Table may not exist yet — silently skip
    }
  }

  Future<UserStreak> checkAndUpdateStreak(String uid) async {
    final streak = await getStreak(uid);
    final today = DateTime.now().toUtc();
    final todayDate = DateTime.utc(today.year, today.month, today.day);

    if (streak.lastLoggedDate != null) {
      final lastDate = DateTime.utc(
        streak.lastLoggedDate!.year,
        streak.lastLoggedDate!.month,
        streak.lastLoggedDate!.day,
      );

      if (lastDate == todayDate) {
        return streak;
      }

      final diff = todayDate.difference(lastDate).inDays;

      if (diff == 1) {
        final newStreak = streak.currentStreak + 1;
        final updated = streak.copyWith(
          currentStreak: newStreak,
          longestStreak: newStreak > streak.longestStreak ? newStreak : streak.longestStreak,
          lastLoggedDate: todayDate,
          totalDaysLogged: streak.totalDaysLogged + 1,
          badges: _checkBadges(streak, newStreak),
        );
        await saveStreak(updated);
        return updated;
      } else {
        final updated = streak.copyWith(
          currentStreak: 1,
          lastLoggedDate: todayDate,
          totalDaysLogged: streak.totalDaysLogged + 1,
          badges: _checkBadges(streak, 1),
        );
        await saveStreak(updated);
        return updated;
      }
    } else {
      final updated = streak.copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastLoggedDate: todayDate,
        totalDaysLogged: 1,
        badges: _checkFirstLogBadge(streak),
      );
      await saveStreak(updated);
      return updated;
    }
  }

  List<Badge> _checkFirstLogBadge(UserStreak streak) {
    final badges = List<Badge>.from(streak.badges);
    if (!streak.hasBadge('first_log')) {
      badges.add(Badge(id: 'first_log', name: 'First Step', description: 'Log your first meal'));
    }
    return badges;
  }

  List<Badge> _checkBadges(UserStreak streak, int newStreak) {
    final badges = List<Badge>.from(streak.badges);

    if (!streak.hasBadge('first_log')) {
      badges.add(Badge(id: 'first_log', name: 'First Step', description: 'Log your first meal'));
    }
    if (newStreak >= 3 && !streak.hasBadge('streak_3')) {
      badges.add(Badge(id: 'streak_3', name: 'On a Roll', description: '3-day logging streak'));
    }
    if (newStreak >= 7 && !streak.hasBadge('streak_7')) {
      badges.add(Badge(id: 'streak_7', name: 'Week Warrior', description: '7-day logging streak'));
    }
    if (newStreak >= 30 && !streak.hasBadge('streak_30')) {
      badges.add(Badge(id: 'streak_30', name: 'Monthly Master', description: '30-day logging streak'));
    }

    return badges;
  }
}
