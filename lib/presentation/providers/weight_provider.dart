import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/weight_log.dart';
import 'providers.dart';

final weightLogsProvider = FutureProvider<List<WeightLog>>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return [];
  return ref.read(weightLogRepoProvider).getLogs(uid);
});

final latestWeightProvider = FutureProvider<WeightLog?>((ref) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) return null;
  return ref.read(weightLogRepoProvider).getLatest(uid);
});
