import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/pdf_report_service.dart';
import '../../../services/sharing_service.dart';
import '../../providers/report_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/report_charts.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late DateTime _start;
  late DateTime _end;
  String _rangeLabel = 'Last 7 Days';

  @override
  void initState() {
    super.initState();
    _end = DateTime.now();
    _start = _end.subtract(const Duration(days: 6));
  }

  void _setRange(String label, int days) {
    setState(() {
      _rangeLabel = label;
      _end = DateTime.now();
      _start = _end.subtract(Duration(days: days - 1));
    });
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _start, end: _end),
    );
    if (picked != null) {
      setState(() {
        _start = picked.start;
        _end = picked.end;
        _rangeLabel = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(
      reportProvider((start: _start, end: _end)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          reportAsync.whenOrNull(
                data: (data) => IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Share',
                  onPressed: () => SharingService.shareText(
                    'My NutriScan Report (${data.daysLogged} days):\n'
                    'Avg Calories: ${data.avgCalories.round()} kcal/day\n'
                    'Avg Protein: ${data.avgProtein.round()}g\n'
                    'Avg Carbs: ${data.avgCarbs.round()}g\n'
                    'Avg Fat: ${data.avgFat.round()}g\n'
                    'Total Meals: ${data.totalMeals}\n',
                  ),
                ),
              ) ??
              const SizedBox.shrink(),
          reportAsync.whenOrNull(
                data: (data) => IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'Export PDF',
                  onPressed: () => PdfReportService.generateAndPrint(data),
                ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _RangeChip(
                  label: 'Last 7 Days',
                  selected: _rangeLabel == 'Last 7 Days',
                  onTap: () => _setRange('Last 7 Days', 7),
                ),
                _RangeChip(
                  label: 'Last 14 Days',
                  selected: _rangeLabel == 'Last 14 Days',
                  onTap: () => _setRange('Last 14 Days', 14),
                ),
                _RangeChip(
                  label: 'Last 30 Days',
                  selected: _rangeLabel == 'Last 30 Days',
                  onTap: () => _setRange('Last 30 Days', 30),
                ),
                _RangeChip(
                  label: 'Custom',
                  selected: _rangeLabel == 'Custom',
                  onTap: _pickCustomRange,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${DateFormat('MMM d').format(_start)} - ${DateFormat('MMM d, yyyy').format(_end)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: reportAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (data) {
                if (data.daysLogged == 0) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bar_chart,
                            size: 48, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text('No data for this period',
                            style:
                                TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                  children: [
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overview',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _SummaryTile(
                                  'Days Logged',
                                  '${data.daysLogged}/${data.totalDays}',
                                  AppTheme.primary),
                              const SizedBox(width: 8),
                              _SummaryTile(
                                  'Total Meals',
                                  '${data.totalMeals}',
                                  const Color(0xFFFF9800)),
                              const SizedBox(width: 8),
                              _SummaryTile(
                                  'Exercises',
                                  '${data.totalExercises}',
                                  const Color(0xFFE91E63)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _SummaryTile(
                                  'Avg Cal/Day',
                                  '${data.avgCalories.round()}',
                                  const Color(0xFFFF9800)),
                              const SizedBox(width: 8),
                              _SummaryTile(
                                  'Avg Water',
                                  data.avgWaterGlasses.toStringAsFixed(1),
                                  const Color(0xFF2196F3)),
                              const SizedBox(width: 8),
                              _SummaryTile(
                                  'Total kcal',
                                  '${data.totalCalories.round()}',
                                  AppTheme.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Calorie Trend',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.w600)),
                              const Spacer(),
                              const _LegendDot(
                                  'Consumed', Color(0xFFFF9800)),
                              const SizedBox(width: 8),
                              const _LegendDot(
                                  'Burned', Color(0xFFE91E63)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          CalorieTrendChart(records: data.records),
                        ],
                      ),
                    ),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Avg. Macro Split',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          MacroPieChart(
                            protein: data.avgProtein,
                            carbs: data.avgCarbs,
                            fat: data.avgFat,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primary.withValues(alpha: 0.15),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryTile(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 9, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDot(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}
