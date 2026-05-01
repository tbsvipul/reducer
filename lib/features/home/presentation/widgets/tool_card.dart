import 'package:flutter/material.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ToolCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl.r),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.lg.r),
          decoration: AppTheme.cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.sm.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                ),
                child: Icon(icon, color: color, size: AppDimensions.iconLg.r),
              ),
              SizedBox(height: AppDimensions.lg.h),
              Text(title, style: AppTextStyles.titleMedium(context)),
              SizedBox(height: AppDimensions.xs2.h),
              Text(subtitle, style: AppTextStyles.bodySmall(context)),
            ],
          ),
        ),
      ),
    );
  }
}
