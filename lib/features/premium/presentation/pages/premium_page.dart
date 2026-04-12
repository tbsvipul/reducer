import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_spacing.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/features/premium/presentation/widgets/app_status_bar.dart';
import 'package:reducer/features/premium/presentation/widgets/already_pro_state.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_error_state.dart';
import 'package:reducer/features/premium/presentation/widgets/no_plans_state.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_close_button.dart';
import 'package:reducer/features/premium/presentation/widgets/benefit_list.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_packages_list.dart';
import 'package:reducer/features/premium/presentation/widgets/subscribe_button.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_footer_links.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_loading_overlay.dart';


class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Listen for state changes → show snackbars ───────────────────────────
    ref.listen<PurchaseState>(premiumControllerProvider, (prev, next) {
      if (next.successMessage.isNotEmpty &&
          (prev == null || prev.successMessage != next.successMessage)) {
        AppStatusBar.showSuccess(context, next.successMessage);
        // Pop back after a brief moment so the user sees the SnackBar.
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (context.mounted) Navigator.pop(context);
        });
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
      extendBody: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background (Static backdrop)
          Positioned.fill(
            child: RepaintBoundary(
              child: Image.asset(
                'assets/premium_screen/bg_image.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.primaryContainer,
                ),
              ),
            ),
          ),

          // Close button
          const SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: AppSpacing.lg, right: AppSpacing.lg),
                child: PremiumCloseButton(),

              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 255, AppSpacing.lg, AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Center(
                    child: Text(
                      "Unlock Premium",
                      style: AppTextStyles.headlineMedium(context).copyWith(
                        color: isDark ? AppColors.onDarkBackground : AppColors.onLightBackground,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Benefits
                  const BenefitList(),


                  const SizedBox(height: AppSpacing.sm),

                  // Packages
                  const Expanded(child: PremiumPackagesList()),

                  
                  const SubscribeButton(),

                  
                  const SizedBox(height: AppSpacing.sm),

                  // Auto-renew
                  Center(
                    child: Text(
                      "Subscriptions auto-renew. Cancel anytime.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall(context).copyWith(
                        color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                   const Center(child: PremiumFooterLinks()),

                ],
              ),
            ),
          ),

          if (state.isLoading) const PremiumLoadingOverlay(),

        ],
      ),
    );
  }
}

