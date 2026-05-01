import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/utils/target_dimension_calculator.dart';

/// Result object for bulk processing updates.
class BulkProgress {
  final double progress;
  final List<File?> batchResults;

  BulkProgress(this.progress, this.batchResults);
}

/// High-performance image processor.
class ImageProcessor {
  /// Process thumbnail for fast live preview.
  static Future<Uint8List?> processImageThumbnail(
    Uint8List inputBytes,
    ImageSettings settings, {
    bool isPremium = false,
  }) async {
    try {
      return await _processNative(inputBytes, settings);
    } catch (e) {
      debugPrint('Error processing thumbnail: $e');
      return null;
    }
  }

  /// Process full-resolution image for final export.
  static Future<File?> processImage(
    File input,
    ImageSettings settings, {
    bool isPremium = false,
  }) async {
    try {
      final bytes = await input.readAsBytes();
      final processedBytes = await _processNative(bytes, settings);
      if (processedBytes == null) return null;

      final tempDir = await getTemporaryDirectory();
      final outputFile = File(
        '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.${settings.format.extension}',
      );
      await outputFile.writeAsBytes(processedBytes);
      return outputFile;
    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
    }
  }

  /// Process image bytes directly.
  static Future<Uint8List?> processImageBytes(
    Uint8List inputBytes,
    ImageSettings settings, {
    bool isPremium = false,
  }) async {
    try {
      return await _processNative(inputBytes, settings);
    } catch (e) {
      debugPrint('Error processing image bytes: $e');
      return null;
    }
  }

  /// Bulk processing with parallel execution and results yielding.
  static Stream<BulkProgress> processBulkWithProgress(
    List<File> inputs,
    ImageSettings settings, {
    bool isPremium = false,
    int maxConcurrent = 3,
    ValueNotifier<bool>? cancellationToken,
  }) async* {
    int completed = 0;
    final total = inputs.length;

    for (int i = 0; i < inputs.length; i += maxConcurrent) {
      // Check for cancellation
      if (cancellationToken != null && cancellationToken.value == true) {
        debugPrint('[ImageProcessor] Bulk processing cancelled by user.');
        break;
      }

      final batch = inputs.skip(i).take(maxConcurrent).toList();

      final results = await Future.wait(
        batch.map((file) => processImage(file, settings, isPremium: isPremium)),
      );

      completed += batch.length;
      yield BulkProgress(completed / total, results);
    }
  }

  static Future<Uint8List?> _processNative(
    Uint8List bytes,
    ImageSettings settings,
  ) async {
    try {
      // 1. Get metadata for scaling calculations without full decoding if possible
      final metadata = await compute(_getImageMetadata, bytes);
      if (metadata == null) return null;

      final targetDim = TargetDimensions.fromScale(
        originalWidth: metadata.width,
        originalHeight: metadata.height,
        scalePercent: settings.scalePercent,
      );

      Uint8List intermediateBytes;

      // ── HYBRID PREPARATION PIPELINE ──────────────────────────────────────────
      // Optimized Path: Use Native (FlutterImageCompress) for Resize/Rotate
      // Fallback Path: Only use pure-Dart 'image' library for complex ops (Flipping/BMP)
      final needsComplexOps =
          settings.flipHorizontal ||
          settings.flipVertical ||
          settings.format == ImageFormat.bmp;

      if (!needsComplexOps) {
        intermediateBytes = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: targetDim.width,
          minHeight: targetDim.height,
          rotate: settings.rotation.toInt(),
          quality: 100, // Intermediate quality
          format: CompressFormat.jpeg,
        );
      } else {
        // Use optimized isolate for complex operations
        final target = await compute(
          _calculateAndPrepareIsolate,
          _PrepareParams(bytes: bytes, settings: settings),
        );
        if (target == null) return null;
        intermediateBytes = target.preparedBytes;
      }

      // ── FINAL ENCODING ───────────────────────────────────────────────────────
      if (settings.format == ImageFormat.bmp) {
        return await compute(_encodeBmpInIsolate, intermediateBytes);
      }

      final compressFormat = _toCompressFormat(settings.format);

      // Smart iterative compression for target file size
      if (settings.targetFileSizeKB != null && settings.targetFileSizeKB! > 0) {
        return await _iterativeCompress(
          intermediateBytes,
          settings.targetFileSizeKB!,
          targetDim.width,
          targetDim.height,
          compressFormat,
        );
      }

      // Standard single-pass compression
      return await FlutterImageCompress.compressWithList(
        intermediateBytes,
        minWidth: targetDim.width,
        minHeight: targetDim.height,
        quality: settings.quality.toInt().clamp(1, 100),
        format: compressFormat,
      );
    } catch (e, stack) {
      debugPrint('[ImageProcessor] Error in Native Pipeline: $e');
      debugPrint(stack.toString());
      return null;
    }
  }

  /// Uses binary search and upscaling to find/force a target file size.
  /// Uses binary search and dynamic scaling to hit target file sizes strictly.
  static Future<Uint8List?> _iterativeCompress(
    Uint8List bytes,
    double targetSizeKB,
    int initialWidth,
    int initialHeight,
    CompressFormat format,
  ) async {
    final targetBytes = (targetSizeKB * 1024).round();
    int currentWidth = initialWidth;
    int currentHeight = initialHeight;
    Uint8List? bestResult;
    double bestDiff = double.infinity;

    // We allow up to 3 major stages (Scaling adjustments) to hit the target
    for (int stage = 0; stage < 3; stage++) {
      int low = 5;
      int high = 100;
      int stageBestSize = 0;

      // Binary search for quality (12 iterations for high precision)
      for (int i = 0; i < 12; i++) {
        if (low > high) break;
        final int mid = (low + high) ~/ 2;

        final result = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: currentWidth,
          minHeight: currentHeight,
          quality: mid,
          format: format,
        );

        final resultSize = result.length;
        final diff = (resultSize - targetBytes).abs().toDouble();

        // Update stage best (we prefer being slightly under, but "closest" is the goal)
        if (diff < bestDiff) {
          bestDiff = diff;
          bestResult = result;
        }

        if (resultSize <= targetBytes) {
          stageBestSize = resultSize;
          low = mid + 1;
        } else {
          high = mid - 1;
        }
      }

      // ── ACCURACY CHECK & DYNAMIC SCALING ─────────────────────────────────────
      final finalStageSize = stageBestSize > 0
          ? stageBestSize
          : (bestResult?.length ?? 0);

      // HIGH ACCURACY: Stop if we are within 0.5% or 1KB of the target
      final diffBytes = (finalStageSize - targetBytes).abs();
      if (diffBytes < (targetBytes * 0.005) || diffBytes < 1024) {
        break;
      }

      // If we are too SMALL even at quality 100, we INCREASE resolution
      // Limit upscaling to 2x to prevent OOM on low-end devices
      if (finalStageSize < targetBytes * 0.98 &&
          currentWidth < initialWidth * 2) {
        // Safety guard: Don't upscale if projected raw buffer exceeds 100MB
        final projectedBufferBytes = currentWidth * currentHeight * 4 * 1.5;
        if (projectedBufferBytes > 100 * 1024 * 1024) {
          debugPrint(
            'Upscale aborted: Potential memory risk (${(projectedBufferBytes / 1024 / 1024).toStringAsFixed(1)}MB)',
          );
          break;
        }

        final scaleFactor = math
            .sqrt(targetBytes / finalStageSize)
            .clamp(1.05, 1.5);
        currentWidth = (currentWidth * scaleFactor).round();
        currentHeight = (currentHeight * scaleFactor).round();
        debugPrint(
          'Target size not met. Upscaling resolution to ${currentWidth}x$currentHeight',
        );
        continue;
      }

      // If we are too LARGE even at quality 5, we DECREASE resolution
      if (finalStageSize > targetBytes * 1.02) {
        final scaleFactor = math
            .sqrt(targetBytes / finalStageSize)
            .clamp(0.5, 0.95);
        currentWidth = (currentWidth * scaleFactor).round();
        currentHeight = (currentHeight * scaleFactor).round();
        debugPrint(
          'Target size exceeded. Downscaling resolution to ${currentWidth}x$currentHeight',
        );
        continue;
      }

      break; // No more adjustments possible
    }

    return bestResult;
  }

  static CompressFormat _toCompressFormat(ImageFormat format) {
    switch (format) {
      case ImageFormat.png:
        return CompressFormat.png;
      case ImageFormat.webp:
        return CompressFormat.webp;
      default:
        return CompressFormat.jpeg;
    }
  }

  /// ── PERFORMANCE: DISK CLEANUP ───────────────────────────────────────────
  /// Automatically purges processed temporary files older than the specified duration.
  static Future<void> cleanupTempFiles({
    Duration olderThan = const Duration(hours: 24),
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cutoff = DateTime.now().subtract(olderThan);
      int count = 0;

      await for (final entity in tempDir.list()) {
        if (entity is File && entity.path.contains('processed_')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
            count++;
          }
        }
      }
      if (count > 0)
        debugPrint('[ImageProcessor] Cleaned up $count stale temp files.');
    } catch (e) {
      debugPrint('[ImageProcessor] Cleanup failed: $e');
    }
  }
}

class _PreparedResult {
  final Uint8List preparedBytes;
  final int width;
  final int height;

  _PreparedResult(this.preparedBytes, this.width, this.height);
}

class _PrepareParams {
  final Uint8List bytes;
  final ImageSettings settings;

  _PrepareParams({required this.bytes, required this.settings});
}

class _Metadata {
  final int width;
  final int height;
  _Metadata(this.width, this.height);
}

_Metadata? _getImageMetadata(Uint8List bytes) {
  final info = img.decodeImage(bytes);
  return info != null ? _Metadata(info.width, info.height) : null;
}

_PreparedResult? _calculateAndPrepareIsolate(_PrepareParams params) {
  var image = img.decodeImage(params.bytes);
  if (image == null) return null;

  final targetDim = TargetDimensions.fromScale(
    originalWidth: image.width,
    originalHeight: image.height,
    scalePercent: params.settings.scalePercent,
  );

  // Apply transformations
  if (image.width != targetDim.width || image.height != targetDim.height) {
    image = img.copyResize(
      image,
      width: targetDim.width,
      height: targetDim.height,
    );
  }

  if (params.settings.rotation % 360 != 0) {
    image = img.copyRotate(image, angle: params.settings.rotation.toInt());
  }

  if (params.settings.flipHorizontal) image = img.flipHorizontal(image);
  if (params.settings.flipVertical) image = img.flipVertical(image);

  // Using 100% quality JPG as an intermediary is significantly faster than PNG
  // in the pure-Dart image library.
  final preparedBytes = Uint8List.fromList(img.encodeJpg(image, quality: 100));
  return _PreparedResult(preparedBytes, image.width, image.height);
}

Uint8List _encodeBmpInIsolate(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  return image != null ? Uint8List.fromList(img.encodeBmp(image)) : bytes;
}
