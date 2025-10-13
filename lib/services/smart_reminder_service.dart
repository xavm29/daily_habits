import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/goals_model.dart';

class SmartReminderService {
  static final SmartReminderService instance = SmartReminderService._internal();
  SmartReminderService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  // Schedule smart reminder based on user's best completion time
  Future<void> scheduleSmartReminder(Goal goal) async {
    final bestTime = await _getBestCompletionTime(goal.id);

    if (bestTime != null) {
      await _scheduleNotification(
        id: goal.id.hashCode,
        title: '⏰ ${goal.title}',
        body: 'You usually complete this habit around this time. Let\'s keep the streak going!',
        scheduledTime: bestTime,
      );
    } else {
      // Fallback to default reminder time
      await scheduleDefaultReminder(goal);
    }
  }

  // Schedule reminder based on user's routine
  Future<void> scheduleDefaultReminder(Goal goal) async {
    final prefs = await SharedPreferences.getInstance();
    final preferredHour = prefs.getInt('reminder_hour') ?? 9; // Default 9 AM
    final preferredMinute = prefs.getInt('reminder_minute') ?? 0;

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      preferredHour,
      preferredMinute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _scheduleNotification(
      id: goal.id.hashCode,
      title: '📝 ${goal.title}',
      body: 'Time to work on your habit!',
      scheduledTime: scheduledDate,
    );
  }

  // Schedule motivational reminder if user is on a streak
  Future<void> scheduleMotivationalReminder(String goalId, int streak) async {
    String message;

    if (streak >= 30) {
      message = '🔥 Amazing! You\'ve maintained a ${streak}-day streak! Don\'t break it now!';
    } else if (streak >= 7) {
      message = '🎯 Great job! You\'re on a ${streak}-day streak! Keep it up!';
    } else if (streak >= 3) {
      message = '💪 You\'re building momentum! ${streak} days in a row!';
    } else {
      return; // Don't send motivational reminders for short streaks
    }

    await _scheduleNotification(
      id: goalId.hashCode + 1000, // Offset to avoid conflict
      title: 'Streak Alert! 🔥',
      body: message,
      scheduledTime: DateTime.now().add(const Duration(hours: 2)),
    );
  }

  // Schedule reminder if user hasn't completed habits today
  Future<void> scheduleIncompleteReminder(List<Goal> incompleteGoals) async {
    if (incompleteGoals.isEmpty) return;

    final now = DateTime.now();
    var reminderTime = DateTime(now.year, now.month, now.day, 20, 0); // 8 PM

    if (reminderTime.isBefore(now)) {
      reminderTime = reminderTime.add(const Duration(days: 1));
    }

    final count = incompleteGoals.length;
    final goalNames = incompleteGoals.take(2).map((g) => g.title).join(', ');

    await _scheduleNotification(
      id: 9999,
      title: '⚠️ ${count} habit${count > 1 ? "s" : ""} pending',
      body: 'Don\'t forget: $goalNames${count > 2 ? " and ${count - 2} more" : ""}',
      scheduledTime: reminderTime,
    );
  }

  // Cancel all notifications for a goal
  Future<void> cancelGoalNotifications(String goalId) async {
    await _notifications.cancel(goalId.hashCode);
    await _notifications.cancel(goalId.hashCode + 1000);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Helper: Schedule a notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_habits_channel',
          'Daily Habits',
          channelDescription: 'Notifications for daily habits',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Analyze user's completion pattern to find best time
  Future<DateTime?> _getBestCompletionTime(String goalId) async {
    final prefs = await SharedPreferences.getInstance();
    final completionTimesJson = prefs.getStringList('completion_times_$goalId');

    if (completionTimesJson == null || completionTimesJson.isEmpty) {
      return null;
    }

    // Parse completion times
    final completionTimes = completionTimesJson
        .map((e) => DateTime.parse(e))
        .toList();

    // Calculate average hour
    final avgHour = completionTimes
        .map((t) => t.hour)
        .reduce((a, b) => a + b) ~/ completionTimes.length;

    // Schedule 30 minutes before average completion time
    final now = DateTime.now();
    var bestTime = DateTime(now.year, now.month, now.day, avgHour, 0)
        .subtract(const Duration(minutes: 30));

    if (bestTime.isBefore(now)) {
      bestTime = bestTime.add(const Duration(days: 1));
    }

    return bestTime;
  }

  // Save completion time for analysis
  Future<void> saveCompletionTime(String goalId, DateTime completionTime) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'completion_times_$goalId';
    final times = prefs.getStringList(key) ?? [];

    times.add(completionTime.toIso8601String());

    // Keep only last 30 completions for analysis
    if (times.length > 30) {
      times.removeAt(0);
    }

    await prefs.setStringList(key, times);
  }

  // Set preferred reminder time
  Future<void> setPreferredReminderTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', hour);
    await prefs.setInt('reminder_minute', minute);
  }

  // Get preferred reminder time
  Future<Map<String, int>> getPreferredReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt('reminder_hour') ?? 9,
      'minute': prefs.getInt('reminder_minute') ?? 0,
    };
  }
}
