import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/utils/image_processor.dart';
import 'package:reducer/core/utils/image_validator.dart';
import 'package:reducer/core/utils/thumbnail_generator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reducer/l10n/app_localizations.dart';

part 'single_image_controller.g.dart';

class SingleImageState {
  final File? originalFile;
  final Uint8List? originalThumbnail;
  final Uint8List? previewThumbnail;
  final Uint8List? processedImageBytes;
  final ImageSettings settings;
  final bool isGeneratingThumbnail;
  final bool isProcessingPreview;
  final bool isProcessingFinal;
  final int originalSize;
  final int originalWidth;
  final int originalHeight;

  SingleImageState({
    this.originalFile,
    this.originalThumbnail,
    this.previewThumbnail,
    this.processedImageBytes,
    ImageSettings? settings,
    this.isGeneratingThumbnail = false,
    this.isProcessingPreview = false,
    this.isProcessingFinal = false,
    this.originalSize = 0,
    this.originalWidth = 0,
    this.originalHeight = 0,
  }) : settings = settings ?? ImageSettings();

  SingleImageState copyWith({
    File? originalFile,
    Uint8List? originalThumbnail,
    Uint8List? previewThumbnail,
    Uint8List? processedImageBytes,
    ImageSettings? settings,
    bool? isGeneratingThumbnail,
    bool? isProcessingPreview,
    bool? isProcessingFinal,
    int? originalSize,
    int? originalWidth,
    int? originalHeight,
  }) {
    return SingleImageState(
      originalFile: originalFile ?? this.originalFile,
      originalThumbnail: originalThumbnail ?? this.originalThumbnail,
      previewThumbnail: previewThumbnail ?? this.previewThumbnail,
      processedImageBytes: processedImageBytes ?? this.processedImageBytes,
      settings: settings ?? this.settings,
      isGeneratingThumbnail:
          isGeneratingThumbnail ?? this.isGeneratingThumbnail,
      isProcessingPreview: isProcessingPreview ?? this.isProcessingPreview,
      isProcessingFinal: isProcessingFinal ?? this.isProcessingFinal,
      originalSize: originalSize ?? this.originalSize,
      originalWidth: originalWidth ?? this.originalWidth,
      originalHeight: originalHeight ?? this.originalHeight,
    );
  }
}

@riverpod
class SingleImageController extends _$SingleImageController {
  @override
  SingleImageState build() {
    return SingleImageState();
  }

  Future<void> pickImage(ImageSource source, AppLocalizations l10n) async {
    state = state.copyWith(isGeneratingThumbnail: true);

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      state = state.copyWith(isGeneratingThumbnail: false);
      return;
    }

    final bytes = await pickedFile.readAsBytes();
    final validation = await ImageValidator.validateImage(bytes, l10n);

    if (!validation.isValid) {
      state = state.copyWith(isGeneratingThumbnail: false);
      // We return the validation result to the UI so it can show the error dialog
      throw validation;
    }

    final thumbnail = await ThumbnailGenerator.generateThumbnailFromXFile(
      pickedFile,
      maxWidth: 1000,
      quality: 70,
    );

    if (thumbnail != null) {
      state = state.copyWith(
        originalFile: File(pickedFile.path),
        originalThumbnail: thumbnail,
        previewThumbnail: thumbnail,
        originalSize: bytes.length,
        originalWidth: validation.width ?? 0,
        originalHeight: validation.height ?? 0,
        isGeneratingThumbnail: false,
        settings: state.settings.copyWith(originalFile: File(pickedFile.path)),
      );
      await regeneratePreview();
    } else {
      state = state.copyWith(isGeneratingThumbnail: false);
    }
  }

  Future<void> regeneratePreview() async {
    if (state.originalThumbnail == null) return;

    state = state.copyWith(isProcessingPreview: true);

    final result = await ImageProcessor.processImageThumbnail(
      state.originalThumbnail!,
      state.settings,
    );

    state = state.copyWith(
      previewThumbnail: result ?? state.previewThumbnail,
      isProcessingPreview: false,
    );
  }

  Future<void> updateSettings(ImageSettings newSettings) async {
    state = state.copyWith(settings: newSettings, processedImageBytes: null);
    await regeneratePreview();
  }

  Future<void> processFinalImage() async {
    if (state.originalFile == null) return;

    state = state.copyWith(isProcessingFinal: true);

    final resultFile = await ImageProcessor.processImage(
      state.originalFile!,
      state.settings,
    );

    if (resultFile != null) {
      final bytes = await resultFile.readAsBytes();
      state = state.copyWith(
        processedImageBytes: bytes,
        isProcessingFinal: false,
      );
    } else {
      state = state.copyWith(isProcessingFinal: false);
    }
  }
}

final singleImageTabIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
