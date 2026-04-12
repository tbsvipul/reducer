import 'dart:io';
import 'dart:async';
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
import 'package:reducer/core/theme/design_tokens.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/features/gallery/presentation/controllers/history_controller.dart';
import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:reducer/core/utils/image_processor.dart';
import 'package:reducer/shared/presentation/widgets/ads/banner_ad_widget.dart';
import 'package:reducer/shared/presentation/widgets/ads/native_ad_widget.dart';
import 'package:reducer/core/utils/image_validator.dart';
import 'package:reducer/core/utils/thumbnail_generator.dart';
import 'package:reducer/core/utils/debouncer.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/core/services/permission_service.dart';
import 'package:reducer/features/editor/presentation/widgets/upload_tab_content.dart';
import 'package:reducer/features/editor/presentation/widgets/export_tab_content.dart';
import 'package:reducer/features/editor/presentation/widgets/editor_settings_panel.dart';


class SingleImageScreen extends ConsumerStatefulWidget {
  const SingleImageScreen({super.key});

  @override
  ConsumerState<SingleImageScreen> createState() => _SingleImageScreenState();
}

class _SingleImageScreenState extends ConsumerState<SingleImageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  File? _selectedFile;
  Uint8List? _selectedImageBytes;

  Uint8List? _originalThumbnail;
  Uint8List? _previewThumbnail;

  Uint8List? _processedImageBytes;

  ImageSettings _settings = ImageSettings();

  bool _isGeneratingThumbnail = false;
  bool _isProcessingPreview = false;
  bool _isProcessingFinal = false;

  final Debouncer _previewDebouncer =
      Debouncer(delay: const Duration(milliseconds: 250));

  bool _cancelled = false;
  int _originalSize = 0;
  int _originalWidth = 0;
  int _originalHeight = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _cancelled = true;
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _previewDebouncer.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() {});
    }
  }

  Future<void> _pickImage([ImageSource source = ImageSource.gallery]) async {
    final bool ok;
    if (source == ImageSource.camera) {
      if (!mounted) return;
      ok = await PermissionService.instance.ensureCameraPermission(context);
    } else {
      if (!mounted) return;
      ok = await PermissionService.instance.ensurePhotosPermission(context);
    }
    if (!ok || !mounted) return;

    final picker = ImagePicker();
    XFile? pickedFile;
    try {
      pickedFile = await picker.pickImage(source: source);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Unable to open ${source == ImageSource.camera ? "camera" : "photos"}: $e')),
        );
      }
      return;
    }

    if (pickedFile == null || !mounted) return;

    setState(() {
      _isGeneratingThumbnail = true;
      _originalThumbnail = null;
      _previewThumbnail = null;
      _processedImageBytes = null;
    });

    try {
      if (!kIsWeb) {
        _selectedFile = File(pickedFile.path);
        if (!_selectedFile!.existsSync()) {
          throw Exception('Captured file missing');
        }
      }

      final bytes = await pickedFile.readAsBytes();
      if (!mounted || _cancelled) return;

      _selectedImageBytes = bytes;

      final validationResult = ImageValidator.validateImage(_selectedImageBytes!);
      if (!validationResult.isValid) {
        if (mounted) {
          ImageValidator.showValidationDialog(context, validationResult);
        }
        return;
      }
      if (validationResult.hasWarning && mounted) {
        ImageValidator.showValidationDialog(context, validationResult);
      }

      // Evict previous images from cache to free memory
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      final thumbnail = await ThumbnailGenerator.generateThumbnailFromXFile(
        pickedFile,
        maxWidth: 1000,
        quality: 70,
      );

      if (!mounted || _cancelled) return;

      if (thumbnail != null) {
        setState(() {
          _originalThumbnail = thumbnail;
          _previewThumbnail = thumbnail;
          _settings = _settings.copyWith(originalFile: _selectedFile);
          _originalSize = bytes.length;
          _originalWidth = validationResult.width ?? 0;
          _originalHeight = validationResult.height ?? 0;
          _selectedImageBytes = null; // Free up bytes memory if possible
          _isGeneratingThumbnail = false;
          _tabController.animateTo(1);
        });
        _regeneratePreview();
      } else {
        throw Exception('Failed to generate thumbnail');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGeneratingThumbnail = false;
        _selectedImageBytes = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading image: $e')),
      );
    }
  }

  Future<void> _regeneratePreview() async {
    if (_originalThumbnail == null || !mounted || _cancelled) return;

    setState(() => _isProcessingPreview = true);

    try {
      final isPro = ref.read(premiumControllerProvider).isPro;
      final result = await ImageProcessor.processImageThumbnail(
        _originalThumbnail!,
        _settings,
        isPremium: isPro,
      );

      if (!mounted || _cancelled) return;

      setState(() {
        _previewThumbnail = result ?? _previewThumbnail;
        _isProcessingPreview = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessingPreview = false);
      debugPrint('Error regenerating preview: $e');
    }
  }

  Future<void> _processFinalImage() async {
    if (_selectedFile == null && _selectedImageBytes == null) {
      if (_selectedFile != null && !kIsWeb) {
        // reload logic if needed
      } else {
        return;
      }
    }
    if (!mounted) return;

    setState(() => _isProcessingFinal = true);

    try {
      final isPro = ref.read(premiumControllerProvider).isPro;
      Uint8List? result;

      if (_selectedImageBytes != null) {
        result = await ImageProcessor.processImageBytes(
          _selectedImageBytes!,
          _settings,
          isPremium: isPro,
        );
      } else if (_selectedFile != null) {
        final fileResult = await ImageProcessor.processImage(
          _selectedFile!,
          _settings,
          isPremium: isPro,
        );
        result = await fileResult?.readAsBytes();
      }

      if (!mounted || _cancelled) return;

      if (result != null) {
        setState(() {
          _processedImageBytes = result;
          _isProcessingFinal = false;
          _tabController.animateTo(2);
        });
      } else {
        setState(() => _isProcessingFinal = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessingFinal = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    }
  }

  void _onSettingChanged(ImageSettings newSettings) {
    if (!mounted) return;
    setState(() => _settings = newSettings);
    _previewDebouncer.call(_regeneratePreview);
  }

  Future<void> _saveToGallery() async {
    final processedBytes = _processedImageBytes;
    final previewBytes = _previewThumbnail ?? _originalThumbnail;

    if (processedBytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No processed image to save')),
      );
      return;
    }
    if (previewBytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No preview available to save in history')),
      );
      return;
    }

    try {
      final ok = await PermissionService.instance.ensurePhotosPermission(context);
      if (!ok) return;

      final timestamp = DateTime.now();
      final timestampMs = timestamp.millisecondsSinceEpoch;
      final tempDir = await getTemporaryDirectory();
      final fileName = 'imagemaster_$timestampMs.${_settings.format.extension}';
      final file = File('${tempDir.path}/$fileName');

      final appDir = await getApplicationDocumentsDirectory();
      final historyDir = Directory(p.join(appDir.path, 'history'));
      if (!await historyDir.exists()) {
        await historyDir.create(recursive: true);
      }

      final thumbRelativePath = 'history/thumb_$timestampMs.jpg';
      final thumbFile = File(p.join(appDir.path, thumbRelativePath));

      await Future.wait([
        file.writeAsBytes(processedBytes),
        thumbFile.writeAsBytes(previewBytes),
      ]);

      if (!mounted || _cancelled) return;

      await Gal.putImage(file.path, album: 'ImageMaster Pro');

      if (!mounted) return;

      final historyItem = HistoryItem(
        id: const Uuid().v4(),
        thumbnailPath: thumbRelativePath,
        originalPath: _selectedFile?.path ?? '',
        settings: _settings,
        timestamp: timestamp,
        originalSize: _originalSize,
        processedSize: processedBytes.length,
      );
      final historyController = await ref.readHistoryControllerReady();
      await historyController.addItem(historyItem);

      if (!mounted) return;
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to save: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _shareImage() async {
    if (_processedImageBytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No processed image to share')),
      );
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'imagemaster_share_${DateTime.now().millisecondsSinceEpoch}.${_settings.format.extension}';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(_processedImageBytes!);

      if (!mounted || _cancelled) return;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Processed with ImageMaster Pro',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to share: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showBanner = _tabController.index == 0;

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
          if (showBanner) const BannerAdWidget(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                UploadTabContent(
                  isGeneratingThumbnail: _isGeneratingThumbnail,
                  originalThumbnail: _originalThumbnail,
                  originalSize: _originalSize,
                  onPickImage: (source) => AdManager().showInterstitialAd(
                    onComplete: () => _pickImage(source),
                  ),
                ),
                _buildSettingsTab(),
                ExportTabContent(
                  processedImageBytes: _processedImageBytes,
                  originalThumbnail: _originalThumbnail,
                  previewThumbnail: _previewThumbnail,
                  settings: _settings,
                  originalSize: _originalSize,
                  originalWidth: _originalWidth,
                  originalHeight: _originalHeight,
                  onSave: _saveToGallery,
                  onShare: _shareImage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    if (_originalThumbnail == null) return _buildEmptyState();

    return EditorSettingsPanel(
      settings: _settings,
      previewThumbnail: _previewThumbnail,
      isProcessingPreview: _isProcessingPreview,
      isProcessingFinal: _isProcessingFinal,
      originalSize: _originalSize,
      originalWidth: _originalWidth,
      originalHeight: _originalHeight,
      isPro: ref.watch(premiumControllerProvider).isPro,
      onSettingChanged: _onSettingChanged,
      onProcessRequested: () => AdManager().showInterstitialAd(
        onComplete: _processFinalImage,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.image, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Please upload an image first',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: NativeAdWidget(size: NativeAdSize.medium),
            ),
          ],
        ),
      ),
    );
  }
}


