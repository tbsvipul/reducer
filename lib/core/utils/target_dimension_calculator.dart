class TargetDimensions {
  final int width;
  final int height;

  const TargetDimensions({required this.width, required this.height});

  static TargetDimensions fromScale({
    required int originalWidth,
    required int originalHeight,
    required double scalePercent,
    int min = 1,
    int max = 10000,
  }) {
    final scaleFactor = scalePercent / 100.0;
    final scaledWidth = (originalWidth * scaleFactor).toInt();
    final scaledHeight = (originalHeight * scaleFactor).toInt();

    return TargetDimensions(
      width: scaledWidth.clamp(min, max).toInt(),
      height: scaledHeight.clamp(min, max).toInt(),
    );
  }
}
