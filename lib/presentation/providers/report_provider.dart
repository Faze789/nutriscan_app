import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/report_data.dart';
import 'providers.dart';

final reportProvider =
    FutureProvider.family<ReportData, ({DateTime start, DateTime end})>(
        (ref, range) async {
  final uid = await ref.watch(currentUidProvider.future);
  if (uid == null) {
    return ReportData(
        start: range.start, end: range.end, records: [], entries: []);
  }

  final records = await ref
      .read(dailyRecordRepoProvider)
      .getRecordsForRange(uid, range.start, range.end);
  final entries = await ref
      .read(foodRepoProvider)
      .getEntriesForRange(uid, range.start, range.end);

  return ReportData(
    start: range.start,
    end: range.end,
    records: records,
    entries: entries,
  );
});
