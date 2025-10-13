import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._internal();
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  // User Properties
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
    debugPrint('Analytics: Set user ID: $userId');
  }

  Future<void> setUserProperty({required String name, required String value}) async {
    await _analytics.setUserProperty(name: name, value: value);
    debugPrint('Analytics: Set user property - $name: $value');
  }

  // Screen Views
  Future<void> logScreenView({required String screenName, String? screenClass}) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
    debugPrint('Analytics: Screen view - $screenName');
  }

  // Authentication Events
  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
    debugPrint('Analytics: Sign up - $method');
  }

  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
    debugPrint('Analytics: Login - $method');
  }

  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
    debugPrint('Analytics: Logout');
  }

  // Goal/Habit Events
  Future<void> logCreateGoal({
    required String goalId,
    required String goalTitle,
    required String category,
  }) async {
    await _analytics.logEvent(
      name: 'create_goal',
      parameters: {
        'goal_id': goalId,
        'goal_title': goalTitle,
        'category': category,
      },
    );
    debugPrint('Analytics: Create goal - $goalTitle');
  }

  Future<void> logCompleteTask({
    required String goalId,
    required String goalTitle,
    required int streak,
    required bool isPerfectDay,
  }) async {
    await _analytics.logEvent(
      name: 'complete_task',
      parameters: {
        'goal_id': goalId,
        'goal_title': goalTitle,
        'streak': streak,
        'is_perfect_day': isPerfectDay,
      },
    );
    debugPrint('Analytics: Complete task - $goalTitle (Streak: $streak)');
  }

  Future<void> logDeleteGoal({required String goalId, required String goalTitle}) async {
    await _analytics.logEvent(
      name: 'delete_goal',
      parameters: {
        'goal_id': goalId,
        'goal_title': goalTitle,
      },
    );
    debugPrint('Analytics: Delete goal - $goalTitle');
  }

  // Reward Events
  Future<void> logEarnCoins({required int amount, required String reason}) async {
    await _analytics.logEvent(
      name: 'earn_coins',
      parameters: {
        'amount': amount,
        'reason': reason,
      },
    );
    debugPrint('Analytics: Earn coins - $amount ($reason)');
  }

  Future<void> logRedeemReward({
    required String rewardId,
    required String rewardTitle,
    required int cost,
  }) async {
    await _analytics.logEvent(
      name: 'redeem_reward',
      parameters: {
        'reward_id': rewardId,
        'reward_title': rewardTitle,
        'cost': cost,
      },
    );
    debugPrint('Analytics: Redeem reward - $rewardTitle ($cost coins)');
  }

  Future<void> logCreateCustomReward({
    required String rewardTitle,
    required int cost,
  }) async {
    await _analytics.logEvent(
      name: 'create_custom_reward',
      parameters: {
        'reward_title': rewardTitle,
        'cost': cost,
      },
    );
    debugPrint('Analytics: Create custom reward - $rewardTitle');
  }

  // Challenge Events
  Future<void> logJoinChallenge({
    required String challengeId,
    required String challengeTitle,
  }) async {
    await _analytics.logEvent(
      name: 'join_challenge',
      parameters: {
        'challenge_id': challengeId,
        'challenge_title': challengeTitle,
      },
    );
    debugPrint('Analytics: Join challenge - $challengeTitle');
  }

  Future<void> logCompleteChallenge({
    required String challengeId,
    required String challengeTitle,
  }) async {
    await _analytics.logEvent(
      name: 'complete_challenge',
      parameters: {
        'challenge_id': challengeId,
        'challenge_title': challengeTitle,
      },
    );
    debugPrint('Analytics: Complete challenge - $challengeTitle');
  }

  // Achievement Events
  Future<void> logUnlockAchievement({
    required String achievementId,
    required String achievementTitle,
  }) async {
    await _analytics.logEvent(
      name: 'unlock_achievement',
      parameters: {
        'achievement_id': achievementId,
        'achievement_title': achievementTitle,
      },
    );
    debugPrint('Analytics: Unlock achievement - $achievementTitle');
  }

  // Social Events
  Future<void> logAddFriend({required String friendId}) async {
    await _analytics.logEvent(
      name: 'add_friend',
      parameters: {
        'friend_id': friendId,
      },
    );
    debugPrint('Analytics: Add friend - $friendId');
  }

  Future<void> logShareProgress({required String shareMethod}) async {
    await _analytics.logShare(
      contentType: 'progress',
      itemId: 'user_progress',
      method: shareMethod,
    );
    debugPrint('Analytics: Share progress - $shareMethod');
  }

  // Settings Events
  Future<void> logChangeTheme({required bool isDarkMode}) async {
    await _analytics.logEvent(
      name: 'change_theme',
      parameters: {
        'is_dark_mode': isDarkMode,
      },
    );
    debugPrint('Analytics: Change theme - Dark mode: $isDarkMode');
  }

  Future<void> logEnableNotifications({required bool enabled}) async {
    await _analytics.logEvent(
      name: 'toggle_notifications',
      parameters: {
        'enabled': enabled,
      },
    );
    debugPrint('Analytics: Toggle notifications - $enabled');
  }

  Future<void> logChangeLanguage({required String language}) async {
    await _analytics.logEvent(
      name: 'change_language',
      parameters: {
        'language': language,
      },
    );
    debugPrint('Analytics: Change language - $language');
  }

  // Review & Feedback Events
  Future<void> logRequestReview() async {
    await _analytics.logEvent(name: 'request_review');
    debugPrint('Analytics: Request review');
  }

  Future<void> logRateApp({required int rating}) async {
    await _analytics.logEvent(
      name: 'rate_app',
      parameters: {
        'rating': rating,
      },
    );
    debugPrint('Analytics: Rate app - $rating stars');
  }

  // Onboarding Events
  Future<void> logCompleteOnboarding() async {
    await _analytics.logTutorialComplete();
    debugPrint('Analytics: Complete onboarding');
  }

  Future<void> logSkipOnboarding() async {
    await _analytics.logEvent(name: 'skip_onboarding');
    debugPrint('Analytics: Skip onboarding');
  }

  // Registration Prompt Events
  Future<void> logShowRegistrationPrompt({required int usageCount}) async {
    await _analytics.logEvent(
      name: 'show_registration_prompt',
      parameters: {
        'usage_count': usageCount,
      },
    );
    debugPrint('Analytics: Show registration prompt - Usage: $usageCount');
  }

  Future<void> logDismissRegistrationPrompt() async {
    await _analytics.logEvent(name: 'dismiss_registration_prompt');
    debugPrint('Analytics: Dismiss registration prompt');
  }

  Future<void> logAcceptRegistrationPrompt() async {
    await _analytics.logEvent(name: 'accept_registration_prompt');
    debugPrint('Analytics: Accept registration prompt');
  }

  // Sync Events
  Future<void> logSyncData({required bool success, String? error}) async {
    await _analytics.logEvent(
      name: 'sync_data',
      parameters: {
        'success': success,
        if (error != null) 'error': error,
      },
    );
    debugPrint('Analytics: Sync data - Success: $success');
  }

  // Export Events
  Future<void> logExportData({required String format}) async {
    await _analytics.logEvent(
      name: 'export_data',
      parameters: {
        'format': format,
      },
    );
    debugPrint('Analytics: Export data - $format');
  }

  // Performance Metrics
  Future<void> logPerformanceMetric({
    required String metric,
    required int value,
  }) async {
    await _analytics.logEvent(
      name: 'performance_metric',
      parameters: {
        'metric': metric,
        'value': value,
      },
    );
    debugPrint('Analytics: Performance - $metric: $value');
  }

  // Custom Events
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters != null ? Map<String, Object>.from(parameters) : null,
    );
    debugPrint('Analytics: Custom event - $eventName');
  }
}
