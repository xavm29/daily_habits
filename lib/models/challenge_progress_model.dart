import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeProgress {
  late String id;
  late String challengeId;
  late String userId;
  late int completedDays;
  late List<DateTime> completedDates;
  late DateTime lastUpdated;
  late DateTime joinedDate;
  late bool isCompleted;
  late int currentStreak;

  ChallengeProgress({
    required this.challengeId,
    required this.userId,
    this.completedDays = 0,
    List<DateTime>? completedDates,
    DateTime? lastUpdated,
    DateTime? joinedDate,
    this.isCompleted = false,
    this.currentStreak = 0,
  })  : completedDates = completedDates ?? [],
        lastUpdated = lastUpdated ?? DateTime.now(),
        joinedDate = joinedDate ?? DateTime.now();

  ChallengeProgress.fromJson(Map<String, dynamic> json) {
    challengeId = json['challengeId'] ?? '';
    userId = json['userId'] ?? '';
    completedDays = json['completedDays'] ?? 0;
    completedDates = (json['completedDates'] as List<dynamic>?)
            ?.map((e) => (e as Timestamp).toDate())
            .toList() ??
        [];
    lastUpdated = (json['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now();
    joinedDate = (json['joinedDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    isCompleted = json['isCompleted'] ?? false;
    currentStreak = json['currentStreak'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'userId': userId,
      'completedDays': completedDays,
      'completedDates': completedDates,
      'lastUpdated': lastUpdated,
      'joinedDate': joinedDate,
      'isCompleted': isCompleted,
      'currentStreak': currentStreak,
    };
  }

  // Verifica si el usuario completó el reto hoy
  bool hasCompletedToday() {
    if (completedDates.isEmpty) return false;
    final today = DateTime.now();
    return completedDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  // Marca el día de hoy como completado
  void markTodayAsCompleted() {
    if (hasCompletedToday()) return;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    completedDates.add(todayDate);
    completedDays = completedDates.length;
    lastUpdated = DateTime.now();

    // Actualizar racha
    _updateStreak();
  }

  // Actualiza la racha actual
  void _updateStreak() {
    if (completedDates.isEmpty) {
      currentStreak = 0;
      return;
    }

    // Ordenar fechas
    final sortedDates = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    int streak = 1;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Verificar si la racha está activa (completado hoy o ayer)
    final mostRecent = sortedDates.first;
    final daysDifference = todayDate.difference(mostRecent).inDays;

    if (daysDifference > 1) {
      currentStreak = 0;
      return;
    }

    // Contar días consecutivos
    for (int i = 0; i < sortedDates.length - 1; i++) {
      final diff = sortedDates[i].difference(sortedDates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    currentStreak = streak;
  }

  // Calcula el progreso como porcentaje (0.0 a 1.0)
  double getProgress(int targetCount) {
    if (targetCount == 0) return 0.0;
    return (completedDays / targetCount).clamp(0.0, 1.0);
  }

  // Obtiene los días restantes para completar
  int getDaysRemaining(int targetCount) {
    return (targetCount - completedDays).clamp(0, targetCount);
  }
}
