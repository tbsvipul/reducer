import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.xl2.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.r, color: AppColors.error),
            SizedBox(height: AppDimensions.lg.h),
            Text(
              'Something went wrong',
              style: AppTextStyles.titleLarge(context).copyWith(
                color: isDark
                    ? AppColors.onDarkSurface
                    : AppColors.onLightSurface,
              ),
            ),
            SizedBox(height: AppDimensions.sm.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: isDark
                    ? AppColors.onDarkSurfaceVariant
                    : AppColors.onLightSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppDimensions.xl2.h),
              AppButton(
                label: 'Retry',
                onPressed: onRetry,
                style: AppButtonStyle.outline,
                width: 120.w,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
