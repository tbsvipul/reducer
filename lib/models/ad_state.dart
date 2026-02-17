import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ads/ad_service.dart';
import '../ads/remote_config_service.dart';

final adStateProvider = Provider((ref) => AdState());

class AdState {
  int _clickCount = 0;

  Future<void> onFeatureClick({
    required BuildContext context,
    required VoidCallback onComplete,
  }) async {
    if (AdService.isPremium) {
      onComplete();
      return;
    }

    _clickCount++;
    final skipClick = RemoteConfigService().adConfig.adsSkipClick;

    if (_clickCount >= skipClick) {
      _clickCount = 0;
      await AdService().showInterstitialAd(onAdClosed: onComplete);
    } else {
      onComplete();
    }
  }
}
