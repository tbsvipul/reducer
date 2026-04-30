import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/core/theme/app_theme.dart';
import 'package:reducer/core/services/permission_service.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/l10n/app_localizations.dart';

import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/common/widgets/app_dialog.dart';
import 'package:reducer/common/presentation/widgets/ads/banner_ad_widget.dart';

import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/features/exif/presentation/providers/exif_providers.dart';

/// Screen for removing EXIF metadata from images to protect privacy.
class ExifEraserScreen extends ConsumerStatefulWidget {
  const ExifEraserScreen({super.key});

  @override
  ConsumerState<ExifEraserScreen> createState() => _ExifEraserScreenState();
}

class _ExifEraserScreenState extends ConsumerState<ExifEraserScreen> {
  XFile? _selectedImage;
  bool _isProcessing = false;

  // ─────────────────────────────────────────────
  // SECTION: Actions
  // ─────────────────────────────────────────────

  Future<void> _pickImage() async {
    if (!await PermissionService.instance.ensurePhotosPermission(context)) {
      debugPrint('Permission Error: Photos permission required');
      return;
    }

    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      debugPrint('Gallery Error: $e');
    }
  }

  Future<void> _cleanMetadata() async {
    if (_selectedImage == null) return;

    final isPro = ref.read(premiumControllerProvider).isPro;
    final credits = ref.read(exifCreditProvider).availableCredits;

    if (!isPro && credits <= 0) {
      if (mounted) unawaited(context.push('/premium'));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      if (!await PermissionService.instance.ensurePhotosPermission(context)) {
        debugPrint('Permission Error: Storage permission required');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/clean_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        _selectedImage!.path,
        targetPath,
        quality: 95,
        keepExif: false,
      );

      if (result != null) {
        await Gal.putImage(result.path, album: 'Reducer');

        if (mounted) {
          if (!isPro) {
            await ref.read(exifCreditProvider.notifier).useCredit();
          }
          _showSuccessDialog();
        }
      }
    } catch (e) {
      debugPrint('Metadata Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context)!;
    AppDialog.show(
      context,
      title: l10n.success,
      message: l10n.exifSuccessMessage,
      type: AppDialogType.success,
      customActions: [
        AppButton(
          label: l10n.viewHistory,
          onPressed: () {
            Navigator.pop(context);
            setState(() => _selectedImage = null);
            context.go('/gallery');
          },
        ),
        AppButton(
          label: l10n.done,
          style: AppButtonStyle.outline,
          onPressed: () {
            Navigator.pop(context);
            setState(() => _selectedImage = null);
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SECTION: Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final creditState = ref.watch(exifCreditProvider);
    final isPro = ref.watch(premiumControllerProvider).isPro;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exifEraser),
        centerTitle: false,
        actions: [
          if (!isPro && !creditState.isLoading) _buildCreditBadge(creditState, l10n),
        ],
      ),
      body: Column(
        children: [
          const BannerAdWidget(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppDimensions.pagePadding.r),
              child: Column(
                children: [
                  _buildPrivacyInfo(context, l10n),
                  SizedBox(height: AppDimensions.xl2.h),
                  if (_selectedImage == null)
                    _buildUploadPlaceholder(l10n)
                  else
                    _buildImagePreview(),
                  SizedBox(height: AppDimensions.xl2.h),
                  if (_selectedImage != null)
                    AppButton(
                      label: _isProcessing ? l10n.cleaning : l10n.cleanAndSave,
                      icon: Iconsax.shield_tick,
                      isLoading: _isProcessing,
                      onPressed: () => AdManager().showInterstitialAd(
                        onComplete: _cleanMetadata,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditBadge(ExifCreditState creditState, AppLocalizations l10n) {
    final color = creditState.availableCredits > 0 ? AppColors.success : AppColors.error;
    return Center(
      child: Container(
        margin: EdgeInsets.only(right: AppDimensions.md.w),
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.sm.w, vertical: AppDimensions.xs2.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
          border: Border.all(color: color, width: 0.5.w),
        ),
        child: Text(
          l10n.freeTrialLeft(creditState.availableCredits),
          style: AppTextStyles.badgeLabel(context).copyWith(color: color),
        ),
      ),
    );
  }

  Widget _buildPrivacyInfo(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.xl.r),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        children: [
          Icon(Iconsax.shield_tick, size: 64.r, color: AppColors.primary),
          SizedBox(height: AppDimensions.md.h),
          Text(
            l10n.privacyFirst,
            style: AppTextStyles.titleLarge(context),
          ),
          SizedBox(height: AppDimensions.xs.h),
          Text(
            l10n.privacyFirstDescription,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(context),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.add_square, size: 48.r, color: AppColors.primary),
            SizedBox(height: AppDimensions.md.h),
            Text(
              l10n.tapToSelectImage,
              style: AppTextStyles.titleMedium(context).copyWith(color: AppColors.primary),
            ),
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
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl.r),
              child: Image.file(
                File(_selectedImage!.path),
                height: 300.h,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            IconButton(
              icon: Icon(Iconsax.close_circle, color: AppColors.error, size: 24.r),
              onPressed: () => setState(() => _selectedImage = null),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.md.h),
        Text(
          _selectedImage!.name,
          style: AppTextStyles.bodySmall(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

