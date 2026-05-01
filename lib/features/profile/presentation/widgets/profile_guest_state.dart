import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';

class ProfileGuestState extends StatelessWidget {
  const ProfileGuestState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                shape: BoxShape.circle,
                boxShadow: isDark ? null : AppColors.cardShadowLight,
              ),
              child: Icon(Iconsax.user, size: 80.r, color: AppColors.primary),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            SizedBox(height: 32.h),
            Text(
              l10n.startSession,
              style: AppTextStyles.headlineMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w900, fontSize: 28.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.signInBenefit,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge(
                context,
              ).copyWith(color: Colors.grey, fontSize: 16.sp),
            ),
            SizedBox(height: 40.h),
            AppButton(
              label: l10n.login,
              isFullWidth: true,
              height: 60.h,
              onPressed: () => context.push('/login'),
            ),
          ],
        ),
      ),
    );
  }
}
