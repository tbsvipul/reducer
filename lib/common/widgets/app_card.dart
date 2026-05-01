import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? tooltip;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.gradient,
    this.onTap,
    this.semanticLabel,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius = (borderRadius ?? AppDimensions.radiusLg).r;

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ??
                  (isDark ? AppColors.darkSurface : AppColors.lightSurface))
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(effectiveRadius),
        boxShadow:
            boxShadow ??
            (isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight),
        border:
            border ??
            Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.r,
            ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(effectiveRadius),
            child: Padding(
              padding: padding ?? EdgeInsets.all(AppDimensions.lg.r),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      card = Semantics(button: true, label: semanticLabel, child: card);
    }

    if (tooltip != null && tooltip!.isNotEmpty) {
      card = Tooltip(message: tooltip!, child: card);
    }

    return card;
  }
}
