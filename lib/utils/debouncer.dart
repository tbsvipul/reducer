import 'dart:async';
import 'package:flutter/foundation.dart';

/// Utility class for debouncing rapid callback executions
/// Useful for slider interactions to avoid excessive reprocessing
class Debouncer {
  final Duration delay;
  Timer? _timer;

  /// Create a debouncer with specified delay
  /// [delay] - Duration to wait before executing callback (default: 250ms)
  Debouncer({this.delay = const Duration(milliseconds: 250)});

  /// Execute the callback after the delay period
  /// Cancels any pending callback if called again before delay expires
  /// 
  /// Example:
  /// ```dart
  /// final debouncer = Debouncer();
  /// 
  /// Slider(
  ///   onChanged: (value) {
  ///     debouncer.call(() {
  ///       // This only runs 250ms after user stops dragging
  ///       processImage();
  ///     });
  ///   }
  /// );
  /// ```
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Immediately execute any pending callback and cancel timer
  void flush() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancel any pending callback without executing
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose of the debouncer and cancel any pending callbacks
  /// Call this in your State's dispose() method
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
