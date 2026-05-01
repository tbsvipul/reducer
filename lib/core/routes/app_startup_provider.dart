import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the application's initialization state (Splash screen work).
class AppStartupNotifier extends StateNotifier<bool> {
  AppStartupNotifier() : super(false);

  void setInitialized() {
    state = true;
  }
}

final appStartupProvider = StateNotifierProvider<AppStartupNotifier, bool>((
  ref,
) {
  return AppStartupNotifier();
});
