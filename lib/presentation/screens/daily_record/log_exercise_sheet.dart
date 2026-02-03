import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/daily_record.dart';
import '../../providers/providers.dart';

class LogExerciseSheet extends ConsumerStatefulWidget {
  const LogExerciseSheet({super.key});

  @override
  ConsumerState<LogExerciseSheet> createState() => _LogExerciseSheetState();
}

class _LogExerciseSheetState extends ConsumerState<LogExerciseSheet> {
  final _nameCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    _caloriesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Log Exercise', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Exercise name', hintText: 'e.g. Running'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _durationCtrl,
                  decoration: const InputDecoration(labelText: 'Duration (min)'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _caloriesCtrl,
                  decoration: const InputDecoration(labelText: 'Calories burned'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final duration = int.tryParse(_durationCtrl.text.trim()) ?? 0;
    final calories = double.tryParse(_caloriesCtrl.text.trim()) ?? 0;
    if (name.isEmpty || duration <= 0) return;

    setState(() => _saving = true);

    final uid = await ref.read(currentUidProvider.future);
    if (uid == null) return;

    final repo = ref.read(dailyRecordRepoProvider);
    final now = DateTime.now();
    final existing = await repo.getRecordForDate(uid, now);
    final exercise = ExerciseEntry(name: name, durationMinutes: duration, caloriesBurned: calories);

    if (existing != null) {
      final exercises = List<ExerciseEntry>.from(existing.exercises)..add(exercise);
      await repo.saveRecord(existing.copyWith(
        exercises: exercises,
        caloriesBurned: existing.caloriesBurned + calories,
      ));
    } else {
      await repo.saveRecord(DailyRecord(
        id: '${uid}_${now.year}${now.month}${now.day}',
        userUid: uid,
        date: now,
        exercises: [exercise],
        caloriesBurned: calories,
      ));
    }

    if (mounted) Navigator.of(context).pop();
  }
}
