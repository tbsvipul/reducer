import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cloudinary_service.g.dart';

@riverpod
CloudinaryService cloudinaryService(CloudinaryServiceRef ref) {
  return CloudinaryService();
}

class CloudinaryService {
  static const String cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
  );
  static const String uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
  );
  static const String apiKey = String.fromEnvironment('CLOUDINARY_API_KEY');

  /// Uploads a profile image to Cloudinary and returns the secure URL.
  Future<String?> uploadProfileImage(File file, String userId) async {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      debugPrint(
        'CloudinaryService: Missing configuration (CLOUDINARY_CLOUD_NAME or CLOUDINARY_UPLOAD_PRESET)',
      );
      return null;
    }

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      // Dynamic folder based on userId as requested
      ..fields['folder'] = 'user_profiles/$userId'
      // Use userId as public_id to overwrite previous profile images or keep them unique
      ..fields['public_id'] = 'profile_$userId'
      ..fields['api_key'] = apiKey
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonMap = jsonDecode(responseBody);
        return jsonMap['secure_url'] as String;
      } else {
        throw Exception('Cloudinary upload failed: $responseBody');
      }
    } catch (e) {
      debugPrint('Cloudinary Error: $e');
      rethrow;
    }
  }
}
