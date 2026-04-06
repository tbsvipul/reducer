import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import 'package:reducer/core/theme/design_tokens.dart';
import 'package:reducer/core/theme/app_theme.dart';
import 'package:reducer/core/widgets/custom_button.dart';
import 'package:reducer/core/widgets/ads/banner_ad_widget.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/core/services/permission_service.dart';

class ExifEraserScreen extends StatefulWidget {
  const ExifEraserScreen({super.key});

  @override
  State<ExifEraserScreen> createState() => _ExifEraserScreenState();
}

class _ExifEraserScreenState extends State<ExifEraserScreen> {
  XFile? _selectedImages;
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    if (!await PermissionService.instance.ensurePhotosPermission(context)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission required to access photos')),
        );
      }
      return;
    }
    final picker = ImagePicker();
    XFile? image;
    try {
      image = await picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open gallery: $e')),
        );
      }
      return;
    }
    if (image != null) {
      setState(() {
        _selectedImages = image;
      });
    }
  }

  Future<void> _cleanMetadata() async {
    if (_selectedImages == null) return;

    setState(() => _isProcessing = true);

    try {
      if (!await PermissionService.instance.ensurePhotosPermission(context)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission required to save')),
          );
        }
        return;
      }
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/clean_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // flutter_image_compress removes EXIF by default
      final result = await FlutterImageCompress.compressAndGetFile(
        _selectedImages!.path,
        targetPath,
        quality: 95,
        keepExif: false, // This is the key
      );

      if (result != null) {
        // Save to gallery
        await Gal.putImage(result.path, album: 'ImageMaster Pro');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Metadata removed and saved to Gallery!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to clean metadata')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cleaning metadata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EXIF Eraser'),
      ),
      body: Column(
        children: [
          const BannerAdWidget(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                   Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.cardDecoration(context),
                    child: Column(
                      children: [
                        const Icon(Iconsax.shield_tick, size: 64, color: DesignTokens.primaryBlue),
                        const SizedBox(height: 16),
                        const Text(
                          'Privacy First',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Remove GPS coordinates, camera info, and other sensitive metadata from your photos before sharing.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  if (_selectedImages == null)
                    _buildUploadPlaceholder()
                  else
                    _buildImagePreview(),
                  
                  const SizedBox(height: 32),
                  
                  if (_selectedImages != null)
                    CustomButton(
                      label: _isProcessing ? 'Cleaning...' : 'Clean & Save',
                      icon: Iconsax.shield_tick,
                      onPressed: () => AdManager().showInterstitialAd(
                        onComplete: _cleanMetadata,
                      ),
                      isLoading: _isProcessing,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // permission handled by PermissionService

  Widget _buildUploadPlaceholder() {
    return GestureDetector(
      onTap: () => AdManager().showInterstitialAd(
        onComplete: _pickImage,
      ),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: DesignTokens.accentBlue,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DesignTokens.primaryBlue.withValues(alpha: 0.2), style: BorderStyle.solid),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.add_square, size: 48, color: DesignTokens.primaryBlue),
            SizedBox(height: 12),
            Text('Tap to select image', style: TextStyle(color: DesignTokens.primaryBlue, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(_selectedImages!.path),
                height: 300,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.close_circle, color: Colors.red),
              onPressed: () => setState(() => _selectedImages = null),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _selectedImages!.name,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
