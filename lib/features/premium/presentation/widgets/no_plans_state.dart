import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:iconsax/iconsax.dart';

class NoPlansState extends ConsumerWidget {
  const NoPlansState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: Stack(
        children: [
          // Background matches PremiumPage
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF020617),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(24.0.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Iconsax.info_circle, size: 40.r, color: Colors.white70),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    AppLocalizations.of(context)!.noPlansAvailable,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppLocalizations.of(context)!.tryAgainLater,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 14.sp),
                  ),
                  SizedBox(height: 40.h),
                  AppButton(
                    label: AppLocalizations.of(context)!.retry,
                    onPressed: () => ref.read(premiumControllerProvider.notifier).fetchOffersAndCheckStatus(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.h,
            left: 20.w,
            child: IconButton(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                padding: EdgeInsets.all(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

