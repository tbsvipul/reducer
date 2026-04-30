import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reducer/core/localization/locale_provider.dart';
import 'package:reducer/core/routes/app_startup_provider.dart';
import 'package:reducer/features/auth/domain/models/user_model.dart';
import 'package:reducer/features/auth/presentation/controllers/auth_controller.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/features/exif/presentation/providers/exif_providers.dart';

/// A notifier that manages the redirect logic for GoRouter based on authentication state.
/// This class implements [Listenable] so GoRouter can react to state changes.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  AppUser? _user;

  RouterNotifier(this._ref) {
    // Initialize with current state
    _user = _ref.read(authStateChangesProvider).value;

    // Listen to startup state and notify GoRouter
    _ref.listen<bool>(appStartupProvider, (previous, current) => notifyListeners());

    // Listen to onboarding state and notify GoRouter
    _ref.listen<bool?>(onboardingProvider, (previous, current) => notifyListeners());

    // Listen to auth state changes and notify GoRouter
    _ref.listen<AsyncValue<AppUser?>>(authStateChangesProvider, (previous, next) {
      if (next is AsyncData) {
        _user = next.value;
        notifyListeners();
      }
    });

    // Listen to premium status changes and notify GoRouter
    _ref.listen<PurchaseState>(premiumControllerProvider, (previous, next) {
      if (previous?.isPro != next.isPro) {
        notifyListeners();
      }
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final path = state.matchedLocation;
    final isInitialized = _ref.read(appStartupProvider);
    final onboardingComplete = _ref.read(onboardingProvider) == false;
    final isPro = _ref.read(premiumControllerProvider).isPro;

    // 1. App initialization guard
    if (!isInitialized) {
      return path == '/splash' ? null : '/splash';
    }

    // 2. Onboarding guard
    final onboardingStatus = _ref.read(onboardingProvider);
    if (onboardingStatus == null) {
      // Still loading onboarding status, stay on splash or current
      return null;
    }
    
    if (onboardingStatus == true) { // true means first time
      return path == '/language-selection' ? null : '/language-selection';
    }

    // 3. Prevent users from manually visiting splash or onboarding once complete
    // EXCEPT if they are coming from settings (indicated by fromSettings query parameter)
    if (isInitialized && onboardingComplete) {
      if (path == '/splash') {
        return '/';
      }
      if (path == '/language-selection' && state.uri.queryParameters['fromSettings'] != 'true') {
        return '/';
      }
    }

    final isAuthRoute = path == '/login' || path == '/register';
    final isLoggedIn = _user != null;
    final requestedRedirect = state.uri.queryParameters['redirect'];

    // Guest mode is allowed across the app, including profile.

    // Hard-gate premium-only routes.
    final credits = _ref.read(exifCreditProvider).availableCredits;
    
    if (path == '/bulk-editor' && !isPro) {
      return '/premium';
    }
    
    if (path == '/exif-eraser' && !isPro && credits <= 0) {
      return '/premium';
    }

    // Keep authenticated users out of auth forms.
    if (isAuthRoute && isLoggedIn) {
      if (_isSafeRedirectTarget(requestedRedirect)) {
        return requestedRedirect;
      }
      return '/';
    }

    // Redirect unauthenticated users from profile to login.
    final isProfilePath = path == '/profile' || state.uri.path == '/profile';
    if (isProfilePath && !isLoggedIn) {
      return '/login?redirect=${Uri.encodeComponent('/profile')}';
    }

    return null;
  }

  bool _isSafeRedirectTarget(String? target) {
    if (target == null || target.isEmpty) return false;
    if (!target.startsWith('/')) return false;
    const forbidden = ['/login', '/register', '/splash', '/language-selection'];
    if (forbidden.contains(target)) return false;
    return true;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>(
  (ref) => RouterNotifier(ref),
);

