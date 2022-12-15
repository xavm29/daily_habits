import 'package:cloud_firestore/cloud_firestore.dart';

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
  late bool completed;
  late int number;
  late String category;
  late int periodic;
  late List<int> weekDays;
  late DateTime endDate;
  late DateTime hourReminder;
  DateTime? lastCompleted;

  Goal(this.title, this.completed, this.number, this.category, this.periodic,
      this.weekDays, this.endDate, this.hourReminder);
  Goal.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? "Goal---";
    completed = json['completed'] ?? false;
    number = json['number'] ?? 1;
    category = json['category'] ?? "";
    periodic = json['periodic'] ?? kDaily;
    weekDays = json['weekDays']?.cast<int>() ?? <int>[];
    endDate = (json['endDate'] as Timestamp).toDate();
    hourReminder = (json['hourReminder'] as Timestamp).toDate();
    lastCompleted = (json['lastCompleted'] != null)
        ? (json['lastCompleted'] as Timestamp).toDate()
        : null;
  }

  bool isCompletedForDate(DateTime dateTime) {
    //TODO: check lastCompleted
    // if (daily && lastcompleted <
     if (periodic ==1 &&lastCompleted => dateTime.now ){

     }
    return completed;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
      'number': number,
      'category': category,
      'periodic': periodic,
      'weekDays': weekDays,
      'endDate': endDate,
      'hourReminder': hourReminder,
      'lastCompleted': lastCompleted
    };
  }

  void completedGoal() {
    var saveCompletedGoals;
    (completed = true) ?? saveCompletedGoals;
  }
}
