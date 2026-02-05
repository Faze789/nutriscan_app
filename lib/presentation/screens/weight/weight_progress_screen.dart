import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/bmi_calculator.dart';
import '../../../data/models/weight_log.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/weight_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/weight_chart.dart';

class WeightProgressScreen extends ConsumerWidget {
  const WeightProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(weightLogsProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weight Progress')),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) {
          final sorted = List<WeightLog>.from(logs)
            ..sort((a, b) => a.date.compareTo(b.date));

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            children: [
              profileAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (profile) {
                  if (profile == null || sorted.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final currentWeight = sorted.last.weightKg;
                  final bmi = BmiCalculator.calculate(
                      currentWeight, profile.heightCm);
                  final bmiCat = BmiCalculator.category(bmi);
                  final bmiColor = _bmiColor(bmi);

                  return GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Stats',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoTile(
                                icon: Icons.monitor_weight,
                                label: 'Current',
                                value:
                                    '${currentWeight.toStringAsFixed(1)} kg',
                                color: const Color(0xFF9C27B0),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _InfoTile(
                                icon: Icons.speed,
                                label: 'BMI',
                                value: bmi.toStringAsFixed(1),
                                color: bmiColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _InfoTile(
                                icon: Icons.category,
                                label: 'Category',
                                value: bmiCat,
                                color: bmiColor,
                              ),
                            ),
                          ],
                        ),
                        if (sorted.length >= 2) ...[
                          const SizedBox(height: 12),
                          _buildChangeIndicator(sorted),
                        ],
                      ],
                    ),
                  );
                },
              ),
              if (sorted.isNotEmpty)
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weight Trend',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      WeightChart(logs: sorted),
                    ],
                  ),
                ),
              if (sorted.isNotEmpty)
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent Entries',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ...sorted.reversed.take(10).map(
                            (log) => _WeightEntryTile(log: log),
                          ),
                    ],
                  ),
                ),
              if (sorted.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.monitor_weight_outlined,
                          size: 48, color: AppTheme.textSecondary),
                      SizedBox(height: 12),
                      Text('No weight logs yet',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      Text('Log your weight from the Activity Log tab',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChangeIndicator(List<WeightLog> sorted) {
    final latest = sorted.last.weightKg;
    final previous = sorted[sorted.length - 2].weightKg;
    final change = latest - previous;
    final isGain = change > 0;
    final color = isGain ? Colors.orange : AppTheme.primary;

    final first = sorted.first.weightKg;
    final totalChange = latest - first;
    final totalIsGain = totalChange > 0;

    return Row(
      children: [
        Icon(
          isGain ? Icons.trending_up : Icons.trending_down,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          '${isGain ? '+' : ''}${change.toStringAsFixed(1)} kg since last entry',
          style: TextStyle(fontSize: 12, color: color),
        ),
        const Spacer(),
        Text(
          '${totalIsGain ? '+' : ''}${totalChange.toStringAsFixed(1)} kg total',
          style: TextStyle(
            fontSize: 12,
            color: totalIsGain ? Colors.orange : AppTheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return AppTheme.primary;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

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
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: color),
              textAlign: TextAlign.center),
          Text(label,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _WeightEntryTile extends StatelessWidget {
  final WeightLog log;

  const _WeightEntryTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${log.date.day}/${log.date.month}/${log.date.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.monitor_weight,
                size: 16, color: Color(0xFF9C27B0)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(dateStr,
                style: const TextStyle(fontSize: 13)),
          ),
          Text('${log.weightKg.toStringAsFixed(1)} kg',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
          if (log.notes != null && log.notes!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: log.notes!,
              child: Icon(Icons.notes,
                  size: 16, color: Colors.grey.shade400),
            ),
          ],
        ],
      ),
    );
  }
}
