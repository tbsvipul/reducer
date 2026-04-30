import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() => _instance;

  RemoteConfigService._internal();

  FirebaseRemoteConfig? _rc;
  FirebaseRemoteConfig get _remoteConfig {
    try {
      return _rc ??= FirebaseRemoteConfig.instance;
    } catch (_) {
      // If Firebase is not initialized, return a dummy or handle it in getters
      rethrow;
    }
  }

  Future<void> init() async {
    try {
      await _remoteConfig.setDefaults({
        // Ad Units (Android)
        'ad_android_banner': 'ca-app-pub-9155918242947466/4133195707',
        'ad_android_interstitial': 'ca-app-pub-9155918242947466/9249791016',
        'ad_android_app_open': 'ca-app-pub-9155918242947466/8096491449',
        'ad_android_native': 'ca-app-pub-9155918242947466/2346295726',
        'ad_android_rewarded': 'ca-app-pub-9155918242947466/1743660491',

        // Ad Units (iOS)
        'ad_ios_banner': 'ca-app-pub-3940256099942544/2934735716',
        'ad_ios_interstitial': 'ca-app-pub-3940256099942544/4411468910',
        'ad_ios_app_open': 'ca-app-pub-3940256099942544/5662855259',
        'ad_ios_native': 'ca-app-pub-3940256099942544/3986624511',
        'ad_ios_rewarded': 'ca-app-pub-3940256099942544/1712485313',

        // IAP
        'iap_product_id': 'ai_image_pro',
        'iap_monthly_plan_id': 'monthly-plan',
        'iap_yearly_plan_id': 'yearly-plan',
        'iap_test_plan_id': 'test-plan',

        // Ad Behavior
        'ad_interstitial_gap_seconds': 30,
        'ad_app_open_gap_seconds': 30,
        'ad_retry_base_seconds': 30,
        'ad_retry_max_seconds': 1800,

        // App Config
        'support_email': 'tarurinfotech@gmail.com',
        'app_store_url': 'https://play.google.com/store/apps/details?id=com.tarurinfotech.reducer',
        'max_file_size_mb': 50,
        'max_image_dimension': 10000,

        // Feature Flags
        'force_update_enabled': false,
        'force_update_min_version': '1.3.1',
        'maintenance_mode': false,
        'ads_enabled': true,
      });

      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 1),
      ));

      await _remoteConfig.fetchAndActivate();
      
      // ── Real-time Updates ──────────────────────────────────────────────
      _remoteConfig.onConfigUpdated.listen((event) async {
        await _remoteConfig.activate();
        debugPrint('[RemoteConfigService] 🔄 Config updated in real-time');
      });

      debugPrint('[RemoteConfigService] ✅ Initialized successfully');
    } catch (e) {
      debugPrint('[RemoteConfigService] ❌ Initialization failed: $e');
    }
  }

  // Generic Getters with safety fallbacks
  String getString(String key) {
    try {
      return _remoteConfig.getString(key);
    } catch (_) {
      return _defaults[key]?.toString() ?? '';
    }
  }

  int getInt(String key) {
    try {
      return _remoteConfig.getInt(key);
    } catch (_) {
      final val = _defaults[key];
      return val is int ? val : 0;
    }
  }

  bool getBool(String key) {
    try {
      return _remoteConfig.getBool(key);
    } catch (_) {
      final val = _defaults[key];
      return val is bool ? val : false;
    }
  }

  double getDouble(String key) {
    try {
      return _remoteConfig.getDouble(key);
    } catch (_) {
      final val = _defaults[key];
      return val is double ? val : (val is int ? val.toDouble() : 0.0);
    }
  }

  // Hardcoded defaults for fallback before initialization
  static const Map<String, dynamic> _defaults = {
    'ad_interstitial_gap_seconds': 30,
    'ad_app_open_gap_seconds': 30,
    'ad_retry_base_seconds': 30,
    'ad_retry_max_seconds': 1800,
    'support_email': 'tarurinfotech@gmail.com',
    'app_store_url': 'https://play.google.com/store/apps/details?id=com.tarurinfotech.reducer',
    'max_file_size_mb': 50,
    'max_image_dimension': 10000,
    'force_update_enabled': false,
    'force_update_min_version': '1.0.0',
    'maintenance_mode': false,
    'ads_enabled': true,
    'iap_product_id': 'ai_image_pro',
  };

  // Convenience Getters
  String get supportEmail => getString('support_email');
  String get appStoreUrl => getString('app_store_url');
  bool get adsEnabled => getBool('ads_enabled');
  bool get maintenanceMode => getBool('maintenance_mode');
  
  // Force Update
  bool get forceUpdateEnabled => getBool('force_update_enabled');
  String get forceUpdateMinVersion => getString('force_update_min_version');

  // Ad Behavior
  int get interstitialGapSeconds => getInt('ad_interstitial_gap_seconds');
  int get appOpenGapSeconds => getInt('ad_app_open_gap_seconds');
  int get retryBaseSeconds => getInt('ad_retry_base_seconds');
  int get retryMaxSeconds => getInt('ad_retry_max_seconds');

  // IAP
  String get productId => getString('iap_product_id');
  String get monthlyPlanId => getString('iap_monthly_plan_id');
  String get yearlyPlanId => getString('iap_yearly_plan_id');
  String get testPlanId => getString('iap_test_plan_id');

  // Limits
  int get maxFileSizeMb => getInt('max_file_size_mb');
  int get maxImageDimension => getInt('max_image_dimension');
}
