import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';

class ResizeTabView extends StatelessWidget {
  final ImageSettings settings;
  final int originalWidth;
  final int originalHeight;
  final ValueChanged<ImageSettings> onSettingsChanged;

  const ResizeTabView({
    super.key,
    required this.settings,
    required this.originalWidth,
    required this.originalHeight,
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
          _buildCard(
            context,
            title: l10n.customDimensions.toUpperCase(),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDimensionInput(
                        context,
                        l10n.width.toUpperCase(),
                        settings.width?.toInt() ?? originalWidth,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.r,
                        color: isDark
                            ? AppColors.onDarkSurfaceVariant
                            : AppColors.onLightSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: _buildDimensionInput(
                        context,
                        l10n.height.toUpperCase(),
                        settings.height?.toInt() ?? originalHeight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.lg.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.lockAspectRatio,
                          style: AppTextStyles.bodyMedium(
                            context,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          l10n.aspectRatioMaintained,
                          style: AppTextStyles.labelSmall(context).copyWith(
                            color: isDark
                                ? AppColors.onDarkSurfaceVariant
                                : AppColors.onLightSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
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
          SizedBox(height: AppDimensions.xl.h),
          _buildCard(
            context,
            title: l10n.transform.toUpperCase(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.flipHorizontal,
                  style: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                Switch.adaptive(
                  value: settings.flipHorizontal,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) =>
                      onSettingsChanged(settings.copyWith(flipHorizontal: v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionInput(BuildContext context, String label, int value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(context).copyWith(
            fontSize: 10.sp,
            color: isDark
                ? AppColors.onDarkSurfaceVariant
                : AppColors.onLightSurfaceVariant,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: value.toString()),
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.bodyLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (val) {
                    final l10n = AppLocalizations.of(context)!;
                    final newVal = double.tryParse(val);
                    if (newVal != null) {
                      if (label == l10n.width.toUpperCase()) {
                        onSettingsChanged(settings.copyWith(width: newVal));
                      } else {
                        onSettingsChanged(settings.copyWith(height: newVal));
                      }
                    }
                  },
                ),
              ),
              Text(
                'px',
                style: TextStyle(
                  color: isDark
                      ? AppColors.onDarkSurfaceVariant
                      : AppColors.onLightSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
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
