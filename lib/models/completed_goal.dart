import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class CompletedTask {
  late String goalId;
  late DateTime completedDateTime;

  CompletedTask(this.goalId, this.completedDateTime);

  CompletedTask.fromJson(Map<String, dynamic> json) {
    goalId = json['goalId'];
    completedDateTime = (json['completedDateTime'] as Timestamp).toDate();
  }

  Map<String, dynamic> toJson() {
    return {'goalId': goalId, 'completedDateTime': completedDateTime};
  }
}
