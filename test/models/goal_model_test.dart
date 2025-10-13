import 'package:flutter_test/flutter_test.dart';
import 'package:daily_habits/models/goals_model.dart';
import 'package:daily_habits/models/completed_goal.dart';
import 'package:daily_habits/models/user_data.dart';

void main() {
  group('Goal Model Tests', () {
    late DateTime now;
    late DateTime hourReminder;

    setUp(() {
      now = DateTime.now();
      hourReminder = DateTime(now.year, now.month, now.day, 9, 0); // 9 AM reminder
    });

    group('Goal Creation', () {
      test('should create checkbox goal with default type', () {
        final goal = Goal(
          'Read a book',
          'Education',
          Goal.kDaily,
          [],
          now.add(const Duration(days: 30)),
          hourReminder,
        );
        goal.id = ''; // Initialize id field

        expect(goal.title, equals('Read a book'));
        expect(goal.category, equals('Education'));
        expect(goal.periodic, equals(Goal.kDaily));
        expect(goal.goalType, equals(Goal.kTypeCheckbox));
        expect(goal.id, isEmpty);
      });

      test('should create quantitative goal with target value', () {
        final goal = Goal(
          'Drink water',
          'Health',
          Goal.kDaily,
          [],
          now.add(const Duration(days: 30)),
          hourReminder,
          goalType: Goal.kTypeQuantity,
          targetValue: 8,
          unit: 'glasses',
        );

        expect(goal.title, equals('Drink water'));
        expect(goal.goalType, equals(Goal.kTypeQuantity));
        expect(goal.targetValue, equals(8));
        expect(goal.unit, equals('glasses'));
      });

      test('should create duration goal', () {
        final goal = Goal(
          'Meditate',
          'Wellness',
          Goal.kDaily,
          [],
          now.add(const Duration(days: 30)),
          hourReminder,
          goalType: Goal.kTypeDuration,
          targetValue: 20,
          unit: 'minutes',
        );

        expect(goal.goalType, equals(Goal.kTypeDuration));
        expect(goal.targetValue, equals(20));
        expect(goal.unit, equals('minutes'));
      });
    });

    group('isVisible', () {
      test('daily goal should be visible every day before end date', () {
        final endDate = now.add(const Duration(days: 30));
        final goal = Goal(
          'Daily Task',
          'General',
          Goal.kDaily,
          [],
          endDate,
          hourReminder,
        );

        expect(goal.isVisible(now), isTrue);
        expect(goal.isVisible(now.add(const Duration(days: 1))), isTrue);
        expect(goal.isVisible(now.add(const Duration(days: 29))), isTrue);
      });

      test('should not be visible after end date', () {
        final endDate = now.subtract(const Duration(days: 5));
        final goal = Goal(
          'Expired Task',
          'General',
          Goal.kDaily,
          [],
          endDate,
          hourReminder,
        );

        expect(goal.isVisible(now), isFalse);
        expect(goal.isVisible(now.add(const Duration(days: 1))), isFalse);
      });

      test('weekly goal should be visible on selected weekdays only', () {
        // Create a goal for Mondays only
        final endDate = now.add(const Duration(days: 30));
        final goal = Goal(
          'Weekly Task',
          'General',
          Goal.kWeekly,
          [Goal.kMonday], // Monday only
          endDate,
          hourReminder,
        );

        // Find next Monday and Tuesday
        final monday = _findNextWeekday(now, DateTime.monday);
        final tuesday = monday.add(const Duration(days: 1));

        expect(goal.isVisible(monday), isTrue);
        expect(goal.isVisible(tuesday), isFalse);
      });

      test('weekly goal should handle multiple weekdays', () {
        final endDate = now.add(const Duration(days: 30));
        final goal = Goal(
          'Multi-day Task',
          'General',
          Goal.kWeekly,
          [Goal.kMonday, Goal.kWednesday, Goal.kFriday], // MWF
          endDate,
          hourReminder,
        );

        final monday = _findNextWeekday(now, DateTime.monday);
        final tuesday = monday.add(const Duration(days: 1));
        final wednesday = monday.add(const Duration(days: 2));

        expect(goal.isVisible(monday), isTrue);
        expect(goal.isVisible(tuesday), isFalse);
        expect(goal.isVisible(wednesday), isTrue);
      });
    });

    group('isCompletedForDate', () {
      test('should return true when daily task is completed on same day', () {
        final goal = Goal(
          'Completed Task',
          'General',
          Goal.kDaily,
          [],
          now.add(const Duration(days: 30)),
          hourReminder,
        );
        goal.id = 'test_goal_id';

        final userData = UserData();
        userData.tasks.add(CompletedTask('test_goal_id', now));

        expect(goal.isCompletedForDate(now, userData), isTrue);
      });

      test('should return false when daily task is not completed', () {
        final goal = Goal(
          'Incomplete Task',
          'General',
          Goal.kDaily,
          [],
          now.add(const Duration(days: 30)),
          hourReminder,
        );
        goal.id = 'test_goal_id';

        final userData = UserData();

        expect(goal.isCompletedForDate(now, userData), isFalse);
      });

      test('should return false for daily task completed on different day', () {
        final goal = Goal(
          'Yesterday Task',
          'General',
          Goal.kDaily,
          [],
          now.add(const Duration(days: 30)),
          hourReminder,
        );
        goal.id = 'test_goal_id';

        final yesterday = now.subtract(const Duration(days: 2)); // More than 1 day ago
        final userData = UserData();
        userData.tasks.add(CompletedTask('test_goal_id', yesterday));

        expect(goal.isCompletedForDate(now, userData), isFalse);
      });

      test('should return true for weekly task completed on correct weekday', () {
        final goal = Goal(
          'Weekly Task',
          'General',
          Goal.kWeekly,
          [Goal.kMonday],
          now.add(const Duration(days: 30)),
          hourReminder,
        );
        goal.id = 'weekly_task_id';

        final monday = _findNextWeekday(now, DateTime.monday);
        final userData = UserData();
        userData.tasks.add(CompletedTask('weekly_task_id', monday));

        expect(goal.isCompletedForDate(monday, userData), isTrue);
      });
    });

    group('Serialization', () {
      test('should serialize to JSON correctly', () {
        final goal = Goal(
          'Test Goal',
          'Testing',
          Goal.kDaily,
          [],
          now.add(const Duration(days: 30)),
          hourReminder,
          goalType: Goal.kTypeCheckbox,
        );

        final json = goal.toJson();

        expect(json['title'], equals('Test Goal'));
        expect(json['category'], equals('Testing'));
        expect(json['periodic'], equals(Goal.kDaily));
        expect(json['goalType'], equals(Goal.kTypeCheckbox));
      });

      test('should serialize quantitative goal with all fields', () {
        final goal = Goal(
          'Quantitative Goal',
          'Health',
          Goal.kDaily,
          [],
          now.add(const Duration(days: 30)),
          hourReminder,
          goalType: Goal.kTypeQuantity,
          targetValue: 10,
          unit: 'reps',
        );

        final json = goal.toJson();

        expect(json['title'], equals('Quantitative Goal'));
        expect(json['goalType'], equals(Goal.kTypeQuantity));
        expect(json['targetValue'], equals(10));
        expect(json['unit'], equals('reps'));
      });
    });

    group('Goal Type Constants', () {
      test('checkbox type should be integer 1', () {
        expect(Goal.kTypeCheckbox, equals(1));
      });

      test('quantity type should be integer 2', () {
        expect(Goal.kTypeQuantity, equals(2));
      });

      test('duration type should be integer 3', () {
        expect(Goal.kTypeDuration, equals(3));
      });
    });

    group('Periodic Constants', () {
      test('daily should be integer 1', () {
        expect(Goal.kDaily, equals(1));
      });

      test('weekly should be integer 2', () {
        expect(Goal.kWeekly, equals(2));
      });

      test('monthly should be integer 3', () {
        expect(Goal.kMonthly, equals(3));
      });
    });

    group('Weekday Constants', () {
      test('weekday constants should match DateTime weekday values', () {
        expect(Goal.kMonday, equals(DateTime.monday));
        expect(Goal.kTuesday, equals(DateTime.tuesday));
        expect(Goal.kWednesday, equals(DateTime.wednesday));
        expect(Goal.kThursday, equals(DateTime.thursday));
        expect(Goal.kFriday, equals(DateTime.friday));
        expect(Goal.kSaturday, equals(DateTime.saturday));
        expect(Goal.kSunday, equals(DateTime.sunday));
      });
    });
  });
}

// Helper function to find next occurrence of a specific weekday
DateTime _findNextWeekday(DateTime start, int targetWeekday) {
  DateTime date = start;
  while (date.weekday != targetWeekday) {
    date = date.add(const Duration(days: 1));
  }
  return date;
}
