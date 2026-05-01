import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/core/theme/app_dimensions.dart';

class PremiumErrorState extends ConsumerWidget {
  final String error;
  const PremiumErrorState({super.key, required this.error});

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
              padding: const EdgeInsets.all(AppDimensions.xl2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ).animate().shake(duration: 500.ms),
                  const SizedBox(height: AppDimensions.xl2),
                  Text(
                    AppLocalizations.of(context)!.errorOccurred,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl3),
                  AppButton(
                    label: AppLocalizations.of(context)!.retry,
                    icon: Icons.refresh,
                    onPressed: () => ref
                        .read(premiumControllerProvider.notifier)
                        .fetchOffersAndCheckStatus(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
