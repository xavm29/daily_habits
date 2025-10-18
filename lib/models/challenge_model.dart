import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';

class Challenge {
  late String id;
  late String title;
  late String description;
  late int durationDays;
  late DateTime startDate;
  late DateTime endDate;
  late List<String> participants;
  late String createdBy;
  late String category;
  late int targetCount;
  late bool isActive; // Si el reto está activo globalmente
  late String? linkedHabitId; // ID del hábito vinculado (opcional)
  late String habitCategory; // Categoría de hábito requerida (si no hay uno específico)
  late String? titleKey; // Translation key for title (for system challenges)
  late String? descriptionKey; // Translation key for description

  Challenge({
    required this.title,
    required this.description,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.participants,
    required this.createdBy,
    required this.category,
    required this.targetCount,
    this.isActive = true,
    this.linkedHabitId,
    this.habitCategory = 'any',
    this.titleKey,
    this.descriptionKey,
  });

  Challenge.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? '';
    description = json['description'] ?? '';
    durationDays = json['durationDays'] ?? 7;
    startDate = (json['startDate'] as Timestamp).toDate();
    endDate = (json['endDate'] as Timestamp).toDate();
    participants = json['participants']?.cast<String>() ?? <String>[];
    createdBy = json['createdBy'] ?? '';
    category = json['category'] ?? 'General';
    targetCount = json['targetCount'] ?? 7;
    isActive = json['isActive'] ?? true;
    linkedHabitId = json['linkedHabitId'];
    habitCategory = json['habitCategory'] ?? 'any';
    titleKey = json['titleKey'];
    descriptionKey = json['descriptionKey'];
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'durationDays': durationDays,
      'startDate': startDate,
      'endDate': endDate,
      'participants': participants,
      'createdBy': createdBy,
      'category': category,
      'targetCount': targetCount,
      'isActive': isActive,
      'linkedHabitId': linkedHabitId,
      'habitCategory': habitCategory,
      'titleKey': titleKey,
      'descriptionKey': descriptionKey,
    };
  }

  bool isActiveNow() {
    DateTime now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  int getDaysRemaining() {
    DateTime now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  double getProgress(int completedCount) {
    if (targetCount == 0) return 0.0;
    return (completedCount / targetCount).clamp(0.0, 1.0);
  }

  bool isParticipant(String userId) {
    return participants.contains(userId);
  }

  // Get localized title
  String getLocalizedTitle(AppLocalizations l10n) {
    if (titleKey == null) return title;

    // Use reflection-like approach to get the translation
    switch (titleKey) {
      case 'challenge7DayConsistency':
        return l10n.challenge7DayConsistency;
      case 'challenge30DayFitness':
        return l10n.challenge30DayFitness;
      case 'challengeMorningRoutineMaster':
        return l10n.challengeMorningRoutineMaster;
      case 'challenge21DayReading':
        return l10n.challenge21DayReading;
      case 'challenge14DayHydration':
        return l10n.challenge14DayHydration;
      default:
        return title; // Fallback to stored title
    }
  }

  // Get localized description
  String getLocalizedDescription(AppLocalizations l10n) {
    if (descriptionKey == null) return description;

    switch (descriptionKey) {
      case 'challenge7DayConsistencyDesc':
        return l10n.challenge7DayConsistencyDesc;
      case 'challenge30DayFitnessDesc':
        return l10n.challenge30DayFitnessDesc;
      case 'challengeMorningRoutineMasterDesc':
        return l10n.challengeMorningRoutineMasterDesc;
      case 'challenge21DayReadingDesc':
        return l10n.challenge21DayReadingDesc;
      case 'challenge14DayHydrationDesc':
        return l10n.challenge14DayHydrationDesc;
      default:
        return description; // Fallback to stored description
    }
  }
}
