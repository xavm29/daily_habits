import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goals_model.dart';
import '../models/completed_goal.dart';

class LocalStorageService {
  static final LocalStorageService instance = LocalStorageService._internal();
  LocalStorageService._internal();

  static const String _goalsBoxName = 'goals';
  static const String _tasksBoxName = 'tasks';
  static const String _usageCountKey = 'usage_count';
  static const String _lastPromptDateKey = 'last_prompt_date';
  static const int _usageBeforePrompt = 5; // Prompt after 5 uses

  Box<Map>? _goalsBox;
  Box<Map>? _tasksBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _goalsBox = await Hive.openBox<Map>(_goalsBoxName);
    _tasksBox = await Hive.openBox<Map>(_tasksBoxName);
  }

  // Track app usage
  Future<bool> shouldPromptForRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    final usageCount = prefs.getInt(_usageCountKey) ?? 0;
    final lastPromptDate = prefs.getString(_lastPromptDateKey);

    // Increment usage count
    await prefs.setInt(_usageCountKey, usageCount + 1);

    // Check if we should prompt
    if (usageCount >= _usageBeforePrompt) {
      // Check if we haven't prompted today
      final today = DateTime.now().toIso8601String().split('T')[0];
      if (lastPromptDate != today) {
        await prefs.setString(_lastPromptDateKey, today);
        return true;
      }
    }

    return false;
  }

  // Reset usage count after registration
  Future<void> resetUsageCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_usageCountKey, 0);
  }

  // Save goal locally
  Future<void> saveGoal(Goal goal) async {
    if (_goalsBox == null) return;
    await _goalsBox!.put(goal.id, goal.toJson());
  }

  // Get all local goals
  List<Goal> getLocalGoals() {
    if (_goalsBox == null) return [];
    return _goalsBox!.values.map((data) {
      final goal = Goal.fromJson(Map<String, dynamic>.from(data));
      return goal;
    }).toList();
  }

  // Delete goal locally
  Future<void> deleteGoal(String id) async {
    if (_goalsBox == null) return;
    await _goalsBox!.delete(id);
  }

  // Save completed task locally
  Future<void> saveCompletedTask(CompletedTask task) async {
    if (_tasksBox == null) return;
    final key = '${task.goalId}_${task.completedDateTime.toIso8601String()}';
    await _tasksBox!.put(key, task.toJson());
  }

  // Get all local completed tasks
  List<CompletedTask> getLocalCompletedTasks() {
    if (_tasksBox == null) return [];
    return _tasksBox!.values.map((data) {
      return CompletedTask.fromJson(Map<String, dynamic>.from(data));
    }).toList();
  }

  // Sync local data to Firebase when user registers
  Future<Map<String, dynamic>> getDataForSync() async {
    return {
      'goals': getLocalGoals().map((g) => g.toJson()).toList(),
      'tasks': getLocalCompletedTasks().map((t) => t.toJson()).toList(),
    };
  }

  // Clear local data after successful sync
  Future<void> clearLocalData() async {
    if (_goalsBox != null) await _goalsBox!.clear();
    if (_tasksBox != null) await _tasksBox!.clear();
  }

  // Check if user is using local storage
  Future<bool> hasLocalData() async {
    return (_goalsBox?.isNotEmpty ?? false) || (_tasksBox?.isNotEmpty ?? false);
  }
}
