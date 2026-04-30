import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/core/services/permission_service.dart';
import 'package:reducer/core/services/analytics_service.dart';
import 'package:reducer/core/utils/file_utils.dart';
import 'package:reducer/core/utils/image_validator.dart';
import 'package:reducer/l10n/app_localizations.dart';

import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/common/widgets/app_snackbar.dart';
import 'package:reducer/common/widgets/app_empty_state.dart';
import 'package:reducer/common/presentation/widgets/ads/banner_ad_widget.dart';
import 'package:reducer/common/presentation/widgets/ads/native_ad_widget.dart';

import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:reducer/features/gallery/presentation/controllers/history_controller.dart';
import 'package:reducer/features/editor/presentation/controllers/single_image_controller.dart';
import 'package:reducer/features/editor/presentation/widgets/compress_tab_view.dart';
import 'package:reducer/features/editor/presentation/widgets/resize_tab_view.dart';
import 'package:reducer/features/editor/presentation/widgets/format_tab_view.dart';
import 'package:reducer/features/editor/presentation/widgets/export_tab_view.dart';
import 'package:reducer/features/settings/presentation/controllers/review_controller.dart';

/// Screen for editing and optimizing a single image.
class SingleImageScreen extends ConsumerStatefulWidget {
  const SingleImageScreen({super.key});

  @override
  ConsumerState<SingleImageScreen> createState() => _SingleImageScreenState();
}

class _SingleImageScreenState extends ConsumerState<SingleImageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showOriginal = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        ref.read(singleImageTabIndexProvider.notifier).state = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // SECTION: Processing & Actions
  // ─────────────────────────────────────────────

  Future<void> _handleProcess() async {
    await AdManager().showInterstitialAd(onComplete: () async {
      await ref.read(singleImageControllerProvider.notifier).processFinalImage();
      if (mounted) _tabController.animateTo(3);
    });
  }

  Future<void> _saveToGallery(SingleImageState state) async {
    final processedBytes = state.processedImageBytes;
    final previewBytes = state.previewThumbnail ?? state.originalThumbnail;
    if (processedBytes == null || previewBytes == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;

    await AdManager().showInterstitialAd(onComplete: () async {
      try {
        if (!mounted) return;
        final ok = await PermissionService.instance.ensurePhotosPermission(context);
        if (!ok || !mounted) return;

        final timestampMs = DateTime.now().millisecondsSinceEpoch;
        final appDir = await getApplicationDocumentsDirectory();
        final thumbRelativePath = 'history/thumb_$timestampMs.jpg';
        final processedRelativePath = 'history/proc_$timestampMs.${state.settings.format.extension}';

        final thumbFile = File(p.join(appDir.path, thumbRelativePath));
        final procFile = File(p.join(appDir.path, processedRelativePath));

        await Directory(p.dirname(thumbFile.path)).create(recursive: true);
        await procFile.writeAsBytes(processedBytes);
        await thumbFile.writeAsBytes(previewBytes);

        await Gal.putImage(procFile.path, album: 'Reducer');
        if (!mounted) return;

        final historyItem = HistoryItem(
          id: const Uuid().v4(),
          thumbnailPath: thumbRelativePath,
          processedPaths: [processedRelativePath],
          originalPath: state.originalFile?.path ?? '',
          settings: state.settings,
          timestamp: DateTime.now(),
          originalSize: state.originalSize,
          processedSize: processedBytes.length,
        );

        await ref.read(historyControllerProvider.notifier).addItem(historyItem);
        if (!mounted) return;

        unawaited(ref.read(analyticsServiceProvider).logCompressionSuccess(
              type: 'single',
              originalSize: state.originalSize,
              compressedSize: processedBytes.length,
              imageCount: 1,
            ));
        unawaited(ref.read(reviewControllerProvider).recordSuccessfulSave());

        if (mounted) {
          AppSnackbar.show(context, l10n.compressionSuccess);
        }
      } catch (e) {
        if (mounted) debugPrint('Save Error: $e');
      }
    });
  }

  Future<void> _shareImage(SingleImageState state) async {
    if (state.processedImageBytes == null || !mounted) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}.${state.settings.format.extension}');
      await file.writeAsBytes(state.processedImageBytes!);

      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: l10n.shareWithReducer,
          ),
        );
      }
    } catch (e) {
      if (mounted) debugPrint('Share Error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // SECTION: Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(singleImageControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.originalThumbnail == null) {
      return _buildEmptyState(context);
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            const BannerAdWidget(),
            _buildPreviewHeader(state, isDark, l10n),
            _buildTabBar(isDark, l10n),
            _buildTabContent(state),
            _buildProcessFooter(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewHeader(SingleImageState state, bool isDark, AppLocalizations l10n) {
    final displayImage = _showOriginal ? state.originalThumbnail! : (state.previewThumbnail ?? state.originalThumbnail!);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(AppDimensions.lg.r),
      padding: EdgeInsets.all(AppDimensions.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
                child: Image.memory(
                  displayImage,
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  cacheHeight: 360,
                ),
              ),
              Positioned(
                top: AppDimensions.sm.h,
                right: AppDimensions.sm.w,
                child: GestureDetector(
                  onTap: () => setState(() => _showOriginal = !_showOriginal),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.md.w, vertical: AppDimensions.xs.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.87),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                      border: Border.all(color: _showOriginal ? AppColors.primary : Colors.white.withValues(alpha: 0.24)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: AppDimensions.xs.r, color: _showOriginal ? AppColors.warning : AppColors.primary),
                        SizedBox(width: AppDimensions.xs.w),
                        Text(
                          _showOriginal ? l10n.showAfter : l10n.showBefore,
                          style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.xl.h),
          Text(
            '${state.originalWidth} × ${state.originalHeight} · ${FileUtils.formatFileSize(state.originalSize)}',
            style: TextStyle(
              color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg.w, vertical: AppDimensions.sm.h),
      child: Container(
        height: 52.h,
        padding: EdgeInsets.all(AppDimensions.xs.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl2.r),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl.r),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: AppDimensions.xs.r,
                  offset: Offset(0, 2.h),
                ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: isDark ? Colors.white : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
          dividerColor: Colors.transparent,
          labelPadding: EdgeInsets.zero,
          labelStyle: AppTextStyles.labelMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5.w,
            fontSize: 12.sp,
          ),
          unselectedLabelStyle: AppTextStyles.labelMedium(context).copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 12.sp,
          ),
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

  Widget _buildTabContent(SingleImageState state) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          CompressTabView(
            settings: state.settings,
            onSettingsChanged: (s) => ref.read(singleImageControllerProvider.notifier).updateSettings(s),
          ),
          ResizeTabView(
            settings: state.settings,
            originalWidth: state.originalWidth,
            originalHeight: state.originalHeight,
            onSettingsChanged: (s) => ref.read(singleImageControllerProvider.notifier).updateSettings(s),
          ),
          FormatTabView(
            settings: state.settings,
            onSettingsChanged: (s) => ref.read(singleImageControllerProvider.notifier).updateSettings(s),
          ),
          ExportTabView(
            processedImageBytes: state.processedImageBytes,
            settings: state.settings,
            originalSize: state.originalSize,
            originalWidth: state.originalWidth,
            originalHeight: state.originalHeight,
            onSave: () => _saveToGallery(state),
            onShare: () => _shareImage(state),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessFooter(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final tabIndex = ref.watch(singleImageTabIndexProvider);
        if (tabIndex >= 3) return const SizedBox.shrink();

        final isProcessing = ref.watch(singleImageControllerProvider.select((s) => s.isProcessingFinal));

        return Padding(
          padding: EdgeInsets.all(AppDimensions.lg.r),
          child: AppButton(
            label: isProcessing ? l10n.processingDot : l10n.processImage,
            icon: Iconsax.flash,
            isLoading: isProcessing,
            onPressed: isProcessing ? null : _handleProcess,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.pagePadding.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BannerAdWidget(),
              SizedBox(height: 40.h),
              AppEmptyState(
                title: l10n.pickImageToStart,
                subtitle: l10n.pickImageSubtitle,
                icon: Iconsax.image,
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.gallery,
                      icon: Iconsax.gallery,
                      onPressed: () async {
                        final l10nCapture = AppLocalizations.of(context)!;
                        try {
                          await ref.read(singleImageControllerProvider.notifier).pickImage(ImageSource.gallery, l10nCapture);
                        } catch (e) {
                          if (e is ValidationResult && context.mounted) {
                            ImageValidator.showValidationDialog(context, e);
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(width: AppDimensions.md.w),
                  Expanded(
                    child: AppButton(
                      label: l10n.camera,
                      icon: Iconsax.camera,
                      style: AppButtonStyle.outline,
                      onPressed: () async {
                        final l10nCapture = AppLocalizations.of(context)!;
                        try {
                          await ref.read(singleImageControllerProvider.notifier).pickImage(ImageSource.camera, l10nCapture);
                        } catch (e) {
                          if (e is ValidationResult && context.mounted) {
                            ImageValidator.showValidationDialog(context, e);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              const NativeAdWidget(size: NativeAdSize.medium),
            ],
          ),
        ),
      ),
    );
  }
}
