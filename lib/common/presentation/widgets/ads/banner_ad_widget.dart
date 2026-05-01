import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  AdSize? _adSize;
  int? _currentWidth;

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAdForWidth(int width) async {
    if (_isLoading || width <= 0 || AdManager.isPremium) {
      return;
    }

    _isLoading = true;
    _currentWidth = width;

    final previousAd = _bannerAd;
    _bannerAd = null;
    _adSize = null;
    if (mounted) {
      setState(() => _isLoaded = false);
    }
    if (previousAd != null) {
      unawaited(previousAd.dispose());
    }

    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);

    if (!mounted || _currentWidth != width) {
      _isLoading = false;
      return;
    }

    if (size == null) {
      debugPrint('[BannerAdWidget] Unable to get adaptive size');
      _isLoading = false;
      return;
    }

    _adSize = size;

    final bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
          _isLoading = false;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[BannerAdWidget] Ad failed to load: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
          }
          _isLoading = false;
        },
      ),
    );

    await bannerAd.load();
  }

  void _scheduleLoad(double width) {
    final normalizedWidth = width.truncate();
    if (_currentWidth == normalizedWidth || _isLoading) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _currentWidth == normalizedWidth) {
        return;
      }
      unawaited(_loadAdForWidth(normalizedWidth));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(
      premiumControllerProvider.select((state) => state.isPro),
    );
    if (isPro || AdManager.isPremium) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        _scheduleLoad(width);

        if (!_isLoaded || _bannerAd == null || _adSize == null) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: double.infinity,
          height: _adSize!.height.toDouble(),
          child: Center(
            child: SizedBox(
              width: _adSize!.width.toDouble(),
              height: _adSize!.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
        );
      },
    );
  }
}
