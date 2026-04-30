import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/features/auth/presentation/controllers/auth_controller.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/core/routes/app_startup_provider.dart';

import '../../core/theme/app_dimensions.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _controller.forward();
    
    // Remove native splash as soon as first Flutter frame is painted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Parallelize branding delay and critical setup
    final minDelay = Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // 1. Resolve Auth first (needed for Premium check)
      await _initializeAuth();

      // 2. Fetch Premium status and sync to AdManager
      // This ensures ads are ONLY initialized if the user is truly non-premium
      await ref.read(premiumControllerProvider.notifier).fetchOffersAndCheckStatus();

      // 3. Concurrent initialization of UI delays and Ads
      await Future.wait([
        minDelay,
        AdManager.initialize(),
      ]);

      if (!mounted) return;

      // 2. Show App Open Ad (Handles timeout internally)
      await AdManager().showSplashAd(onDone: () async {
        if (mounted) {
          ref.read(appStartupProvider.notifier).setInitialized();
        }
      });
    } catch (e) {
      debugPrint('Splash init error: $e');
      if (mounted) {
        ref.read(appStartupProvider.notifier).setInitialized();
      }
    }
  }
  Future<void> _initializeAuth() async {
    final authRepo = ref.read(authRepositoryProvider);
    if (authRepo.currentUser == null) {
      await authRepo.signInAnonymously();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern off-white background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient for a soft, premium feel
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF0F7FF), // Extremely subtle blue tint
                    Color(0xFFF8FAFC),
                  ],
                ),
              ),
            ),
          ),

          // Optional: Subtle floating decorative elements
          _buildDecorativeCircle(top: -50, right: -50, size: 200, opacity: 0.03),
          _buildDecorativeCircle(bottom: 100, left: -30, size: 150, opacity: 0.02),

          // Central Logo & Branding
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.08),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo/reducer_logo_bg.png',
                      width: 160.r,
                      height: 160.r,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .moveY(begin: -5, end: 5, duration: 2500.ms, curve: Curves.easeInOut)
                    .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 2500.ms, curve: Curves.easeInOut),
                
                SizedBox(height: 40.h),
                
                // Minimalist App Name
                Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: const Color(0xFF1E293B), // Slate 800
                    fontWeight: FontWeight.w800,
                    letterSpacing: 10.w,
                    fontSize: 26.sp,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 800.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                
                SizedBox(height: 8.h),
                
                Text(
                  "IMAGE STUDIO",
                  style: TextStyle(
                    color: const Color(0xFF64748B), // Slate 500
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 4.w,
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 800.ms),
              ],
            ),
          ),

          // Bottom Loading / Status
          Positioned(
            bottom: 80.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 60.w,
                  height: 3.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
                    child: const LinearProgressIndicator(
                      backgroundColor: Color(0xFFE2E8F0), // Slate 200
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)), // Blue 500
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1000.ms)
                    .scaleX(begin: 0, end: 1, duration: 600.ms),
                SizedBox(height: 20.h),
                Text(
                  AppLocalizations.of(context)!.poweredByAi.toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xFF94A3B8), // Slate 400
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.w,
                  ),
                ).animate().fadeIn(delay: 1400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircle({
    required double size,
    required double opacity,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size.r,
        height: size.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF3B82F6).withValues(alpha: opacity),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
      .move(begin: const Offset(-10, -10), end: const Offset(10, 10), duration: 5.seconds, curve: Curves.easeInOut);
  }
}

