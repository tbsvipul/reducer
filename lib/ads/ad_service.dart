import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'remote_config_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static bool isPremium = false;
  static String get bannerAdUnitId => RemoteConfigService().adConfig.bannerAdUnitId;
  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    if (isPremium || _isAdLoading) return;
    _isAdLoading = true;

    final adUnitId = RemoteConfigService().adConfig.preInterstitialAd;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isAdLoading = false;
          // Retry later
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  Future<void> showSplashInterstitialAd({required VoidCallback onAdClosed}) async {
    if (isPremium) {
      onAdClosed();
      return;
    }

    final adUnitId = RemoteConfigService().adConfig.splashInterstitialAd;
    
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onAdClosed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onAdClosed();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          onAdClosed();
        },
      ),
    );
  }

  Future<void> showInterstitialAd({required VoidCallback onAdClosed}) async {
    if (isPremium || _interstitialAd == null) {
      onAdClosed();
      if (!isPremium) _loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
        onAdClosed();
      },
    );

    await _interstitialAd!.show();
  }
}
