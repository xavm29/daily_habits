import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class CompletedTask {
  late String goalId;
  late DateTime completedDateTime;
  double? achievedValue; // For quantitative tracking
  String? notes; // Optional notes for the task
  String? mood; // Optional mood indicator

  CompletedTask(this.goalId, this.completedDateTime, {this.achievedValue, this.notes, this.mood});

  CompletedTask.fromJson(Map<String, dynamic> json) {
    goalId = json['goalId'];
    completedDateTime = (json['completedDateTime'] as Timestamp).toDate();
    achievedValue = json['achievedValue']?.toDouble();
    notes = json['notes'];
    mood = json['mood'];
  }

  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'completedDateTime': completedDateTime,
      'achievedValue': achievedValue,
      'notes': notes,
      'mood': mood,
    };
  }
}
