import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:reducer/l10n/app_localizations.dart';
import 'package:reducer/core/services/remote_config_service.dart';

/// Utility class for validating image inputs before processing
class ImageValidator {
  // Maximum file size in bytes (from Remote Config)
  static int get maxFileSize =>
      RemoteConfigService().maxFileSizeMb * 1024 * 1024;

  // Maximum image dimensions (from Remote Config)
  static int get maxDimension => RemoteConfigService().maxImageDimension;

  /// Validate file size
  static ValidationResult validateFileSize(
    Uint8List bytes,
    AppLocalizations l10n,
  ) {
    if (bytes.length > maxFileSize) {
      final sizeMB = (bytes.length / (1024 * 1024)).toStringAsFixed(1);
      return ValidationResult(
        isValid: false,
        errorMessage: l10n.imageTooLarge(sizeMB),
        warningMessage: l10n.largeFileWarning,
      );
    }
    return ValidationResult(isValid: true);
  }

  /// Validate image dimensions
  static ValidationResult validateDimensions(
    img.Image image,
    AppLocalizations l10n,
  ) {
    if (image.width > maxDimension || image.height > maxDimension) {
      return ValidationResult(
        isValid: false,
        errorMessage: l10n.imageDimensionsTooLarge(
          image.width.toString(),
          image.height.toString(),
        ),
      );
    }
    return ValidationResult(isValid: true);
  }

  /// Validate image can be decoded
  static ValidationResult validateImageData(
    Uint8List bytes,
    AppLocalizations l10n,
  ) {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) {
        return ValidationResult(
          isValid: false,
          errorMessage: l10n.cannotDecodeImage,
        );
      }
      final dimensionResult = validateDimensions(image, l10n);
      if (!dimensionResult.isValid) return dimensionResult;

      return ValidationResult(
        isValid: true,
        width: image.width,
        height: image.height,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errorMessage: l10n.errorReadingImage(e.toString()),
      );
    }
  }

  /// Validate all aspects of an image
  static Future<ValidationResult> validateImage(
    Uint8List bytes,
    AppLocalizations l10n,
  ) async {
    // First check file size (lightweight)
    final sizeResult = validateFileSize(bytes, l10n);
    if (!sizeResult.isValid) return sizeResult;

    // Then check if it's a valid image and dimensions (heavyweight)
    final imageResult = await compute(_validateImageDataIsolate, [bytes, l10n]);
    if (!imageResult.isValid) return imageResult;

    // All checks passed
    return ValidationResult(
      isValid: true,
      warningMessage: sizeResult.warningMessage,
      width: imageResult.width,
      height: imageResult.height,
    );
  }

  /// Internal worker for Isolate validation
  static ValidationResult _validateImageDataIsolate(List<dynamic> args) {
    final bytes = args[0] as Uint8List;
    final l10n = args[1] as AppLocalizations;
    return validateImageData(bytes, l10n);
  }

  /// Show validation error dialog
  static void showValidationDialog(
    BuildContext context,
    ValidationResult result,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.isValid ? Icons.warning : Icons.error,
              color: result.isValid ? Colors.orange : Colors.red,
            ),
            const SizedBox(width: 12),
            Text(result.isValid ? l10n.warning : l10n.error),
          ],
        ),
        content: Text(result.errorMessage ?? result.warningMessage!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
          if (result.isValid && result.hasWarning)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.continueAnyway),
            ),
        ],
      ),
    );
  }
}

/// Validation result class
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? warningMessage;
  final int? width;
  final int? height;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warningMessage,
    this.width,
    this.height,
  });

  bool get hasWarning => warningMessage != null;
}
