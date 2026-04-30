import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';

enum AppButtonStyle { primary, secondary, premium, outline, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? iconWidget;
  final bool isLoading;
  final AppButtonStyle style;
  final double? width;
  final double? height;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.iconWidget,
    this.isLoading = false,
    this.style = AppButtonStyle.primary,
    this.width,
    this.height,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 48.h;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.r,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getForegroundColor(context),
              ),
            ),
          )
        else ...[
          if (iconWidget != null) ...[
            iconWidget!,
            SizedBox(width: AppDimensions.sm.w),
          ] else if (icon != null) ...[
            Icon(icon, size: 20.r, color: _getForegroundColor(context)),
            SizedBox(width: AppDimensions.sm.w),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.buttonText(context).copyWith(
                color: _getForegroundColor(context),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : (width?.w),
      height: effectiveHeight,
      child: _buildButtonDecoration(context, content),
    );
  }

  Widget _buildButtonDecoration(BuildContext context, Widget child) {
    final decoration = _getBoxDecoration(context);
    
    return Container(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg.w),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  BoxDecoration? _getBoxDecoration(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppDimensions.radiusFull.r);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (style) {
      case AppButtonStyle.premium:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.premiumGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius,
          boxShadow: AppColors.premiumButtonShadow,
        );
      case AppButtonStyle.primary:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius,
          boxShadow: AppColors.buttonShadow,
        );
      case AppButtonStyle.secondary:
        return BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.secondary,
          borderRadius: borderRadius,
        );
      case AppButtonStyle.outline:
        return BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: AppColors.primary, width: 1.5.r),
        );
      case AppButtonStyle.ghost:
        return null;
    }
  }

  Color _getForegroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (style) {
      case AppButtonStyle.outline:
      case AppButtonStyle.ghost:
        return AppColors.primary;
      case AppButtonStyle.secondary:
        return isDark ? AppColors.onDarkSurface : AppColors.onLightSurface;
      default:
        return AppColors.onPrimary;
    }
  }
}

