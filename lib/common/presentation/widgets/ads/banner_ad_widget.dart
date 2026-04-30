import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _claimedAd;

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
  static const int _maxRetries = 15;
  Timer? _retryTimer;

  void _tryClaimAd() {
    if (!mounted) return;
    
    final ad = AdManager().getCachedBanner();
    if (ad != null && AdManager().isAdAvailable(ad)) {
      AdManager().claimAd(ad);
      if (mounted) {
        setState(() {
          _claimedAd = ad;
        });
      }
    } else if (_retryCount < _maxRetries) {
      _retryCount++;
      // Exponential backoff: 200ms, 400ms, 800ms... up to several seconds
      final delay = Duration(milliseconds: 200 * _retryCount);
      _retryTimer?.cancel();
      _retryTimer = Timer(delay, () {
        if (mounted && _claimedAd == null) _tryClaimAd();
      });
    } else {
      debugPrint('[BannerAdWidget] Max retries reached for ad claim.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(premiumControllerProvider.select((state) => state.isPro));
    if (isPro || AdManager.isPremium) {
      return const SizedBox.shrink();
    }

    if (_claimedAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: _claimedAd!.size.height.toDouble(),
      child: AdWidget(ad: _claimedAd!),
    );
  }
}

