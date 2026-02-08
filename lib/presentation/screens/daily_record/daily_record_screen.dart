import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/daily_record.dart';
import '../../../data/models/food_entry.dart';
import '../../providers/daily_record_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/quick_add_sheet.dart';
import '../../providers/weight_provider.dart';
import '../../widgets/water_tracker.dart';
import '../water/water_detail_screen.dart';
import '../weight/weight_progress_screen.dart';
import '../../../data/models/weight_log.dart';
import 'package:uuid/uuid.dart';
import '../../widgets/weekly_chart.dart';
import 'log_exercise_sheet.dart';
import 'log_water_sheet.dart';

enum LogFilter { all, meals, exercise, water }

class DailyRecordScreen extends ConsumerStatefulWidget {
  const DailyRecordScreen({super.key});

  @override
  ConsumerState<DailyRecordScreen> createState() => _DailyRecordScreenState();
}

class _DailyRecordScreenState extends ConsumerState<DailyRecordScreen>
    with SingleTickerProviderStateMixin {
  LogFilter _filter = LogFilter.all;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text('Activity Log',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Track your daily health journey',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Today'),
                      Tab(text: 'History'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TodayTab(filter: _filter, onFilterChanged: (f) => setState(() => _filter = f)),
                const _HistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayTab extends ConsumerWidget {
  final LogFilter filter;
  final ValueChanged<LogFilter> onFilterChanged;

  const _TodayTab({required this.filter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayRecordProvider);
    final entriesAsync = ref.watch(todayEntriesProvider);
    final weeklyAsync = ref.watch(weeklyRecordsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todayRecordProvider);
        ref.invalidate(weeklyRecordsProvider);
        ref.invalidate(todayEntriesProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.fitness_center,
                    label: 'Log Exercise',
                    color: const Color(0xFFE91E63),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const LogExerciseSheet(),
                    ).then((_) {
                      ref.invalidate(todayRecordProvider);
                      ref.invalidate(weeklyRecordsProvider);
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.water_drop,
                    label: 'Add Water',
                    color: const Color(0xFF2196F3),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => const LogWaterSheet(),
                    ).then((_) => ref.invalidate(todayRecordProvider)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Log Weight',
                    color: const Color(0xFF9C27B0),
                    onTap: () => _showWeightDialog(context, ref),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.favorite_outlined,
                    label: 'Quick Add',
                    color: const Color(0xFFFF5722),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const QuickAddSheet(),
                    ).then((_) {
                      ref.invalidate(todayRecordProvider);
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GlassCard(
            child: todayAsync.when(
              loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const Text('Error'),
              data: (record) => WaterTracker(
                glasses: record?.waterGlasses ?? 0,
                onAdd: () => _updateWater(ref, record?.waterGlasses ?? 0, 1),
                onRemove: () => _updateWater(ref, record?.waterGlasses ?? 0, -1),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WaterDetailScreen()),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: LogFilter.values.map((f) {
                final isSelected = filter == f;
                return FilterChip(
                  label: Text(f.name[0].toUpperCase() + f.name.substring(1)),
                  selected: isSelected,
                  selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppTheme.primary,
                  onSelected: (_) => onFilterChanged(f),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          todayAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (record) {
              if (record == null) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No activity logged today yet.\nStart by adding water or exercise!',
                      textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary))),
                );
              }
              return _TodaySummaryCard(record: record, filter: filter);
            },
          ),

          if (filter == LogFilter.all || filter == LogFilter.meals)
            entriesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (entries) {
                if (entries.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Text('Meals Today',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    ...entries.asMap().entries.map((e) => _MealLogTile(entry: e.value, index: e.key)),
                  ],
                );
              },
            ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Weekly Overview',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: weeklyAsync.when(
                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox(height: 200, child: Center(child: Text('Error'))),
                data: (records) => WeeklyChart(records: records),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateWater(WidgetRef ref, int current, int delta) async {
    try {
      final uid = await ref.read(currentUidProvider.future);
      if (uid == null) return;
      final repo = ref.read(dailyRecordRepoProvider);
      final existing = await repo.getRecordForDate(uid, DateTime.now());
      final glasses = (current + delta).clamp(0, 20);
      if (existing != null) {
        await repo.saveRecord(existing.copyWith(waterGlasses: glasses, waterMl: glasses * 250));
      } else {
        final now = DateTime.now();
        await repo.saveRecord(DailyRecord(
          id: '${uid}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
          userUid: uid,
          date: now,
          waterGlasses: glasses,
          waterMl: glasses * 250,
        ));
      }
      ref.invalidate(todayRecordProvider);
    } catch (e) {
      // Water update failed silently; UI stays consistent
    }
  }

  void _showWeightDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Weight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Weight in kg',
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                hintText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes, size: 18),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final weight = double.tryParse(controller.text);
              if (weight == null || weight <= 0) return;
              try {
                final uid = await ref.read(currentUidProvider.future);
                if (uid == null) return;
                final repo = ref.read(dailyRecordRepoProvider);
                final existing = await repo.getRecordForDate(uid, DateTime.now());
                if (existing != null) {
                  await repo.saveRecord(existing.copyWith(weightKg: weight));
                } else {
                  final now = DateTime.now();
                  await repo.saveRecord(DailyRecord(
                    id: '${uid}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
                    userUid: uid,
                    date: now,
                    weightKg: weight,
                  ));
                }

                final weightLogRepo = ref.read(weightLogRepoProvider);
                await weightLogRepo.addLog(WeightLog(
                  id: const Uuid().v4(),
                  userUid: uid,
                  date: DateTime.now(),
                  weightKg: weight,
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                ));

                ref.invalidate(todayRecordProvider);
                ref.invalidate(weightLogsProvider);
                ref.invalidate(latestWeightProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Failed to save weight: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyAsync = ref.watch(monthlyRecordsProvider);

    return monthlyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (records) {
        if (records.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('No history yet', style: TextStyle(color: AppTheme.textSecondary)),
                Text('Start logging to see your progress!', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        final sorted = List<DailyRecord>.from(records)..sort((a, b) => b.date.compareTo(a.date));

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          physics: const BouncingScrollPhysics(),
          itemCount: sorted.length,
          itemBuilder: (_, i) => _HistoryDayCard(record: sorted[i], index: i),
        );
      },
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: widget.color.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: widget.color.withValues(alpha: 0.2)),
            ),
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) => _controller.reverse(),
              onTapCancel: () => _controller.reverse(),
              borderRadius: BorderRadius.circular(14),
              splashColor: widget.color.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(widget.icon, color: widget.color, size: 26),
                    const SizedBox(height: 6),
                    Text(widget.label,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: widget.color),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  final DailyRecord record;
  final LogFilter filter;

  const _TodaySummaryCard({required this.record, required this.filter});

  @override
  Widget build(BuildContext context) {
    final netCalories = record.caloriesConsumed - record.caloriesBurned;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text("Today's Summary",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 20),

          Row(
            children: [
              Expanded(child: _StatPill(
                icon: Icons.local_fire_department,
                label: 'Eaten',
                value: '${record.caloriesConsumed.round()}',
                unit: 'kcal',
                color: const Color(0xFFFF9800),
              )),
              const SizedBox(width: 8),
              Expanded(child: _StatPill(
                icon: Icons.whatshot,
                label: 'Burned',
                value: '${record.caloriesBurned.round()}',
                unit: 'kcal',
                color: const Color(0xFFE91E63),
              )),
              const SizedBox(width: 8),
              Expanded(child: _StatPill(
                icon: Icons.balance,
                label: 'Net',
                value: '${netCalories.round()}',
                unit: 'kcal',
                color: netCalories > 0 ? const Color(0xFFFF9800) : AppTheme.primary,
              )),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _StatPill(
                icon: Icons.water_drop,
                label: 'Water',
                value: '${record.waterGlasses}',
                unit: 'glasses',
                color: const Color(0xFF2196F3),
              )),
              const SizedBox(width: 8),
              if (record.weightKg != null)
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WeightProgressScreen()),
                    ),
                    child: _StatPill(
                      icon: Icons.monitor_weight,
                      label: 'Weight',
                      value: record.weightKg!.toStringAsFixed(1),
                      unit: 'kg',
                      color: const Color(0xFF9C27B0),
                    ),
                  ),
                ),
            ],
          ),

          if ((filter == LogFilter.all || filter == LogFilter.exercise) && record.exercises.isNotEmpty) ...[
            const Divider(height: 20),
            Text('Exercises', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade700)),
            const SizedBox(height: 6),
            ...record.exercises.asMap().entries.map((e) => _ExerciseTile(exercise: e.value, index: e.key)),
          ],
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatPill({required this.icon, required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
          Text(unit, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7))),
          Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatefulWidget {
  final ExerciseEntry exercise;
  final int index;

  const _ExerciseTile({required this.exercise, required this.index});

  @override
  State<_ExerciseTile> createState() => _ExerciseTileState();
}

class _ExerciseTileState extends State<_ExerciseTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(widget.exercise.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
              Text('${widget.exercise.durationMinutes}min',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${widget.exercise.caloriesBurned.round()} kcal',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE91E63))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealLogTile extends StatefulWidget {
  final FoodEntry entry;
  final int index;

  const _MealLogTile({required this.entry, required this.index});

  @override
  State<_MealLogTile> createState() => _MealLogTileState();
}

class _MealLogTileState extends State<_MealLogTile> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;

  IconData get _mealIcon {
    switch (widget.entry.mealType) {
      case 'breakfast': return Icons.wb_sunny_outlined;
      case 'lunch': return Icons.light_mode_outlined;
      case 'dinner': return Icons.nightlight_outlined;
      default: return Icons.cookie_outlined;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
        child: GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_mealIcon, color: AppTheme.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.entry.mealType[0].toUpperCase() + widget.entry.mealType.substring(1),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            '${widget.entry.items.length} items · ${widget.entry.totalCalories.round()} kcal',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Text(DateFormat('h:mm a').format(widget.entry.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      ...widget.entry.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(child: Text(item.name, style: const TextStyle(fontSize: 12))),
                            Text(item.portion, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            const SizedBox(width: 8),
                            Text('${item.calories.round()} kcal',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _MiniMacro('P', widget.entry.totalProtein, Colors.blue),
                          const SizedBox(width: 6),
                          _MiniMacro('C', widget.entry.totalCarbs, AppTheme.accent),
                          const SizedBox(width: 6),
                          _MiniMacro('F', widget.entry.totalFat, Colors.red.shade400),
                        ],
                      ),
                    ],
                  ),
                ),
                crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String label;
  final double grams;
  final Color color;
  const _MiniMacro(this.label, this.grams, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$label: ${grams.round()}g',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _HistoryDayCard extends StatefulWidget {
  final DailyRecord record;
  final int index;

  const _HistoryDayCard({required this.record, required this.index});

  @override
  State<_HistoryDayCard> createState() => _HistoryDayCardState();
}

class _HistoryDayCardState extends State<_HistoryDayCard> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    Future.delayed(Duration(milliseconds: (widget.index * 60).clamp(0, 600)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final dateStr = DateFormat('EEE, MMM d').format(r.date);
    final isToday = DateUtils.isSameDay(r.date, DateTime.now());

    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)),
        child: GlassCard(
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isToday ? AppTheme.primary : Colors.grey).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isToday ? Icons.today : Icons.calendar_today,
                        color: isToday ? AppTheme.primary : Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isToday ? 'Today' : dateStr,
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                                  color: isToday ? AppTheme.primary : AppTheme.textPrimary)),
                          Text('${r.caloriesConsumed.round()} kcal in · ${r.caloriesBurned.round()} kcal out · ${r.waterGlasses} glasses',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down, size: 22, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _StatPill(
                            icon: Icons.local_fire_department,
                            label: 'Eaten',
                            value: '${r.caloriesConsumed.round()}',
                            unit: 'kcal',
                            color: const Color(0xFFFF9800),
                          )),
                          const SizedBox(width: 6),
                          Expanded(child: _StatPill(
                            icon: Icons.whatshot,
                            label: 'Burned',
                            value: '${r.caloriesBurned.round()}',
                            unit: 'kcal',
                            color: const Color(0xFFE91E63),
                          )),
                          const SizedBox(width: 6),
                          Expanded(child: _StatPill(
                            icon: Icons.water_drop,
                            label: 'Water',
                            value: '${r.waterGlasses}',
                            unit: 'glasses',
                            color: const Color(0xFF2196F3),
                          )),
                        ],
                      ),
                      if (r.exercises.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ...r.exercises.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 14, color: Color(0xFF4CAF50)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(e.name, style: const TextStyle(fontSize: 12))),
                              Text('${e.durationMinutes}min · ${e.caloriesBurned.round()} kcal',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            ],
                          ),
                        )),
                      ],
                      if (r.weightKg != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.monitor_weight, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 6),
                            Text('Weight: ${r.weightKg!.toStringAsFixed(1)} kg',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
