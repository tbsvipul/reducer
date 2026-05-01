import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Cloudinary configuration
  static const String cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
  );
  static const String uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
  );

  /// Upload image to Cloudinary using unsigned upload preset.
  /// Returns the secure delivery URL on success, else null.
  Future<String?> uploadImage(File imageFile, {String? userId}) async {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      debugPrint(
        'CloudinaryService: Missing configuration (CLOUD_NAME or UPLOAD_PRESET)',
      );
      return null;
    }

    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        // Dynamic folders mode: this folder path will auto-create if missing.
        ..fields['folder'] = userId == null || userId.isEmpty
            ? 'profile_images/guest'
            : 'profile_images/$userId'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final raw = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final secureUrl = decoded['secure_url'] as String?;
        if (secureUrl != null && secureUrl.isNotEmpty) {
          return secureUrl;
        }
        debugPrint(
          'CloudinaryService: secure_url missing in response: $decoded',
        );
        return null;
      }

      debugPrint('CloudinaryService: upload failed (${response.statusCode})');
      return null;
    } catch (e) {
      debugPrint('CloudinaryService: upload error: $e');
      return null;
    }
  }
}
