import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/features/premium/presentation/widgets/package_card.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HorizontalPackageSelector extends ConsumerWidget {
  const HorizontalPackageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(premiumControllerProvider);
    final notifier = ref.read(premiumControllerProvider.notifier);

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
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                  letterSpacing: 1.0.w,
                ),
              ),
            ),
            const Expanded(child: Divider(height: 1, color: Colors.black12)),
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
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFACC15),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          l10n.popular,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9.sp,
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

