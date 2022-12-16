import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_data.dart';

class Goal {
  static const kDaily = 1;
  static const kWeekly = 2;
  static const kMonthly = 3;

  static const kMonday = 1;
  static const kTuesday = 2;
  static const kWednesday = 3;
  static const kThursday = 4;
  static const kFriday = 5;
  static const kSaturday = 6;
  static const kSunday = 7;

  late String id;
  late String title;

  late String category;
  late int periodic;
  late List<int> weekDays;
  late DateTime endDate;
  late DateTime hourReminder;
  DateTime? lastCompleted;

  Goal(this.title, this.category, this.periodic, this.weekDays, this.endDate,
      this.hourReminder);

  Goal.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? "Goal---";
    category = json['category'] ?? "";
    periodic = json['periodic'] ?? kDaily;
    weekDays = json['weekDays']?.cast<int>() ?? <int>[];
    endDate = (json['endDate'] as Timestamp).toDate();
    hourReminder = (json['hourReminder'] as Timestamp).toDate();
    lastCompleted = (json['lastCompleted'] != null)
        ? (json['lastCompleted'] as Timestamp).toDate()
        : null;
  }

  bool isVisible(DateTime dateTime) {
    if (dateTime.isAfter(endDate)) return false;
    if (periodic == Goal.kWeekly && !weekDays.contains(dateTime.weekday)) {
      return false;
    }
    return true;
  }

  bool isCompletedForDate(DateTime dateTime, UserData userData) {
    bool completed = false;
    for (var task in userData.tasks) {
      if (task.goalId == id) {
        Duration difference = task.completedDateTime.difference(dateTime);
        int days = difference.inDays.abs();
        if (periodic == Goal.kDaily && days < 1) {
          completed = true;
        }
        if (periodic == Goal.kWeekly &&
            days < 7 &&
            weekDays.contains(task.completedDateTime.weekday)) {
          completed = true;
        }
        if (periodic == Goal.kMonthly && days < 30) {
          completed = true;
        }
      }
    }
    return completed;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'periodic': periodic,
      'weekDays': weekDays,
      'endDate': endDate,
      'hourReminder': hourReminder,
      'lastCompleted': lastCompleted
    };
  }
}
