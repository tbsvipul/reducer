
class AdConfig {
  final String splashInterstitialAd;
  final String preInterstitialAd;
  final String introNativeAd;
  final String bannerAdUnitId;
  final String languageNativeAd;
  final String appOpenAdId;
  final int adsSkipClick;
  final String facebookId;
  final String facebookToken;
  final int freeUse;
  final int perDayCall;
  final bool defaultYearlySelectPackage;

  AdConfig({
    required this.splashInterstitialAd,
    required this.preInterstitialAd,
    required this.introNativeAd,
    required this.bannerAdUnitId,
    required this.languageNativeAd,
    required this.appOpenAdId,
    required this.adsSkipClick,
    required this.facebookId,
    required this.facebookToken,
    required this.freeUse,
    required this.perDayCall,
    required this.defaultYearlySelectPackage,
  });

  factory AdConfig.fromJson(Map<String, dynamic> json) {
    return AdConfig(
      splashInterstitialAd: json['splashInterstitialAd'] as String? ?? "ca-app-pub-9155918242947466/8096491449",
      preInterstitialAd: json['preInterstitialAd'] as String? ?? "ca-app-pub-9155918242947466/9249791016",
      introNativeAd: json['introNativeAd'] as String? ?? "ca-app-pub-9155918242947466/2346295726",
      bannerAdUnitId: json['bannerAdUnitId'] as String? ?? "ca-app-pub-9155918242947466/4133195707",
      languageNativeAd: json['languageNativeAd'] as String? ?? "ca-app-pub-9155918242947466/2346295726",
      appOpenAdId: json['appOpenAdId'] as String? ?? "ca-app-pub-9155918242947466/8096491449",
      adsSkipClick: json['adsSkipClick'] as int? ?? 2,
      facebookId: json['facebookId'] as String? ?? "",
      facebookToken: json['facebookToken'] as String? ?? "",
      freeUse: json['freeUse'] as int? ?? 0,
      perDayCall: json['perDayCall'] as int? ?? 2,
      defaultYearlySelectPackage: json['defaultYearlySelectPackage'] as bool? ?? true,
    );
  }
}

