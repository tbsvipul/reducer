import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/features/premium/presentation/widgets/package_card.dart';
import 'package:reducer/l10n/app_localizations.dart';

class HorizontalPackageSelector extends ConsumerWidget {
  const HorizontalPackageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(premiumControllerProvider);
    final notifier = ref.read(premiumControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    if (state.availablePackages.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(height: 1, color: Colors.black12)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
              child: Text(
                l10n.selectPlan,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
            ),
            Expanded(
              child: Divider(height: 1, color: colorScheme.outlineVariant),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: state.availablePackages.map((package) {
            // Show Popular badge on Yearly plan
            final isPopular = package.isYearly;

            return Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  PackageCard(
                    package: package,
                    isSelected: package == state.selectedPackage,
                    onTap: () => notifier.selectPackage(package),
                  ),
                  if (isPopular)
                    Positioned(
                      top: -12.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          l10n.popular,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
