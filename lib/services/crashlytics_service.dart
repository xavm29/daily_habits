import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static final CrashlyticsService instance = CrashlyticsService._internal();
  CrashlyticsService._internal();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Initialize Crashlytics
  Future<void> initialize() async {
    // Enable crash collection in release mode
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Pass all uncaught Flutter errors to Crashlytics
    FlutterError.onError = (errorDetails) {
      _crashlytics.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('Crashlytics: Initialized successfully');
  }

  /// Set user identifier
  Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
    debugPrint('Crashlytics: Set user ID: $userId');
  }

  /// Set custom key-value pairs
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
    debugPrint('Crashlytics: Set custom key - $key: $value');
  }

  /// Log a message
  Future<void> log(String message) async {
    await _crashlytics.log(message);
    debugPrint('Crashlytics: Log - $message');
  }

  /// Record an error
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Iterable<Object>? information,
  }) async {
    await _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
      information: information ?? [],
    );
    debugPrint('Crashlytics: Error recorded - $exception');
  }

  /// Record Flutter error
  Future<void> recordFlutterError(FlutterErrorDetails errorDetails) async {
    await _crashlytics.recordFlutterError(errorDetails);
    debugPrint('Crashlytics: Flutter error recorded');
  }

  /// Send unsent reports
  Future<void> sendUnsentReports() async {
    await _crashlytics.sendUnsentReports();
    debugPrint('Crashlytics: Sent unsent reports');
  }

  /// Delete unsent reports
  Future<void> deleteUnsentReports() async {
    await _crashlytics.deleteUnsentReports();
    debugPrint('Crashlytics: Deleted unsent reports');
  }

  /// Check for unsent reports
  Future<bool> checkForUnsentReports() async {
    return await _crashlytics.checkForUnsentReports();
  }

  // Convenience methods for common scenarios

  /// Record authentication error
  Future<void> recordAuthError(dynamic exception, StackTrace? stackTrace) async {
    await setCustomKey('error_type', 'authentication');
    await recordError(exception, stackTrace, reason: 'Authentication error');
  }

  /// Record Firebase error
  Future<void> recordFirebaseError(dynamic exception, StackTrace? stackTrace) async {
    await setCustomKey('error_type', 'firebase');
    await recordError(exception, stackTrace, reason: 'Firebase operation error');
  }

  /// Record network error
  Future<void> recordNetworkError(dynamic exception, StackTrace? stackTrace) async {
    await setCustomKey('error_type', 'network');
    await recordError(exception, stackTrace, reason: 'Network error');
  }

  /// Record UI error
  Future<void> recordUIError(dynamic exception, StackTrace? stackTrace) async {
    await setCustomKey('error_type', 'ui');
    await recordError(exception, stackTrace, reason: 'UI rendering error');
  }

  /// Record data sync error
  Future<void> recordSyncError(dynamic exception, StackTrace? stackTrace) async {
    await setCustomKey('error_type', 'sync');
    await recordError(exception, stackTrace, reason: 'Data synchronization error');
  }

  /// Record local storage error
  Future<void> recordStorageError(dynamic exception, StackTrace? stackTrace) async {
    await setCustomKey('error_type', 'storage');
    await recordError(exception, stackTrace, reason: 'Local storage error');
  }

  /// Test crash (only for testing purposes)
  void testCrash() {
    if (kDebugMode) {
      debugPrint('Crashlytics: Test crash triggered');
      _crashlytics.crash();
    }
  }

  /// Log breadcrumb for debugging
  Future<void> logBreadcrumb(String message, {Map<String, dynamic>? data}) async {
    final breadcrumb = StringBuffer(message);
    if (data != null) {
      breadcrumb.write(' - ');
      breadcrumb.write(data.entries.map((e) => '${e.key}: ${e.value}').join(', '));
    }
    await log(breadcrumb.toString());
  }

  /// Set user properties for better crash reports
  Future<void> setUserProperties({
    String? email,
    String? username,
    String? userId,
    int? level,
    int? totalTasks,
    int? streak,
  }) async {
    if (email != null) await setCustomKey('email', email);
    if (username != null) await setCustomKey('username', username);
    if (userId != null) await setUserId(userId);
    if (level != null) await setCustomKey('user_level', level);
    if (totalTasks != null) await setCustomKey('total_tasks', totalTasks);
    if (streak != null) await setCustomKey('current_streak', streak);

    debugPrint('Crashlytics: User properties set');
  }
}
