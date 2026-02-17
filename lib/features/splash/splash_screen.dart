import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_tokens.dart';
import '../../ads/ad_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Show splash interstitial ad before navigating
    final adService = AdService();
    await adService.showSplashInterstitialAd(
      onAdClosed: () {
        if (mounted) {
          context.go('/home');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000), // 10% opacity black
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.image_search,
                size: 60,
                color: DesignTokens.primaryBlue,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            const Text(
              'ImageMaster Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),
            const SizedBox(height: 8),
            const Text(
              'Resize, Compress & Convert Effortlessly',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
