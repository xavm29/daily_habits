import 'package:cloud_firestore/cloud_firestore.dart';

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
    };
  }

  bool isActive() {
    DateTime now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
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
}
