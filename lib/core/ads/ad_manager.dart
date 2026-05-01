import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';
import 'consent_manager.dart';
import 'package:reducer/core/services/remote_config_service.dart';

/// Manages all Google Mobile Ads loading, presentation, and lifecycle.
///
/// Refactored for 2026 Production Standards:
/// • Consent-aware initialization (GDPR/UMP).
/// • Robust App Open (Splash) lifecycle.
/// • Integrated error handling and fallbacks.
class AdManager {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // ── Premium flag ──────────────────────────────────────────────────────────
  /// Private premium status to prevent external tampering.
  static bool _isPremium = false;

  /// Public getter to check status.
  static bool get isPremium => _isPremium;

  /// Internal update method for authorized use only (PurchaseNotifier).
  static void updatePremiumStatus(bool pro) {
    _isPremium = pro;
    debugPrint('[AdManager] Global premium status synced: $pro');
  }

  // ── Ad-unit ID getters (used by widgets) ──────────────────────────────────
  static String get bannerAdUnitId => AdIds.bannerId;
  static String get nativeAdUnitId => AdIds.nativeId;

  // ── SDK Initializer ───────────────────────────────────────────────────────
  /// Initializes the SDK AFTER consent check. Returns [true] if ads can be requested.
  static Future<bool> initialize() async {
    try {
      // Consent gathering is required before any ad requests
      await ConsentManager().gatherConsent();

      final canRequest = await ConsentManager().canRequestAds();
      if (!canRequest || !RemoteConfigService().adsEnabled) return false;

      // Note: MobileAds.instance.initialize() is now called in main.dart for earlier warmup.
      // Preload ads in background (non-blocking)
      if (!_isPremium) {
        AdManager()._scheduleLoadEssential();
      }
      return true;
    } catch (e) {
      debugPrint('[AdManager] Initialization failed: $e');
      return false;
    }
  }

  void _scheduleLoadEssential() {
    // Only load the App Open ad immediately as it is needed for the splash screen.
    unawaited(loadAppOpenAd());

    Future.delayed(const Duration(seconds: 2), () {
      if (!_isPremium) {
        loadInterstitialAd();
      }
    });

    // Banners and Native ads are now loaded per-widget to support adaptive sizing
    // and multiple placements.
  }

  // ── Interstitial state ────────────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  bool _isShowing = false;
  DateTime? _lastInterstitialShownAt;
  Duration get _interstitialMinGap =>
      Duration(seconds: RemoteConfigService().interstitialGapSeconds);

  bool get isInterstitialReady => _interstitialAd != null && !_isShowing;

  int _interstitialRetryCount = 0;
  Timer? _interstitialRetryTimer;

  void loadInterstitialAd() {
    if (isPremium ||
        _isInterstitialLoading ||
        _interstitialAd != null ||
        !RemoteConfigService().adsEnabled)
      return;

    _interstitialRetryTimer?.cancel();
    _interstitialRetryTimer = null;
    _isInterstitialLoading = true;
    debugPrint(
      '[AdManager] Loading Interstitial (Attempt ${_interstitialRetryCount + 1})...',
    );

    InterstitialAd.load(
      adUnitId: AdIds.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _interstitialRetryCount = 0; // Reset on success
          debugPrint('[AdManager] ✅ Interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          _interstitialRetryCount++;
          debugPrint('[AdManager] ❌ Interstitial failed: $error');

          final base = RemoteConfigService().retryBaseSeconds;
          final max = RemoteConfigService().retryMaxSeconds;
          final delaySeconds = (base * (1 << (_interstitialRetryCount - 1)))
              .clamp(base, max);
          debugPrint(
            '[AdManager] Retrying Interstitial in $delaySeconds seconds',
          );
          _interstitialRetryTimer = Timer(
            Duration(seconds: delaySeconds),
            loadInterstitialAd,
          );
        },
      ),
    );
  }

  /// Shows an interstitial and executes [onComplete] only AFTER dismissal or error.
  Future<void> showInterstitialAd({required VoidCallback onComplete}) async {
    if (_lastInterstitialShownAt != null &&
        DateTime.now().difference(_lastInterstitialShownAt!) <
            _interstitialMinGap) {
      onComplete();
      return;
    }
    if (isPremium || !isInterstitialReady) {
      onComplete();
      if (!isPremium && !isInterstitialReady) loadInterstitialAd();
      return;
    }

    _isShowing = true;
    // Set timestamp BEFORE showing to prevent race conditions
    _lastInterstitialShownAt = DateTime.now();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdManager] Interstitial shown');
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isShowing = false;
        loadInterstitialAd(); // Preload next
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isShowing = false;
        loadInterstitialAd();
        onComplete();
      },
      onAdImpression: (ad) {
        debugPrint('[AdManager] Interstitial impression');
      },
      onAdClicked: (ad) {
        debugPrint('[AdManager] Interstitial clicked');
      },
    );

    await _interstitialAd!.show();
  }

  // ── App Open / Splash state ───────────────────────────────────────────────
  AppOpenAd? _appOpenAd;
  bool _isAppOpenLoading = false;
  DateTime? _appOpenLoadTime;
  DateTime? _lastAppOpenShownAt;
  Duration get _appOpenMinGap =>
      Duration(seconds: RemoteConfigService().appOpenGapSeconds);

  bool get isAppOpenReady {
    if (isPremium || _appOpenAd == null || _appOpenLoadTime == null) {
      return false;
    }
    // Expire preloaded ad after 4 hours per Google policy
    return DateTime.now().difference(_appOpenLoadTime!) <
        const Duration(hours: 4);
  }

  int _appOpenRetryCount = 0;
  Timer? _appOpenRetryTimer;
  Completer<void>? _appOpenLoadCompleter;

  Future<void> loadAppOpenAd() async {
    if (isPremium ||
        _isAppOpenLoading ||
        _appOpenAd != null ||
        !RemoteConfigService().adsEnabled)
      return;

    _appOpenRetryTimer?.cancel();
    _appOpenRetryTimer = null;
    _isAppOpenLoading = true;
    _appOpenLoadCompleter = Completer<void>();
    debugPrint(
      '[AdManager] Loading App Open (Attempt ${_appOpenRetryCount + 1})...',
    );

    await AppOpenAd.load(
      adUnitId: AdIds.appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenLoading = false;
          _appOpenLoadTime = DateTime.now();
          _appOpenRetryCount = 0; // Reset on success
          debugPrint('[AdManager] ✅ App Open loaded');
          if (_appOpenLoadCompleter?.isCompleted == false) {
            _appOpenLoadCompleter?.complete();
          }
        },
        onAdFailedToLoad: (error) {
          _isAppOpenLoading = false;
          _appOpenAd = null;
          _appOpenRetryCount++;
          debugPrint('[AdManager] ❌ App Open failed: $error');

          if (_appOpenLoadCompleter?.isCompleted == false) {
            _appOpenLoadCompleter?.complete();
          }

          final base = RemoteConfigService().retryBaseSeconds;
          final max = RemoteConfigService().retryMaxSeconds;
          final delaySeconds = (base * (1 << (_appOpenRetryCount - 1))).clamp(
            base,
            max,
          );
          debugPrint('[AdManager] Retrying App Open in $delaySeconds seconds');
          _appOpenRetryTimer = Timer(
            Duration(seconds: delaySeconds),
            loadAppOpenAd,
          );
        },
      ),
    );
  }

  /// Specialized show for Splash screen. Executes [onDone] after dismissal.
  Future<void> showSplashAd({required VoidCallback onDone}) async {
    if (isPremium) {
      onDone();
      return;
    }

    if (_lastAppOpenShownAt != null &&
        DateTime.now().difference(_lastAppOpenShownAt!) < _appOpenMinGap) {
      debugPrint('[AdManager] App Open gap not met, skipping splash ad');
      onDone();
      return;
    }

    if (isAppOpenReady) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('[AdManager] App Open shown');
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _appOpenAd = null;
          _lastAppOpenShownAt = DateTime.now();
          loadAppOpenAd(); // Preload next
          onDone();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _appOpenAd = null;
          onDone();
        },
        onAdImpression: (ad) {
          debugPrint('[AdManager] App Open impression');
        },
      );
      await _appOpenAd!.show();
    } else {
      // If not ready, load and wait (with hard timeout)
      if (!_isAppOpenLoading) {
        unawaited(loadAppOpenAd());
      }

      // Wait for the load completer or a hard 2s timeout
      await _appOpenLoadCompleter?.future
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () => debugPrint('[AdManager] App Open wait timeout'),
          )
          .catchError((_) => null);

      if (isAppOpenReady) {
        // Show inline — no recursion
        _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) {
            debugPrint('[AdManager] App Open shown (after wait)');
          },
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _appOpenAd = null;
            _lastAppOpenShownAt = DateTime.now();
            loadAppOpenAd(); // Preload next
            onDone();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _appOpenAd = null;
            onDone();
          },
          onAdImpression: (ad) {
            debugPrint('[AdManager] App Open impression');
          },
        );
        await _appOpenAd!.show();
      } else {
        debugPrint('[AdManager] Skipping splash ad (not ready)');
        onDone();
      }
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────
  void disposeAll() {
    _interstitialAd?.dispose();
    _interstitialAd = null;

    _appOpenAd?.dispose();
    _appOpenAd = null;

    _interstitialRetryTimer?.cancel();
    _interstitialRetryTimer = null;
    _appOpenRetryTimer?.cancel();
    _appOpenRetryTimer = null;

    _isShowing = false;
  }
}

// ── App Resume Lifecycle Observer ────────────────────────────────────────────
class AppLifecycleObserver extends WidgetsBindingObserver {
  AppLifecycleState? _lastState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_lastState == state) return;
    _lastState = state;

    if (state == AppLifecycleState.resumed) {
      debugPrint('[Lifecycle] App resumed, showing App Open ad if ready');
      AdManager().showSplashAd(
        onDone: () {
          debugPrint('[Lifecycle] App Open ad completed or skipped');
        },
      );
    }
  }
}
