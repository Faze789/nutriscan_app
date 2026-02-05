import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/weight_log.dart';

class WeightChart extends StatelessWidget {
  final List<WeightLog> logs;

  const WeightChart({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No weight data yet')),
      );
    }

    final sorted = List<WeightLog>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].weightKg));
    }

    final weights = sorted.map((l) => l.weightKg).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final range = maxW - minW;
    final padding = range > 0 ? range * 0.15 : 2.0;
    final yMin = (minW - padding - 1).floorToDouble();
    final yMax = (maxW + padding + 1).ceilToDouble();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = isDark ? Colors.white12 : Colors.grey.shade200;
    final textColor = isDark ? Colors.white70 : Colors.grey.shade600;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _calcInterval(yMin, yMax),
            getDrawingHorizontalLine: (value) => FlLine(
              color: gridColor,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: _calcInterval(yMin, yMax),
                getTitlesWidget: (value, meta) => Text(
                  '${value.toStringAsFixed(0)}kg',
                  style: TextStyle(fontSize: 10, color: textColor),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: _bottomInterval(sorted.length),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sorted.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('d/M').format(sorted[idx].date),
                      style: TextStyle(fontSize: 9, color: textColor),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (sorted.length - 1).toDouble().clamp(1.0, double.infinity),
          minY: yMin,
          maxY: yMax,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: const Color(0xFF9C27B0),
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: const Color(0xFF9C27B0),
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final idx = spot.x.toInt();
                  final log = sorted[idx];
                  return LineTooltipItem(
                    '${log.weightKg.toStringAsFixed(1)} kg\n${DateFormat('MMM d').format(log.date)}',
                    TextStyle(
                      color: isDark ? Colors.white : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  double _calcInterval(double min, double max) {
    final range = max - min;
    if (range <= 5) return 1;
    if (range <= 10) return 2;
    if (range <= 20) return 5;
    return 10;
  }

  double _bottomInterval(int count) {
    if (count <= 7) return 1;
    if (count <= 14) return 2;
    if (count <= 30) return 5;
    return (count / 6).ceilToDouble();
  }
}
