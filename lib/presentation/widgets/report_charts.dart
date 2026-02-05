import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/daily_record.dart';

class CalorieTrendChart extends StatelessWidget {
  final List<DailyRecord> records;

  const CalorieTrendChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SizedBox(
          height: 200, child: Center(child: Text('No data')));
    }

    final sorted = List<DailyRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final consumedSpots = <FlSpot>[];
    final burnedSpots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      consumedSpots.add(FlSpot(i.toDouble(), sorted[i].caloriesConsumed));
      burnedSpots.add(FlSpot(i.toDouble(), sorted[i].caloriesBurned));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = isDark ? Colors.white12 : Colors.grey.shade200;
    final textColor = isDark ? Colors.white70 : Colors.grey.shade600;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: gridColor, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: TextStyle(fontSize: 9, color: textColor),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (sorted.length / 5).ceilToDouble().clamp(1, 100),
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= sorted.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(DateFormat('d/M').format(sorted[idx].date),
                      style: TextStyle(fontSize: 9, color: textColor));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: consumedSpots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: const Color(0xFFFF9800),
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFFF9800).withValues(alpha: 0.1),
              ),
            ),
            LineChartBarData(
              spots: burnedSpots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: const Color(0xFFE91E63),
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class MacroPieChart extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;

  const MacroPieChart({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fat;
    if (total == 0) {
      return const SizedBox(
          height: 150, child: Center(child: Text('No data')));
    }

    return SizedBox(
      height: 150,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: protein,
                    color: Colors.blue,
                    title:
                        '${(protein / total * 100).round()}%',
                    titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    radius: 40,
                  ),
                  PieChartSectionData(
                    value: carbs,
                    color: AppTheme.accent,
                    title:
                        '${(carbs / total * 100).round()}%',
                    titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    radius: 40,
                  ),
                  PieChartSectionData(
                    value: fat,
                    color: Colors.red.shade400,
                    title: '${(fat / total * 100).round()}%',
                    titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    radius: 40,
                  ),
                ],
                centerSpaceRadius: 25,
                sectionsSpace: 2,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Legend('Protein', Colors.blue, '${protein.round()}g'),
              const SizedBox(height: 6),
              _Legend('Carbs', AppTheme.accent, '${carbs.round()}g'),
              const SizedBox(height: 6),
              _Legend('Fat', Colors.red.shade400, '${fat.round()}g'),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  final String value;

  const _Legend(this.label, this.color, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label: $value',
            style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
