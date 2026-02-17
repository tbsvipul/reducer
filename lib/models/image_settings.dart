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
    };
  }

  factory ImageSettings.fromJson(Map<String, dynamic> json) {
    return ImageSettings(
      width: json['width'],
      height: json['height'],
      lockAspect: json['lockAspect'] ?? true,
      quality: json['quality'] ?? 80.0,
      format: ImageFormat.values[json['format'] ?? 0],
      scalePercent: json['scalePercent'] ?? 100.0,
      rotation: json['rotation'] ?? 0.0,
      flipHorizontal: json['flipHorizontal'] ?? false,
      flipVertical: json['flipVertical'] ?? false,
      targetFileSizeKB: json['targetFileSizeKB'],
    );
  }
}
