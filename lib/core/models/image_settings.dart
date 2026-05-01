import 'dart:io';

enum ImageFormat { jpeg, png, webp, bmp }

extension ImageFormatExtension on ImageFormat {
  String get name => toString().split('.').last.toUpperCase();
  String get extension => toString().split('.').last;
}

class ImageSettings {
  final double? width;
  final double? height;
  final bool lockAspect;
  final double quality;
  final ImageFormat format;
  final double scalePercent;
  final double rotation;
  final bool flipHorizontal;
  final bool flipVertical;
  final File? originalFile;
  final double? targetFileSizeKB; // Target file size in KB for compression
  final bool isTargetUnitMb;

  ImageSettings({
    this.width,
    this.height,
    this.lockAspect = true,
    this.quality = 80.0,
    this.format = ImageFormat.jpeg,
    this.scalePercent = 100.0,
    this.rotation = 0.0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.originalFile,
    this.targetFileSizeKB,
    this.isTargetUnitMb = true,
  });

  ImageSettings copyWith({
    double? width,
    double? height,
    bool? lockAspect,
    double? quality,
    ImageFormat? format,
    double? scalePercent,
    double? rotation,
    bool? flipHorizontal,
    bool? flipVertical,
    File? originalFile,
    double? targetFileSizeKB,
    bool? isTargetUnitMb,
  }) {
    return ImageSettings(
      width: width ?? this.width,
      height: height ?? this.height,
      lockAspect: lockAspect ?? this.lockAspect,
      quality: quality ?? this.quality,
      format: format ?? this.format,
      scalePercent: scalePercent ?? this.scalePercent,
      rotation: rotation ?? this.rotation,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      originalFile: originalFile ?? this.originalFile,
      targetFileSizeKB: targetFileSizeKB ?? this.targetFileSizeKB,
      isTargetUnitMb: isTargetUnitMb ?? this.isTargetUnitMb,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'lockAspect': lockAspect,
      'quality': quality,
      'format': format.index,
      'scalePercent': scalePercent,
      'rotation': rotation,
      'flipHorizontal': flipHorizontal,
      'flipVertical': flipVertical,
      'targetFileSizeKB': targetFileSizeKB,
      'isTargetUnitMb': isTargetUnitMb,
    };
  }

  factory ImageSettings.fromJson(Map<String, dynamic> json) {
    return ImageSettings(
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      lockAspect: json['lockAspect'] ?? true,
      quality: (json['quality'] as num?)?.toDouble() ?? 80.0,
      format: ImageFormat.values[json['format'] ?? 0],
      scalePercent: (json['scalePercent'] as num?)?.toDouble() ?? 100.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      flipHorizontal: json['flipHorizontal'] ?? false,
      flipVertical: json['flipVertical'] ?? false,
      targetFileSizeKB: (json['targetFileSizeKB'] as num?)?.toDouble(),
      isTargetUnitMb: json['isTargetUnitMb'] ?? true,
    );
  }
}
