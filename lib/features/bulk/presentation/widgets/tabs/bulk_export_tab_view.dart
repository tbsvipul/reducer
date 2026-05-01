import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/features/bulk/presentation/controllers/bulk_image_controller.dart';
import 'package:reducer/features/bulk/presentation/widgets/image_grid_tile.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:reducer/core/utils/file_utils.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class BulkExportTabView extends StatelessWidget {
  final BulkImageState state;
  final VoidCallback onProcess;
  final VoidCallback onSaveAll;
  final VoidCallback onExportZip;

  const BulkExportTabView({
    super.key,
    required this.state,
    required this.onProcess,
    required this.onSaveAll,
    required this.onExportZip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasProcessed = state.processedResults.isNotEmpty;

    return Column(
      children: [
        // Summary Section (Visible after processing)
        if (hasProcessed && !state.isProcessing)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.lg.w,
              vertical: AppDimensions.sm.h,
            ),
            child: Container(
              padding: EdgeInsets.all(AppDimensions.md.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1.r,
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    l10n.totalOriginal,
                    FileUtils.formatBytesDetailed(state.totalOriginalSize),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  _buildSummaryRow(
                    context,
                    l10n.totalCompressed,
                    FileUtils.formatBytesDetailed(state.totalCompressedSize),
                    valueColor: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  _buildSummaryRow(
                    context,
                    l10n.spaceSaved,
                    '${state.totalOriginalSize > 0 ? ((state.totalOriginalSize - state.totalCompressedSize) / state.totalOriginalSize * 100).toInt() : 0}%',
                    valueColor: AppColors.success,
                  ),
                ],
              ),
            ),
          ),

        // Progress Overlay (Only visible during processing)
        if (state.isProcessing)
          Container(
            padding: EdgeInsets.all(AppDimensions.lg.r),
            color: AppColors.primary.withValues(alpha: 0.05),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.processingProgress(state.selectedImages.length),
                      style: AppTextStyles.labelMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold, fontSize: 13.sp),
                    ),
                    Text(
                      '${(state.progress * 100).toInt()}%',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.md.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXs.r),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 8.h,
                  ),
                ),
              ],
            ),
          ),

        Expanded(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.md.r),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppDimensions.sm.h,
                crossAxisSpacing: AppDimensions.sm.w,
              ),
              itemCount: state.selectedImages.length,
              itemBuilder: (context, index) {
                final xFile = state.selectedImages[index];
                final isProcessed = state.processedResults.containsKey(
                  xFile.name,
                );
                final hasSucceeded = state.processedResults[xFile.name] != null;
                return ImageGridTile(
                  path: xFile.path,
                  isProcessed: isProcessed,
                  hasSucceeded: hasSucceeded,
                );
              },
            ),
          ),
        ),

        // Bottom Actions
        if (hasProcessed && !state.isProcessing)
          Container(
            padding: EdgeInsets.all(AppDimensions.lg.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: AppDimensions.md.r,
                  offset: Offset(0, -2.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSaveAll,
                    icon: Icon(Iconsax.gallery, size: AppDimensions.iconSm.r),
                    label: Text(
                      l10n.saveAll,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.lg.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd.r,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.md.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onExportZip,
                    icon: Icon(Iconsax.archive, size: AppDimensions.iconSm.r),
                    label: Text(
                      l10n.zip,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.lg.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd.r,
                        ),
                      ),
                      side: BorderSide(color: AppColors.primary, width: 1.r),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(context).copyWith(
            color: isDark
                ? AppColors.onDarkSurfaceVariant
                : AppColors.onLightSurfaceVariant,
            fontSize: 11.sp,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color:
                valueColor ??
                (isDark ? AppColors.onDarkSurface : AppColors.onLightSurface),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  // Replaced by FileUtils.formatBytesDetailed
}
