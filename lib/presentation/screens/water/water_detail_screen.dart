import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../providers/water_provider.dart';
import '../../widgets/glass_card.dart';

class WaterDetailScreen extends ConsumerWidget {
  const WaterDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(todayWaterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Water Intake')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getBackgroundGradient(context)),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              child: waterAsync.when(
                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (water) {
                  final totalMl = water?.totalMl ?? 0;
                  final goalMl = water?.goalMl ?? 2000;
                  final progress = goalMl > 0 ? (totalMl / goalMl).clamp(0.0, 1.0) : 0.0;

                  return Column(
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 12,
                                backgroundColor: const Color(0xFF2196F3).withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.water_drop, color: Color(0xFF2196F3), size: 28),
                                const SizedBox(height: 4),
                                Text('${totalMl.round()} ml',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                Text('of ${goalMl.round()} ml',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        progress >= 1.0 ? 'Goal reached!' : '${((1 - progress) * goalMl).round()} ml remaining',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: progress >= 1.0 ? AppTheme.primary : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('Quick Add',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _QuickAddBtn(ml: 100, ref: ref, context: context),
                const SizedBox(width: 8),
                _QuickAddBtn(ml: 250, ref: ref, context: context),
                const SizedBox(width: 8),
                _QuickAddBtn(ml: 500, ref: ref, context: context),
                const SizedBox(width: 8),
                _QuickAddBtn(ml: 750, ref: ref, context: context),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text("Today's Log",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            waterAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (water) {
                if (water == null || water.entries.isEmpty) {
                  return const GlassCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No water logged yet today', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  );
                }
                final sorted = List.from(water.entries)..sort((a, b) => b.time.compareTo(a.time));
                return GlassCard(
                  child: Column(
                    children: sorted.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.water_drop, color: const Color(0xFF2196F3).withValues(alpha: 0.6), size: 18),
                          const SizedBox(width: 10),
                          Text('${e.ml.round()} ml', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text(DateFormat('h:mm a').format(e.time),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    )).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddBtn extends StatelessWidget {
  final int ml;
  final WidgetRef ref;
  final BuildContext context;

  const _QuickAddBtn({required this.ml, required this.ref, required this.context});

  @override
  Widget build(BuildContext outerContext) {
    return Expanded(
      child: FilledButton.tonal(
        onPressed: () async {
          final uid = await ref.read(currentUidProvider.future);
          if (uid == null) return;
          await ref.read(waterIntakeRepoProvider).addWater(uid, DateTime.now(), ml.toDouble());
          ref.invalidate(todayWaterProvider);
          ref.invalidate(weeklyWaterProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('+${ml}ml added!'), duration: const Duration(seconds: 1)),
            );
          }
        },
        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
        child: Text('+${ml}ml', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
