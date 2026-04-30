import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const ProfileListTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: color, size: 20.r),
      ),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
      ),
      trailing: Icon(Iconsax.arrow_right_3, size: 16.r, color: Colors.grey),
    );
  }
}
