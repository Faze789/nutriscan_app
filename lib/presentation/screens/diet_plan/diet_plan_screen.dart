import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/diet_plan.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/providers.dart';

class DietPlanScreen extends ConsumerStatefulWidget {
  const DietPlanScreen({super.key});

  @override
  ConsumerState<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends ConsumerState<DietPlanScreen> {
  bool _generating = false;

  Future<void> _generate() async {
    final profile = await ref.read(userProfileProvider.future);
    if (profile == null) return;

    setState(() => _generating = true);
    try {
      final days = await ref.read(geminiServiceProvider).generateMealPlan(profile);
      final uid = await ref.read(currentUidProvider.future);
      if (uid == null) return;

      final plan = DietPlan(
        id: const Uuid().v4(),
        userUid: uid,
        generatedAt: DateTime.now(),
        days: days,
      );

      await ref.read(dietPlanRepoProvider).savePlan(plan);
      ref.invalidate(dietPlanProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(dietPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('7-Day Meal Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Generate new plan',
            onPressed: _generating ? null : _generate,
          ),
        ],
      ),
      body: _generating
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('AI is crafting your meal plan...', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : planAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (plan) {
                if (plan == null || plan.days.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('No meal plan yet'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _generate,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate with AI'),
                        ),
                      ],
                    ),
                  );
                }

                return DefaultTabController(
                  length: plan.days.length,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        labelColor: AppTheme.primary,
                        unselectedLabelColor: AppTheme.textSecondary,
                        tabs: plan.days.map((d) => Tab(text: d.dayName)).toList(),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: plan.days.map((day) => _DayView(day: day)).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _DayView extends StatelessWidget {
  final DayPlan day;
  const _DayView({required this.day});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: AppTheme.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(label: 'Total', value: '${day.totalCalories.round()} kcal'),
                _Stat(label: 'Meals', value: '${day.meals.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...day.meals.map((meal) => _MealPlanTile(meal: meal)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _MealPlanTile extends StatelessWidget {
  final MealPlan meal;
  const _MealPlanTile({required this.meal});

  IconData get _icon {
    switch (meal.mealType) {
      case 'breakfast': return Icons.wb_sunny_outlined;
      case 'lunch': return Icons.light_mode_outlined;
      case 'dinner': return Icons.nightlight_outlined;
      default: return Icons.cookie_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon, color: AppTheme.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    meal.mealType[0].toUpperCase() + meal.mealType.substring(1),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                ),
                Text('${meal.calories.round()} kcal',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 6),
            Text(meal.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Text(meal.description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Row(
              children: [
                _MacroChip('P', meal.protein, Colors.blue),
                const SizedBox(width: 8),
                _MacroChip('C', meal.carbs, AppTheme.accent),
                const SizedBox(width: 8),
                _MacroChip('F', meal.fat, Colors.red.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double grams;
  final Color color;
  const _MacroChip(this.label, this.grams, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$label: ${grams.round()}g',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
