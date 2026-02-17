import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/design_tokens.dart';
import '../../core/theme.dart';
import '../../models/image_settings.dart';
import '../../models/history_item.dart';
import '../../providers/history_provider.dart';
import '../../services/image_processor.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../models/ad_state.dart';
import '../../utils/image_validator.dart';
import '../../utils/thumbnail_generator.dart';
import '../../utils/debouncer.dart';
import '../../providers/premium_provider.dart';

class SingleImageScreen extends ConsumerStatefulWidget {
  const SingleImageScreen({super.key});

  @override
  ConsumerState<SingleImageScreen> createState() => _SingleImageScreenState();
}

class _SingleImageScreenState extends ConsumerState<SingleImageScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Original full-resolution data (for final export)
  File? _selectedFile;
  Uint8List? _selectedImageBytes;
  
  // Thumbnail data (for fast preview and live editing)
  Uint8List? _originalThumbnail;
  Uint8List? _previewThumbnail;
  
  // Final processed output
  File? _processedFile;
  Uint8List? _processedImageBytes;
  
  ImageSettings _settings = ImageSettings();
  
  // Loading states
  bool _isGeneratingThumbnail = false;
  bool _isProcessingPreview = false;
  bool _isProcessingFinal = false;
  bool _showBeforeImage = false; // For before/after toggle
  
  // Debouncer for slider interactions (prevents excessive reprocessing)
  final Debouncer _previewDebouncer = Debouncer(delay: const Duration(milliseconds: 250));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _previewDebouncer.dispose();
    super.dispose();
  }

  Future<void> _pickImage([ImageSource source = ImageSource.gallery]) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
        _isGeneratingThumbnail = true;
        // Clear previous data
        _originalThumbnail = null;
        _previewThumbnail = null;
        _processedImageBytes = null;
      });

      try {
        // Store full-resolution file reference
        if (!kIsWeb) {
          _selectedFile = File(pickedFile.path);
        }
        
        // Store full bytes for file size comparison
        final bytes = await pickedFile.readAsBytes();
        _selectedImageBytes = bytes;

        // Validate image before processing
        final validationResult = ImageValidator.validateImage(_selectedImageBytes!);
        if (!validationResult.isValid) {
          if (mounted) {
            ImageValidator.showValidationDialog(context, validationResult);
          }
          return; // Stop if validation fails
        }
        
        // Show warning if needed but continue
        if (validationResult.hasWarning && mounted) {
          ImageValidator.showValidationDialog(context, validationResult);
        }
        
        // Generate fast thumbnail for preview (critical for performance!)
        final thumbnail = await ThumbnailGenerator.generateThumbnailFromXFile(
          pickedFile,
          maxWidth: 1000,
          quality: 70,
        );

        if (thumbnail != null) {
          setState(() {
            _originalThumbnail = thumbnail;
            _previewThumbnail = thumbnail; // Initial preview is same as original
            _settings = _settings.copyWith(originalFile: _selectedFile);
            _isGeneratingThumbnail = false;
            _tabController.animateTo(1);
          });
          
          // Auto-generate initial preview
          _regeneratePreview();
        } else {
          throw Exception('Failed to generate thumbnail');
        }
      } catch (e) {
        setState(() => _isGeneratingThumbnail = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading image: $e')),
          );
        }
      }
    }
  }

  /// Regenerate preview from thumbnail (fast, non-blocking)
  Future<void> _regeneratePreview() async {
    if (_originalThumbnail == null) return;

    setState(() => _isProcessingPreview = true);

    try {
      final isPro = ref.read(premiumProvider).isPro;
      // Process thumbnail in isolate (fast!)
      final result = await ImageProcessor.processImageThumbnail(
        _originalThumbnail!,
        _settings,
        isPremium: isPro,
      );

      if (result != null && mounted) {
        setState(() {
          _previewThumbnail = result;
          _isProcessingPreview = false;
        });
      } else {
        setState(() => _isProcessingPreview = false);
      }
    } catch (e) {
      setState(() => _isProcessingPreview = false);
      debugPrint('Error regenerating preview: $e');
    }
  }

  /// Process full-resolution image for final export
  Future<void> _processFinalImage() async {
    if (_selectedImageBytes == null) return;

    setState(() => _isProcessingFinal = true);

    try {
      final isPro = ref.read(premiumProvider).isPro;
      // Process full-resolution bytes in isolate
      final result = await ImageProcessor.processImageBytes(
        _selectedImageBytes!,
        _settings,
        isPremium: isPro,
      );

      if (result != null && mounted) {
        setState(() {
          _processedImageBytes = result;
          _isProcessingFinal = false;
          _tabController.animateTo(2); // Jump to Export tab (3 tabs: 0,1,2)
        });
      } else {
        setState(() => _isProcessingFinal = false);
      }
    } catch (e) {
      setState(() => _isProcessingFinal = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
      }
    }
  }

  /// Debounced settings update (prevents excessive preview regeneration)
  void _onSettingChanged(ImageSettings newSettings) {
    setState(() => _settings = newSettings);
    
    // Debounce preview regeneration (only runs 250ms after user stops dragging)
    _previewDebouncer.call(() {
      _regeneratePreview();
    });
  }

  /// Save processed image to device gallery
  Future<void> _saveToGallery() async {
    if (_processedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No processed image to save')),
      );
      return;
    }

    try {
      // Create temp file with processed bytes
      final tempDir = await getTemporaryDirectory();
      final fileName = 'imagemaster_${DateTime.now().millisecondsSinceEpoch}.${_settings.format.extension}';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(_processedImageBytes!);

      // Save thumbnail for history (FIXED: use app documents instead of temp)
      final appDir = await getApplicationDocumentsDirectory();
      final historyDir = Directory(p.join(appDir.path, 'history'));
      if (!await historyDir.exists()) {
        await historyDir.create(recursive: true);
      }
      final thumbFileName = 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final thumbRelativePath = 'history/$thumbFileName';
      final thumbFile = File(p.join(appDir.path, thumbRelativePath));
      await thumbFile.writeAsBytes(_previewThumbnail ?? _originalThumbnail!);

      // Save to gallery using gal package
      await Gal.putImage(file.path, album: 'ImageMaster Pro');

      // Save to history
      final historyItem = HistoryItem(
        id: const Uuid().v4(),
        thumbnailPath: thumbRelativePath, // Save relative path
        originalPath: _selectedFile?.path ?? '',
        settings: _settings,
        timestamp: DateTime.now(),
        originalSize: _selectedImageBytes?.length ?? 0,
        processedSize: _processedImageBytes!.length,
      );
      await ref.read(historyProvider).addItem(historyItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✓ Saved to Gallery!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Share processed image via system share sheet
  Future<void> _shareImage() async {
    if (_processedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No processed image to share')),
      );
      return;
    }

    try {
      // Create temp file with processed bytes
      final tempDir = await getTemporaryDirectory();
      final fileName = 'imagemaster_share_${DateTime.now().millisecondsSinceEpoch}.${_settings.format.extension}';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(_processedImageBytes!);

      // Share via share_plus
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Processed with ImageMaster Pro',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Editor'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: DesignTokens.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: DesignTokens.primaryBlue,
          tabs: const [
            Tab(text: 'Upload', icon: Icon(Iconsax.document_upload)),
            Tab(text: 'Edit & Preview', icon: Icon(Iconsax.setting_2)),
            Tab(text: 'Export', icon: Icon(Iconsax.export)),
          ],
        ),
      ),
      body: Column(
        children: [
          const BannerAdWidget(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUploadTab(),
                _buildSettingsTab(),
                _buildExportTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isGeneratingThumbnail)
            Column(
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading image...', style: TextStyle(color: Colors.grey)),
              ],
            )
          else if (_originalThumbnail != null)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.memory(
                        _originalThumbnail!,
                        height: 300,
                        fit: BoxFit.contain,
                        cacheWidth: 800, // Limit decode size
                        cacheHeight: 600,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Original Size: ${_formatFileSize(_selectedImageBytes!.length)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const Icon(Iconsax.image, size: 80, color: Colors.grey),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isGeneratingThumbnail ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Iconsax.gallery),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isGeneratingThumbnail ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Iconsax.camera),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    if (_originalThumbnail == null) return _buildEmptyState();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsSection(
            title: 'Resize & Scale',
            child: Column(
              children: [
                _buildSlider(
                  label: 'Scale Percentage',
                  value: _settings.scalePercent,
                  min: 10,
                  max: 200,
                  onChanged: (v) {
                    _onSettingChanged(_settings.copyWith(scalePercent: v));
                  },
                ),
              ],
            ),
          ),
          _buildSettingsSection(
            title: 'Adjustments',
            child: Column(
              children: [
                _buildSlider(
                  label: 'Rotation',
                  value: _settings.rotation,
                  min: 0,
                  max: 360,
                  onChanged: (v) {
                    _onSettingChanged(_settings.copyWith(rotation: v));
                  },
                ),
                _buildSlider(
                  label: 'Quality',
                  value: _settings.quality,
                  min: 1,
                  max: 100,
                  onChanged: (v) {
                    _onSettingChanged(_settings.copyWith(quality: v));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFlipToggle(
                      label: 'Flip H',
                      value: _settings.flipHorizontal,
                      onChanged: (v) {
                        _onSettingChanged(_settings.copyWith(flipHorizontal: v));
                      },
                    ),
                    _buildFlipToggle(
                      label: 'Flip V',
                      value: _settings.flipVertical,
                      onChanged: (v) {
                        _onSettingChanged(_settings.copyWith(flipVertical: v));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildSettingsSection(
            title: 'Export Format',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ImageFormat.values.map((f) {
                return ChoiceChip(
                  label: Text(f.name),
                  selected: _settings.format == f,
                  onSelected: (selected) {
                    if (selected) {
                      _onSettingChanged(_settings.copyWith(format: f));
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: _isProcessingFinal ? 'Processing...' : 'Process Image',
              icon: Iconsax.cpu,
              onPressed: () async {
                final adState = ref.read(adStateProvider);
                await adState.onFeatureClick(
                  context: context,
                  onComplete: () => _processFinalImage(),
                );
              },
              isLoading: _isProcessingFinal,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildExportTab() {
    if (_processedImageBytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.info_circle, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No processed image yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Go to Settings tab and click "Process Image"',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: AppTheme.neumorphicDecoration(context),
            child: Column(
              children: [
                // Before/After Toggle Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _showBeforeImage ? 'Before (Original)' : 'After (Processed)',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showBeforeImage = !_showBeforeImage;
                        });
                      },
                      icon: Icon(_showBeforeImage ? Iconsax.eye : Iconsax.eye_slash, size: 18),
                      label: Text(_showBeforeImage ? 'Show After' : 'Show Before'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Preview Image
                RepaintBoundary(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _showBeforeImage ? (_originalThumbnail ?? _processedImageBytes!) : _processedImageBytes!,
                      height: 300,
                      fit: BoxFit.contain,
                      cacheWidth: 800,
                      cacheHeight: 600,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Text('Ready to Export!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Format:', style: TextStyle(color: Colors.grey)),
                          Text(_settings.format.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quality:', style: TextStyle(color: Colors.grey)),
                          Text('${_settings.quality.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('File Size:', style: TextStyle(color: Colors.grey)),
                          Text(
                            _formatFileSize(_processedImageBytes!.length),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _processedImageBytes!.length < _selectedImageBytes!.length 
                                  ? Colors.green 
                                  : DesignTokens.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      if (_processedImageBytes!.length < _selectedImageBytes!.length) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Size Reduced:', style: TextStyle(color: Colors.grey)),
                            Text(
                              '${_getSizeReductionPercentage().toStringAsFixed(1)}%',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Save to Gallery',
                  icon: Iconsax.save_2,
                  onPressed: _saveToGallery,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  label: 'Share',
                  icon: Iconsax.share,
                  onPressed: _shareImage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('Please upload an image first', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildSettingsSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.neumorphicDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${value.toInt()}${label.contains('Percent') ? '%' : ''}'),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: DesignTokens.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildFlipToggle({required String label, required bool value, required Function(bool) onChanged}) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: DesignTokens.primaryBlue,
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  double _getSizeReductionPercentage() {
    if (_selectedImageBytes == null || _processedImageBytes == null) return 0.0;
    final originalSize = _selectedImageBytes!.length;
    final processedSize = _processedImageBytes!.length;
    return ((originalSize - processedSize) / originalSize * 100);
  }
}
