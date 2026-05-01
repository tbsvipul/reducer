import 'package:flutter/material.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_spacing.dart';
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
  final double height;
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
    this.height = 48,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getForegroundColor(context),
              ),
            ),
          )
        else ...[
          if (iconWidget != null) ...[
            iconWidget!,
            const SizedBox(width: AppSpacing.sm),
          ] else if (icon != null) ...[
            Icon(icon, size: 20, color: _getForegroundColor(context)),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            label,
            style: AppTextStyles.buttonText(context).copyWith(
              color: _getForegroundColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  BoxDecoration? _getBoxDecoration(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppSpacing.radiusFull);
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
          border: Border.all(color: AppColors.primary, width: 1.5),
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
