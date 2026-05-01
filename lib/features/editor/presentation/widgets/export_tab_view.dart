import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:reducer/core/utils/file_utils.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExportTabView extends StatelessWidget {
  final Uint8List? processedImageBytes;
  final ImageSettings settings;
  final int originalSize;
  final int originalWidth;
  final int originalHeight;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const ExportTabView({
    super.key,
    required this.processedImageBytes,
    required this.settings,
    required this.originalSize,
    required this.originalWidth,
    required this.originalHeight,
    required this.onSave,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final processedSize = processedImageBytes?.length ?? 0;
    final savedPercent = originalSize > 0
        ? ((originalSize - processedSize) / originalSize * 100).toInt()
        : 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.lg.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            context,
            title: l10n.resultSummary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  FileUtils.formatFileSizeDetailed(processedSize),
                  l10n.output,
                ),
                _buildSummaryItem(
                  context,
                  '$savedPercent%',
                  l10n.saved,
                  color: AppColors.primary,
                ),
                _buildSummaryItem(
                  context,
                  settings.format.name,
                  l10n.formatLabel,
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.lg.h),
          Container(
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                _buildStatRow(
                  context,
                  l10n.originalSize,
                  FileUtils.formatFileSize(originalSize),
                ),
                _buildStatRow(
                  context,
                  l10n.compressed,
                  FileUtils.formatFileSize(processedSize),
                  valueColor: AppColors.primary,
                ),
                _buildStatRow(
                  context,
                  l10n.dimensions,
                  '${settings.width?.toInt() ?? originalWidth} × ${settings.height?.toInt() ?? originalHeight}',
                ),
                _buildStatRow(
                  context,
                  l10n.format,
                  settings.format.name,
                  isLast: true,
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.xl2.h),

          if (processedImageBytes != null) ...[
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l10n.saveToGallery,
                    icon: Iconsax.save_2,
                    onPressed: onSave,
                    isFullWidth: true,
                  ),
                ),
                SizedBox(width: AppDimensions.md.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShare,
                    icon: Icon(Iconsax.share, size: 20.r),
                    label: Text(
                      l10n.share,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(color: AppColors.primary, width: 1.r),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(AppDimensions.xl.r),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1.r,
                ),
              ),
              child: Column(
                children: [
                  Icon(Iconsax.flash, color: AppColors.primary, size: 32.r),
                  SizedBox(height: 12.h),
                  Text(
                    l10n.readyToExport,
                    style: AppTextStyles.titleMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10n.applyChangesMessage,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall(context).copyWith(
                      color: isDark
                          ? AppColors.onDarkSurfaceVariant
                          : AppColors.onLightSurfaceVariant,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String value,
    String label, {
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge(context).copyWith(
            fontWeight: FontWeight.w800,
            color:
                color ??
                (isDark ? AppColors.onDarkSurface : AppColors.onLightSurface),
            fontSize: 20.sp,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall(context).copyWith(
            color: isDark
                ? AppColors.onDarkSurfaceVariant
                : AppColors.onLightSurfaceVariant,
            letterSpacing: 1.w,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? AppColors.onDarkSurfaceVariant
                  : AppColors.onLightSurfaceVariant,
              fontSize: 13.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  valueColor ??
                  (isDark ? AppColors.onDarkSurface : AppColors.onLightSurface),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelSmall(context).copyWith(
            letterSpacing: 1.2.w,
            fontWeight: FontWeight.w800,
            color: isDark
                ? AppColors.onDarkSurfaceVariant
                : AppColors.onLightSurfaceVariant,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: AppDimensions.sm.h),
        Container(
          padding: EdgeInsets.all(AppDimensions.lg.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.r,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}
