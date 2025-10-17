import 'package:daily_habits/models/challenge_model.dart';
import 'package:daily_habits/models/challenge_progress_model.dart';
import 'package:daily_habits/services/challenge_service.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final Challenge challenge;

  const ChallengeDetailScreen({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final ChallengeService _challengeService = ChallengeService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.challenge.title),
        backgroundColor: AppColors.primarys,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<ChallengeProgress?>(
        stream: _challengeService.getUserProgress(widget.challenge.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final progress = snapshot.data;

          if (progress == null) {
            return const Center(
              child: Text('No se encontró el progreso del reto'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(progress),
                const SizedBox(height: 16),
                _buildTodayCard(progress),
                const SizedBox(height: 16),
                _buildProgressCard(progress),
                const SizedBox(height: 16),
                _buildCalendarView(progress),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(ChallengeProgress progress) {
    final progressPercent = progress.getProgress(widget.challenge.targetCount);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.challenge.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 20.0,
              percent: progressPercent,
              center: Text(
                "${(progressPercent * 100).toInt()}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              progressColor: _getProgressColor(progressPercent),
              backgroundColor: Colors.grey[300],
              barRadius: const Radius.circular(10),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  icon: Icons.check_circle,
                  label: 'Completados',
                  value: '${progress.completedDays}',
                  color: Colors.green,
                ),
                _buildStat(
                  icon: Icons.local_fire_department,
                  label: 'Racha',
                  value: '${progress.currentStreak}',
                  color: Colors.orange,
                ),
                _buildStat(
                  icon: Icons.flag,
                  label: 'Meta',
                  value: '${widget.challenge.targetCount}',
                  color: Colors.blue,
                ),
                _buildStat(
                  icon: Icons.timer,
                  label: 'Restantes',
                  value: '${widget.challenge.getDaysRemaining()}',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayCard(ChallengeProgress progress) {
    final hasCompletedToday = progress.hasCompletedToday();

    return Card(
      elevation: 2,
      color: hasCompletedToday ? Colors.green[50] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasCompletedToday ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: hasCompletedToday ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasCompletedToday
                            ? '¡Completado hoy!'
                            : 'Marca el día de hoy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: hasCompletedToday ? Colors.green[700] : Colors.black87,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, d MMMM', 'es').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!hasCompletedToday) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _challengeService.markTodayCompleted(widget.challenge.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Día marcado como completado!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Marcar como Completado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purplelow,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(ChallengeProgress progress) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu Progreso',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    'Días Completados',
                    '${progress.completedDays} / ${widget.challenge.targetCount}',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressItem(
                    'Tasa de Éxito',
                    '${((progress.completedDays / widget.challenge.durationDays) * 100).toStringAsFixed(0)}%',
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    'Fecha de Inicio',
                    DateFormat('d MMM', 'es').format(progress.joinedDate),
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProgressItem(
                    'Fecha Final',
                    DateFormat('d MMM', 'es').format(widget.challenge.endDate),
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(ChallengeProgress progress) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calendario del Reto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCalendarGrid(progress),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(ChallengeProgress progress) {
    final startDate = widget.challenge.startDate;
    final endDate = widget.challenge.endDate;
    final totalDays = endDate.difference(startDate).inDays + 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: totalDays,
      itemBuilder: (context, index) {
        final date = startDate.add(Duration(days: index));
        final isCompleted = progress.completedDates.any((completedDate) =>
            completedDate.year == date.year &&
            completedDate.month == date.month &&
            completedDate.day == date.day);
        final isToday = _isToday(date);
        final isFuture = date.isAfter(DateTime.now());

        return Container(
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isFuture
                    ? Colors.grey[200]
                    : Colors.red[100],
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? Colors.white
                        : isFuture
                            ? Colors.grey[400]
                            : Colors.red[700],
                  ),
                ),
                if (isCompleted)
                  const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }
}
