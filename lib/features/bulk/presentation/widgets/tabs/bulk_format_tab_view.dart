import 'package:flutter/material.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BulkFormatTabView extends StatelessWidget {
  final ImageSettings settings;
  final ValueChanged<ImageSettings> onSettingsChanged;

  const BulkFormatTabView({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.lg.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoNote(context, l10n.bulkFormatNote),
          SizedBox(height: AppDimensions.lg.h),
          _buildCard(
            context,
            title: l10n.chooseOutputFormat.toUpperCase(),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppDimensions.md.h,
              crossAxisSpacing: AppDimensions.md.w,
              childAspectRatio: 2.2,
              children: [
                _buildFormatOption(context, ImageFormat.jpeg, 'JPEG', l10n.bestForPhotos),
                _buildFormatOption(context, ImageFormat.png, 'PNG', l10n.bestForGraphics),
                _buildFormatOption(context, ImageFormat.webp, 'WebP', l10n.modernAndSmall),
                _buildFormatOption(context, ImageFormat.bmp, 'BMP', l10n.uncompressed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote(BuildContext context, String text) {
     return Container(
      padding: EdgeInsets.all(AppDimensions.md.r),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: AppDimensions.iconSm.r, color: AppColors.primary),
          SizedBox(width: AppDimensions.sm.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelSmall(context).copyWith(color: AppColors.primary, fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(BuildContext context, ImageFormat format, String title, String subtitle) {
    final isSelected = settings.format == format;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onSettingsChanged(settings.copyWith(format: format)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withValues(alpha: 0.1) 
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 2.r,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg.w, vertical: AppDimensions.sm.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : (isDark ? AppColors.onDarkSurface : AppColors.onLightSurface),
                fontSize: 14.sp,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.sp,
                color: isSelected ? AppColors.primary.withValues(alpha: 0.7) : (isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelSmall(context).copyWith(
            letterSpacing: 1.2.w,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: AppDimensions.sm.h),
        Container(
          padding: EdgeInsets.all(AppDimensions.lg.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.r),
          ),
          child: child,
        ),
      ],
    );
  }
}

