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
    // 1. Minimum splash time for branding
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    try {
      // 2. Load premium state
      final premiumState = ref.read(premiumControllerProvider);
      AdManager.isPremium = premiumState.isPro;

      // 3. Initialize ads (consent-aware)
      await AdManager.initialize();
    } catch (e) {
      debugPrint('Splash init error: $e');
    }

    // 4. Navigate to home once
    if (mounted) {
      context.go('/home');
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
            // Logo Container
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.gallery_edit,
                size: AppSpacing.iconXl4,
                color: AppColors.primaryDark,
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
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 600.ms, curve: Curves.easeOut),

            // Subtitle
            Text(
              'Pro Editing Suite',
              style: AppTextStyles.titleMedium(context).copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 2,
              ),
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 800.ms, duration: 600.ms, curve: Curves.easeOut),

            const SizedBox(height: AppSpacing.xl6),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            )
             .animate()
             .fadeIn(delay: 1200.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
