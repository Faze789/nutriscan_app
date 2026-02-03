import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/daily_record.dart';

class WeeklyChart extends StatelessWidget {
  final List<DailyRecord> records;

  const WeeklyChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final bars = <BarChartGroupData>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final record = records.where((r) =>
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day).firstOrNull;
      final cal = record?.caloriesConsumed ?? 0;
      bars.add(BarChartGroupData(
        x: 6 - i,
        barRods: [
          BarChartRodData(
            toY: cal,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
            ),
          ),
        ],
      ));
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: bars,
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final date = now.subtract(Duration(days: 6 - value.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(days[date.weekday - 1], style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) {
                return BarTooltipItem(
                  '${rod.toY.round()} kcal',
                  const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
