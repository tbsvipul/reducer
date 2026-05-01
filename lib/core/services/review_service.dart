import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._();
  factory ReviewService() => _instance;
  ReviewService._();

  static const String _countKey = 'compression_success_count';
  static const String _lastReviewRequestKey = 'last_review_request_date';
  static const int _threshold = 5;

  /// Increments the compression count and triggers a review prompt if threshold is met.
  Future<void> logSuccessAndCheckReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_countKey) ?? 0;
      final newCount = currentCount + 1;
      await prefs.setInt(_countKey, newCount);

      if (newCount >= _threshold) {
        final InAppReview inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          final lastRequest = prefs.getString(_lastReviewRequestKey);
          if (lastRequest != null) {
            final lastDate = DateTime.parse(lastRequest);
            if (DateTime.now().difference(lastDate).inDays < 60) return;
          }

          debugPrint(
            '[ReviewService] Threshold met, requesting native review flow',
          );
          await inAppReview.requestReview();

          await prefs.setString(
            _lastReviewRequestKey,
            DateTime.now().toIso8601String(),
          );
          await prefs.setInt(_countKey, 0);
        }
      }
    } catch (e) {
      debugPrint('[ReviewService] logSuccess Error: $e');
    }
  }

  /// Manually triggers the native in-app review window.
  ///
  /// IMPORTANT: Use this only for automatic triggers (e.g. after a task).
  /// For manual "Rate Now" buttons, use [openStoreListing] instead, as Google
  /// Play may suppress this native dialog due to quotas, leading to a broken UX.
  Future<void> requestReview() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;

      if (await inAppReview.isAvailable()) {
        debugPrint('[ReviewService] Requesting native in-app review window...');
        await inAppReview.requestReview();
      } else {
        debugPrint(
          '[ReviewService] Native review window NOT available (Quota/Policy/Environment)',
        );
      }
    } catch (e) {
      debugPrint('[ReviewService] requestReview Error: $e');
    }
  }

  /// Opens the store listing for the app (kept for specific use cases if needed).
  Future<void> openStoreListing() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;
      await inAppReview.openStoreListing();
    } catch (e) {
      debugPrint('[ReviewService] openStoreListing Error: $e');
    }
  }
}
