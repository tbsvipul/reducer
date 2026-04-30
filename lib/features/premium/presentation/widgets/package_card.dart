import 'package:flutter/material.dart';
import 'package:reducer/features/premium/domain/models/premium_plan.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PackageCard extends StatelessWidget {
  final PremiumPlan package;
  final bool isSelected;
  final VoidCallback onTap;

  const PackageCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white
              : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected 
                ? Colors.black87
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              spreadRadius: 2.r,
              offset: Offset(0, 4.h),
            )
          ] : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getPlanLabel(context),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.black87 : Colors.black54,
              ),
            ),
            SizedBox(height: 12.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _currencySymbol,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected ? Colors.black87 : Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _numericPrice,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: -0.5.w,
                    ),
                  ),
                ],
              ),
            ),
            // Show trial badge if available
            if (package.trialPeriod != null) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${package.trialPeriod} ${AppLocalizations.of(context)!.freeLabel}',
                  style: TextStyle(
                    color: const Color(0xFF16A34A),
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
            SizedBox(height: 16.h),
            // The BUY Button built into the card
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black87 : Colors.black12,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.buy.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5.w,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The label displayed at the top of the card, derived from the plan type.
  String _getPlanLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (package.isTestPlan) return l10n.trial;
    if (package.isYearly) return l10n.yearly;
    if (package.isMonthly) return l10n.monthly;
    return package.periodName.toUpperCase();
  }

  /// Extract currency symbol - handles both prefix (₹99) and suffix (99 €) formats
  String get _currencySymbol {
    // Try prefix first (e.g., ₹99.00, $1.99, R$ 4.99)
    final prefix = RegExp(r'^[^\d]+').stringMatch(package.price)?.trim();
    if (prefix != null && prefix.isNotEmpty) return prefix;
    
    // Try suffix (e.g., 0,99 €, 4,99 zł)
    final suffix = RegExp(r'[^\d,.\s]+$').stringMatch(package.price)?.trim();
    return suffix ?? '';
  }

  /// Extract numeric portion from the formatted price.
  String get _numericPrice {
    return RegExp(r'[\d,.]+').stringMatch(package.price) ?? '0';
  }

}

