import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'ad_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  late FirebaseRemoteConfig _remoteConfig;

  static const String freeUse = 'freeUse';
  static const String perDayCall = 'perDayCall';
  static const String defaultYearlySelectPackage = 'defaultYearlySelectPackage';

  Future<void> initialize() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 12),
      ),
    );

    await _remoteConfig.setDefaults({
      'ad_config': jsonEncode({
        "appid": "ca-app-pub-9155918242947466~4984600180",
        "splashInterstitialAd": "ca-app-pub-9155918242947466/8096491449",
        "preInterstitialAd": "ca-app-pub-9155918242947466/9249791016",
        "introNativeAd": "ca-app-pub-9155918242947466/2346295726",
        "bannerAdUnitId": "ca-app-pub-9155918242947466/4133195707",
        "languageNativeAd": "ca-app-pub-9155918242947466/2346295726",
        "appOpenAdId": "ca-app-pub-9155918242947466/8096491449",
        "adsSkipClick": 2,
        "facebookId": "",
        "facebookToken": "",
        "freeUse": 0,
        "perDayCall": 2,
        "defaultYearlySelectPackage": true
      }),
      freeUse: 0,
      perDayCall: 2,
      defaultYearlySelectPackage: true,
    });

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Silent fail
    }
  }

  int getInt(String key) => _remoteConfig.getInt(key);
  bool getBool(String key) => _remoteConfig.getBool(key);

  AdConfig get adConfig {
    final jsonString = _remoteConfig.getString('ad_config');
    if (jsonString.isEmpty) return AdConfig.fromJson({});

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return AdConfig.fromJson(jsonMap);
    } catch (e) {
      return AdConfig.fromJson({});
    }
  }
  void debugPrintAllValues() {
    print('══════ Remote Config Debug ══════');
    print('Source: ${_remoteConfig.lastFetchTime != null ? "fetched ${ _remoteConfig.lastFetchTime}" : "defaults"}');

    print('\n→ ad_config raw:');
    final raw = _remoteConfig.getString('ad_config');
    print(raw.isNotEmpty ? raw : '(empty → using defaults)');

    print('\n→ Parsed AdConfig:');
    final config = adConfig;
    print('splashInterstitialAd : ${config.splashInterstitialAd}');
    print('preInterstitialAd    : ${config.preInterstitialAd}');
    print('introNativeAd        : ${config.introNativeAd}');
    print('bannerAdUnitId       : ${config.bannerAdUnitId}');
    print('languageNativeAd     : ${config.languageNativeAd}');
    print('appOpenAdId          : ${config.appOpenAdId}');
    print('adsSkipClick         : ${config.adsSkipClick}');
    print('facebookId           : "${config.facebookId}"');
    print('facebookToken        : "${config.facebookToken}"');
    print('freeUse              : ${config.freeUse}');
    print('perDayCall           : ${config.perDayCall}');
    print('yearlyDefault        : ${config.defaultYearlySelectPackage}');

    print('\n→ Individual keys:');
    print('freeUse                  : $freeUse');
    print('perDayCall               : $perDayCall');
    print('defaultYearlySelectPackage : $defaultYearlySelectPackage');
    print('═══════════════════════════════');
  }
}