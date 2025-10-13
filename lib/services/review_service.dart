import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static final ReviewService instance = ReviewService._internal();
  ReviewService._internal();

  final InAppReview _inAppReview = InAppReview.instance;

  static const String _reviewRequestCountKey = 'review_request_count';
  static const String _lastReviewRequestKey = 'last_review_request';
  static const String _hasLeftReviewKey = 'has_left_review';
  static const int _daysBeforeNextRequest = 30;
  static const int _completionsBeforeRequest = 20; // Ask after 20 completed tasks

  // Check if we should request a review
  Future<bool> shouldRequestReview(int totalCompletedTasks) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if user has already left a review
    final hasLeftReview = prefs.getBool(_hasLeftReviewKey) ?? false;
    if (hasLeftReview) return false;

    // Check if user has completed enough tasks
    if (totalCompletedTasks < _completionsBeforeRequest) return false;

    // Check last request date
    final lastRequestTimestamp = prefs.getInt(_lastReviewRequestKey) ?? 0;
    final lastRequestDate = DateTime.fromMillisecondsSinceEpoch(lastRequestTimestamp);
    final daysSinceLastRequest = DateTime.now().difference(lastRequestDate).inDays;

    // Only request if it's been enough days since last request
    return daysSinceLastRequest >= _daysBeforeNextRequest || lastRequestTimestamp == 0;
  }

  // Request a review
  Future<void> requestReview() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Check if in-app review is available
      if (await _inAppReview.isAvailable()) {
        // Request the review
        await _inAppReview.requestReview();

        // Update last request date
        await prefs.setInt(
          _lastReviewRequestKey,
          DateTime.now().millisecondsSinceEpoch,
        );

        // Increment request count
        final count = prefs.getInt(_reviewRequestCountKey) ?? 0;
        await prefs.setInt(_reviewRequestCountKey, count + 1);
      }
    } catch (e) {
      print('Error requesting review: $e');
    }
  }

  // Open store listing (fallback if in-app review not available)
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: '', // Add your iOS App Store ID here if needed
      );
    } catch (e) {
      print('Error opening store listing: $e');
    }
  }

  // Mark that user has left a review
  Future<void> markReviewAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasLeftReviewKey, true);
  }

  // Show review dialog with options
  Future<void> showReviewPrompt({
    required Function() onReviewNow,
    required Function() onReviewLater,
    required Function() onNoThanks,
  }) async {
    // This will be called from UI
    // The actual dialog will be shown in the UI layer
  }
}
