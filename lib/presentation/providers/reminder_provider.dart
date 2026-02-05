import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_reminder.dart';
import 'providers.dart';

final remindersProvider = FutureProvider<List<UserReminder>>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return [];
  return ref.read(reminderRepoProvider).getReminders(uid);
});
