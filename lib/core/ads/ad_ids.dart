import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:reducer/core/services/remote_config_service.dart';

// ── Ad Unit IDs ─────────────────────────────────────────────────────────────
// FIX: Always use TEST IDs in debug mode — production IDs return "No fill" (error 3)
// in development/test environments. Real ads only serve in production builds.

class AdIds {
  // ── Test Ad Unit IDs (Google official test IDs) ───────────────────────────
  static const String _testBanner = 'ca-app-pub-3940256099942544/9214589741';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testAppOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const String _testNative = 'ca-app-pub-3940256099942544/2247696110';
  static const String _testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // ── Android production ad unit IDs (from Remote Config) ───────────────────
  static String get _androidBanner =>
      RemoteConfigService().getString('ad_android_banner');
  static String get _androidInterstitial =>
      RemoteConfigService().getString('ad_android_interstitial');
  static String get _androidAppOpen =>
      RemoteConfigService().getString('ad_android_app_open');
  static String get _androidNative =>
      RemoteConfigService().getString('ad_android_native');
  static String get _androidRewarded =>
      RemoteConfigService().getString('ad_android_rewarded');

  // ── iOS production ad unit IDs (from Remote Config) ───────────────────────
  static String get _iosBanner =>
      RemoteConfigService().getString('ad_ios_banner');
  static String get _iosInterstitial =>
      RemoteConfigService().getString('ad_ios_interstitial');
  static String get _iosAppOpen =>
      RemoteConfigService().getString('ad_ios_app_open');
  static String get _iosNative =>
      RemoteConfigService().getString('ad_ios_native');
  static String get _iosRewarded =>
      RemoteConfigService().getString('ad_ios_rewarded');

  // ── Platform-resolved getters ─────────────────────────────────────────────
  static String get bannerId {
    if (kDebugMode) return _testBanner;
    final id = Platform.isAndroid ? _androidBanner : _iosBanner;
    return id.isNotEmpty ? id : _testBanner;
  }

  static String get interstitialId {
    if (kDebugMode) return _testInterstitial;
    final id = Platform.isAndroid ? _androidInterstitial : _iosInterstitial;
    return id.isNotEmpty ? id : _testInterstitial;
  }

  static String get appOpenId {
    if (kDebugMode) return _testAppOpen;
    final id = Platform.isAndroid ? _androidAppOpen : _iosAppOpen;
    return id.isNotEmpty ? id : _testAppOpen;
  }

  static String get nativeId {
    if (kDebugMode) return _testNative;
    final id = Platform.isAndroid ? _androidNative : _iosNative;
    return id.isNotEmpty ? id : _testNative;
  }

  static String get rewardedId {
    if (kDebugMode) return _testRewarded;
    final id = Platform.isAndroid ? _androidRewarded : _iosRewarded;
    return id.isNotEmpty ? id : _testRewarded;
  }
}
