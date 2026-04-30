import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          : (selectedPlan.isMonthly ? l10n.month : selectedPlan.periodName.toLowerCase());
      buttonText = l10n.subscribeWithPrice(selectedPlan.price, period);
    } else {
      buttonText = l10n.startProAccess;
    }

    // Trial text if available
    final trialText = selectedPlan?.trialPeriod != null
        ? l10n.trialPeriodText(selectedPlan!.trialPeriod!)
        : null;

    return Column(
      children: [
        GestureDetector(
          onTap: state.isLoading 
            ? null 
            : () {
                if (authState == null || authState.isAnonymous) {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => Container(
                      padding: EdgeInsets.all(24.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1D27),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PremiumLoginRequiredBlock(),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  );
                } else {
                  notifier.purchaseSelectedPackage();
                }
              },
          child: Container(
            width: double.infinity,
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Center(
              child: state.isLoading
                  ? SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.r,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      buttonText.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        letterSpacing: 1.0.w,
                      ),
                    ),
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.01, 1.01),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        ),
        SizedBox(height: 8.h),
        // Show trial info or fallback text
        Text(
          trialText ?? l10n.cancelAnytime,
          style: TextStyle(
            color: trialText != null ? const Color(0xFF16A34A).withValues(alpha: 0.9) : Colors.black38,
            fontSize: 11.sp,
            fontWeight: trialText != null ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

