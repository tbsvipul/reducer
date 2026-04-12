import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_auth;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/ads/ad_manager.dart';
import 'core/ads/consent_manager.dart';
import 'core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Configure global image cache early to avoid memory spikes
  PaintingBinding.instance.imageCache
    ..maximumSizeBytes = 120 << 20 // 120MB
    ..maximumSize = 200;

  // 2. Core initialization
  await Firebase.initializeApp();
  await google_auth.GoogleSignIn.instance.initialize();

  // 3. Configure UMP debug settings before any ad request is made.
  await ConsentManager().configure(
    testDeviceIds: _umpTestDeviceIdsFromEnv(),
    forceEeaInDebug: kDebugMode,
  );
  
  // 4. Start App
  runApp(const ProviderScope(child: MyApp()));
}

List<String> _umpTestDeviceIdsFromEnv() {
  const raw = String.fromEnvironment('UMP_TEST_DEVICE_IDS');
  if (raw.isEmpty) return const [];
  return raw
      .split(',')
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toList(growable: false);
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // Observes foreground/background transitions for App Open ads
  final AppLifecycleObserver _lifecycleObserver = AppLifecycleObserver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    AdManager().disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ImageMaster Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

