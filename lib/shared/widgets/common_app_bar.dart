import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_spacing.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
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
        title = l10n.viewHistory;
        break;
      case 3:
        title = l10n.profile;
        break;
    }

    return AppBar(
      leading: index == 0
          ? IconButton(
              icon: const Icon(Iconsax.setting_2),
              onPressed: () => context.push('/settings'),
            )
          : null,
      title: Text(
        title,
        style: AppTextStyles.headlineSmall(context).copyWith(fontSize: 20),
      ),
      actions: [
        ...actions,
        const SizedBox(width: AppSpacing.sm),
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
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: GestureDetector(
          onTap: onTap,
          child:
              Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFD700),
                          Color(0xFFFFA500),
                        ], // Gold to Orange
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.premium.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.crown,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.proBadge,
                          style: AppTextStyles.labelSmall(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
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
                  ),
        ),
      ),
    );
  }
}
