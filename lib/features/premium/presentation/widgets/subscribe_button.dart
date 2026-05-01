import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/core/theme/app_brand_theme.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:reducer/features/premium/presentation/widgets/premium_login_required_block.dart';
import 'package:reducer/features/auth/presentation/controllers/auth_controller.dart';

class SubscribeButton extends ConsumerWidget {
  const SubscribeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumControllerProvider);
    final authState = ref.watch(authStateChangesProvider).value;
    final notifier = ref.read(premiumControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    // Build button text from selected plan
    final selectedPlan = state.selectedPackage;

    String buttonText;
    if (selectedPlan != null) {
      final period = selectedPlan.isYearly
          ? l10n.year
          : (selectedPlan.isMonthly
                ? l10n.month
                : selectedPlan.periodName.toLowerCase());
      buttonText = l10n.subscribeWithPrice(selectedPlan.price, period);
    } else {
      buttonText = l10n.startProAccess;
    }

    // Trial text if available
    final trialText = selectedPlan?.trialPeriod != null
        ? l10n.trialPeriodText(selectedPlan!.trialPeriod!)
        : null;

    final reduceMotion =
        MediaQuery.of(context).disableAnimations ||
        MediaQuery.of(context).accessibleNavigation;

    Widget button = AppButton(
      label: buttonText.toUpperCase(),
      semanticLabel: buttonText,
      tooltip: buttonText,
      style: AppButtonStyle.premium,
      isFullWidth: true,
      isLoading: state.isLoading,
      onPressed: () {
        if (state.isLoading) {
          return;
        }

        if (authState == null || authState.isAnonymous) {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [PremiumLoginRequiredBlock(), SizedBox(height: 16)],
              ),
            ),
          );
        } else {
          notifier.purchaseSelectedPackage();
        }
      },
    );

    if (!reduceMotion) {
      button = button
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.01, 1.01),
            duration: 1500.ms,
            curve: Curves.easeInOut,
          );
    }

    return Column(
      children: [
        button,
        const SizedBox(height: AppDimensions.sm),
        Text(
          trialText ?? l10n.cancelAnytime,
          style: AppTextStyles.labelMedium(context).copyWith(
            color: trialText != null
                ? AppColors.success
                : context.brandTheme.mutedForeground,
            fontWeight: trialText != null ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
