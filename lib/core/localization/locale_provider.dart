import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'locale_service.dart';

final localeServiceProvider = Provider<LocaleService>((ref) => LocaleService());

class LocaleNotifier extends StateNotifier<Locale> {
  final LocaleService _service;

  LocaleNotifier(this._service) : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final locale = await _service.getLocale();
    if (locale != null) {
      state = locale;
    } else {
      // Default to system locale if not set
      final systemLocale = PlatformDispatcher.instance.locale;
      state = Locale(systemLocale.languageCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _service.saveLocale(locale);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final service = ref.watch(localeServiceProvider);
  return LocaleNotifier(service);
});

class OnboardingNotifier extends StateNotifier<bool?> {
  final LocaleService _service;

  OnboardingNotifier(this._service) : super(null) {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    state = await _service.isFirstTime();
  }

  Future<void> completeOnboarding() async {
    await _service.setFirstTime(false);
    state = false;
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool?>((
  ref,
) {
  final service = ref.watch(localeServiceProvider);
  return OnboardingNotifier(service);
});
