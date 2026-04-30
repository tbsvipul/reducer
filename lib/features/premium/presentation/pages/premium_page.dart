import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/common/widgets/app_status_bar.dart';
import 'package:reducer/features/premium/presentation/widgets/already_pro_state.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_error_state.dart';
import 'package:reducer/features/premium/presentation/widgets/no_plans_state.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_feature_item.dart';
import 'package:reducer/features/premium/presentation/widgets/horizontal_package_selector.dart';
import 'package:reducer/features/premium/presentation/widgets/subscribe_button.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_footer_links.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_loading_overlay.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/core/theme/app_dimensions.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumControllerProvider);

    // Listen for state changes → show snackbars
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

    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FF), // Soft light blue base
      body: Stack(
        children: [
          // Premium Background Gradient (Very light topographical style)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8F3FF),
                    Color(0xFFF8FBFF),
                    Color(0xFFE0EFFF),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.xl3, vertical: 12.h),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 16.h,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Custom AppBar / Header inside the column flow
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/');
                                  }
                                },
                                icon: const Icon(Icons.close, color: Colors.black87),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                                  padding: const EdgeInsets.all(12),
                                ),
                              ).animate().fadeIn(duration: 400.ms),
                              Text(
                                'Upgrade Premium',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 48.w), // Spacer to balance the back button
                            ],
                          ),
                          SizedBox(height: 24.h),
                          // Hero Content
                          _buildHeroHeader(context),
                          
                          const Spacer(),

                          // Simple Features List
                          _buildFeaturesCard(context),

                          SizedBox(height: 16.h),

                          // Plan Selection
                          const HorizontalPackageSelector()
                              .animate()
                              .fadeIn(delay: 600.ms, duration: 500.ms)
                              .slideY(begin: 0.1, end: 0),

                          SizedBox(height: 16.h),

                          // Subscribe Button & Trust Subtext (If kept, or replaced by card logic)
                          const SubscribeButton()
                              .animate()
                              .fadeIn(delay: 800.ms, duration: 500.ms)
                              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

                          const Spacer(),
                          SizedBox(height: 16.h),

                          // Restores & Legal
                          const PremiumFooterLinks(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (state.isLoading) const PremiumLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Column(
      children: [
        // Premium Mascot Integration with multiply blend to eliminate white background
        Image.asset(
          'assets/premium_screen/premium_mascot.png',
          height: 160.h,
          fit: BoxFit.contain,
          colorBlendMode: BlendMode.multiply,
        ).animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: -5.h, end: 5.h, duration: 2.seconds, curve: Curves.easeInOut)
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 2.seconds, curve: Curves.easeInOut),
        
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
  }


}

