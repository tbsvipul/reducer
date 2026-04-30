import 'package:flutter/material.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';


import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormatTabView extends StatelessWidget {
  final ImageSettings settings;
  final ValueChanged<ImageSettings> onSettingsChanged;

  const FormatTabView({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.lg.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            context,
            title: 'EXPORT FORMAT',
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppDimensions.md.h,
              crossAxisSpacing: AppDimensions.md.w,
              childAspectRatio: 2.2,
              children: ImageFormat.values.map((format) {
                final isSelected = settings.format == format;
                return _buildFormatOption(context, format, isSelected);
              }).toList(),
            ),
          ),
          SizedBox(height: AppDimensions.xl.h),
          _buildCard(
            context,
            title: 'FORMAT QUALITY',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Smaller file', style: AppTextStyles.labelSmall(context).copyWith(color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant, fontSize: 11.sp)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${settings.quality.toInt()}%',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.sp),
                      ),
                    ),
                    Text('Better quality', style: AppTextStyles.labelSmall(context).copyWith(color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant, fontSize: 11.sp)),
                  ],
                ),
                Slider(
                  value: settings.quality,
                  min: 1,
                  max: 100,
                  activeColor: AppColors.primary,
                  inactiveColor: isDark ? Colors.white10 : AppColors.lightBorder,
                  onChanged: (v) => onSettingsChanged(settings.copyWith(quality: v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(BuildContext context, ImageFormat format, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String sub = '';
    switch (format) {
      case ImageFormat.jpeg: sub = 'Lossy · Web'; break;
      case ImageFormat.png: sub = 'Lossless · Alpha'; break;
      case ImageFormat.webp: sub = 'Modern · Small'; break;
      case ImageFormat.bmp: sub = 'Old · Basic'; break;
    }

    return GestureDetector(
      onTap: () => onSettingsChanged(settings.copyWith(format: format)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1.5.r,
          ),
          boxShadow: isSelected && !isDark ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 8.r)] : null,
        ),
        child: Row(
          children: [
            Container(
              height: 12.r,
              width: 12.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    format.name,
                    style: AppTextStyles.titleMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.onDarkSurface : AppColors.onLightSurface),
                    ),
                  ),
                  Text(
                    sub,
                    style: AppTextStyles.labelSmall(context).copyWith(
                      color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
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
            color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: AppDimensions.sm.h),
        Container(
          padding: EdgeInsets.all(AppDimensions.lg.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.r),
          ),
          child: child,
        ),
      ],
    );
  }
}

