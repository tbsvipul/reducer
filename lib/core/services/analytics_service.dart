import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:reducer/core/services/review_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  FirebaseAnalytics? _fa;
  FirebaseAnalytics get _analytics {
    try {
      return _fa ??= FirebaseAnalytics.instance;
    } catch (_) {
      rethrow;
    }
  }

  /// Safe helper for all analytics calls
  Future<void> _safeLog(Future<void> Function() logCall) async {
    try {
      await logCall();
    } catch (e) {
      // Silently fail if Firebase is not initialized yet
      // This prevents crashes during rapid activity recreation (e.g. Camera return)
      debugPrint('[AnalyticsService] Skipping log: Firebase not ready');
    }
  }

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Track when a specific filter or tool is used
  Future<void> logFeatureUsed({
    required String featureName,
    Map<String, Object>? parameters,
  }) async {
    await _safeLog(() => _analytics.logEvent(
      name: 'feature_used',
      parameters: {
        'feature_name': featureName,
        ...?parameters,
      },
    ));
  }

  /// Track when a user starts a potentially monetizable action
  Future<void> logMonetizationIntent({
    required String action,
    required String targetPlan,
  }) async {
    await _safeLog(() => _analytics.logEvent(
      name: 'monetization_intent',
      parameters: {
        'action': action,
        'target_plan': targetPlan,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }

  /// Track successful image optimization
  Future<void> logCompressionSuccess({
    required String type, // 'bulk' or 'single'
    required int originalSize,
    required int compressedSize,
    required int imageCount,
  }) async {
    // ── NEW: Trigger Review Prompt after success ───────────────────────────
    unawaited(ReviewService().logSuccessAndCheckReview());

    await _safeLog(() => _analytics.logEvent(
      name: 'compression_success',
      parameters: {
        'type': type,
        'original_size_kb': originalSize ~/ 1024,
        'compressed_size_kb': compressedSize ~/ 1024,
        'reduction_percent': ((1 - (compressedSize / originalSize)) * 100).toInt(),
        'image_count': imageCount,
      },
    ));
  }

  /// Track errors for business logic (non-crashes)
  Future<void> logBusinessError(String errorType, String message) async {
    await _safeLog(() => _analytics.logEvent(
      name: 'business_error',
      parameters: {
        'error_type': errorType,
        'message': message,
      },
    ));
  }
}

