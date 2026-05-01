import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/common/widgets/app_status_bar.dart';
import 'package:reducer/core/theme/app_brand_theme.dart';
import 'package:reducer/core/theme/app_breakpoints.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/features/premium/presentation/widgets/already_pro_state.dart';
import 'package:reducer/features/premium/presentation/widgets/horizontal_package_selector.dart';
import 'package:reducer/features/premium/presentation/widgets/no_plans_state.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_error_state.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_feature_item.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_footer_links.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_loading_overlay.dart';
import 'package:reducer/features/premium/presentation/widgets/subscribe_button.dart';
import 'package:reducer/l10n/app_localizations.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumControllerProvider);

    ref.listen<PurchaseState>(premiumControllerProvider, (prev, next) {
      final l10n = AppLocalizations.of(context)!;

      if (next.statusType != PurchaseStatusType.none &&
          (prev == null || prev.statusType != next.statusType)) {
        if (next.statusType == PurchaseStatusType.purchaseSuccess) {
          AppStatusBar.showSuccess(context, l10n.successPurchase);
        } else if (next.statusType == PurchaseStatusType.restoreSuccess) {
          AppStatusBar.showSuccess(context, l10n.successRestore);
        }
      }

      if (next.errorMessage.isNotEmpty &&
          (prev == null || prev.errorMessage != next.errorMessage)) {
        AppStatusBar.showError(context, next.errorMessage);
      }
    });

    if (state.isPro) {
      return const AlreadyProState();
    }

    if (state.errorMessage.isNotEmpty && state.availablePackages.isEmpty) {
      return PremiumErrorState(error: state.errorMessage);
    }

    if (!state.isLoading && state.availablePackages.isEmpty) {
      return const NoPlansState();
    }

    final l10n = AppLocalizations.of(context)!;
    final reduceMotion =
        MediaQuery.of(context).disableAnimations ||
        MediaQuery.of(context).accessibleNavigation;
    final maxWidth = AppBreakpoints.contentMaxWidth(
      context,
      compactWidth: 680,
      mediumWidth: 760,
      expandedWidth: 900,
    );

    return Scaffold(
      backgroundColor: context.brandTheme.heroBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: context.brandTheme.heroBackgroundGradient,
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.xl2,
                    AppDimensions.md,
                    AppDimensions.xl2,
                    AppDimensions.xl2,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(context, l10n),
                            const SizedBox(height: AppDimensions.xl2),
                            _buildHeroHeader(context, reduceMotion),
                            const SizedBox(height: AppDimensions.xl),
                            _buildFeaturesCard(context),
                            const SizedBox(height: AppDimensions.xl),
                            const HorizontalPackageSelector()
                                .animate()
                                .fadeIn(delay: 300.ms, duration: 450.ms)
                                .slideY(begin: 0.08, end: 0),
                            const SizedBox(height: AppDimensions.xl),
                            const SubscribeButton()
                                .animate()
                                .fadeIn(delay: 500.ms, duration: 450.ms)
                                .scale(
                                  begin: const Offset(0.98, 0.98),
                                  end: const Offset(1, 1),
                                ),
                            const SizedBox(height: AppDimensions.xl2),
                            const PremiumFooterLinks(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (state.isLoading) const PremiumLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: l10n.cancel,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: const Icon(Icons.close),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Text(
            l10n.upgradeToPro,
            style: AppTextStyles.titleLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroHeader(BuildContext context, bool reduceMotion) {
    final image = Image.asset(
      'assets/premium_screen/premium_mascot.png',
      height: 168,
      fit: BoxFit.contain,
      colorBlendMode: BlendMode.multiply,
    );

    return Center(
      child: reduceMotion
          ? image
          : image
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveY(
                  begin: -4,
                  end: 4,
                  duration: 2.seconds,
                  curve: Curves.easeInOut,
                )
                .scale(
                  begin: const Offset(0.97, 0.97),
                  end: const Offset(1, 1),
                  duration: 2.seconds,
                  curve: Curves.easeInOut,
                ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl2),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PremiumFeatureItem(
                icon: Iconsax.maximize_4,
                label: AppLocalizations.of(context)!.featureBulkStudio,
              ),
              PremiumFeatureItem(
                icon: Iconsax.cpu,
                label: AppLocalizations.of(context)!.featureAiTurbo,
              ),
              PremiumFeatureItem(
                icon: Iconsax.shield_slash,
                label: AppLocalizations.of(context)!.featureZeroAds,
              ),
              PremiumFeatureItem(
                icon: Iconsax.document_download,
                label: AppLocalizations.of(context)!.featureDirectZip,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 150.ms, duration: 450.ms)
        .slideY(begin: 0.08, end: 0);
  }
}
