import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';

enum AppLoaderStyle { inline, fullscreen, shimmer }

class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;
  final AppLoaderStyle style;

  const AppLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.message,
    this.style = AppLoaderStyle.inline,
  });

  @override
  Widget build(BuildContext context) {
    if (style == AppLoaderStyle.fullscreen) {
      return Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: _buildLoaderContent(context),
        ),
      );
    }

    return _buildLoaderContent(context);
  }

  Widget _buildLoaderContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size.r,
          height: size.r,
          child: CircularProgressIndicator(
            strokeWidth: (size / 10).r,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
          ),
        ),
        if (message != null) ...[
          SizedBox(height: AppDimensions.md.h),
          Text(
            message!,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: color ?? (Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.onDarkSurface 
                  : AppColors.onLightSurface),
            ),
          ),
        ],
      ],
    );
  }
}
