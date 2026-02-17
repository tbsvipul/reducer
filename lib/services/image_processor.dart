import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../models/image_settings.dart';

/// High-performance image processor with isolate-based processing
/// Uses pure Dart image package for transformations and encoding
class ImageProcessor {
  
  /// Process thumbnail for fast live preview (low-res, optimized for speed)
  /// Runs in isolate to avoid blocking UI
  /// 
  /// [inputBytes] - Thumbnail bytes (should already be downsampled)
  /// [settings] - Image settings to apply
  /// [isPremium] - Whether user has premium (affects watermark)
  /// 
  /// Returns: Processed thumbnail bytes
  static Future<Uint8List?> processImageThumbnail(
    Uint8List inputBytes,
    ImageSettings settings, {
    bool isPremium = false,
  }) async {
    try {
      // Run processing in isolate
      return await compute(_processImageInIsolate, _ProcessParams(
        inputBytes: inputBytes,
        settings: settings,
        isPremium: isPremium,
        isThumbnail: true,
      ));
    } catch (e) {
      debugPrint('Error processing thumbnail: $e');
      return null;
    }
  }

  /// Process full-resolution image for final export
  /// Runs in isolate to avoid blocking UI
  /// 
  /// [input] - Input file at full resolution
  /// [settings] - Image settings to apply
  /// [isPremium] - Whether user has premium (affects watermark)
  /// 
  /// Returns: Processed file saved to temp directory
  static Future<File?> processImage(
    File input,
    ImageSettings settings, {
    bool isPremium = false,
  }) async {
    try {
      final bytes = await input.readAsBytes();
      final processedBytes = await compute(
        _processImageInIsolate,
        _ProcessParams(
          inputBytes: bytes,
          settings: settings,
          isPremium: isPremium,
          isThumbnail: false,
        ),
      );

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

  /// Process image bytes directly (web-compatible)
  /// Runs in isolate to avoid blocking UI
  static Future<Uint8List?> processImageBytes(
    Uint8List inputBytes,
    ImageSettings settings, {
    bool isPremium = false,
  }) async {
    try {
      return await compute(_processImageInIsolate, _ProcessParams(
        inputBytes: inputBytes,
        settings: settings,
        isPremium: isPremium,
        isThumbnail: false,
      ));
    } catch (e) {
      debugPrint('Error processing image bytes: $e');
      return null;
    }
  }

  /// Bulk processing with parallel execution and progress tracking
  /// Limits concurrency to avoid OOM errors
  /// 
  /// [inputs] - List of input files
  /// [settings] - Settings to apply to all images
  /// [isPremium] - Premium status
  /// [maxConcurrent] - Max parallel isolates (default: 4)
  /// 
  /// Returns: Stream of progress (0.0 to 1.0) and final list of processed files
  static Stream<double> processBulkWithProgress(
    List<File> inputs,
    ImageSettings settings, {
    bool isPremium = false,
    int maxConcurrent = 4,
  }) async* {
    final processed = <File>[];
    int completed = 0;
    final total = inputs.length;

    // Process in batches to limit concurrency
    for (int i = 0; i < inputs.length; i += maxConcurrent) {
      final batch = inputs.skip(i).take(maxConcurrent).toList();
      
      // Process batch in parallel
      final results = await Future.wait(
        batch.map((file) => processImage(file, settings, isPremium: isPremium)),
      );

      // Collect non-null results
      for (final result in results) {
        if (result != null) processed.add(result);
        completed++;
        yield completed / total; // Progress update
      }
    }
  }

  /// Legacy bulk processing (synchronous, for compatibility)
  static Future<List<File>> processBulk(
    List<File> inputs,
    ImageSettings settings, {
    bool isPremium = false,
  }) async {
    List<File> processed = [];
    for (var file in inputs) {
      final result = await processImage(file, settings, isPremium: isPremium);
      if (result != null) processed.add(result);
    }
    return processed;
  }

  // ============================================================================
  // PRIVATE ISOLATE ENTRY POINT
  // ============================================================================

  /// Main processing logic running in isolate (non-blocking)
  /// Handles all transformations: resize, rotate, flip, compress
  static Future<Uint8List?> _processImageInIsolate(_ProcessParams params) async {
    try {
      // 1. Decode image
      var image = img.decodeImage(params.inputBytes);
      if (image == null) return null;

      // 2. Resize/Scale
      int? targetWidth = params.settings.width?.toInt();
      int? targetHeight = params.settings.height?.toInt();

      if (params.settings.scalePercent != 100.0) {
        targetWidth = (image.width * (params.settings.scalePercent / 100.0)).toInt();
        targetHeight = (image.height * (params.settings.scalePercent / 100.0)).toInt();
      }

      if (targetWidth != null || targetHeight != null) {
        image = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      // 3. Rotate
      if (params.settings.rotation != 0) {
        image = img.copyRotate(image, angle: params.settings.rotation.toInt());
      }

      // 4. Flip
      if (params.settings.flipHorizontal) {
        image = img.flipHorizontal(image);
      }
      if (params.settings.flipVertical) {
        image = img.flipVertical(image);
      }

      // 5. Watermark (only if not premium and not thumbnail)
      if (!params.isPremium && !params.isThumbnail) {
        // TODO: Add watermark using img.drawString when font is available
        // For now, skip watermark to avoid blocking
      }

      // 6. Encode - Use pure Dart image package (works in isolates)
      Uint8List? outputBytes;

      switch (params.settings.format) {
        case ImageFormat.jpeg:
          // Use pure Dart JPEG encoding (works in isolates)
          outputBytes = Uint8List.fromList(
            img.encodeJpg(image, quality: params.settings.quality.toInt())
          );
          break;
        
        case ImageFormat.png:
          outputBytes = Uint8List.fromList(img.encodePng(image));
          break;
        
        case ImageFormat.webp:
          // Pure Dart doesn't support webp well, use PNG as fallback
          outputBytes = Uint8List.fromList(img.encodePng(image));
          break;
        
        case ImageFormat.bmp:
          outputBytes = Uint8List.fromList(img.encodeBmp(image));
          break;
      }

      return outputBytes;
    } catch (e) {
      print('Error in image processing isolate: $e');
      return null;
    }
  }
}

// ============================================================================
// PARAMETER CLASSES
// ============================================================================

/// Parameters for isolate-based image processing
class _ProcessParams {
  final Uint8List inputBytes;
  final ImageSettings settings;
  final bool isPremium;
  final bool isThumbnail;

  _ProcessParams({
    required this.inputBytes,
    required this.settings,
    required this.isPremium,
    this.isThumbnail = false,
  });
}


