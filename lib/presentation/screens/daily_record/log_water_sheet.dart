import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/daily_record.dart';
import '../../providers/providers.dart';

class LogWaterSheet extends ConsumerStatefulWidget {
  const LogWaterSheet({super.key});

  @override
  ConsumerState<LogWaterSheet> createState() => _LogWaterSheetState();
}

class _LogWaterSheetState extends ConsumerState<LogWaterSheet> {
  int _glasses = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Add Water', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.outlined(
                onPressed: _glasses > 1 ? () => setState(() => _glasses--) : null,
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('$_glasses', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              ),
              IconButton.filled(
                onPressed: () => setState(() => _glasses++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Text('glasses (${_glasses * 250} ml)', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => _save(),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final uid = await ref.read(currentUidProvider.future);
    if (uid == null) return;

    final repo = ref.read(dailyRecordRepoProvider);
    final now = DateTime.now();
    final existing = await repo.getRecordForDate(uid, now);

    if (existing != null) {
      final total = existing.waterGlasses + _glasses;
      await repo.saveRecord(existing.copyWith(waterGlasses: total, waterMl: total * 250));
    } else {
      await repo.saveRecord(DailyRecord(
        id: '${uid}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        userUid: uid,
        date: now,
        waterGlasses: _glasses,
        waterMl: _glasses * 250,
      ));
    }

    if (mounted) Navigator.of(context).pop();
  }
}
