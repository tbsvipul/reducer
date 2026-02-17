import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/design_tokens.dart';
import '../../core/theme.dart';
import '../../models/image_settings.dart';
import '../../services/image_processor.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../models/ad_state.dart';
import '../../providers/history_provider.dart';
import '../../models/history_item.dart';
import '../../utils/thumbnail_generator.dart';
import '../../providers/premium_provider.dart';
import 'package:uuid/uuid.dart';

class BulkImageScreen extends ConsumerStatefulWidget {
  const BulkImageScreen({super.key});

  @override
  ConsumerState<BulkImageScreen> createState() => _BulkImageScreenState();
}

class _BulkImageScreenState extends ConsumerState<BulkImageScreen> {
  List<XFile> _selectedImages = [];
  ImageSettings _settings = ImageSettings();
  bool _isProcessing = false;
  double _progress = 0.0;
  Map<String, File?> _processedResults = {}; // filename -> processed file

  Future<void> _pickMultipleImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      final isPro = ref.read(premiumProvider).isPro;
      setState(() {
        _selectedImages = isPro ? pickedFiles : pickedFiles.take(50).toList();
        _processedResults.clear();
      });
    }
  }

  Future<void> _processAllImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _processedResults.clear();
    });

    try {
      for (int i = 0; i < _selectedImages.length; i++) {
        final xFile = _selectedImages[i];
        
        try {
          // Create temp file for processing
          final tempDir = Directory.systemTemp;
          final tempFileName = 'temp_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final tempFile = File('${tempDir.path}/$tempFileName');
          await tempFile.writeAsBytes(await xFile.readAsBytes());

          final isPro = ref.read(premiumProvider).isPro;
          // Process individual image
          final result = await ImageProcessor.processImage(
            tempFile,
            _settings,
            isPremium: isPro,
          );

          if (result != null) {
            _processedResults[xFile.name] = result;
          } else {
            _processedResults[xFile.name] = null; // Mark as failed
          }
        } catch (e) {
          print('Error processing ${xFile.name}: $e');
          _processedResults[xFile.name] = null;
        }

        setState(() {
          _progress = (i + 1) / _selectedImages.length;
        });
      }

      if (mounted) {
        final successfulResults = _processedResults.values.where((f) => f != null).toList();
        
        if (successfulResults.isNotEmpty) {
          // Save to history
          try {
            final appDir = await getApplicationDocumentsDirectory();
            final historyDir = Directory('${appDir.path}/history');
            if (!await historyDir.exists()) {
              await historyDir.create(recursive: true);
            }

            // Generate session-specific directory for persistent storage
            final sessionId = const Uuid().v4();
            final sessionRelativeDir = 'history/bulk_$sessionId';
            final sessionDir = Directory(p.join(appDir.path, sessionRelativeDir));
            if (!await sessionDir.exists()) {
              await sessionDir.create(recursive: true);
            }

            // Copy all processed files to persistent storage
            final persistentRelativePaths = <String>[];
            for (final file in successfulResults) {
              if (file != null) {
                final fileName = p.basename(file.path);
                final persistentFile = await file.copy(p.join(sessionDir.path, fileName));
                persistentRelativePaths.add('$sessionRelativeDir/$fileName');
              }
            }

            // Generate thumbnail from first image
            final firstFile = successfulResults.first!;
            final thumbBytes = await ThumbnailGenerator.generateSmallThumbnail(XFile(firstFile.path));
            
            if (thumbBytes != null) {
              final thumbFileName = 'thumb_bulk_$sessionId.jpg';
              final thumbRelativePath = 'history/$thumbFileName';
              final thumbFile = File(p.join(appDir.path, thumbRelativePath));
              await thumbFile.writeAsBytes(thumbBytes);

              // Calculate total sizes
              int totalOriginalSize = 0;
              int totalProcessedSize = 0;
              
              for (final xFile in _selectedImages) {
                totalOriginalSize += await xFile.length();
              }
              for (final file in successfulResults) {
                totalProcessedSize += await file!.length();
              }

              final historyItem = HistoryItem(
                id: sessionId,
                thumbnailPath: thumbRelativePath, // Save relative path
                originalPath: _selectedImages.first.path, // Use first as reference
                settings: _settings,
                timestamp: DateTime.now(),
                originalSize: totalOriginalSize,
                processedSize: totalProcessedSize,
                isBulk: true,
                itemCount: successfulResults.length,
                processedPaths: persistentRelativePaths, // Save relative paths
              );

              await ref.read(historyProvider).addItem(historyItem);
            }
          } catch (e) {
            print('Error saving bulk history: $e');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Processed ${_processedResults.values.where((f) => f != null).length} of ${_selectedImages.length} images',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// Save all processed images to gallery
  Future<void> _saveAllToGallery() async {
    final successfulResults = _processedResults.values.where((f) => f != null).toList();
    
    if (successfulResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images to save')),
      );
      return;
    }

    try {
      int savedCount = 0;
      for (final file in successfulResults) {
        if (file != null) {
          await Gal.putImage(file.path, album: 'ImageMaster Pro');
          savedCount++;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Saved $savedCount images to gallery!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Export all processed images as ZIP
  Future<void> _exportAsZip() async {
    final successfulResults = _processedResults.values.where((f) => f != null).toList();
    
    if (successfulResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images to export')),
      );
      return;
    }

    try {
      // Create archive
      final archive = Archive();
      
      for (int i = 0; i < successfulResults.length; i++) {
        final file = successfulResults[i];
        if (file != null) {
          final bytes = await file.readAsBytes();
          final fileName = 'image_${i + 1}.${_settings.format.extension}';
          archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
        }
      }

      // Encode to ZIP
      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive);

      if (zipBytes == null) throw Exception('Failed to create ZIP');

      // Save ZIP file
      final tempDir = await getTemporaryDirectory();
      final zipFile = File('${tempDir.path}/imagemaster_bulk_${DateTime.now().millisecondsSinceEpoch}.zip');
      await zipFile.writeAsBytes(zipBytes);

      // Share ZIP
      await Share.shareXFiles(
        [XFile(zipFile.path)],
        text: 'Bulk processed images (${successfulResults.length} files)',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ ZIP file ready to share!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating ZIP: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Export Options',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Iconsax.gallery, color: DesignTokens.primaryBlue),
              title: const Text('Save All to Gallery'),
              subtitle: Text('${_processedResults.values.where((f) => f != null).length} images'),
              onTap: () {
                Navigator.pop(context);
                _saveAllToGallery();
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.archive, color: DesignTokens.primaryBlue),
              title: const Text('Export as ZIP'),
              subtitle: const Text('Create shareable ZIP file'),
              onTap: () {
                Navigator.pop(context);
                _exportAsZip();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Processing'),
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Iconsax.trash),
              onPressed: () {
                setState(() {
                  _selectedImages.clear();
                  _processedResults.clear();
                });
              },
            ),
        ],
      ),
      body: _selectedImages.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                const BannerAdWidget(),
                // Image Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      final xFile = _selectedImages[index];
                      final isProcessed = _processedResults.containsKey(xFile.name);
                      final hasSucceeded = _processedResults[xFile.name] != null;
                      
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(xFile.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          if (isProcessed)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: hasSucceeded
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  hasSucceeded ? Iconsax.tick_circle : Iconsax.close_circle,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                // Settings & Controls
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.neumorphicDecoration(context),
                  child: Column(
                    children: [
                      // Progress Bar
                      if (_isProcessing) ...[
                        LinearProgressIndicator(value: _progress),
                        const SizedBox(height: 8),
                        Text('${(_progress * 100).toInt()}% Complete'),
                        const SizedBox(height: 16),
                      ],
                      // Quick Settings
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Quality', style: TextStyle(fontSize: 12)),
                                Slider(
                                  value: _settings.quality,
                                  min: 10,
                                  max: 100,
                                  divisions: 9,
                                  label: '${_settings.quality.toInt()}%',
                                  onChanged: _isProcessing
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _settings = _settings.copyWith(quality: value);
                                          });
                                        },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Scale', style: TextStyle(fontSize: 12)),
                                Slider(
                                  value: _settings.scalePercent,
                                  min: 25,
                                  max: 100,
                                  divisions: 3,
                                  label: '${_settings.scalePercent.toInt()}%',
                                  onChanged: _isProcessing
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _settings = _settings.copyWith(scalePercent: value);
                                          });
                                        },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          label: _processedResults.isEmpty
                              ? 'Process All (${_selectedImages.length})'
                              : 'Results Ready',
                          icon: _processedResults.isEmpty ? Iconsax.cpu : Iconsax.tick_circle,
                          onPressed: _isProcessing
                              ? () {} // Empty callback when processing
                              : () {
                                   if (_processedResults.isEmpty) {
                                     _processAllImages();
                                   } else {
                                     _showExportOptions();
                                   }
                                 },
                          isLoading: _isProcessing,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.grid_5, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            'Bulk Image Processing',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select up to 50 images to process at once',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final adState = ref.read(adStateProvider);
              await adState.onFeatureClick(
                context: context,
                onComplete: _pickMultipleImages,
              );
            },
            icon: const Icon(Iconsax.add),
            label: const Text('Select Images'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
