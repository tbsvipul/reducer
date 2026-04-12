import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reducer/features/auth/presentation/pages/login_screen.dart';
import 'package:reducer/features/auth/presentation/pages/register_screen.dart';
import 'package:reducer/features/auth/presentation/pages/profile_screen.dart';
import 'package:reducer/core/routes/router_notifier.dart';
import 'package:reducer/features/splash/presentation/pages/splash_page.dart';
import 'package:reducer/features/home/presentation/pages/home_page.dart';
import 'package:reducer/features/editor/presentation/pages/single_image_page.dart';
import 'package:reducer/features/bulk/presentation/pages/bulk_image_page.dart';
import 'package:reducer/features/premium/presentation/pages/premium_page.dart';
import 'package:reducer/features/gallery/presentation/pages/gallery_page.dart';
import 'package:reducer/features/exif/presentation/pages/exif_eraser_page.dart';
import 'package:reducer/features/settings/presentation/pages/settings_page.dart';
import 'package:reducer/features/settings/presentation/pages/privacy_policy_page.dart';
import 'package:reducer/features/gallery/presentation/pages/bulk_history_detail_page.dart';
import 'package:reducer/features/gallery/data/models/history_item.dart';


Widget _splash(BuildContext context, GoRouterState state) => const SplashScreen();
Widget _home(BuildContext context, GoRouterState state) => const HomeScreen();
Widget _single(BuildContext context, GoRouterState state) => const SingleImageScreen();
Widget _bulk(BuildContext context, GoRouterState state) => const BulkImageScreen();
Widget _premium(BuildContext context, GoRouterState state) => const PremiumScreen();
Widget _gallery(BuildContext context, GoRouterState state) => const GalleryScreen();
Widget _exif(BuildContext context, GoRouterState state) => const ExifEraserScreen();
Widget _settings(BuildContext context, GoRouterState state) => const SettingsScreen();
Widget _privacy(BuildContext context, GoRouterState state) => const PrivacyPolicyScreen();
Widget _login(BuildContext context, GoRouterState state) => const LoginScreen();
Widget _register(BuildContext context, GoRouterState state) => const RegisterScreen();
Widget _profile(BuildContext context, GoRouterState state) => const ProfileScreen();
Widget _bulkHistory(BuildContext _, GoRouterState state) => BulkHistoryDetailScreen(item: state.extra as HistoryItem);

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(path: '/splash', builder: _splash),
      GoRoute(path: '/', builder: _home),
      GoRoute(path: '/home', builder: _home),
      GoRoute(path: '/single-editor', builder: _single),
      GoRoute(path: '/bulk-editor', builder: _bulk),
      GoRoute(path: '/premium', builder: _premium),
      GoRoute(path: '/gallery', builder: _gallery),
      GoRoute(path: '/bulk-history-detail', builder: _bulkHistory),
      GoRoute(path: '/exif-eraser', builder: _exif),
      GoRoute(path: '/settings', builder: _settings),
      GoRoute(path: '/privacy-policy', builder: _privacy),
      GoRoute(path: '/login', builder: _login),
      GoRoute(path: '/register', builder: _register),
      GoRoute(path: '/profile', builder: _profile),
    ],
  );
});
