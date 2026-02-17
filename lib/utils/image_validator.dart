import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Utility class for validating image inputs before processing
class ImageValidator {
  // Maximum file size in bytes (50MB)
  static const int maxFileSize = 50 * 1024 * 1024;
  
  // Maximum image dimensions
  static const int maxDimension = 10000;

  /// Validate file size
  static ValidationResult validateFileSize(Uint8List bytes) {
    if (bytes.length > maxFileSize) {
      final sizeMB = (bytes.length / (1024 * 1024)).toStringAsFixed(1);
      return ValidationResult(
        isValid: false,
        errorMessage: 'Image too large ($sizeMB MB).\nMaximum size is 50MB.',
        warningMessage: 'Large file detected. Processing may take longer.',
      );
    }
    return ValidationResult(isValid: true);
  }

  /// Validate image dimensions
  static ValidationResult validateDimensions(img.Image image) {
    if (image.width > maxDimension || image.height > maxDimension) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Image dimensions too large (${image.width}x${image.height}).\nMaximum is 10000x10000 pixels.',
      );
    }
    return ValidationResult(isValid: true);
  }

  /// Validate image can be decoded
  static ValidationResult validateImageData(Uint8List bytes) {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Cannot decode image.\nFile may be corrupted or invalid format.',
        );
      }
      return validateDimensions(image);
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Error reading image: ${e.toString()}',
      );
    }
  }

  /// Validate all aspects of an image
  static ValidationResult validateImage(Uint8List bytes) {
    // First check file size
    final sizeResult = validateFileSize(bytes);
    if (!sizeResult.isValid) return sizeResult;

    // Then check if it's a valid image and dimensions
    final imageResult = validateImageData(bytes);
    if (!imageResult.isValid) return imageResult;

    // All checks passed, but return size warning if exists
    return sizeResult.hasWarning ? sizeResult : ValidationResult(isValid: true);
  }

  /// Show validation error dialog
  static void showValidationDialog(BuildContext context, ValidationResult result) {
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
            Text(result.isValid ? 'Warning' : 'Error'),
          ],
        ),
        content: Text(result.errorMessage ?? result.warningMessage!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (result.isValid && result.hasWarning)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Continue with processing
              },
              child: const Text('Continue Anyway'),
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

  ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warningMessage,
  });

  bool get hasWarning => warningMessage != null;
}
