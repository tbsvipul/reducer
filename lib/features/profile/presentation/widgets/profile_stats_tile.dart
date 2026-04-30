import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/core/theme/app_text_styles.dart';

class ProfileStatsTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const ProfileStatsTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10.r,
                  offset: Offset(0, 5.h),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18.r),
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 24.sp,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall(context).copyWith(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
