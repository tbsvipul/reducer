import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/editor/single_image_screen.dart';
import 'features/bulk/bulk_image_screen.dart';
import 'features/premium/premium_screen.dart';
import 'features/gallery/gallery_screen.dart';
import 'features/gallery/bulk_history_detail_screen.dart';
import 'features/exif/exif_eraser_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/privacy_policy_screen.dart';
import 'models/history_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ads/ad_service.dart';
import 'services/purchase_service.dart';
import 'ads/remote_config_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize services
  await RemoteConfigService().initialize();
  await AdService().init();
  await PurchaseService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ImageMaster Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/single-editor',
      builder: (context, state) => const SingleImageScreen(),
    ),
    GoRoute(
      path: '/bulk-editor',
      builder: (context, state) => const BulkImageScreen(),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/gallery',
      builder: (context, state) => const GalleryScreen(),
    ),
    GoRoute(
      path: '/bulk-history-detail',
      builder: (context, state) {
        final item = state.extra as HistoryItem;
        return BulkHistoryDetailScreen(item: item);
      },
    ),
    GoRoute(
      path: '/exif-eraser',
      builder: (context, state) => const ExifEraserScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
  ],
);
