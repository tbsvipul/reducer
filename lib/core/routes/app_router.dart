import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reducer/features/auth/presentation/pages/login_page.dart';
import 'package:reducer/features/auth/presentation/pages/register_page.dart';
import 'package:reducer/features/profile/presentation/pages/profile_page.dart';
import 'package:reducer/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:reducer/features/auth/presentation/pages/change_password_page.dart';
import 'package:reducer/core/routes/router_notifier.dart';
import 'package:reducer/features/splash/splash_page.dart';
import 'package:reducer/features/home/presentation/pages/main_screen.dart';
import 'package:reducer/features/home/presentation/pages/home_page.dart';
import 'package:reducer/features/editor/presentation/pages/single_image_page.dart';
import 'package:reducer/features/bulk/presentation/pages/bulk_image_page.dart';
import 'package:reducer/features/premium/presentation/pages/premium_page.dart';
import 'package:reducer/features/gallery/presentation/pages/gallery_page.dart';
import 'package:reducer/features/exif/presentation/pages/exif_eraser_page.dart';
import 'package:reducer/features/settings/presentation/pages/settings_page.dart';

import 'package:reducer/core/services/analytics_service.dart';
import 'package:reducer/features/gallery/presentation/pages/bulk_history_detail_page.dart';
import 'package:reducer/features/gallery/data/models/history_item.dart';
import 'package:reducer/features/localization/presentation/pages/language_selection_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);
  final analytics = ref.read(analyticsServiceProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    observers: [analytics.observer],
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      // -- MAIN SHELL ROUTES --
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Editor Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/single-editor',
                builder: (context, state) => const SingleImageScreen(),
              ),
            ],
          ),
          // Bulk Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bulk-editor',
                builder: (context, state) => const BulkImageScreen(),
              ),
            ],
          ),
          // History Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/gallery',
                builder: (context, state) => const GalleryScreen(),
              ),
            ],
          ),
          // Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // -- OTHER STANDALONE ROUTES --
      GoRoute(
        path: '/premium',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: '/bulk-history-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final item = state.extra as HistoryItem?;
          if (item == null) {
            return const Scaffold(
              body: Center(child: Text('History item missing')),
            );
          }
          return BulkHistoryDetailScreen(item: item);
        },
      ),
      GoRoute(
        path: '/exif-eraser',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExifEraserScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/change-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/language-selection',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final isFromSettings =
              state.uri.queryParameters['fromSettings'] == 'true';
          return LanguageSelectionPage(isFromSettings: isFromSettings);
        },
      ),
    ],
  );
});
