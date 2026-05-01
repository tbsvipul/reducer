class FileUtils {
  /// General file size formatting (e.g. 1.2 MB)
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Formats with higher precision for detailed summary views (e.g. 1.24 MB)
  static String formatBytesDetailed(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    final mb = kb / 1024;
    if (mb >= 0.1) {
      return '${mb.toStringAsFixed(2)} MB';
    }
    return '${kb.toStringAsFixed(1)} KB';
  }

  /// Alias for backward compatibility if needed, but preferred to use formatBytes
  static String formatFileSize(int bytes) => formatBytes(bytes);
  static String formatFileSizeDetailed(int bytes) => formatBytesDetailed(bytes);
}
