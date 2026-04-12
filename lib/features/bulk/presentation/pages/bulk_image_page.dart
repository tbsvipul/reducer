import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:reducer/core/theme/design_tokens.dart';
import 'package:reducer/core/theme/app_theme.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/utils/image_processor.dart';
import 'package:reducer/shared/presentation/widgets/custom_button.dart';
import 'package:reducer/shared/presentation/widgets/ads/banner_ad_widget.dart';
import 'package:reducer/features/gallery/presentation/controllers/history_controller.dart';
import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/core/utils/thumbnail_generator.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:reducer/core/services/permission_service.dart';
import 'package:reducer/features/bulk/presentation/widgets/image_grid_tile.dart';


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
  final Map<String, File?> _processedResults = {};

  // ── FIX 1: Cancellation flag to prevent setState() after dispose() ──────
  bool _cancelled = false;

  @override
  void dispose() {
    _cancelled = true; // Signals the processing loop to stop safely
    super.dispose();
  }

  Future<void> _pickMultipleImages() async {
    if (!await PermissionService.instance.ensurePhotosPermission(context)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Photos permission is required to select images')),
        );
      }
      return;
    }
    final picker = ImagePicker();
    List<XFile> pickedFiles = const [];
    try {
      pickedFiles = await picker.pickMultiImage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open gallery: $e')),
        );
      }
      return;
    }

    if (pickedFiles.isNotEmpty) {
      // ── FIX 2: mounted check after every await ──────────────────────────
      if (!mounted) return;
      final isPro = ref.read(premiumControllerProvider).isPro;
      final files = pickedFiles;
      setState(() {
        _selectedImages = isPro ? files : files.take(50).toList();
        _processedResults.clear();
      });
      if (!isPro && files.length > _selectedImages.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Free users can process up to 50 images. Upgrade to Pro for unlimited.')),
        );
      }
    }
  }

  Future<void> _processAllImages() async {
    if (_selectedImages.isEmpty || !mounted) return;

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _processedResults.clear();
      _cancelled = false;
    });

    try {
      final inputFiles = _selectedImages.map((x) => File(x.path)).toList();
      final isPro = ref.read(premiumControllerProvider).isPro;

      // Start parallel processing stream
      final progressStream = ImageProcessor.processBulkWithProgress(
        inputFiles,
        _settings,
        isPremium: isPro,
        maxConcurrent: 3,
      );

      int currentIndex = 0;
      await for (final update in progressStream) {
        if (!mounted || _cancelled) break;

        final batch = _selectedImages
            .skip(currentIndex)
            .take(update.batchResults.length)
            .toList();
        for (int i = 0; i < batch.length; i++) {
          _processedResults[batch[i].name] = update.batchResults[i];
        }
        currentIndex += update.batchResults.length;

        setState(() {
          _progress = update.progress;
        });
      }

      if (!mounted || _cancelled) return;

      final successfulResults = _processedResults.values
          .where((f) => f != null)
          .cast<File>()
          .toList();

      if (successfulResults.isNotEmpty) {
        await _saveToHistory(successfulResults);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Processed ${successfulResults.length} of ${_selectedImages.length} images',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveToHistory(List<File> successfulResults) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final sessionId = const Uuid().v4();
      final sessionRelativeDir = 'history/bulk_$sessionId';
      final sessionDir = Directory(p.join(appDir.path, sessionRelativeDir));
      if (!await sessionDir.exists()) {
        await sessionDir.create(recursive: true);
      }

      final persistentRelativePaths = <String>[];
      final copyFutures = <Future>[];

      for (final file in successfulResults) {
        if (!mounted || _cancelled) return;
        final fileName = p.basename(file.path);
        final persistentRelativePath = '$sessionRelativeDir/$fileName';
        persistentRelativePaths.add(persistentRelativePath);
        copyFutures.add(file.copy(p.join(appDir.path, persistentRelativePath)));
      }

      await Future.wait(copyFutures);

      final firstFile = successfulResults.first;
      final thumbBytes = await ThumbnailGenerator.generateSmallThumbnail(
          XFile(firstFile.path));

      if (thumbBytes == null || !mounted || _cancelled) return;

      final thumbRelativePath = 'history/thumb_bulk_$sessionId.jpg';
      final thumbFile = File(p.join(appDir.path, thumbRelativePath));
      await thumbFile.writeAsBytes(thumbBytes);

      // ── FIX 10: Compute sizes in parallel instead of sequential awaits ─
      final sizeFutures = [
        ..._selectedImages.map((x) => x.length()),
        ...successfulResults.map((f) => f.length()),
      ];
      final sizes = await Future.wait(sizeFutures);
      final totalOriginalSize =
          sizes.sublist(0, _selectedImages.length).fold(0, (a, b) => a + b);
      final totalProcessedSize =
          sizes.sublist(_selectedImages.length).fold(0, (a, b) => a + b);

      if (!mounted || _cancelled) return;

      final historyItem = HistoryItem(
        id: sessionId,
        thumbnailPath: thumbRelativePath,
        originalPath: _selectedImages.first.path,
        settings: _settings,
        timestamp: DateTime.now(),
        originalSize: totalOriginalSize,
        processedSize: totalProcessedSize,
        isBulk: true,
        itemCount: successfulResults.length,
        processedPaths: persistentRelativePaths,
      );

      final historyController = await ref.readHistoryControllerReady();
      await historyController.addItem(historyItem);
    } catch (e) {
      debugPrint('Error saving bulk history: $e');
    }
  }

  Future<void> _saveAllToGallery() async {
    if (!await PermissionService.instance.ensurePhotosPermission(context)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission required to save')),
        );
      }
      return;
    }
    final successfulResults =
        _processedResults.values.where((f) => f != null).cast<File>().toList();

    if (successfulResults.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No images to save')));
      return;
    }

    try {
      // ── FIX 11: Save in parallel instead of sequential loop ────────────
      await Future.wait(
        successfulResults
            .map((f) => Gal.putImage(f.path, album: 'ImageMaster Pro')),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('✓ Saved ${successfulResults.length} images to gallery!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error saving: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _exportAsZip() async {
    final successfulResults =
        _processedResults.values.where((f) => f != null).cast<File>().toList();

    if (successfulResults.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No images to export')));
      return;
    }

    try {
      // ── FIX 12: Build zip in isolate so UI stays responsive ────────────
      final zipArgs = _ZipArgs(
        filePaths: successfulResults.map((f) => f.path).toList(),
        extension: _settings.format.extension,
      );
      final zipBytes = await compute(_buildZipIsolate, zipArgs);

      if (zipBytes == null) throw Exception('Failed to create ZIP');

      if (!mounted) return;
      final tempDir = await getTemporaryDirectory();
      final zipFile = File(
          '${tempDir.path}/imagemaster_bulk_${DateTime.now().millisecondsSinceEpoch}.zip');
      await zipFile.writeAsBytes(zipBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(zipFile.path)],
          text: 'Bulk processed images (${successfulResults.length} files)',
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✓ ZIP file ready to share!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error creating ZIP: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showExportOptions() {
    final readyCount = _processedResults.values.where((f) => f != null).length;
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Export Options',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading:
                  const Icon(Iconsax.gallery, color: DesignTokens.primaryBlue),
              title: const Text('Save All to Gallery'),
              subtitle: Text('$readyCount images'),
              onTap: () {
                Navigator.pop(context);
                AdManager().showInterstitialAd(onComplete: _saveAllToGallery);
              },
            ),
            ListTile(
              leading:
                  const Icon(Iconsax.archive, color: DesignTokens.primaryBlue),
              title: const Text('Export as ZIP'),
              subtitle: const Text('Create shareable ZIP file'),
              onTap: () {
                Navigator.pop(context);
                AdManager().showInterstitialAd(onComplete: _exportAsZip);
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
              onPressed: () => setState(() {
                _selectedImages.clear();
                _processedResults.clear();
              }),
            ),
        ],
      ),
      body: _selectedImages.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                const BannerAdWidget(),
                // ── FIX 13: Grid uses const delegate & RepaintBoundary ──────
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _selectedImages.length,
                    // ── FIX 14: addAutomaticKeepAlives false = less memory ──
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    itemBuilder: (context, index) {
                      final xFile = _selectedImages[index];
                      final isProcessed =
                          _processedResults.containsKey(xFile.name);
                      final hasSucceeded =
                          _processedResults[xFile.name] != null;

                      // ── FIX 15: Extracted to const-friendly widget ──────
                      return ImageGridTile(
                        path: xFile.path,
                        isProcessed: isProcessed,
                        hasSucceeded: hasSucceeded,
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration(context),
                  child: Column(
                    children: [
                      if (_isProcessing) ...[
                        LinearProgressIndicator(value: _progress),
                        const SizedBox(height: 8),
                        Text('${(_progress * 100).toInt()}% Complete'),
                        const SizedBox(height: 16),
                      ],
                      Column(
                        // Vertical stacking for column-style UI
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Quality',
                                      style: TextStyle(fontSize: 12)),
                                  const Text('100%',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              Slider(
                                value: _settings.quality,
                                min: 10,
                                max: 100,
                                divisions: 9,
                                label: '${_settings.quality.toInt()}%',
                                onChanged: _isProcessing
                                    ? null
                                    : (value) => setState(() {
                                          _settings = _settings.copyWith(
                                              quality: value);
                                        }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16), // Vertical spacing
                          _buildScaleControl(
                            value: _settings.scalePercent,
                            enabled: !_isProcessing,
                            onChanged: (value) => setState(() {
                              _settings =
                                  _settings.copyWith(scalePercent: value);
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          label: _processedResults.isEmpty
                              ? 'Process All (${_selectedImages.length})'
                              : 'Results Ready',
                          icon: _processedResults.isEmpty
                              ? Iconsax.cpu
                              : Iconsax.tick_circle,
                          onPressed: _isProcessing
                              ? () {}
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
    return Column(
      children: [
        const BannerAdWidget(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.grid_5, size: 80, color: Colors.grey),
                const SizedBox(height: 24),
                const Text('Bulk Image Processing',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Select up to 50 images to process at once',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => AdManager()
                      .showInterstitialAd(onComplete: _pickMultipleImages),
                  icon: const Icon(Iconsax.add),
                  label: const Text('Select Images'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScaleControl({
    required double value,
    required ValueChanged<double> onChanged,
    bool enabled = true,
  }) {
    const double minScale = 10;
    const double maxScale = 200;
    const double step = 5;

    return Column(
      children: [
        const Text('Scale', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _scaleButton(
              icon: Icons.remove_rounded,
              onTap: (enabled && value > minScale)
                  ? () => setState(() {
                        _settings = _settings.copyWith(
                          scalePercent:
                              (value - step).clamp(minScale, maxScale),
                        );
                      })
                  : null,
            ),
            const SizedBox(width: 4),
            Text('KB',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500)),
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DesignTokens.primaryBlue.withValues(alpha: 0.85),
                      DesignTokens.primaryBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '${value.toInt()}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1),
                ),
              ),
            ),
            Text('MB',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500)),
            const SizedBox(width: 4),
            _scaleButton(
              icon: Icons.add_rounded,
              onTap: (enabled && value < maxScale)
                  ? () => setState(() {
                        _settings = _settings.copyWith(
                          scalePercent:
                              (value + step).clamp(minScale, maxScale),
                        );
                      })
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: DesignTokens.primaryBlue,
            inactiveTrackColor: DesignTokens.primaryBlue.withValues(alpha: 0.2),
            thumbColor: DesignTokens.primaryBlue,
            overlayColor: DesignTokens.primaryBlue.withValues(alpha: 0.15),
            disabledActiveTrackColor: Colors.grey.shade400,
            disabledThumbColor: Colors.grey.shade400,
          ),
          child: Slider(
              value: value,
              min: minScale,
              max: maxScale,
              onChanged: enabled ? onChanged : null),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('10%',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            Text('100%',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            Text('200%',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
          ],
        ),
      ],
    );
  }

  Widget _scaleButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null
              ? DesignTokens.primaryBlue.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: onTap != null
                ? DesignTokens.primaryBlue.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(icon,
            size: 18,
            color: onTap != null
                ? DesignTokens.primaryBlue
                : Colors.grey.shade400),
      ),
    );
  }
}


// ── Isolate helpers (must be top-level or static) ────────────────────────────

class _ZipArgs {
  final List<String> filePaths;
  final String extension;
  const _ZipArgs({required this.filePaths, required this.extension});
}

/// Builds the ZIP archive in an isolate. Returns raw bytes or null.
Future<List<int>?> _buildZipIsolate(_ZipArgs args) async {
  try {
    final archive = Archive();
    for (int i = 0; i < args.filePaths.length; i++) {
      final bytes = await File(args.filePaths[i]).readAsBytes();
      final fileName = 'image_${i + 1}.${args.extension}';
      archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
    }
    return ZipEncoder().encode(archive);
  } catch (_) {
    return null;
  }
}

