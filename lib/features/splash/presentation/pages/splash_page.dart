import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_spacing.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/features/auth/presentation/providers/auth_providers.dart';

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Start min delay and heavy lifting concurrently
    final minDelay = Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      // 1. Load premium state & sync it with AdManager
      final premiumState = ref.read(premiumControllerProvider);
      AdManager.isPremium = premiumState.isPro;

      // 2. Initialize essential services concurrently
      await Future.wait([
        AdManager.initialize(),
        _initializeAuth(),
      ]);

      // 3. Ensure we've at least shown the brand for a brief moment
      await minDelay;

      if (!mounted) return;

      // 4. Show Splash Ad (Handles consent internally)
      await AdManager().showSplashAd(onDone: () {
        if (mounted) {
          context.go('/home');
        }
      });
    } catch (e) {
      debugPrint('Splash init error: $e');
      await minDelay;
      if (mounted) context.go('/home');
    }
  }

  Future<void> _initializeAuth() async {
    final authService = ref.read(authServiceProvider);
    if (authService.currentUser == null) {
      await authService.signInAnonymously();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.splashGradient,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container with Glassmorphism
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.gallery_edit,
                size: AppSpacing.iconXl4,
                color: Color(0xFFEAB308), // Using the premium yellow/gold
              ),
            )
                .animate()
                .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack)
                .fadeIn(delay: 200.ms, duration: 600.ms),

            const SizedBox(height: AppSpacing.xl3),

            // App Title
            Text(
              'ImageMaster',
              style: AppTextStyles.displaySmall(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 600.ms, curve: Curves.easeOut),

            // Subtitle
            Text(
              'PRO EDITING SUITE',
              style: AppTextStyles.titleMedium(context).copyWith(
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 4,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 800.ms, duration: 600.ms, curve: Curves.easeOut),

            const SizedBox(height: AppSpacing.xl6),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEAB308)),
              strokeWidth: 2,
            )
             .animate()
             .fadeIn(delay: 1200.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
