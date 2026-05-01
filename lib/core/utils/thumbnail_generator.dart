import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Fast thumbnail generator using native compression
/// FlutterImageCompress runs on main isolate (platform channels required)
class ThumbnailGenerator {
  /// Generate a thumbnail from an XFile (picked image)
  /// Uses native compression for fast performance
  ///
  /// [file] - The XFile from image_picker
  /// [maxWidth] - Maximum width of thumbnail (default: 1000px)
  /// [quality] - Compression quality 1-100 (default: 70 for speed)
  ///
  /// Returns: Compressed thumbnail as Uint8List JPEG bytes
  static Future<Uint8List?> generateThumbnailFromXFile(
    XFile file, {
    int maxWidth = 1000,
    int quality = 70,
  }) async {
    try {
      // Read bytes from file
      final bytes = await file.readAsBytes();

      // Call FlutterImageCompress directly (platform channels require main isolate)
      // No compute/isolate needed - native compression is already very fast
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: maxWidth,
        minHeight: maxWidth,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      return result;
    } catch (e) {
      debugPrint('Error generating thumbnail from XFile: $e');
      return null;
    }
  }

  /// Generate a thumbnail from existing byte data
  /// Uses native compression for fast performance
  ///
  /// [bytes] - Original image bytes
  /// [maxWidth] - Maximum width of thumbnail (default: 1000px)
  /// [quality] - Compression quality 1-100 (default: 70 for speed)
  ///
  /// Returns: Compressed thumbnail as Uint8List JPEG bytes
  static Future<Uint8List?> generateThumbnailFromBytes(
    Uint8List bytes, {
    int maxWidth = 1000,
    int quality = 70,
  }) async {
    try {
      // Call FlutterImageCompress directly (platform channels require main isolate)
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: maxWidth,
        minHeight: maxWidth,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      return result;
    } catch (e) {
      debugPrint('Error generating thumbnail from bytes: $e');
      return null;
    }
  }

  /// Generate a small thumbnail for bulk mode grid previews
  /// Optimized for fast generation with lower quality/resolution
  ///
  /// [file] - The XFile from image_picker
  /// [maxWidth] - Maximum width (default: 300px for grid)
  /// [quality] - Compression quality (default: 60 for smaller size)
  ///
  /// Returns: Small compressed thumbnail as Uint8List JPEG bytes
  static Future<Uint8List?> generateSmallThumbnail(
    XFile file, {
    int maxWidth = 300,
    int quality = 60,
  }) async {
    return generateThumbnailFromXFile(
      file,
      maxWidth: maxWidth,
      quality: quality,
    );
  }
}
