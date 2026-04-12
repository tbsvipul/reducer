import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';
import 'consent_manager.dart';

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
  /// Set to [true] to suppress all ads (e.g. after a successful purchase).
  static bool isPremium = false;

  // ── Ad-unit ID getters (used by widgets) ──────────────────────────────────
  static String get bannerAdUnitId => AdIds.bannerId;
  static String get nativeAdUnitId => AdIds.nativeId;

  // ── SDK Initializer ───────────────────────────────────────────────────────
  /// Initializes the SDK AFTER consent check. Returns [true] if ads can be requested.
  static Future<bool> initialize() async {
    // 1. Gather consent (GDPR check)
    await ConsentManager().gatherConsent();

    // 2. Check if we have consent to request ads
    final canRequest = await ConsentManager().canRequestAds();
    if (!canRequest) {
      debugPrint(
          '[AdManager] Ads cannot be requested yet. Consent not gathered.');
      return false;
    }

    // 3. Initialize the SDK
    await MobileAds.instance.initialize();

    // 4. Preload ads if not premium
    if (!isPremium) {
      AdManager()._scheduleLoadAll();
    }

    return true;
  }

  void _scheduleLoadAll() {
    // Staggered load to avoid heavy burst of requests
    Future.delayed(const Duration(seconds: 1), () {
      loadInterstitialAd();
      loadAppOpenAd();
    });
  }

  // ── Interstitial state ────────────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  bool _isShowing = false;
  DateTime? _lastInterstitialShownAt;
  static const Duration _interstitialMinGap = Duration(seconds: 45);

  bool get isInterstitialReady => _interstitialAd != null && !_isShowing;

  int _interstitialRetryCount = 0;

  void loadInterstitialAd() {
    if (isPremium || _isInterstitialLoading || _interstitialAd != null) return;

    _isInterstitialLoading = true;
    debugPrint('[AdManager] Loading Interstitial (Attempt ${_interstitialRetryCount + 1})...');

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
          
          // Exponential backoff: 30s, 60s, 120s... max 30 mins
          final delaySeconds = (30 * (1 << (_interstitialRetryCount - 1))).clamp(30, 1800);
          debugPrint('[AdManager] Retrying Interstitial in $delaySeconds seconds');
          Future.delayed(Duration(seconds: delaySeconds), loadInterstitialAd);
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
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
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
    );

    await _interstitialAd!.show();
    _lastInterstitialShownAt = DateTime.now();
  }

  // ── App Open / Splash state ───────────────────────────────────────────────
  AppOpenAd? _appOpenAd;
  bool _isAppOpenLoading = false;
  DateTime? _appOpenLoadTime;

  bool get isAppOpenReady {
    if (isPremium || _appOpenAd == null || _appOpenLoadTime == null) {
      return false;
    }
    // Expire preloaded ad after 4 hours
    return DateTime.now().difference(_appOpenLoadTime!) <
        const Duration(hours: 4);
  }

  int _appOpenRetryCount = 0;

  Future<void> loadAppOpenAd() async {
    if (isPremium || _isAppOpenLoading || _appOpenAd != null) return;

    _isAppOpenLoading = true;
    debugPrint('[AdManager] Loading App Open (Attempt ${_appOpenRetryCount + 1})...');

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
        },
        onAdFailedToLoad: (error) {
          _isAppOpenLoading = false;
          _appOpenAd = null;
          _appOpenRetryCount++;
          debugPrint('[AdManager] ❌ App Open failed: $error');

          // Exponential backoff
          final delaySeconds = (30 * (1 << (_appOpenRetryCount - 1))).clamp(30, 1800);
          debugPrint('[AdManager] Retrying App Open in $delaySeconds seconds');
          Future.delayed(Duration(seconds: delaySeconds), loadAppOpenAd);
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

    if (isAppOpenReady) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _appOpenAd = null;
          onDone();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _appOpenAd = null;
          onDone();
        },
      );
      await _appOpenAd!.show();
    } else {
      // If not ready, load and wait up to 3s (Splash optimization)
      if (!_isAppOpenLoading) {
        loadAppOpenAd();
      }

      int timerCount = 0;
      while (_isAppOpenLoading && timerCount < 30) {
        // Wait max 3 seconds
        await Future.delayed(const Duration(milliseconds: 100));
        timerCount++;
      }

      if (isAppOpenReady) {
        await showSplashAd(onDone: onDone);
      } else {
        debugPrint('[AdManager] App Open timeout, skipping splash ad');
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
      debugPrint('[Lifecycle] App resumed');
      // Potentially show App Open Ad here if not on Splash/Auth
    }
  }
}
