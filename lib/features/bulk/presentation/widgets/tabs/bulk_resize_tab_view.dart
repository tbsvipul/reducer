import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BulkResizeTabView extends StatelessWidget {
  final ImageSettings settings;
  final ValueChanged<ImageSettings> onSettingsChanged;

  const BulkResizeTabView({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.lg.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoNote(context, l10n.bulkResizeNote),
          SizedBox(height: AppDimensions.lg.h),

          _buildCard(
            context,
            title: l10n.scalePercentRecommended.toUpperCase(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.smaller,
                      style: AppTextStyles.labelSmall(
                        context,
                      ).copyWith(fontSize: 11.sp),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.md.w,
                        vertical: AppDimensions.xs.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd.r,
                        ),
                      ),
                      child: Text(
                        '${settings.scalePercent.toInt()}%',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Text(
                      l10n.original,
                      style: AppTextStyles.labelSmall(
                        context,
                      ).copyWith(fontSize: 11.sp),
                    ),
                  ],
                ),
                Slider(
                  value: settings.scalePercent,
                  min: 1,
                  max: 100,
                  activeColor: AppColors.primary,
                  onChanged: (v) => onSettingsChanged(
                    settings.copyWith(
                      scalePercent: v,
                      width: null, // Clear custom size when scaling
                      height: null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppDimensions.lg.h),

          _buildCard(
            context,
            title: l10n.fixedDimensionsExpert.toUpperCase(),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDimensionField(
                        l10n.width,
                        settings.width?.toInt().toString() ?? '',
                        (v) => onSettingsChanged(
                          settings.copyWith(width: double.tryParse(v)),
                        ),
                        isDark,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.md,
                      ),
                      child: Text(
                        '×',
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: isDark
                              ? AppColors.onDarkSurfaceVariant
                              : AppColors.onLightSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildDimensionField(
                        l10n.height,
                        settings.height?.toInt().toString() ?? '',
                        (v) => onSettingsChanged(
                          settings.copyWith(height: double.tryParse(v)),
                        ),
                        isDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.lg.h),
                Row(
                  children: [
                    Icon(
                      Iconsax.link,
                      size: AppDimensions.iconSm.r,
                      color: isDark
                          ? AppColors.onDarkSurfaceVariant
                          : AppColors.onLightSurfaceVariant,
                    ),
                    SizedBox(width: AppDimensions.sm.w),
                    Text(
                      l10n.lockAspectRatio,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.onDarkSurfaceVariant
                            : AppColors.onLightSurfaceVariant,
                        fontSize: 13.sp,
                      ),
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: settings.lockAspect,
                      activeTrackColor: AppColors.primary,
                      onChanged: (v) =>
                          onSettingsChanged(settings.copyWith(lockAspect: v)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(AppDimensions.md.r),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.r,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: AppDimensions.iconSm.r,
            color: AppColors.primary,
          ),
          SizedBox(width: AppDimensions.sm.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelSmall(context).copyWith(
                color: isDark ? AppColors.onDarkSurface : AppColors.primary,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionField(
    String label,
    String value,
    ValueChanged<String> onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: isDark
                ? AppColors.onDarkSurfaceVariant
                : AppColors.onLightSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppDimensions.xs.h),
        TextField(
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: isDark ? AppColors.onDarkSurface : AppColors.onLightSurface,
            fontSize: 14.sp,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
              borderSide: isDark
                  ? const BorderSide(color: AppColors.darkBorder)
                  : const BorderSide(color: AppColors.lightBorder),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
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
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
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
