import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/personalization_engine.dart';
import 'dashboard_provider.dart';
import 'daily_record_provider.dart';

final personalizedTipsProvider =
    FutureProvider<List<PersonalizedTip>>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  final record = await ref.watch(todayRecordProvider.future);
  if (profile == null) return [];
  return PersonalizationEngine.generateTips(profile, record);
});
