import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/core/theme/app_brand_theme.dart';
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
  final String? semanticLabel;
  final String? tooltip;

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
    this.semanticLabel,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = ((height ?? 52).clamp(
      48,
      double.infinity,
    )).toDouble();

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

    Widget button = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: isFullWidth ? double.infinity : 48,
        minHeight: effectiveHeight,
      ),
      child: SizedBox(
        width: isFullWidth ? double.infinity : width,
        child: _buildButtonDecoration(context, content, effectiveHeight),
      ),
    );

    button = Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: semanticLabel ?? label,
      child: button,
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }

  Widget _buildButtonDecoration(
    BuildContext context,
    Widget child,
    double effectiveHeight,
  ) {
    final decoration = _getBoxDecoration(context);
    final borderRadius = BorderRadius.circular(AppDimensions.radiusFull.r);

    final Widget button = Container(
      constraints: BoxConstraints(minHeight: effectiveHeight),
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.lg.w,
              vertical: AppDimensions.md.h,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );

    return FocusableActionDetector(
      enabled: onPressed != null && !isLoading,
      child: button,
    );
  }

  BoxDecoration? _getBoxDecoration(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppDimensions.radiusFull.r);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final brandTheme = context.brandTheme;

    switch (style) {
      case AppButtonStyle.premium:
        return BoxDecoration(
          gradient: brandTheme.premiumGradient,
          borderRadius: borderRadius,
          boxShadow: brandTheme.premiumButtonShadow,
        );
      case AppButtonStyle.primary:
        return BoxDecoration(
          gradient: brandTheme.primaryGradient,
          borderRadius: borderRadius,
          boxShadow: brandTheme.buttonShadow,
        );
      case AppButtonStyle.secondary:
        return BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest
              : AppColors.secondaryContainer,
          borderRadius: borderRadius,
        );
      case AppButtonStyle.outline:
        return BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: theme.colorScheme.outline, width: 1.5.r),
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
        return Theme.of(context).colorScheme.primary;
      case AppButtonStyle.secondary:
        return isDark
            ? Theme.of(context).colorScheme.onSurface
            : AppColors.secondaryDark;
      default:
        return Theme.of(context).colorScheme.onPrimary;
    }
  }
}
