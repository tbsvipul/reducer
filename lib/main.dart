import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:reducer/core/localization/locale_provider.dart';
import 'package:reducer/core/utils/image_processor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:reducer/core/services/connectivity_service.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/ads/ad_manager.dart';
import 'core/ads/consent_manager.dart';
import 'core/routes/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/force_update_service.dart';
import 'package:reducer/core/services/remote_config_service.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Core Framework Setup
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Preserve native splash until Flutter is ready
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 3. Essential services with Crashlytics hardening
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Centralized Firestore Configuration with optimized cache size
    // Using unlimited cache size so OS manages it or relying on the default bounds.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // 2. Memory & Image Configuration
    // Reduced from 120MB/200 to 64MB/100 to prevent OOM on low-end devices
    PaintingBinding.instance.imageCache
      ..maximumSizeBytes = 64 << 20 // 64MB
      ..maximumSize = 100;

    // Fire and forget non-blocking initializations
    await Future.microtask(() async {
      await RemoteConfigService().init();
      
      // 5. Firebase Crashlytics Setup
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      
      unawaited(_initializeSecondaryServices());
    });
  } catch (e) {
    debugPrint('Critical initialization failure: $e');
  }

    // 6. Global Error Boundary (Production Hardening)
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        child: Container(
          color: const Color(0xFF020617),
          padding: const EdgeInsets.all(24.0),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 60),
              SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We encountered an unexpected error. Our team has been notified.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    };

    // 7. Start App immediately
    runApp(const ProviderScope(child: MyApp()));
}

/// Services that can initialize in the background without blocking the UI thread.
Future<void> _initializeSecondaryServices() async {
  try {

    
    // Notifications init - Await to ensure channels are ready
    await NotificationService().init();
    
    // Permission requests shouldn't block startup
    unawaited(NotificationService().requestPermissions());
    
    // Consent & Ads
    unawaited(ConsentManager().configure(
      testDeviceIds: _umpTestDeviceIdsFromEnv(),
      forceEeaInDebug: kDebugMode,
    ));

    // Cleanup old temp processing files
    unawaited(ImageProcessor.cleanupTempFiles());
  } catch (e) {
    debugPrint('Secondary service initialization error: $e');
  }
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
    ConnectivityService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
          title: 'Reducer',
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ForceUpdateService().checkAndEnforce(context);
            });
            return child!;
          },
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
        Locale('hi'),
        Locale('es'),
        Locale('ar'),
        Locale('fr'),
        Locale('pt'),
        Locale('ru'),
        Locale('de'),
        Locale('ja'),
        Locale('ko'),
        Locale('tr'),
        Locale('vi'),
        Locale('id'),
        Locale('pl'),
        Locale('et'),
      ],
    );
      },
    );
  }
}

