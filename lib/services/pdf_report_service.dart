import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../core/utils/report_data.dart';

class PdfReportService {
  static Future<void> generateAndPrint(ReportData data) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM d, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('NutriScan Report',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  '${dateFormat.format(data.start)} - ${dateFormat.format(data.end)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Summary'),
          _buildSummaryTable(data),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Daily Averages'),
          _buildAveragesTable(data),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Daily Log'),
          _buildDailyLog(data),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: 'NutriScan_Report_${DateFormat('yyyyMMdd').format(data.start)}_${DateFormat('yyyyMMdd').format(data.end)}',
    );
  }

  static pw.Widget _buildSummaryTable(ReportData data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        _tableRow('Period', '${data.totalDays} days'),
        _tableRow('Days Logged', '${data.daysLogged}'),
        _tableRow('Total Calories Consumed',
            '${data.totalCalories.round()} kcal'),
        _tableRow('Total Calories Burned',
            '${data.totalBurned.round()} kcal'),
        _tableRow('Total Meals', '${data.totalMeals}'),
        _tableRow('Total Exercises', '${data.totalExercises}'),
      ],
    );
  }

  static pw.Widget _buildAveragesTable(ReportData data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        _tableRow(
            'Avg. Calories/Day', '${data.avgCalories.round()} kcal'),
        _tableRow('Avg. Protein/Day', '${data.avgProtein.round()}g'),
        _tableRow('Avg. Carbs/Day', '${data.avgCarbs.round()}g'),
        _tableRow('Avg. Fat/Day', '${data.avgFat.round()}g'),
        _tableRow('Avg. Water/Day',
            '${data.avgWaterGlasses.toStringAsFixed(1)} glasses'),
      ],
    );
  }

  static pw.Widget _buildDailyLog(ReportData data) {
    final sorted = List.of(data.records)
      ..sort((a, b) => a.date.compareTo(b.date));

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _headerCell('Date'),
            _headerCell('Calories In'),
            _headerCell('Calories Out'),
            _headerCell('Water'),
            _headerCell('Weight'),
          ],
        ),
        ...sorted.map((r) => pw.TableRow(children: [
              _cell(DateFormat('MMM d').format(r.date)),
              _cell('${r.caloriesConsumed.round()} kcal'),
              _cell('${r.caloriesBurned.round()} kcal'),
              _cell('${r.waterGlasses} glasses'),
              _cell(r.weightKg != null
                  ? '${r.weightKg!.toStringAsFixed(1)} kg'
                  : '-'),
            ])),
      ],
    );
  }

  static pw.TableRow _tableRow(String label, String value) {
    return pw.TableRow(children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(value),
      ),
    ]);
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, fontSize: 10)),
    );
  }

  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }
}
