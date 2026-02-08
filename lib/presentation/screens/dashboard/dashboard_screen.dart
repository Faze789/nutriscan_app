import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/diet_plan.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/daily_record_provider.dart';
import '../../providers/providers.dart';
import '../../providers/personalization_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/calorie_ring.dart';
import '../../widgets/macro_bar.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/personalized_tip_card.dart';
import '../../widgets/streak_card.dart';
import '../../widgets/weekly_chart.dart';
import '../achievements/achievements_screen.dart';
import '../diet_plan/diet_plan_screen.dart';
import '../recipes/recipes_screen.dart';
import '../profile/profile_setup_screen.dart';
import '../auth/login_screen.dart';
import '../settings/reminders_screen.dart';
import '../reports/reports_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _generatingPlan = false;

  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  Future<void> _generateMealPlan() async {
    final profile = await ref.read(userProfileProvider.future);
    if (profile == null) return;
    if (!mounted) return;

    setState(() => _generatingPlan = true);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('7-day meal plan generated!'), backgroundColor: AppTheme.primary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingPlan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final totalsAsync = ref.watch(dailyTotalsProvider);
    final entriesAsync = ref.watch(todayEntriesProvider);
    final dietAsync = ref.watch(dietPlanProvider);
    final tipsAsync = ref.watch(personalizedTipsProvider);
    final weeklyAsync = ref.watch(weeklyRecordsProvider);

    return SafeArea(
      child: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () async {
                  final uid = await ref.read(currentUidProvider.future);
                  final name = await ref.read(authServiceProvider).getUserName() ?? '';
                  final email = await ref.read(authServiceProvider).getUserEmail() ?? '';
                  if (context.mounted) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ProfileSetupScreen(uid: uid ?? '', name: name, email: email),
                    ));
                  }
                },
                child: const Text('Setup Profile'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(todayEntriesProvider);
              ref.invalidate(dailyTotalsProvider);
              ref.invalidate(dietPlanProvider);
              ref.invalidate(personalizedTipsProvider);
              ref.invalidate(weeklyRecordsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              physics: const BouncingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${profile.name.split(' ').first}!',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Here\'s your nutrition summary for today.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bar_chart_outlined),
                        tooltip: 'Reports',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ReportsScreen()),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        tooltip: 'Reminders',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RemindersScreen()),
                        ),
                      ),
                      IconButton(
                        icon: Icon(_themeIcon(ref.watch(themeProvider))),
                        tooltip: 'Toggle theme',
                        onPressed: () => ref.read(themeProvider.notifier).cycle(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                          await ref.read(authServiceProvider).logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (_) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                ref.watch(userStreakProvider).when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (streak) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: StreakCard(
                      streak: streak,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedGlassCard(
                    delayMs: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: totalsAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('Error loading totals'),
                          data: (totals) => CalorieRing(
                            consumed: totals['calories'] ?? 0,
                            target: profile.dailyCalorieTarget,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                totalsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (totals) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedGlassCard(
                      delayMs: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            MacroBar(label: 'Protein', current: totals['protein'] ?? 0, target: profile.proteinTargetG, color: Colors.blue),
                            const SizedBox(height: 14),
                            MacroBar(label: 'Carbs', current: totals['carbs'] ?? 0, target: profile.carbsTargetG, color: AppTheme.accent),
                            const SizedBox(height: 14),
                            MacroBar(label: 'Fat', current: totals['fat'] ?? 0, target: profile.fatTargetG, color: Colors.red.shade400),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                dietAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (plan) {
                    if (plan != null && plan.days.isNotEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AnimatedGlassCard(
                        delayMs: 350,
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.08),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('AI Meal Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('Personalized 7-day plan based on your profile',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: _generatingPlan
                                  ? const Center(child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ))
                                  : FilledButton.icon(
                                      icon: const Icon(Icons.auto_awesome, size: 18),
                                      label: const Text('Generate 7-Day AI Meal Plan'),
                                      onPressed: _generateMealPlan,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                tipsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (tips) {
                    if (tips.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Tips For You', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            physics: const BouncingScrollPhysics(),
                            itemCount: tips.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: PersonalizedTipCard(tip: tips[i], index: i),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),

                dietAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (plan) {
                    if (plan == null || plan.days.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Your Meal Plan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DietPlanScreen())),
                                    child: const Text('View All'),
                                  ),
                                  IconButton(
                                    icon: _generatingPlan
                                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.refresh, size: 20),
                                    tooltip: 'Regenerate plan',
                                    onPressed: _generatingPlan ? null : _generateMealPlan,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            physics: const BouncingScrollPhysics(),
                            itemCount: plan.days.length,
                            itemBuilder: (_, i) => _DayPlanCard(day: plan.days[i], index: i),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedGlassCard(
                    delayMs: 350,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RecipesScreen()),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.restaurant_menu, color: AppTheme.accent, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('My Recipes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Save and track your favorite recipes',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Weekly Progress', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedGlassCard(
                    delayMs: 400,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: weeklyAsync.when(
                        loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                        error: (_, __) => const SizedBox(height: 200, child: Center(child: Text('Error'))),
                        data: (records) => WeeklyChart(records: records),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Today's Meals", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                entriesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Error')),
                  data: (entries) {
                    if (entries.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No meals logged yet.\nTap Scan to add food!', textAlign: TextAlign.center)),
                      );
                    }
                    return Column(
                      children: entries.asMap().entries.map((e) => MealCard(
                        entry: e.value,
                        index: e.key,
                        onDelete: () async {
                          await ref.read(foodRepoProvider).deleteEntry(e.value.id);
                          ref.invalidate(todayEntriesProvider);
                          ref.invalidate(dailyTotalsProvider);
                        },
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DayPlanCard extends StatefulWidget {
  final DayPlan day;
  final int index;
  const _DayPlanCard({required this.day, this.index = 0});

  @override
  State<_DayPlanCard> createState() => _DayPlanCardState();
}

class _DayPlanCardState extends State<_DayPlanCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
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
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          child: GlassCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.day.dayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text('${widget.day.totalCalories.round()} kcal',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500, fontSize: 13)),
                const Spacer(),
                ...widget.day.meals.take(3).map((m) => Text(
                  m.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                )),
                if (widget.day.meals.length > 3)
                  Text('+${widget.day.meals.length - 3} more', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
