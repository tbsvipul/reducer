import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/core/theme/app_brand_theme.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/l10n/app_localizations.dart';

class CommonAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final StatefulNavigationShell navigationShell;

  const CommonAppBar({super.key, required this.navigationShell});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
          if (!isPro) _PremiumBadge(onTap: () => context.push('/premium')),
        ];
        break;
      case 1:
        title = l10n.singleEditor;
        break;
      case 2:
        title = l10n.bulkStudio;
        break;
      case 3:
        title = l10n.viewHistory;
        break;
      case 4:
        title = l10n.profile;
        break;
    }

    return AppBar(
      leading: index == 0
          ? IconButton(
              icon: Icon(Iconsax.setting_2, size: 24.r),
              tooltip: l10n.settings,
              onPressed: () => context.push('/settings'),
            )
          : null,
      title: Text(
        title,
        style: AppTextStyles.titleLarge(
          context,
        ).copyWith(fontWeight: FontWeight.w700),
      ),
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
    final l10n = AppLocalizations.of(context)!;
    final reduceMotion =
        MediaQuery.of(context).disableAnimations ||
        MediaQuery.of(context).accessibleNavigation;

    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.md.w,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: context.brandTheme.premiumGradient,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.premium.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.crown, size: 14.r, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            l10n.proBadge,
            style: AppTextStyles.labelSmall(
              context,
            ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    final animatedBadge = reduceMotion
        ? badge
        : badge
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                delay: 2.seconds,
                duration: 1500.ms,
                color: Colors.white.withValues(alpha: 0.5),
              )
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 1.seconds,
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                begin: const Offset(1.05, 1.05),
                end: const Offset(1, 1),
                duration: 1.seconds,
                curve: Curves.easeInOut,
              );

    return Center(
      child: Padding(
        padding: EdgeInsets.only(right: AppDimensions.sm.w),
        child: Semantics(
          button: true,
          label: l10n.upgradeToPro,
          child: Tooltip(
            message: l10n.upgradeToPro,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12.r),
                child: animatedBadge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
