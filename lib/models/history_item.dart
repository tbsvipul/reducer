import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/image_settings.dart';

/// Represents a single item in the edit history
class HistoryItem {
  final String id;
  final String thumbnailPath; // Relative path to documents directory
  final String originalPath;  // Original path (can be absolute or relative)
  final ImageSettings settings;
  final DateTime timestamp;
  final int originalSize;
  final int processedSize;
  final bool isBulk;
  final int itemCount;
  final List<String> processedPaths; // Relative paths for bulk items

  HistoryItem({
    required this.id,
    required this.thumbnailPath,
    required this.originalPath,
    required this.settings,
    required this.timestamp,
    required this.originalSize,
    required this.processedSize,
    this.isBulk = false,
    this.itemCount = 1,
    this.processedPaths = const [],
  });

  /// Get absolute thumbnail path (handles both relative and absolute paths)
  String getAbsoluteThumbnailPath(String appDocDir) {
    if (thumbnailPath.isEmpty) return '';
    // If it's already an absolute path and exists, use it
    if (p.isAbsolute(thumbnailPath) && File(thumbnailPath).existsSync()) {
      return thumbnailPath;
    }
    // Otherwise, assume it's relative to documents directory
    // If it's absolute but doesn't exist, try to fix it by taking the basename
    if (p.isAbsolute(thumbnailPath)) {
       return p.join(appDocDir, 'history', p.basename(thumbnailPath));
    }
    return p.join(appDocDir, thumbnailPath);
  }

  /// Get absolute processed paths for bulk mode (handles both relative and absolute)
  List<String> getAbsoluteProcessedPaths(String appDocDir) {
    return processedPaths.map((path) {
      if (p.isAbsolute(path) && File(path).existsSync()) {
        return path;
      }
      if (p.isAbsolute(path)) {
        // Fix for old absolute paths in bulk sessions
        // bulk sessions are in history/bulk_ID/filename.jpg
        return p.join(appDocDir, 'history', 'bulk_$id', p.basename(path));
      }
      return p.join(appDocDir, path);
    }).toList();
  }


  /// Serialize to JSON for SharedPreferences
  Map<String, dynamic> toJson() => {
        'id': id,
        'thumbnailPath': thumbnailPath,
        'originalPath': originalPath,
        'settings': settings.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'originalSize': originalSize,
        'processedSize': processedSize,
        'isBulk': isBulk,
        'itemCount': itemCount,
        'processedPaths': processedPaths,
      };

  /// Deserialize from JSON
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      thumbnailPath: json['thumbnailPath'] as String,
      originalPath: json['originalPath'] as String,
      settings: ImageSettings.fromJson(json['settings'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      originalSize: json['originalSize'] as int,
      processedSize: json['processedSize'] as int,
      isBulk: json['isBulk'] as bool? ?? false,
      itemCount: json['itemCount'] as int? ?? 1,
      processedPaths: (json['processedPaths'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  /// Calculate compression percentage
  double get compressionPercent {
    if (originalSize == 0) return 0;
    return ((originalSize - processedSize) / originalSize * 100);
  }
}
