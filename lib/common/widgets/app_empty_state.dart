import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? imagePath;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.imagePath,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.xl2.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(imagePath!, width: 200.w, height: 200.h)
            else if (icon != null)
              Icon(
                icon,
                size: 80.r,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            SizedBox(height: AppDimensions.xl2.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge(context).copyWith(
                color: isDark
                    ? AppColors.onDarkSurface
                    : AppColors.onLightSurface,
              ),
            ),
            SizedBox(height: AppDimensions.sm.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: isDark
                    ? AppColors.onDarkSurfaceVariant
                    : AppColors.onLightSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppDimensions.xl2.h),
              AppButton(label: actionLabel!, onPressed: onAction, width: 200.w),
            ],
          ],
        ),
      ),
    );
  }
}
