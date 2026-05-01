import 'package:in_app_review/in_app_review.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

final reviewControllerProvider = Provider<ReviewController>((ref) {
  return ReviewController();
});

class ReviewController {
  final InAppReview _inAppReview = InAppReview.instance;
  static const String _saveCountKey = 'successful_save_count';
  static const String _lastReviewMilestoneKey = 'last_review_milestone';

  /// Increments the save count and triggers review if milestone reached
  Future<void> recordSuccessfulSave() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_saveCountKey) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_saveCountKey, newCount);

    debugPrint('[ReviewController] New save count: $newCount');

    // Milestones: 5, 20, 50, 100
    if (await _shouldRequestReview(newCount, prefs)) {
      await _requestReview(newCount, prefs);
    }
  }

  Future<bool> _shouldRequestReview(int count, SharedPreferences prefs) async {
    if (!await _inAppReview.isAvailable()) return false;

    final lastMilestone = prefs.getInt(_lastReviewMilestoneKey) ?? 0;

    // Milestones to trigger review
    final milestones = [5, 20, 50, 100];

    for (final milestone in milestones) {
      if (count >= milestone && lastMilestone < milestone) {
        return true;
      }
    }

    return false;
  }

  Future<void> _requestReview(int milestone, SharedPreferences prefs) async {
    debugPrint(
      '[ReviewController] Triggering In-App Review for milestone: $milestone',
    );
    try {
      await _inAppReview.requestReview();
      await prefs.setInt(_lastReviewMilestoneKey, milestone);
    } catch (e) {
      debugPrint('[ReviewController] Error requesting review: $e');
    }
  }

  /// Manually trigger store listing (e.g. from Settings)
  Future<void> openStoreListing() async {
    await _inAppReview.openStoreListing();
  }
}
