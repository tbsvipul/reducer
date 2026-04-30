import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'package:reducer/core/models/image_settings.dart';

/// Represents a single item in the edit history.
final class HistoryItem extends Equatable {
  /// Unique identifier for the history entry.
  final String id;

  /// Relative path to the thumbnail image in the documents directory.
  final String thumbnailPath;

  /// Path to the original image file.
  final String originalPath;

  /// The settings used to process the image.
  final ImageSettings settings;

  /// Timestamp when the processing occurred.
  final DateTime timestamp;

  /// Size of the original image in bytes.
  final int originalSize;

  /// Size of the processed image in bytes.
  final int processedSize;

  /// Whether this entry represents a bulk processing session.
  final bool isBulk;

  /// Number of items processed in this session.
  final int itemCount;

  /// List of relative paths to processed images for bulk sessions.
  final List<String> processedPaths;

  const HistoryItem({
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
        return p.join(appDocDir, 'history', 'bulk_$id', p.basename(path));
      }
      return p.join(appDocDir, path);
    }).toList();
  }

  /// Serialize to JSON for storage.
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

  /// Deserialize from JSON.
  /// Deserialize from JSON.
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    DateTime parseTimestamp(Object? value) {
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      // Handle Firebase Timestamp if it comes from Firestore sync
      try {
        if (value != null && value.runtimeType.toString().contains('Timestamp')) {
          return (value as dynamic).toDate();
        }
      } catch (_) {}
      return DateTime.now();
    }

    return HistoryItem(
      id: json['id'] as String? ?? '',
      thumbnailPath: json['thumbnailPath'] as String? ?? '',
      originalPath: json['originalPath'] as String? ?? '',
      settings: ImageSettings.fromJson(json['settings'] as Map<String, dynamic>? ?? {}),
      timestamp: parseTimestamp(json['timestamp']),
      originalSize: (json['originalSize'] as num?)?.toInt() ?? 0,
      processedSize: (json['processedSize'] as num?)?.toInt() ?? 0,
      isBulk: json['isBulk'] as bool? ?? false,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 1,
      processedPaths: (json['processedPaths'] as List<dynamic>?)?.whereType<String>().toList() ?? [],
    );
  }

  /// Creates a copy of this [HistoryItem] with the given fields replaced.
  HistoryItem copyWith({
    String? id,
    String? thumbnailPath,
    String? originalPath,
    ImageSettings? settings,
    DateTime? timestamp,
    int? originalSize,
    int? processedSize,
    bool? isBulk,
    int? itemCount,
    List<String>? processedPaths,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      originalPath: originalPath ?? this.originalPath,
      settings: settings ?? this.settings,
      timestamp: timestamp ?? this.timestamp,
      originalSize: originalSize ?? this.originalSize,
      processedSize: processedSize ?? this.processedSize,
      isBulk: isBulk ?? this.isBulk,
      itemCount: itemCount ?? this.itemCount,
      processedPaths: processedPaths ?? this.processedPaths,
    );
  }

  @override
  List<Object?> get props => [
        id,
        thumbnailPath,
        originalPath,
        settings,
        timestamp,
        originalSize,
        processedSize,
        isBulk,
        itemCount,
        processedPaths,
      ];

  @override
  String toString() => 'HistoryItem(id: $id, timestamp: $timestamp, isBulk: $isBulk)';

  /// Calculate compression percentage.
  double get compressionPercent {
    if (originalSize == 0) return 0;
    return ((originalSize - processedSize) / originalSize * 100);
  }
}

