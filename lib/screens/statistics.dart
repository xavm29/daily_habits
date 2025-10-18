import 'package:daily_habits/models/completed_goal.dart';
import 'package:daily_habits/models/goals_model.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data.dart';
import '../services/firebase_service.dart';
import '../services/export_service.dart';
import '../models/gamification_model.dart';
import '../l10n/app_localizations.dart';

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  var goals = <String, Goal>{};
  late UserData userData;
  int currentStreak = 0;
  int longestStreak = 0;
  double weeklyCompletionRate = 0.0;

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);
    _loadGoals();
    _calculateStats();
  }

  void _loadGoals() {
    var stream = FirebaseService.instance.goalsStream;
    stream.listen((event) {
      goals.clear();
      for (var doc in event.docs) {
        var goal = Goal.fromJson(doc.data());
        goal.id = doc.id;
        goals[doc.id] = goal;
      }
      _calculateStats();
      setState(() {});
    });
  }

  void _calculateStats() {
    // Calculate current streak
    currentStreak = _getCurrentStreak();
    longestStreak = _getLongestStreak();
    weeklyCompletionRate = _getWeeklyCompletionRate();
  }

  int _getCurrentStreak() {
    if (userData.tasks.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      bool hasTaskForDay = userData.tasks.any((task) {
        DateTime taskDate = DateTime(
          task.completedDateTime.year,
          task.completedDateTime.month,
          task.completedDateTime.day,
        );
        DateTime compareDate = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
        );
        return taskDate == compareDate;
      });

      if (!hasTaskForDay) break;
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _getLongestStreak() {
    if (userData.tasks.isEmpty) return 0;

    // Sort tasks by date
    List<CompletedTask> sortedTasks = List.from(userData.tasks)
      ..sort((a, b) => a.completedDateTime.compareTo(b.completedDateTime));

    int maxStreak = 0;
    int currentStreak = 1;

    for (int i = 1; i < sortedTasks.length; i++) {
      DateTime prevDate = DateTime(
        sortedTasks[i - 1].completedDateTime.year,
        sortedTasks[i - 1].completedDateTime.month,
        sortedTasks[i - 1].completedDateTime.day,
      );
      DateTime currDate = DateTime(
        sortedTasks[i].completedDateTime.year,
        sortedTasks[i].completedDateTime.month,
        sortedTasks[i].completedDateTime.day,
      );

      if (currDate.difference(prevDate).inDays == 1) {
        currentStreak++;
      } else if (currDate != prevDate) {
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
        currentStreak = 1;
      }
    }

    return currentStreak > maxStreak ? currentStreak : maxStreak;
  }

  double _getWeeklyCompletionRate() {
    DateTime now = DateTime.now();
    DateTime weekAgo = now.subtract(const Duration(days: 7));

    int completedCount = userData.tasks.where((task) {
      return task.completedDateTime.isAfter(weekAgo);
    }).length;

    int totalGoals = goals.length * 7;
    if (totalGoals == 0) return 0.0;

    return (completedCount / totalGoals * 100).clamp(0.0, 100.0);
  }

  List<BarChartGroupData> _getWeeklyData() {
    DateTime now = DateTime.now();
    List<BarChartGroupData> barGroups = [];

    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      DateTime dayStart = DateTime(day.year, day.month, day.day);

      int count = userData.tasks.where((task) {
        DateTime taskDate = DateTime(
          task.completedDateTime.year,
          task.completedDateTime.month,
          task.completedDateTime.day,
        );
        return taskDate == dayStart;
      }).length;

      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: AppColors.primarys,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(l10n.statistics),
        backgroundColor: AppColors.primarys,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: l10n.currentStreak,
                      value: '$currentStreak',
                      subtitle: l10n.days,
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: l10n.longestStreak,
                      value: '$longestStreak',
                      subtitle: l10n.days,
                      icon: Icons.emoji_events,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Completion Rate Card
              _StatCard(
                title: l10n.weeklyCompletion,
                value: '${weeklyCompletionRate.toStringAsFixed(1)}%',
                subtitle: l10n.ofGoalsCompleted,
                icon: Icons.check_circle,
                color: Colors.green,
                isFullWidth: true,
              ),
              const SizedBox(height: 24),

              // Weekly Chart
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.weeklyActivity,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (goals.length.toDouble() * 1.2).clamp(5, double.infinity),
                            barGroups: _getWeeklyData(),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                    return Text(
                                      days[value.toInt()],
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                            ),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Total Goals Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalOverview,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.flag,
                        label: l10n.activeGoals,
                        value: '${goals.length}',
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: Icons.check_circle_outline,
                        label: l10n.totalCompleted,
                        value: '${userData.tasks.length}',
                      ),
                      const Divider(),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: l10n.daysActive,
                        value: _getActiveDays().toString(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Export Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dataExport,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.downloadYourHabitsData,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _exportToCSV(),
                              icon: const Icon(Icons.table_chart),
                              label: Text(l10n.exportCSV),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _exportToPDF(),
                              icon: const Icon(Icons.picture_as_pdf),
                              label: Text(l10n.exportPDF),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportToCSV() async {
    try {
      await ExportService.instance.exportToCSV(
        goals: goals.values.toList(),
        tasks: userData.tasks,
      );
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.csvExportedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorExportingCSV}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToPDF() async {
    try {
      final totalXP = GamificationService.calculateXP(
        habitsCompleted: userData.tasks.length,
        streakDays: currentStreak,
      );

      await ExportService.instance.exportToPDF(
        goals: goals.values.toList(),
        tasks: userData.tasks,
        statistics: {
          'currentStreak': currentStreak,
          'longestStreak': longestStreak,
          'totalXP': totalXP,
        },
      );
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pdfReportExportedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorExportingPDF}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _getActiveDays() {
    if (userData.tasks.isEmpty) return 0;

    Set<String> uniqueDays = {};
    for (var task in userData.tasks) {
      String dateKey = '${task.completedDateTime.year}-${task.completedDateTime.month}-${task.completedDateTime.day}';
      uniqueDays.add(dateKey);
    }
    return uniqueDays.length;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isFullWidth;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: isFullWidth ? 32 : 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primarys),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
