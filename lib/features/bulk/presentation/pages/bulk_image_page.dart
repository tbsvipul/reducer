import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/common/widgets/app_snackbar.dart';
import 'package:reducer/common/widgets/app_empty_state.dart';
import 'package:reducer/common/presentation/widgets/ads/banner_ad_widget.dart';
import 'package:reducer/common/presentation/widgets/ads/native_ad_widget.dart';
import 'package:reducer/features/gallery/presentation/controllers/history_controller.dart';
import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/core/utils/thumbnail_generator.dart';
import 'package:reducer/core/services/permission_service.dart';
import 'package:reducer/features/bulk/presentation/controllers/bulk_image_controller.dart';
import 'package:reducer/features/bulk/presentation/widgets/tabs/bulk_compress_tab_view.dart';
import 'package:reducer/features/bulk/presentation/widgets/tabs/bulk_resize_tab_view.dart';
import 'package:reducer/features/bulk/presentation/widgets/tabs/bulk_format_tab_view.dart';
import 'package:reducer/features/bulk/presentation/widgets/tabs/bulk_export_tab_view.dart';
import 'package:reducer/core/services/analytics_service.dart';
import 'package:reducer/features/settings/presentation/controllers/review_controller.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:reducer/core/utils/file_utils.dart';

/// Screen for bulk image processing including compression, resizing, and format conversion.
class BulkImageScreen extends ConsumerStatefulWidget {
  const BulkImageScreen({super.key});

  @override
  ConsumerState<BulkImageScreen> createState() => _BulkImageScreenState();
}

class _BulkImageScreenState extends ConsumerState<BulkImageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // SECTION: Image Selection
  // ─────────────────────────────────────────────

  Future<void> _pickMultipleImages() async {
    if (!mounted) return;
    if (!await PermissionService.instance.ensurePhotosPermission(context)) return;

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty && mounted) {
      final isPro = ref.read(premiumControllerProvider).isPro;
      final selected = isPro ? pickedFiles : pickedFiles.take(50).toList();
      unawaited(ref.read(bulkImageControllerProvider.notifier).selectImages(selected));

      if (!isPro && pickedFiles.length > 50) {
        debugPrint('Limit Warning: ${AppLocalizations.of(context)!.freeUserLimit}');
      }
    }
  }

  // ─────────────────────────────────────────────
  // SECTION: Processing & Actions
  // ─────────────────────────────────────────────

  Future<void> _handleProcess() async {
    final isPro = ref.read(premiumControllerProvider).isPro;
    final l10n = AppLocalizations.of(context)!;
    await ref.read(bulkImageControllerProvider.notifier).processAll(isPro, l10n);

    final state = ref.read(bulkImageControllerProvider);
    final successful = state.processedResults.values.where((f) => f != null).cast<File>().toList();
    if (successful.isNotEmpty) {
      await _saveToHistory(successful, state);
    }
  }

  Future<void> _saveAllToGallery(BulkImageState state) async {
    final successful = state.processedResults.values.where((f) => f != null).cast<File>().toList();
    if (successful.isEmpty) return;

    try {
      await Future.wait(successful.map((f) => Gal.putImage(f.path, album: 'Reducer')));
      if (mounted) {
        AppSnackbar.show(context, AppLocalizations.of(context)!.savedXImages(successful.length));
      }
    } catch (e) {
      if (mounted) debugPrint('Save Error: $e');
    }
  }

  Future<void> _exportAsZip(BulkImageState state) async {
    final successful = state.processedResults.values.where((f) => f != null).cast<File>().toList();
    if (successful.isEmpty) return;

    try {
      final zipBytes = await compute(_buildZipIsolate, _ZipArgs(
        filePaths: successful.map((f) => f.path).toList(),
        extension: state.settings.format.extension,
      ));

      if (zipBytes == null) throw Exception('ZIP creation failed');

      final tempDir = await getTemporaryDirectory();
      final zipFile = File('${tempDir.path}/bulk_${DateTime.now().millisecondsSinceEpoch}.zip');
      await zipFile.writeAsBytes(zipBytes);

      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(zipFile.path)],
          subject: AppLocalizations.of(context)!.processedImages,
        ),
      );
    } catch (e) {
      if (mounted) debugPrint('Zip Error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // SECTION: Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bulkImageControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.selectedImages.isEmpty) {
      return _buildEmptyState(context);
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l10n.bulkStudio),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.trash),
            onPressed: () => ref.read(bulkImageControllerProvider.notifier).clear(),
          ),
        ],
      ),
      body: Column(
        children: [
          const BannerAdWidget(),
          _buildTabBar(isDark, l10n),
          if (state.totalCompressedSize > 0) _buildStatsBanner(isDark, l10n, state),
          _buildTabContent(state),
          if (state.processedResults.isEmpty || state.isProcessing) _buildProcessFooter(isDark, l10n, state),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg.w, vertical: AppDimensions.sm.h),
      child: Container(
        height: 52.h,
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(26.r),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: isDark ? Colors.white : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
          dividerColor: Colors.transparent,
          labelPadding: EdgeInsets.zero,
          labelStyle: AppTextStyles.labelMedium(context).copyWith(fontWeight: FontWeight.bold, fontSize: 12.sp),
          tabs: [
            Tab(text: l10n.compress),
            Tab(text: l10n.resize),
            Tab(text: l10n.format),
            Tab(text: l10n.export),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBanner(bool isDark, AppLocalizations l10n, BulkImageState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg.w),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Icon(Iconsax.chart_21, size: 16.r, color: Colors.white),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.batchOptimizationComplete,
                    style: AppTextStyles.labelSmall(context).copyWith(
                      letterSpacing: 1.1.w,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        FileUtils.formatBytes(state.totalOriginalSize),
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
                          fontSize: 13.sp,
                        ),
                      ),
                      Icon(Icons.arrow_right_alt, size: 16.r, color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant),
                      Text(
                        FileUtils.formatBytes(state.totalCompressedSize),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                      ),
                      const Spacer(),
                      Text(
                        '${((1 - (state.totalCompressedSize / state.totalOriginalSize)) * 100).toStringAsFixed(1)}% ${l10n.smaller}',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(BulkImageState state) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          BulkCompressTabView(
            settings: state.settings,
            onSettingsChanged: (s) => ref.read(bulkImageControllerProvider.notifier).updateSettings(s),
          ),
          BulkResizeTabView(
            settings: state.settings,
            onSettingsChanged: (s) => ref.read(bulkImageControllerProvider.notifier).updateSettings(s),
          ),
          BulkFormatTabView(
            settings: state.settings,
            onSettingsChanged: (s) => ref.read(bulkImageControllerProvider.notifier).updateSettings(s),
          ),
          BulkExportTabView(
            state: state,
            onProcess: _handleProcess,
            onSaveAll: () => AdManager().showInterstitialAd(onComplete: () => _saveAllToGallery(state)),
            onExportZip: () => AdManager().showInterstitialAd(onComplete: () => _exportAsZip(state)),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessFooter(bool isDark, AppLocalizations l10n, BulkImageState state) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: state.isProcessing
              ? l10n.processingProgress((state.progress * 100).toInt())
              : l10n.startBatchProcessing,
          icon: state.isProcessing ? null : Iconsax.flash,
          isLoading: state.isProcessing,
          onPressed: state.isProcessing ? null : _handleProcess,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bulkStudio)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.pagePadding.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BannerAdWidget(),
              SizedBox(height: 40.h),
              AppEmptyState(
                title: l10n.batchProcessing,
                subtitle: l10n.batchDescription,
                icon: Iconsax.grid_5,
                actionLabel: l10n.selectMultipleImages,
                onAction: () => AdManager().showInterstitialAd(onComplete: _pickMultipleImages),
              ),
              SizedBox(height: 30.h),
              const NativeAdWidget(size: NativeAdSize.medium),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SECTION: History
  // ─────────────────────────────────────────────

  Future<void> _saveToHistory(List<File> results, BulkImageState state) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final sessionId = const Uuid().v4();
      final sessionRelativeDir = 'history/bulk_$sessionId';
      final sessionDir = Directory(p.join(appDir.path, sessionRelativeDir));
      await sessionDir.create(recursive: true);

      final persistentRelativePaths = <String>[];
      for (final file in results) {
        final fileName = p.basename(file.path);
        final relPath = '$sessionRelativeDir/$fileName';
        persistentRelativePaths.add(relPath);
        await file.copy(p.join(appDir.path, relPath));
      }

      final thumbBytes = await ThumbnailGenerator.generateSmallThumbnail(XFile(results.first.path));
      if (thumbBytes == null) return;

      final thumbRelPath = 'history/thumb_bulk_$sessionId.jpg';
      await File(p.join(appDir.path, thumbRelPath)).writeAsBytes(thumbBytes);

      final historyItem = HistoryItem(
        id: sessionId,
        thumbnailPath: thumbRelPath,
        originalPath: state.selectedImages.first.path,
        settings: state.settings,
        timestamp: DateTime.now(),
        originalSize: state.totalOriginalSize,
        processedSize: state.totalCompressedSize,
        isBulk: true,
        itemCount: results.length,
        processedPaths: persistentRelativePaths,
      );

      await ref.read(historyControllerProvider.notifier).addItem(historyItem);

      unawaited(ref.read(analyticsServiceProvider).logCompressionSuccess(
            type: 'bulk',
            originalSize: state.totalOriginalSize,
            compressedSize: state.totalCompressedSize,
            imageCount: results.length,
          ));
      unawaited(ref.read(reviewControllerProvider).recordSuccessfulSave());
    } catch (e) {
      debugPrint('Error saving bulk history: $e');
    }
  }
}

class _ZipArgs {
  final List<String> filePaths;
  final String extension;
  const _ZipArgs({required this.filePaths, required this.extension});
}

Future<List<int>?> _buildZipIsolate(_ZipArgs args) async {
  try {
    final archive = Archive();
    for (int i = 0; i < args.filePaths.length; i++) {
      final bytes = await File(args.filePaths[i]).readAsBytes();
      archive.addFile(ArchiveFile('image_${i + 1}.${args.extension}', bytes.length, bytes));
    }
    return ZipEncoder().encode(archive);
  } catch (_) {
    return null;
  }
}

