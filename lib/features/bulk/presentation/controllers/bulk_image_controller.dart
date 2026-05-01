import 'dart:async';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/utils/image_processor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reducer/core/services/notification_service.dart';
import 'package:reducer/l10n/app_localizations.dart';

part 'bulk_image_controller.g.dart';

class BulkImageState {
  final List<XFile> selectedImages;
  final Map<String, File?> processedResults;
  final bool isProcessing;
  final double progress;
  final ImageSettings settings;
  final int totalOriginalSize;
  final int totalCompressedSize;

  BulkImageState({
    this.selectedImages = const [],
    this.processedResults = const {},
    this.isProcessing = false,
    this.progress = 0.0,
    this.totalOriginalSize = 0,
    this.totalCompressedSize = 0,
    ImageSettings? settings,
  }) : settings = settings ?? ImageSettings();

  BulkImageState copyWith({
    List<XFile>? selectedImages,
    Map<String, File?>? processedResults,
    bool? isProcessing,
    double? progress,
    int? totalOriginalSize,
    int? totalCompressedSize,
    ImageSettings? settings,
  }) {
    return BulkImageState(
      selectedImages: selectedImages ?? this.selectedImages,
      processedResults: processedResults ?? this.processedResults,
      isProcessing: isProcessing ?? this.isProcessing,
      progress: progress ?? this.progress,
      totalOriginalSize: totalOriginalSize ?? this.totalOriginalSize,
      totalCompressedSize: totalCompressedSize ?? this.totalCompressedSize,
      settings: settings ?? this.settings,
    );
  }
}

@riverpod
class BulkImageController extends _$BulkImageController {
  @override
  BulkImageState build() {
    return BulkImageState();
  }

  Future<void> selectImages(List<XFile> images) async {
    // Parallelize file size calculation
    final sizes = await Future.wait(images.map((img) => img.length()));
    final totalSize = sizes.fold(0, (sum, size) => sum + size);

    state = state.copyWith(
      selectedImages: images,
      processedResults: {},
      totalOriginalSize: totalSize,
      totalCompressedSize: 0,
    );
  }

  Future<void> processAll(bool isPro, AppLocalizations l10n) async {
    if (state.selectedImages.isEmpty) return;

    // Internal Security Guard: Enforce 50-image limit for non-premium even if UI is bypassed
    final effectiveImages = isPro
        ? state.selectedImages
        : state.selectedImages.take(50).toList();

    state = state.copyWith(
      isProcessing: true,
      progress: 0.0,
      processedResults: {},
      totalCompressedSize: 0,
    );

    final inputFiles = effectiveImages.map((x) => File(x.path)).toList();
    final progressStream = ImageProcessor.processBulkWithProgress(
      inputFiles,
      state.settings,
      isPremium: isPro,
    );

    int currentIndex = 0;
    await for (final update in progressStream) {
      if (!state.isProcessing) break; // Safety check

      final batchImages = state.selectedImages
          .skip(currentIndex)
          .take(update.batchResults.length)
          .toList();

      int batchCompressedSize = 0;
      for (final file in update.batchResults) {
        if (file != null) {
          batchCompressedSize += await file.length();
        }
      }

      state = state.copyWith(
        progress: update.progress,
        processedResults: {
          ...state.processedResults,
          for (int i = 0; i < batchImages.length; i++)
            batchImages[i].name: update.batchResults[i],
        },
        totalCompressedSize: state.totalCompressedSize + batchCompressedSize,
      );

      currentIndex += update.batchResults.length;
    }

    state = state.copyWith(isProcessing: false);

    // Trigger completion notification
    if (state.processedResults.isNotEmpty) {
      final firstResult = state.processedResults.values.firstWhere(
        (f) => f != null,
        orElse: () => null,
      );
      if (firstResult != null) {
        final original = _formatSize(state.totalOriginalSize);
        final compressed = _formatSize(state.totalCompressedSize);
        final reduction =
            ((1 - (state.totalCompressedSize / state.totalOriginalSize)) * 100)
                .toStringAsFixed(1);

        unawaited(
          NotificationService().showImageNotification(
            id: 101,
            title: l10n.optimizationComplete,
            body: l10n.bulkOptimizationResult(
              state.selectedImages.length,
              original,
              compressed,
              reduction,
            ),
            imagePath: firstResult.path,
          ),
        );
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void updateSettings(ImageSettings settings) {
    state = state.copyWith(settings: settings);
  }

  void clear() {
    state = BulkImageState();
  }
}
