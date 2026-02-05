import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_streak.dart';
import 'providers.dart';

final userStreakProvider = FutureProvider<UserStreak>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return UserStreak(id: '', userUid: '');
  return ref.read(streakRepoProvider).getStreak(uid);
});
