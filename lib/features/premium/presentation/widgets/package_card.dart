import 'package:flutter/material.dart';
import 'package:reducer/features/premium/domain/models/premium_plan.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${_getPlanLabel(context)} ${package.price}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surface
              : colorScheme.surface.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 12.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getPlanLabel(context),
                    style: AppTextStyles.labelMedium(context).copyWith(
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
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
                          style: AppTextStyles.titleSmall(context).copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _numericPrice,
                          style: AppTextStyles.headlineSmall(context).copyWith(
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (package.trialPeriod != null) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${package.trialPeriod} ${AppLocalizations.of(context)!.freeLabel}',
                        style: AppTextStyles.labelSmall(context).copyWith(
                          color: const Color(0xFF15803D),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.buy.toUpperCase(),
                        style: AppTextStyles.labelLarge(context).copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
