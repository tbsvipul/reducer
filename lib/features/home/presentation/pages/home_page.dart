import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/shared/presentation/widgets/ads/banner_ad_widget.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_spacing.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reducer/features/home/presentation/widgets/home_header.dart';
import 'package:reducer/features/home/presentation/widgets/quick_actions_section.dart';
import 'package:reducer/features/home/presentation/widgets/pro_tools_section.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── OPTIMIZATION: Only rebuild if isPro changes ──────────────────────────
    final isPro = ref.watch(premiumControllerProvider.select((s) => s.isPro));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Custom App Bar ────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                title: Text(
                  'ImageMaster',
                  style: AppTextStyles.headlineSmall(context),
                ),
              ),
              actions: [
                if (!isPro)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.premium,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 0),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                        ),
                        onPressed: () => context.push('/premium'),
                        icon: const Icon(Iconsax.crown, size: AppSpacing.iconSm),
                        label: Text('PRO', style: AppTextStyles.labelMedium(context).copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Iconsax.setting_2),
                  onPressed: () => context.push('/settings'),
                  tooltip: 'Settings',
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),

            // ── Banner Ad ─────────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: BannerAdWidget(),
            ),

            // ── Main Content ──────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const HomeHeader(),
                  const SizedBox(height: AppSpacing.xl2),
                  const QuickActionsSection(),
                  const SizedBox(height: AppSpacing.xl3),
                  ProToolsSection(isPro: isPro),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AdManager().showInterstitialAd(
            onComplete: () => context.push('/single-editor'),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.edit),
        label: Text('New Edit', style: AppTextStyles.buttonText(context)),
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(delay: 2000.ms, duration: 1500.ms, color: Colors.white.withValues(alpha: 0.2)),
    );
  }
}



