import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum NativeAdSize { small, medium }

class NativeAdWidget extends ConsumerStatefulWidget {
  const NativeAdWidget({
    super.key,
    this.size = NativeAdSize.small,
  });

  final NativeAdSize size;

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> {
  NativeAd? _claimedAd;

  @override
  void initState() {
    super.initState();
    _tryClaimAd();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    if (_claimedAd != null) {
      AdManager().releaseAd(_claimedAd!);
    }
    super.dispose();
  }

  int _retryCount = 0;
  static const int _maxRetries = 20;
  Timer? _retryTimer;

  void _tryClaimAd() {
    if (!mounted) return;
    
    final ad = AdManager().getCachedNative();
    if (ad != null && AdManager().isAdAvailable(ad)) {
      AdManager().claimAd(ad);
      if (mounted) {
        setState(() {
          _claimedAd = ad;
        });
      }
    } else if (_retryCount < _maxRetries) {
      _retryCount++;
      // Exponential backoff for polling the global cache
      final delay = Duration(milliseconds: 500 * _retryCount);
      _retryTimer?.cancel();
      _retryTimer = Timer(delay, () {
        if (mounted && _claimedAd == null) _tryClaimAd();
      });
    } else {
      debugPrint('[NativeAdWidget] Max retries reached for native ad claim.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if premium is active
    final isPro = ref.watch(premiumControllerProvider).isPro;
    
    if (isPro || AdManager.isPremium) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double height = widget.size == NativeAdSize.small ? 100.h : 360.h;

    if (_claimedAd == null) {
      // Placeholder while waiting for the global ad instance to become available
      return Container(
        height: height,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Container(
      height: height,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: AdWidget(ad: _claimedAd!)),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.premium,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(11.r),
                    bottomRight: Radius.circular(8.r),
                  ),
                ),
                child: Text(
                  'AD',
                  style: TextStyle(
                    color: AppColors.onPremium,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
