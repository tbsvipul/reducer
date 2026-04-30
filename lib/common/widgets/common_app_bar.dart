import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final StatefulNavigationShell navigationShell;

  const CommonAppBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = navigationShell.currentIndex;
    final isPro = ref.watch(premiumControllerProvider.select((s) => s.isPro));

    final l10n = AppLocalizations.of(context)!;
    String title = l10n.appTitle;
    List<Widget> actions = [];

    switch (index) {
      case 0:
        title = l10n.appTitle;
        actions = [
          if (!isPro)
            _PremiumBadge(onTap: () => context.push('/premium')),
        ];
        break;
      case 1:
        title = l10n.singleEditor;
        break;
      case 2:
        title = l10n.viewHistory;
        break;
      case 3:
        title = l10n.profile;
        break;
    }

    return AppBar(
      leading: index == 0 ? IconButton(
        icon: Icon(Iconsax.setting_2, size: 24.r),
        onPressed: () => context.push('/settings'),
      ) : null,
      title: Text(title, style: AppTextStyles.headlineSmall(context).copyWith(fontSize: 20.sp)),
      actions: [
        ...actions,
        SizedBox(width: AppDimensions.sm.w),
      ],
      elevation: 0,
      centerTitle: false,
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(right: AppDimensions.sm.w),
        child: GestureDetector(
          onTap: onTap,
          child:  Container(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.md.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)], // Gold to Orange
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.premium.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.crown, size: 14.r, color: Colors.white),
                SizedBox(width: 4.w),
                Text(
                  AppLocalizations.of(context)!.proBadge,
                  style: AppTextStyles.labelSmall(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .shimmer(delay: 2.seconds, duration: 1500.ms, color: Colors.white.withValues(alpha: 0.5))
           .scale(
             begin: const Offset(1, 1),
             end: const Offset(1.05, 1.05),
             duration: 1.seconds,
             curve: Curves.easeInOut,
           ).then().scale(
             begin: const Offset(1.05, 1.05),
             end: const Offset(1, 1),
             duration: 1.seconds,
             curve: Curves.easeInOut,
           ),
        ),
      ),
    );
  }
}

