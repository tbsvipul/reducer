import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Handles UMP consent flow and ad request readiness in a fail-safe way.
class ConsentManager {
  ConsentManager._internal();

  static final ConsentManager _instance = ConsentManager._internal();
  factory ConsentManager() => _instance;
  static const bool _forceUmpInDebug = bool.fromEnvironment(
    'FORCE_UMP_DEBUG',
    defaultValue: false,
  );

  ConsentDebugSettings? _debugSettings;
  bool _hasRequestedConsent = false;
  bool _canRequestAdsCache = false;

  Future<void> configure({
    List<String> testDeviceIds = const [],
    bool forceEeaInDebug = false,
  }) async {
    final cleanedIds = testDeviceIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    // Fix: Explicitly mark test devices for both ads requests and UMP debug mode.
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: cleanedIds),
    );

    if (cleanedIds.isEmpty) {
      _debugSettings = null;
      return;
    }

    _debugSettings = ConsentDebugSettings(
      debugGeography: forceEeaInDebug
          ? DebugGeography.debugGeographyEea
          : DebugGeography.debugGeographyDisabled,
      testIdentifiers: cleanedIds,
    );
  }

  /// Requests latest consent info and shows form when required.
  Future<void> gatherConsent() async {
    // Keep debug runs clean unless explicitly testing UMP.
    if (kDebugMode && !_forceUmpInDebug) {
      _hasRequestedConsent = true;
      _canRequestAdsCache = true;
      return;
    }

    final completer = Completer<void>();

    final params = ConsentRequestParameters(
      tagForUnderAgeOfConsent: false,
      consentDebugSettings: _debugSettings,
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        try {
          final formAvailable = await ConsentInformation.instance
              .isConsentFormAvailable();

          if (formAvailable) {
            // Fix: Gracefully handles "no form needed" and dismissal errors.
            await ConsentForm.loadAndShowConsentFormIfRequired((
              FormError? formError,
            ) {
              if (formError != null) {
                debugPrint(
                  '[ConsentManager] Consent form dismissed with error: ${formError.message}',
                );
              }
            });
          } else {
            debugPrint(
              '[ConsentManager] No consent form available for this region/user.',
            );
          }
        } catch (e) {
          debugPrint('[ConsentManager] Consent form handling failed: $e');
        } finally {
          _canRequestAdsCache = await canRequestAds(refresh: true);
          _hasRequestedConsent = true;
          if (!completer.isCompleted) completer.complete();
        }
      },
      (FormError error) async {
        // Fix: App keeps running even when consent info update fails.
        if (error.errorCode == 3) {
          debugPrint(
            '------------------------------------------------------------',
          );
          debugPrint(
            '[ConsentManager] CRITICAL: AdMob Publisher Misconfiguration!',
          );
          debugPrint('[ConsentManager] ErrorCode 3 usually means:');
          debugPrint(
            '1. You have NOT created a GDPR message for this app in AdMob.',
          );
          debugPrint('2. The message is not "Published".');
          debugPrint(
            '3. The App ID in AndroidManifest does not match the dashboard app.',
          );
          debugPrint('Check: https://apps.admob.com/v2/privacymessaging');
          debugPrint(
            '------------------------------------------------------------',
          );
        } else {
          debugPrint(
            '[ConsentManager] Consent info update failed (${error.errorCode}): ${error.message}',
          );
        }
        _canRequestAdsCache = await canRequestAds(refresh: true);
        _hasRequestedConsent = true;
        if (!completer.isCompleted) completer.complete();
      },
    );

    // Reduced timeout from 12s to 6s for better UX on slow networks.
    await completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () {
        debugPrint(
          '[ConsentManager] Consent flow timeout (6s). Continuing safely.',
        );
      },
    );
  }

  Future<bool> canRequestAds({bool refresh = false}) async {
    if (!refresh && _canRequestAdsCache) return true;

    try {
      final allowed = await ConsentInformation.instance.canRequestAds();
      _canRequestAdsCache = allowed;
      return allowed;
    } catch (e) {
      debugPrint('[ConsentManager] canRequestAds check failed: $e');
      return false;
    }
  }

  Future<bool> shouldRequestConsent() async {
    if (!_hasRequestedConsent) return true;

    final status = await ConsentInformation.instance.getConsentStatus();
    return status == ConsentStatus.required;
  }

  Future<void> showPrivacyOptionsIfRequired() async {
    try {
      final requirement = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      if (requirement != PrivacyOptionsRequirementStatus.required) return;

      await ConsentForm.showPrivacyOptionsForm((FormError? error) {
        if (error != null) {
          debugPrint(
            '[ConsentManager] Privacy options form failed: ${error.message}',
          );
        }
      });
    } catch (e) {
      debugPrint('[ConsentManager] Unable to show privacy options: $e');
    }
  }

  Future<void> resetConsent() async {
    await ConsentInformation.instance.reset();
    _hasRequestedConsent = false;
    _canRequestAdsCache = false;
  }
}
