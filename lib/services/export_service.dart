import 'dart:io';
import 'package:csv/csv.dart';
import 'package:daily_habits/models/completed_goal.dart';
import 'package:daily_habits/models/goals_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ExportService {
  static final ExportService instance = ExportService._internal();
  ExportService._internal();

  // Export to CSV
  Future<void> exportToCSV({
    required List<Goal> goals,
    required List<CompletedTask> tasks,
  }) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Date',
      'Goal Title',
      'Goal Type',
      'Target Value',
      'Achieved Value',
      'Unit',
      'Mood',
      'Notes',
    ]);

    // Data rows
    for (var task in tasks) {
      final goal = goals.firstWhere(
        (g) => g.id == task.goalId,
        orElse: () => Goal('Unknown', '', Goal.kDaily, [], DateTime.now(), DateTime.now()),
      );

      rows.add([
        DateFormat('yyyy-MM-dd HH:mm').format(task.completedDateTime),
        goal.title,
        _getGoalTypeName(goal.goalType),
        goal.targetValue ?? '',
        task.achievedValue ?? 'Completed',
        goal.unit ?? '',
        task.mood ?? '',
        task.notes ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/habits_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(csv);

    // Share the file
    await Share.shareXFiles([XFile(path)], text: 'Daily Habits Export');
  }

  // Export to PDF
  Future<void> exportToPDF({
    required List<Goal> goals,
    required List<CompletedTask> tasks,
    required Map<String, dynamic> statistics,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Title
          pw.Header(
            level: 0,
            child: pw.Text(
              'Daily Habits Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // Statistics Section
          pw.Header(
            level: 1,
            child: pw.Text('Statistics', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _buildPdfRow('Total Goals', '${goals.length}', isHeader: false),
              _buildPdfRow('Total Completions', '${tasks.length}', isHeader: false),
              _buildPdfRow('Current Streak', '${statistics['currentStreak'] ?? 0} days', isHeader: false),
              _buildPdfRow('Longest Streak', '${statistics['longestStreak'] ?? 0} days', isHeader: false),
              _buildPdfRow('Total XP', '${statistics['totalXP'] ?? 0}', isHeader: false),
            ],
          ),
          pw.SizedBox(height: 20),

          // Goals Section
          pw.Header(
            level: 1,
            child: pw.Text('Active Goals', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          ...goals.map((goal) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      goal.title,
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Type: ${_getGoalTypeName(goal.goalType)}'),
                    if (goal.targetValue != null)
                      pw.Text('Target: ${goal.targetValue} ${goal.unit ?? ""}'),
                    pw.Text('Frequency: ${_getPeriodicityName(goal.periodic)}'),
                  ],
                ),
              )),
          pw.SizedBox(height: 20),

          // Recent Completions
          pw.Header(
            level: 1,
            child: pw.Text('Recent Completions', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              _buildPdfRow('Date', 'Goal', isHeader: true),
              ...tasks.take(20).map((task) {
                final goal = goals.firstWhere(
                  (g) => g.id == task.goalId,
                  orElse: () => Goal('Unknown', '', Goal.kDaily, [], DateTime.now(), DateTime.now()),
                );
                return _buildPdfRow(
                  DateFormat('yyyy-MM-dd').format(task.completedDateTime),
                  goal.title,
                );
              }),
            ],
          ),
        ],
      ),
    );

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/habits_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    // Share the file
    await Share.shareXFiles([XFile(path)], text: 'Daily Habits Report');
  }

  pw.TableRow _buildPdfRow(String cell1, String cell2, {bool isHeader = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            cell1,
            style: pw.TextStyle(
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            cell2,
            style: pw.TextStyle(
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  String _getGoalTypeName(int type) {
    switch (type) {
      case Goal.kTypeCheckbox:
        return 'Checkbox';
      case Goal.kTypeQuantity:
        return 'Quantity';
      case Goal.kTypeDuration:
        return 'Duration';
      default:
        return 'Unknown';
    }
  }

  String _getPeriodicityName(int periodic) {
    switch (periodic) {
      case Goal.kDaily:
        return 'Daily';
      case Goal.kWeekly:
        return 'Weekly';
      case Goal.kMonthly:
        return 'Monthly';
      default:
        return 'Unknown';
    }
  }
}
